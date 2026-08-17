import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteService {
  FavoriteService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<Set<String>> watchFavoriteProductIds(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((document) => document.id).toSet(),
        );
  }

  Future<void> setFavorite({
    required String userId,
    required String productId,
    required bool isFavorite,
  }) async {
    final reference = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(productId);

    if (isFavorite) {
      await reference.set({
        'productId': productId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await reference.delete();
    }
  }
}
