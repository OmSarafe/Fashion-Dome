import 'package:cloud_firestore/cloud_firestore.dart';

class StoredCartItem {
  const StoredCartItem({
    required this.id,
    required this.productId,
    required this.size,
    required this.quantity,
  });

  final String id;
  final String productId;
  final String size;
  final int quantity;

  factory StoredCartItem.fromMap(String id, Map<String, dynamic> data) {
    return StoredCartItem(
      id: id,
      productId: data['productId'] as String? ?? '',
      size: data['size'] as String? ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
    );
  }
}

class CartService {
  CartService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<StoredCartItem>> watchCart(String userId) {
    return _cartCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (document) => StoredCartItem.fromMap(document.id, document.data()),
          )
          .where(
            (item) =>
                item.productId.isNotEmpty &&
                item.size.isNotEmpty &&
                item.quantity > 0,
          )
          .toList(growable: false);
    });
  }

  Future<void> saveCartItem({
    required String userId,
    required String cartItemId,
    required String productId,
    required String size,
    required int quantity,
  }) {
    return _cartCollection(userId).doc(cartItemId).set({
      'productId': productId,
      'size': size,
      'quantity': quantity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeCartItem({
    required String userId,
    required String cartItemId,
  }) {
    return _cartCollection(userId).doc(cartItemId).delete();
  }

  Future<void> clearCart(String userId) async {
    final snapshot = await _cartCollection(userId).get();
    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final document in snapshot.docs) {
      batch.delete(document.reference);
    }
    await batch.commit();
  }

  CollectionReference<Map<String, dynamic>> _cartCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('cart');
  }
}
