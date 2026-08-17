import 'package:ecommerence_project/models/order.dart';
import 'package:ecommerence_project/models/product.dart';
import 'package:ecommerence_project/models/product_review.dart';
import 'package:ecommerence_project/providers/shop_provider.dart';
import 'package:ecommerence_project/services/review_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductReviewsSection extends StatelessWidget {
  ProductReviewsSection({super.key, required this.product});

  final Product product;
  final ReviewService _reviewService = ReviewService();

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final canReview = shop.orders.any(
      (order) =>
          order.status == OrderStatus.delivered &&
          order.items.any((item) => item.product.id == product.id),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Customer reviews',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
              ),
            ),
            if (canReview)
              TextButton.icon(
                onPressed: () => _openReviewDialog(context),
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text('Write review'),
              ),
          ],
        ),
        if (!canReview) ...[
          const SizedBox(height: 6),
          Text(
            'Reviews can be written after this product has been delivered.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
        const SizedBox(height: 14),
        StreamBuilder<List<ProductReview>>(
          stream: _reviewService.watchReviews(product.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Text('Unable to load reviews right now.');
            }
            final reviews = snapshot.data ?? const [];
            if (reviews.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'No reviews yet. Delivered customers can be the first to review.',
                  textAlign: TextAlign.center,
                ),
              );
            }
            return Column(
              children: reviews
                  .map((review) => _ReviewCard(review: review))
                  .toList(growable: false),
            );
          },
        ),
      ],
    );
  }

  Future<void> _openReviewDialog(BuildContext context) async {
    final submitted = await showDialog<bool>(
      context: context,
      builder: (_) => _ReviewDialog(
        onSubmit: (rating, comment) => _reviewService.submitReview(
          productId: product.id,
          rating: rating,
          comment: comment,
        ),
      ),
    );
    if (submitted == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your review has been saved.')),
      );
    }
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final ProductReview review;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    review.userName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const Icon(Icons.verified, color: Colors.green, size: 17),
                const SizedBox(width: 4),
                const Text('Verified purchase', style: TextStyle(fontSize: 11)),
              ],
            ),
            const SizedBox(height: 7),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < review.rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: Colors.amber,
                  size: 19,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(review.comment),
          ],
        ),
      ),
    );
  }
}

class _ReviewDialog extends StatefulWidget {
  const _ReviewDialog({required this.onSubmit});

  final Future<void> Function(int rating, String comment) onSubmit;

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  final _commentController = TextEditingController();
  int _rating = 5;
  bool _isSaving = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Review this product'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => IconButton(
                  onPressed: _isSaving
                      ? null
                      : () => setState(() => _rating = index + 1),
                  icon: Icon(
                    index < _rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: Colors.amber,
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              enabled: !_isSaving,
              minLines: 3,
              maxLines: 5,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Your review',
                hintText: 'What did you think about this product?',
              ),
            ),
            if (_error != null)
              Text(_error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final comment = _commentController.text.trim();
    if (comment.length < 3) {
      setState(() => _error = 'Write at least 3 characters.');
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await widget.onSubmit(_rating, comment);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _error = 'Unable to save the review. Confirm the order is delivered.';
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
