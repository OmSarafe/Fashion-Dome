import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:ecommerence_project/models/cart_item.dart';
import 'package:ecommerence_project/models/order.dart' as shop;

class OrderService {
  OrderService({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions =
            functions ?? FirebaseFunctions.instanceFor(region: 'europe-west2');

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

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

  Future<shop.Order> submitOrder({
    required String userId,
    required List<CartItem> items,
    required String deliveryAddress,
    required String paymentMethod,
    String? stripePaymentIntentId,
  }) async {
    final response = await _functions.httpsCallable('submitOrder').call({
      'items': items
          .map(
            (item) => {
              'productId': item.product.id,
              'size': item.size,
              'quantity': item.quantity,
            },
          )
          .toList(growable: false),
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      if (stripePaymentIntentId != null)
        'paymentIntentId': stripePaymentIntentId,
    });
    final data = Map<String, dynamic>.from(response.data as Map);
    final orderId = data['orderId'] as String? ?? '';
    if (orderId.isEmpty) {
      throw StateError('The server did not return an order reference.');
    }

    final snapshot = await _firestore.collection('orders').doc(orderId).get();
    final orderData = snapshot.data();
    if (!snapshot.exists ||
        orderData == null ||
        orderData['userId'] != userId) {
      throw StateError('The saved order could not be loaded.');
    }
    return shop.Order.fromMap(snapshot.id, orderData);
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
