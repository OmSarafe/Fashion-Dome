const {
  onDocumentCreated,
  onDocumentUpdated,
} = require("firebase-functions/v2/firestore");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();

const stripeSecretKey = defineSecret("STRIPE_SECRET_KEY");
const stripePublishableKey = defineSecret("STRIPE_PUBLISHABLE_KEY");

const statusLabels = {
  placed: "placed",
  processing: "being processed",
  shipped: "on its way",
  delivered: "delivered",
  cancelled: "cancelled",
};

async function sendMarketingNotification({title, body, data}) {
  const database = getFirestore();
  const usersSnapshot = await database.collection("users")
      .where("role", "==", "customer")
      .get();
  const tokenOwners = new Map();

  for (const userSnapshot of usersSnapshot.docs) {
    if (userSnapshot.get("marketingNotificationsEnabled") === false) continue;
    const storedTokens = userSnapshot.get("fcmTokens");
    if (!Array.isArray(storedTokens)) continue;
    for (const token of storedTokens) {
      if (typeof token === "string" && token.length > 0) {
        tokenOwners.set(token, userSnapshot.ref);
      }
    }
  }

  const tokens = [...tokenOwners.keys()];
  let sentCount = 0;
  const invalidTokensByUser = new Map();

  for (let index = 0; index < tokens.length; index += 500) {
    const batchTokens = tokens.slice(index, index + 500);
    const response = await getMessaging().sendEachForMulticast({
      tokens: batchTokens,
      notification: {title, body},
      data,
      android: {priority: "high"},
    });
    sentCount += response.successCount;

    response.responses.forEach((result, responseIndex) => {
      const errorCode = result.error && result.error.code;
      if (errorCode !== "messaging/registration-token-not-registered" &&
          errorCode !== "messaging/invalid-registration-token") {
        return;
      }
      const token = batchTokens[responseIndex];
      const owner = tokenOwners.get(token);
      if (!owner) return;
      const existing = invalidTokensByUser.get(owner.path) || {
        reference: owner,
        tokens: [],
      };
      existing.tokens.push(token);
      invalidTokensByUser.set(owner.path, existing);
    });
  }

  await Promise.all([...invalidTokensByUser.values()].map((entry) =>
    entry.reference.update({
      fcmTokens: FieldValue.arrayRemove(...entry.tokens),
    }),
  ));

  return {sentCount, deviceCount: tokens.length};
}

exports.sendPromotionalNotification = onCall(
    {region: "europe-west2"},
    async (request) => {
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "Administrator sign-in required.");
      }

      const database = getFirestore();
      const adminSnapshot = await database.collection("users")
          .doc(request.auth.uid)
          .get();
      if (!adminSnapshot.exists || adminSnapshot.get("role") !== "admin") {
        throw new HttpsError("permission-denied", "Administrator access required.");
      }

      const title = typeof request.data?.title === "string" ?
        request.data.title.trim() : "";
      const body = typeof request.data?.body === "string" ?
        request.data.body.trim() : "";
      if (title.length < 3 || title.length > 60 ||
          body.length < 3 || body.length > 180) {
        throw new HttpsError("invalid-argument", "Enter a valid title and message.");
      }

      const result = await sendMarketingNotification({
        title,
        body,
        data: {type: "promotion"},
      });
      await database.collection("notificationCampaigns").add({
        title,
        body,
        type: "promotion",
        sentCount: result.sentCount,
        deviceCount: result.deviceCount,
        sentBy: request.auth.uid,
        createdAt: FieldValue.serverTimestamp(),
      });
      return result;
    },
);

exports.sendNewProductNotification = onDocumentCreated(
    {
      document: "products/{productId}",
      region: "europe-west2",
    },
    async (event) => {
      const product = event.data && event.data.data();
      const name = product && product.name;
      if (typeof name !== "string" || name.trim().length === 0) return;
      const category = typeof product.category === "string" ?
        product.category : "clothing";
      await sendMarketingNotification({
        title: `New arrival: ${name.trim()}`.slice(0, 60),
        body: `A new ${category} item is now available. Open the app to view it.`,
        data: {
          type: "new_product",
          productId: event.params.productId,
        },
      });
    },
);

exports.createStripePaymentIntent = onCall(
    {
      region: "europe-west2",
      secrets: [stripeSecretKey, stripePublishableKey],
    },
    async (request) => {
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "Sign in before paying.");
      }

      const requestedItems = request.data && request.data.items;
      if (!Array.isArray(requestedItems) || requestedItems.length === 0 ||
          requestedItems.length > 50) {
        throw new HttpsError("invalid-argument", "The cart is invalid.");
      }

      const database = getFirestore();
      const customerSnapshot = await database.collection("users")
          .doc(request.auth.uid)
          .get();
      if (!customerSnapshot.exists ||
          customerSnapshot.get("role") !== "customer") {
        throw new HttpsError(
            "permission-denied",
            "Only customer accounts can make payments.",
        );
      }
      let subtotalInPence = 0;
      const requestedQuantities = new Map();
      for (const item of requestedItems) {
        const productId = item && item.productId;
        const size = item && item.size;
        const quantity = Number(item && item.quantity);
        if (typeof productId !== "string" || productId.length === 0 ||
            typeof size !== "string" || size.length === 0 ||
            !Number.isInteger(quantity) || quantity < 1) {
          throw new HttpsError("invalid-argument", "A cart item is invalid.");
        }

        const productSnapshot = await database
            .collection("products")
            .doc(productId)
            .get();
        if (!productSnapshot.exists) {
          throw new HttpsError("not-found", "A product is no longer available.");
        }
        const product = productSnapshot.data();
        const priceInPence = Number(product.priceInPence);
        const stock = Number(product.stock);
        const sizes = Array.isArray(product.availableSizes) ?
          product.availableSizes : [];
        const requestedQuantity =
          (requestedQuantities.get(productId) || 0) + quantity;
        if (!Number.isInteger(priceInPence) || priceInPence < 1 ||
            !Number.isInteger(stock) || stock < requestedQuantity ||
            !sizes.includes(size)) {
          throw new HttpsError(
              "failed-precondition",
              "A product price, size, or stock level has changed.",
          );
        }
        requestedQuantities.set(productId, requestedQuantity);
        subtotalInPence += priceInPence * quantity;
      }

      const shippingInPence = 80;
      const totalInPence = subtotalInPence + shippingInPence;
      const stripe = require("stripe")(stripeSecretKey.value());
      const email = request.auth.token.email;
      const paymentIntent = await stripe.paymentIntents.create({
        amount: totalInPence,
        currency: "gbp",
        automatic_payment_methods: {enabled: true},
        ...(typeof email === "string" ? {receipt_email: email} : {}),
        metadata: {
          firebaseUserId: request.auth.uid,
          app: "msc-clothing-ecommerce",
        },
      });

      return {
        clientSecret: paymentIntent.client_secret,
        paymentIntentId: paymentIntent.id,
        publishableKey: stripePublishableKey.value(),
        totalInPence,
      };
    },
);

exports.verifyStripePayment = onCall(
    {
      region: "europe-west2",
      secrets: [stripeSecretKey],
    },
    async (request) => {
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "Sign in before paying.");
      }
      const paymentIntentId = request.data && request.data.paymentIntentId;
      if (typeof paymentIntentId !== "string" ||
          !paymentIntentId.startsWith("pi_")) {
        throw new HttpsError("invalid-argument", "The payment is invalid.");
      }

      const stripe = require("stripe")(stripeSecretKey.value());
      const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);
      if (paymentIntent.metadata.firebaseUserId !== request.auth.uid) {
        throw new HttpsError(
            "permission-denied",
            "This payment belongs to another customer.",
        );
      }
      return {
        paid: paymentIntent.status === "succeeded",
        totalInPence: paymentIntent.amount,
      };
    },
);

exports.submitProductReview = onCall(
    {region: "europe-west2"},
    async (request) => {
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "Sign in before reviewing.");
      }

      const productId = request.data && request.data.productId;
      const rating = Number(request.data && request.data.rating);
      const comment = String(request.data && request.data.comment || "").trim();
      if (typeof productId !== "string" || productId.length === 0 ||
          !Number.isInteger(rating) || rating < 1 || rating > 5 ||
          comment.length < 3 || comment.length > 500) {
        throw new HttpsError("invalid-argument", "The review is invalid.");
      }

      const database = getFirestore();
      const ordersSnapshot = await database.collection("orders")
          .where("userId", "==", request.auth.uid)
          .get();
      const purchasedAndDelivered = ordersSnapshot.docs.some((document) => {
        const order = document.data();
        const items = Array.isArray(order.items) ? order.items : [];
        return order.status === "delivered" && items.some(
            (item) => item && item.productId === productId,
        );
      });
      if (!purchasedAndDelivered) {
        throw new HttpsError(
            "failed-precondition",
            "Only customers with a delivered purchase can review this product.",
        );
      }

      const productReference = database.collection("products").doc(productId);
      const reviewReference = productReference
          .collection("reviews")
          .doc(request.auth.uid);
      const userSnapshot = await database.collection("users")
          .doc(request.auth.uid)
          .get();
      const userName = userSnapshot.exists &&
          typeof userSnapshot.get("name") === "string" ?
        userSnapshot.get("name") : "Customer";

      await database.runTransaction(async (transaction) => {
        const productSnapshot = await transaction.get(productReference);
        const existingReview = await transaction.get(reviewReference);
        if (!productSnapshot.exists) {
          throw new HttpsError("not-found", "The product no longer exists.");
        }

        const product = productSnapshot.data();
        const oldRating = existingReview.exists ?
          Number(existingReview.get("rating")) : 0;
        const currentCount = Number(product.ratingCount) || 0;
        const currentSum = Number(product.ratingSum) || 0;
        const ratingCount = existingReview.exists ? currentCount : currentCount + 1;
        const ratingSum = currentSum - oldRating + rating;

        transaction.set(reviewReference, {
          userId: request.auth.uid,
          userName,
          rating,
          comment,
          verifiedPurchase: true,
          createdAt: existingReview.exists ?
            existingReview.get("createdAt") : FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        });
        transaction.update(productReference, {
          ratingCount,
          ratingSum,
          averageRating: ratingCount === 0 ? 0 : ratingSum / ratingCount,
          updatedAt: FieldValue.serverTimestamp(),
        });
      });

      return {saved: true};
    },
);

exports.reserveOrderStock = onDocumentCreated(
    {
      document: "orders/{orderId}",
      region: "europe-west2",
    },
    async (event) => {
      const orderReference = event.data.ref;
      const database = getFirestore();

      await database.runTransaction(async (transaction) => {
        const orderSnapshot = await transaction.get(orderReference);
        const order = orderSnapshot.data();
        if (!order || order.inventoryStatus) return;

        if (order.status === "cancelled") {
          transaction.update(orderReference, {
            inventoryStatus: "cancelled_before_reservation",
            inventoryProcessedAt: FieldValue.serverTimestamp(),
          });
          return;
        }

        const quantities = new Map();
        const items = Array.isArray(order.items) ? order.items : [];
        for (const item of items) {
          const productId = item && item.productId;
          const quantity = Number(item && item.quantity);
          if (typeof productId !== "string" || !Number.isInteger(quantity) ||
              quantity < 1) {
            transaction.update(orderReference, {
              status: "cancelled",
              inventoryStatus: "invalid_order",
              inventoryMessage: "The order contained an invalid item.",
              inventoryProcessedAt: FieldValue.serverTimestamp(),
            });
            return;
          }
          quantities.set(productId, (quantities.get(productId) || 0) + quantity);
        }

        if (quantities.size === 0 || items.length > 50) {
          transaction.update(orderReference, {
            status: "cancelled",
            inventoryStatus: "invalid_order",
            inventoryMessage: "The order did not contain any items.",
            inventoryProcessedAt: FieldValue.serverTimestamp(),
          });
          return;
        }

        const products = [];
        for (const [productId, quantity] of quantities.entries()) {
          const reference = database.collection("products").doc(productId);
          const snapshot = await transaction.get(reference);
          products.push({reference, snapshot, quantity});
        }

        const unavailable = products.find(({snapshot, quantity}) =>
          !snapshot.exists || Number(snapshot.get("stock")) < quantity,
        );
        if (unavailable) {
          transaction.update(orderReference, {
            status: "cancelled",
            inventoryStatus: "insufficient_stock",
            inventoryMessage: "One or more products are no longer in stock.",
            inventoryProcessedAt: FieldValue.serverTimestamp(),
          });
          return;
        }

        const productSnapshots = new Map(
            products.map(({reference, snapshot}) => [reference.id, snapshot]),
        );
        const invalidSize = items.some((item) => {
          const snapshot = productSnapshots.get(item.productId);
          const sizes = snapshot && snapshot.get("availableSizes");
          return typeof item.size !== "string" ||
            !Array.isArray(sizes) || !sizes.includes(item.size);
        });
        const calculatedSubtotal = products.reduce((total, product) => {
          const priceInPence = Number(product.snapshot.get("priceInPence"));
          return total + priceInPence * product.quantity;
        }, 0);
        const supportedPayment =
          (order.paymentMethod === "Cash on delivery" &&
            order.paymentStatus === "pending") ||
          (order.paymentMethod === "Stripe card payment" &&
            order.paymentStatus === "verification_pending" &&
            typeof order.stripePaymentIntentId === "string" &&
            order.stripePaymentIntentId.startsWith("pi_"));
        const validOrderDetails = !invalidSize &&
          Number.isInteger(calculatedSubtotal) && calculatedSubtotal > 0 &&
          Number(order.subtotalInPence) === calculatedSubtotal &&
          Number(order.shippingInPence) === 80 &&
          Number(order.totalInPence) === calculatedSubtotal + 80 &&
          typeof order.deliveryAddress === "string" &&
          order.deliveryAddress.trim().length >= 10 &&
          supportedPayment;
        if (!validOrderDetails) {
          transaction.update(orderReference, {
            status: "cancelled",
            inventoryStatus: "invalid_order",
            inventoryMessage: "Order details could not be verified.",
            inventoryProcessedAt: FieldValue.serverTimestamp(),
          });
          return;
        }

        for (const {reference, snapshot, quantity} of products) {
          const previousStock = Number(snapshot.get("stock"));
          const resultingStock = previousStock - quantity;
          transaction.update(reference, {
            stock: resultingStock,
            updatedAt: FieldValue.serverTimestamp(),
          });
          const movementReference = reference.collection("stockMovements")
              .doc(`order-${event.params.orderId}-reserved`);
          transaction.set(movementReference, {
            type: "order_reserved",
            delta: -quantity,
            previousStock,
            resultingStock,
            orderId: event.params.orderId,
            createdAt: FieldValue.serverTimestamp(),
          });
        }
        transaction.update(orderReference, {
          inventoryStatus: "reserved",
          inventoryProcessedAt: FieldValue.serverTimestamp(),
        });
      });
    },
);

exports.restoreCancelledOrderStock = onDocumentUpdated(
    {
      document: "orders/{orderId}",
      region: "europe-west2",
    },
    async (event) => {
      const before = event.data.before.data();
      const after = event.data.after.data();
      if (!after || before.status === "cancelled" ||
          after.status !== "cancelled") {
        return;
      }

      const orderReference = event.data.after.ref;
      const database = getFirestore();
      await database.runTransaction(async (transaction) => {
        const orderSnapshot = await transaction.get(orderReference);
        const order = orderSnapshot.data();
        if (!order || order.status !== "cancelled") return;

        if (order.inventoryStatus === "restored" ||
            order.inventoryStatus === "cancelled_before_reservation") {
          return;
        }

        if (!order.inventoryStatus) {
          transaction.update(orderReference, {
            inventoryStatus: "cancelled_before_reservation",
            inventoryProcessedAt: FieldValue.serverTimestamp(),
          });
          return;
        }

        if (order.inventoryStatus !== "reserved") return;

        const quantities = new Map();
        const items = Array.isArray(order.items) ? order.items : [];
        for (const item of items) {
          const productId = item && item.productId;
          const quantity = Number(item && item.quantity);
          if (typeof productId !== "string" ||
              !Number.isInteger(quantity) || quantity < 1) {
            transaction.update(orderReference, {
              inventoryStatus: "restore_failed",
              inventoryMessage: "The cancelled order contained an invalid item.",
              inventoryProcessedAt: FieldValue.serverTimestamp(),
            });
            return;
          }
          quantities.set(productId, (quantities.get(productId) || 0) + quantity);
        }

        const products = [];
        for (const [productId, quantity] of quantities.entries()) {
          const reference = database.collection("products").doc(productId);
          const snapshot = await transaction.get(reference);
          products.push({reference, snapshot, quantity});
        }

        if (products.some(({snapshot}) => !snapshot.exists)) {
          transaction.update(orderReference, {
            inventoryStatus: "restore_failed",
            inventoryMessage: "A cancelled product no longer exists.",
            inventoryProcessedAt: FieldValue.serverTimestamp(),
          });
          return;
        }

        for (const {reference, snapshot, quantity} of products) {
          const previousStock = Number(snapshot.get("stock"));
          const resultingStock = previousStock + quantity;
          transaction.update(reference, {
            stock: resultingStock,
            updatedAt: FieldValue.serverTimestamp(),
          });
          const movementReference = reference.collection("stockMovements")
              .doc(`order-${event.params.orderId}-restored`);
          transaction.set(movementReference, {
            type: "order_restored",
            delta: quantity,
            previousStock,
            resultingStock,
            orderId: event.params.orderId,
            createdAt: FieldValue.serverTimestamp(),
          });
        }
        transaction.update(orderReference, {
          inventoryStatus: "restored",
          inventoryMessage: FieldValue.delete(),
          inventoryProcessedAt: FieldValue.serverTimestamp(),
        });
      });
    },
);

exports.confirmStripeOrderPayment = onDocumentUpdated(
    {
      document: "orders/{orderId}",
      region: "europe-west2",
      secrets: [stripeSecretKey],
    },
    async (event) => {
      const before = event.data.before.data();
      const after = event.data.after.data();
      if (!after || before.inventoryStatus === "reserved" ||
          after.inventoryStatus !== "reserved" ||
          after.paymentMethod !== "Stripe card payment" ||
          after.paymentStatus !== "verification_pending") {
        return;
      }

      const paymentIntentId = after.stripePaymentIntentId;
      if (typeof paymentIntentId !== "string" ||
          !paymentIntentId.startsWith("pi_")) {
        await event.data.after.ref.update({
          status: "cancelled",
          paymentStatus: "failed",
          paymentMessage: "The Stripe payment reference was invalid.",
          updatedAt: FieldValue.serverTimestamp(),
        });
        return;
      }

      const stripe = require("stripe")(stripeSecretKey.value());
      const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);
      const validCustomer =
        paymentIntent.metadata.firebaseUserId === after.userId;
      const validAmount = paymentIntent.amount === Number(after.totalInPence);
      if (paymentIntent.status !== "succeeded" ||
          !validCustomer || !validAmount) {
        await event.data.after.ref.update({
          status: "cancelled",
          paymentStatus: "failed",
          paymentMessage: "Stripe could not verify this order payment.",
          updatedAt: FieldValue.serverTimestamp(),
        });
        return;
      }

      await event.data.after.ref.update({
        paymentStatus: "paid",
        paymentVerifiedAt: FieldValue.serverTimestamp(),
        paymentMessage: FieldValue.delete(),
        updatedAt: FieldValue.serverTimestamp(),
      });
    },
);

exports.refundCancelledStripeOrder = onDocumentUpdated(
    {
      document: "orders/{orderId}",
      region: "europe-west2",
      secrets: [stripeSecretKey],
    },
    async (event) => {
      const before = event.data.before.data();
      const after = event.data.after.data();
      if (!after || before.status === "cancelled" ||
          after.status !== "cancelled" ||
          after.paymentMethod !== "Stripe card payment" ||
          after.paymentStatus === "refunded") {
        return;
      }

      const paymentIntentId = after.stripePaymentIntentId;
      if (typeof paymentIntentId !== "string" ||
          !paymentIntentId.startsWith("pi_")) {
        return;
      }

      const stripe = require("stripe")(stripeSecretKey.value());
      const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);
      if (paymentIntent.status !== "succeeded") {
        await event.data.after.ref.update({
          paymentStatus: "cancelled",
          updatedAt: FieldValue.serverTimestamp(),
        });
        return;
      }

      await stripe.refunds.create(
          {payment_intent: paymentIntentId},
          {idempotencyKey: `cancelled-order-${event.params.orderId}`},
      );
      await event.data.after.ref.update({
        paymentStatus: "refunded",
        refundedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
    },
);

exports.sendOrderStatusNotification = onDocumentUpdated(
    {
      document: "orders/{orderId}",
      region: "europe-west2",
    },
    async (event) => {
      const before = event.data.before.data();
      const after = event.data.after.data();

      if (!after || before.status === after.status) return;

      const userId = after.userId;
      if (typeof userId !== "string" || userId.length === 0) return;

      const userReference = getFirestore().collection("users").doc(userId);
      const userSnapshot = await userReference.get();
      if (!userSnapshot.exists ||
          userSnapshot.get("orderNotificationsEnabled") === false) {
        return;
      }
      const storedTokens = userSnapshot.get("fcmTokens");
      const tokens = Array.isArray(storedTokens) ?
        [...new Set(storedTokens.filter((token) => typeof token === "string"))] :
        [];

      if (tokens.length === 0) return;

      const readableStatus = statusLabels[after.status] || after.status;
      const response = await getMessaging().sendEachForMulticast({
        tokens,
        notification: {
          title: "Order update",
          body: `Your order is now ${readableStatus}.`,
        },
        data: {
          orderId: event.params.orderId,
          status: String(after.status),
        },
        android: {
          priority: "high",
        },
      });

      const invalidTokens = [];
      response.responses.forEach((result, index) => {
        const errorCode = result.error && result.error.code;
        if (
          errorCode === "messaging/registration-token-not-registered" ||
          errorCode === "messaging/invalid-registration-token"
        ) {
          invalidTokens.push(tokens[index]);
        }
      });

      if (invalidTokens.length > 0) {
        await userReference.update({
          fcmTokens: FieldValue.arrayRemove(...invalidTokens),
        });
      }
    },
);
