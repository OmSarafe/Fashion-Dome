import 'package:ecommerence_project/models/cart_item.dart';
import 'package:ecommerence_project/models/order.dart';
import 'package:ecommerence_project/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Order lifecycle', () {
    test('placed order can be processed or cancelled', () {
      final order = _orderWithStatus(OrderStatus.placed);

      expect(order.canBeCancelled, true);
      expect(order.canTransitionTo(OrderStatus.processing), true);
      expect(order.canTransitionTo(OrderStatus.cancelled), true);
      expect(order.canTransitionTo(OrderStatus.shipped), false);
      expect(order.canTransitionTo(OrderStatus.delivered), false);
    });

    test('processing order can be shipped or cancelled', () {
      final order = _orderWithStatus(OrderStatus.processing);

      expect(order.canBeCancelled, true);
      expect(order.canTransitionTo(OrderStatus.shipped), true);
      expect(order.canTransitionTo(OrderStatus.cancelled), true);
      expect(order.canTransitionTo(OrderStatus.delivered), false);
    });

    test('shipped order can only be delivered', () {
      final order = _orderWithStatus(OrderStatus.shipped);

      expect(order.canBeCancelled, false);
      expect(order.canTransitionTo(OrderStatus.delivered), true);
      expect(order.canTransitionTo(OrderStatus.cancelled), false);
      expect(order.canTransitionTo(OrderStatus.processing), false);
    });

    test('delivered order is a final state', () {
      final order = _orderWithStatus(OrderStatus.delivered);

      expect(order.canBeCancelled, false);
      expect(order.allowedNextStatuses, isEmpty);
    });

    test('cancelled order is a final state', () {
      final order = _orderWithStatus(OrderStatus.cancelled);

      expect(order.canBeCancelled, false);
      expect(order.allowedNextStatuses, isEmpty);
    });

    test('unknown stored status safely defaults to placed', () {
      final order = Order.fromMap('order-2', {
        'userId': 'customer-1',
        'items': const [],
        'subtotalInPence': 2500,
        'shippingInPence': 80,
        'totalInPence': 2580,
        'deliveryAddress': '10 Test Street, London',
        'paymentMethod': 'Cash on delivery',
        'status': 'unknown-status',
      });

      expect(order.status, OrderStatus.placed);
      expect(order.subtotalInPence, 2500);
      expect(order.shippingInPence, 80);
      expect(order.totalInPence, 2580);
    });

    test('order item collection cannot be modified', () {
      final order = _orderWithStatus(OrderStatus.placed);

      expect(
        () => order.items.add(order.items.first),
        throwsUnsupportedError,
      );
    });
  });
}

Order _orderWithStatus(OrderStatus status) {
  const product = Product(
    id: 'test-jacket',
    name: 'Test Jacket',
    description: 'A product used by automated tests.',
    category: 'Jackets',
    priceInPence: 2500,
    assetImagePath: 'assets/image1.png',
    availableSizes: ['M'],
    stock: 5,
  );

  return Order(
    id: 'order-1',
    userId: 'customer-1',
    items: const [CartItem(product: product, size: 'M', quantity: 1)],
    subtotalInPence: 2500,
    shippingInPence: 80,
    totalInPence: 2580,
    deliveryAddress: '10 Test Street, London',
    paymentMethod: 'Cash on delivery',
    createdAt: DateTime(2026, 8, 15),
    status: status,
  );
}
