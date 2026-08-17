import 'package:cloud_firestore/cloud_firestore.dart';

class ProductReview {
  const ProductReview({
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String userId;
  final String userName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  factory ProductReview.fromMap(String id, Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    return ProductReview(
      userId: data['userId'] as String? ?? id,
      userName: data['userName'] as String? ?? 'Customer',
      rating: (data['rating'] as num?)?.toInt().clamp(1, 5).toInt() ?? 1,
      comment: data['comment'] as String? ?? '',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }
}
