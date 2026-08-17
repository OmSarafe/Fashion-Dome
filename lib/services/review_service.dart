import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:ecommerence_project/models/product_review.dart';

class ReviewService {
  ReviewService({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions =
            functions ?? FirebaseFunctions.instanceFor(region: 'europe-west2');

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  Stream<List<ProductReview>> watchReviews(String productId) {
    return _firestore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      final reviews = snapshot.docs
          .map(
              (document) => ProductReview.fromMap(document.id, document.data()))
          .toList(growable: false);
      return reviews;
    });
  }

  Future<void> submitReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    await _functions.httpsCallable('submitProductReview').call({
      'productId': productId,
      'rating': rating,
      'comment': comment.trim(),
    }).timeout(
      const Duration(seconds: 25),
      onTimeout: () => throw TimeoutException(
        'The review service took too long to respond.',
      ),
    );
  }
}
