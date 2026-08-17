import 'package:ecommerence_project/models/cart_item.dart';
import 'package:ecommerence_project/models/product.dart';
import 'package:ecommerence_project/utils/cart_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const shirt = Product(
    id: 'test-shirt',
    name: 'Test Shirt',
    description: 'A product used by automated tests.',
    category: 'Shirts',
    priceInPence: 1299,
    assetImagePath: 'assets/image1.png',
    availableSizes: ['S', 'M', 'L'],
    stock: 3,
  );

  group('Cart calculations', () {
    test('calculates an item line total from price and quantity', () {
      const item = CartItem(product: shirt, size: 'M', quantity: 3);

      expect(item.lineTotalInPence, 3897);
    });

    test('calculates the subtotal of multiple cart items', () {
      const items = [
        CartItem(product: shirt, size: 'S', quantity: 2),
        CartItem(product: shirt, size: 'L', quantity: 1),
      ];

      expect(CartCalculator.subtotalInPence(items), 3897);
    });

    test('adds the standard 80 pence shipping charge', () {
      expect(CartCalculator.standardShippingInPence, 80);
      expect(CartCalculator.totalInPence(3897), 3977);
    });

    test('allows quantities below available stock', () {
      expect(CartCalculator.canAddAnother(shirt, 2), true);
    });

    test('blocks quantities at the available stock limit', () {
      expect(CartCalculator.canAddAnother(shirt, 3), false);
    });

    test('blocks products that are out of stock', () {
      const unavailableShirt = Product(
        id: 'sold-out-shirt',
        name: 'Sold Out Shirt',
        description: 'Unavailable product.',
        category: 'Shirts',
        priceInPence: 999,
        assetImagePath: 'assets/image1.png',
        availableSizes: ['M'],
        stock: 0,
      );

      expect(CartCalculator.canAddAnother(unavailableShirt, 0), false);
    });
  });
}
