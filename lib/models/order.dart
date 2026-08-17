import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerence_project/models/cart_item.dart';

enum OrderStatus { placed, processing, shipped, delivered, cancelled }

class Order {
  Order({
    required this.id,
    required this.userId,
    required List<CartItem> items,
    required this.subtotalInPence,
    required this.shippingInPence,
    required this.totalInPence,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.createdAt,
    this.paymentStatus = 'pending',
    this.stripePaymentIntentId,
    this.updatedAt,
    this.cancelledAt,
    this.cancelledBy,
    this.inventoryStatus,
    this.status = OrderStatus.placed,
  }) : items = UnmodifiableListView(items);

  final String id;
  final String userId;
  final UnmodifiableListView<CartItem> items;
  final int subtotalInPence;
  final int shippingInPence;
  final int totalInPence;
  final String deliveryAddress;
  final String paymentMethod;
  final String paymentStatus;
  final String? stripePaymentIntentId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? cancelledAt;
  final String? cancelledBy;
  final String? inventoryStatus;
  final OrderStatus status;

  bool get canBeCancelled =>
      status == OrderStatus.placed || status == OrderStatus.processing;

  List<OrderStatus> get allowedNextStatuses => switch (status) {
        OrderStatus.placed => const [
            OrderStatus.processing,
            OrderStatus.cancelled,
          ],
        OrderStatus.processing => const [
            OrderStatus.shipped,
            OrderStatus.cancelled,
          ],
        OrderStatus.shipped => const [OrderStatus.delivered],
        OrderStatus.delivered || OrderStatus.cancelled => const [],
      };

  bool canTransitionTo(OrderStatus nextStatus) =>
      allowedNextStatuses.contains(nextStatus);

  factory Order.fromMap(String id, Map<String, dynamic> data) {
    final rawItems = data['items'] as List<dynamic>? ?? const [];
    final createdAtValue = data['createdAt'];
    final updatedAtValue = data['updatedAt'];
    final cancelledAtValue = data['cancelledAt'];
    return Order(
      id: id,
      userId: data['userId'] as String? ?? '',
      items: rawItems
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (item) => CartItem.fromMap(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
      subtotalInPence: (data['subtotalInPence'] as num?)?.toInt() ??
          ((data['subtotalInPaise'] as num?)?.toInt() ?? 0) ~/ 100,
      shippingInPence: (data['shippingInPence'] as num?)?.toInt() ??
          ((data['shippingInPaise'] as num?)?.toInt() ?? 0) ~/ 100,
      totalInPence: (data['totalInPence'] as num?)?.toInt() ??
          ((data['totalInPaise'] as num?)?.toInt() ?? 0) ~/ 100,
      deliveryAddress: data['deliveryAddress'] as String? ?? '',
      paymentMethod: data['paymentMethod'] as String? ?? '',
      paymentStatus: data['paymentStatus'] as String? ?? 'pending',
      stripePaymentIntentId: data['stripePaymentIntentId'] as String?,
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : DateTime.now(),
      updatedAt: updatedAtValue is Timestamp ? updatedAtValue.toDate() : null,
      cancelledAt:
          cancelledAtValue is Timestamp ? cancelledAtValue.toDate() : null,
      cancelledBy: data['cancelledBy'] as String?,
      inventoryStatus: data['inventoryStatus'] as String?,
      status: OrderStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => OrderStatus.placed,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(growable: false),
      'subtotalInPence': subtotalInPence,
      'shippingInPence': shippingInPence,
      'totalInPence': totalInPence,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'stripePaymentIntentId': stripePaymentIntentId,
      'status': status.name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
