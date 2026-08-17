import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerence_project/models/cart_item.dart';
import 'package:ecommerence_project/models/order.dart' as shop;

class OrderService {
  OrderService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<shop.Order>> watchOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs
          .map((document) => shop.Order.fromMap(document.id, document.data()))
          .toList(growable: false);
      orders.sort(
        (first, second) => second.createdAt.compareTo(first.createdAt),
      );
      return orders;
    });
  }

  Stream<List<shop.Order>> watchAllOrders() {
    return _firestore.collection('orders').snapshots().map((snapshot) {
      final orders = snapshot.docs
          .map((document) => shop.Order.fromMap(document.id, document.data()))
          .toList(growable: false);
      orders.sort(
        (first, second) => second.createdAt.compareTo(first.createdAt),
      );
      return orders;
    });
  }

  Future<shop.Order> createOrder({
    required String userId,
    required List<CartItem> items,
    required int subtotalInPence,
    required int shippingInPence,
    required String deliveryAddress,
    required String paymentMethod,
    String paymentStatus = 'pending',
    String? stripePaymentIntentId,
  }) async {
    final reference = _firestore.collection('orders').doc();
    final order = shop.Order(
      id: reference.id,
      userId: userId,
      items: items,
      subtotalInPence: subtotalInPence,
      shippingInPence: shippingInPence,
      totalInPence: subtotalInPence + shippingInPence,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      stripePaymentIntentId: stripePaymentIntentId,
      createdAt: DateTime.now(),
    );
    await reference.set(order.toMap());
    return order;
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required shop.OrderStatus status,
  }) async {
    final reference = _firestore.collection('orders').doc(orderId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      if (!snapshot.exists) {
        throw StateError('The order no longer exists.');
      }
      final order = shop.Order.fromMap(snapshot.id, snapshot.data()!);
      if (!order.canTransitionTo(status)) {
        throw StateError(
          'The order cannot move from ${order.status.name} to ${status.name}.',
        );
      }
      transaction.update(reference, {
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
        if (status == shop.OrderStatus.cancelled)
          'cancelledAt': FieldValue.serverTimestamp(),
        if (status == shop.OrderStatus.cancelled) 'cancelledBy': 'admin',
      });
    });
  }

  Future<void> cancelOrder({
    required String orderId,
    required String userId,
  }) async {
    final reference = _firestore.collection('orders').doc(orderId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      if (!snapshot.exists) {
        throw StateError('The order no longer exists.');
      }
      final order = shop.Order.fromMap(snapshot.id, snapshot.data()!);
      if (order.userId != userId) {
        throw StateError('You cannot cancel another customer\'s order.');
      }
      if (!order.canBeCancelled) {
        throw StateError('This order can no longer be cancelled.');
      }
      transaction.update(reference, {
        'status': shop.OrderStatus.cancelled.name,
        'cancelledBy': 'customer',
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
