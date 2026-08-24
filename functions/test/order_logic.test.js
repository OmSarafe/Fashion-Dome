const test = require("node:test");
const assert = require("node:assert/strict");

const {
  normalizeRequestedItems,
  productSnapshot,
  stripeOrderId,
  validateDeliveryAddress,
} = require("../order_logic");

test("normalizes a valid cart without accepting client product data", () => {
  assert.deepEqual(normalizeRequestedItems([{
    productId: " shirt-1 ",
    size: " M ",
    quantity: 2,
    priceInPence: 1,
  }]), [{productId: "shirt-1", size: "M", quantity: 2}]);
});

test("rejects invalid quantities and empty carts", () => {
  assert.throws(() => normalizeRequestedItems([]), /cart is invalid/i);
  assert.throws(
      () => normalizeRequestedItems([
        {productId: "shirt-1", size: "M", quantity: 0},
      ]),
      /cart item is invalid/i,
  );
});

test("uses a deterministic document id for a Stripe payment", () => {
  assert.equal(stripeOrderId("pi_123_test"), "stripe_pi_123_test");
  assert.throws(() => stripeOrderId("not-a-payment"), /reference is invalid/i);
});

test("validates and trims the delivery address", () => {
  assert.equal(
      validateDeliveryAddress(" 10 Test Street, London "),
      "10 Test Street, London",
  );
  assert.throws(() => validateDeliveryAddress("short"), /valid delivery/i);
});

test("builds an order snapshot only from trusted product fields", () => {
  const snapshot = productSnapshot({
    name: "Test Shirt",
    description: "Description",
    category: "Shirts",
    priceInPence: 2500,
    compareAtPriceInPence: null,
    assetImagePath: "assets/test.png",
    imageUrl: null,
    availableSizes: ["S", "M"],
    stock: 8,
    lowStockThreshold: 3,
    injected: "ignored",
  });
  assert.equal(snapshot.priceInPence, 2500);
  assert.equal(Object.hasOwn(snapshot, "injected"), false);
});
