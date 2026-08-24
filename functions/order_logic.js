const STRIPE_ORDER_PREFIX = "stripe_";

function normalizeRequestedItems(requestedItems) {
  if (!Array.isArray(requestedItems) || requestedItems.length === 0 ||
      requestedItems.length > 50) {
    throw new TypeError("The cart is invalid.");
  }

  return requestedItems.map((item) => {
    const productId = item && item.productId;
    const size = item && item.size;
    const quantity = Number(item && item.quantity);
    if (typeof productId !== "string" || productId.trim().length === 0 ||
        productId.length > 200 || typeof size !== "string" ||
        size.trim().length === 0 || size.length > 40 ||
        !Number.isInteger(quantity) || quantity < 1 || quantity > 99) {
      throw new TypeError("A cart item is invalid.");
    }
    return {
      productId: productId.trim(),
      size: size.trim(),
      quantity,
    };
  });
}

function validateDeliveryAddress(value) {
  const address = typeof value === "string" ? value.trim() : "";
  if (address.length < 10 || address.length > 500) {
    throw new TypeError("Enter a valid delivery address.");
  }
  return address;
}

function stripeOrderId(paymentIntentId) {
  if (typeof paymentIntentId !== "string" ||
      !/^pi_[A-Za-z0-9_]+$/.test(paymentIntentId)) {
    throw new TypeError("The payment reference is invalid.");
  }
  return `${STRIPE_ORDER_PREFIX}${paymentIntentId}`;
}

function productSnapshot(product) {
  return {
    name: typeof product.name === "string" ? product.name : "",
    description: typeof product.description === "string" ?
      product.description : "",
    category: typeof product.category === "string" ? product.category : "Other",
    priceInPence: Number(product.priceInPence),
    compareAtPriceInPence: product.compareAtPriceInPence ?? null,
    assetImagePath: typeof product.assetImagePath === "string" ?
      product.assetImagePath : "",
    imageUrl: typeof product.imageUrl === "string" ? product.imageUrl : null,
    availableSizes: Array.isArray(product.availableSizes) ?
      product.availableSizes.filter((size) => typeof size === "string") : [],
    stock: Number(product.stock),
    lowStockThreshold: Number.isInteger(Number(product.lowStockThreshold)) ?
      Number(product.lowStockThreshold) : 5,
  };
}

module.exports = {
  normalizeRequestedItems,
  productSnapshot,
  stripeOrderId,
  validateDeliveryAddress,
};
