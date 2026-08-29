import 'package:ecommerence_project/models/product.dart';
import 'package:ecommerence_project/providers/shop_provider.dart';
import 'package:ecommerence_project/screens/account/fit_profile_page.dart';
import 'package:ecommerence_project/services/fit_profile_service.dart';
import 'package:ecommerence_project/services/fit_recommendation_service.dart';
import 'package:ecommerence_project/utils/currency_formatter.dart';
import 'package:ecommerence_project/utils/responsive_layout.dart';
import 'package:ecommerence_project/widgets/product_image.dart';
import 'package:ecommerence_project/widgets/product_reviews_section.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String? _selectedSize;
  final _fitProfileService = FitProfileService();
  final _fitRecommendationService = FitRecommendationService();

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.product.availableSizes.isEmpty
        ? null
        : widget.product.availableSizes.first;
  }

  Future<void> _findMySize(Product product) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    var profile = await _fitProfileService.loadProfile(userId: userId);
    if (!mounted) return;

    if (profile == null) {
      final createProfile = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.straighten_outlined),
          title: const Text('Create your Fit Profile'),
          content: const Text(
            'Add your measurements once, then Fashion Dome can explain '
            'which available size may suit you. Your data stays on this device.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Create profile'),
            ),
          ],
        ),
      );
      if (createProfile != true || !mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FitProfilePage()),
      );
      if (!mounted) return;
      profile = await _fitProfileService.loadProfile(userId: userId);
      if (!mounted || profile == null) return;
    }

    final recommendation = _fitRecommendationService.recommend(
      profile: profile,
      product: product,
    );
    if (recommendation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Size guidance is not available for this product.'),
        ),
      );
      return;
    }

    setState(() => _selectedSize = recommendation.recommendedSize);
    final colors = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your size guidance',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommended size',
                      style: TextStyle(color: colors.onPrimaryContainer),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recommendation.recommendedSize,
                      style: TextStyle(
                        color: colors.onPrimaryContainer,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recommendation.confidence.label,
                      style: TextStyle(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                recommendation.explanation,
                style: const TextStyle(height: 1.5),
              ),
              const SizedBox(height: 12),
              Text(
                'Guidance only: brand, material and product cut can affect fit.',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: Text('Use size ${recommendation.recommendedSize}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final product = shop.products.firstWhere(
      (item) => item.id == widget.product.id,
      orElse: () => widget.product,
    );
    final isFavorite = shop.isFavorite(product.id);
    final canAddToCart = shop.canAddProduct(product);
    final selectedSize = product.availableSizes.contains(_selectedSize)
        ? _selectedSize
        : product.availableSizes.isEmpty
            ? null
            : product.availableSizes.first;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text(
          'Product details',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () => shop.toggleFavorite(product.id),
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite
                  ? Colors.red
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
      body: ResponsiveContent(
        maxWidth: 760,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 8, bottom: 132),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 0.94,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ProductImage(product: product),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                product.category.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                style: const TextStyle(
                  fontFamily: 'GeneralSans',
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 21),
                  const SizedBox(width: 4),
                  Text(
                    product.ratingCount == 0
                        ? 'No ratings yet'
                        : '${product.averageRating.toStringAsFixed(1)} '
                            '(${product.ratingCount} review${product.ratingCount == 1 ? '' : 's'})',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    formatPounds(product.priceInPence),
                    style: const TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (product.compareAtPriceInPence != null) ...[
                    const SizedBox(width: 10),
                    Text(
                      formatPounds(product.compareAtPriceInPence!),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 18),
              Text(
                product.description,
                style: TextStyle(
                  height: 1.55,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                !product.isInStock
                    ? 'Currently out of stock'
                    : product.isLowStock
                        ? 'Only ${product.stock} left in stock'
                        : 'In stock',
                style: TextStyle(
                  color: !product.isInStock
                      ? Colors.red
                      : product.isLowStock
                          ? Colors.orange.shade800
                          : Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select size',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  TextButton.icon(
                    onPressed: product.availableSizes.isEmpty
                        ? null
                        : () => _findMySize(product),
                    icon: const Icon(Icons.straighten_outlined),
                    label: const Text('Find my size'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (product.availableSizes.isEmpty)
                Text(
                  'No sizes are currently available for this product.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: product.availableSizes.map((size) {
                    final selected = selectedSize == size;
                    final colors = Theme.of(context).colorScheme;
                    return SizedBox(
                      width: 52,
                      height: 44,
                      child: ChoiceChip(
                        label: SizedBox(
                          width: double.infinity,
                          child: Text(size, textAlign: TextAlign.center),
                        ),
                        selected: selected,
                        showCheckmark: false,
                        selectedColor: colors.primary,
                        backgroundColor: colors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: selected ? colors.primary : colors.outline,
                          ),
                        ),
                        labelPadding: EdgeInsets.zero,
                        labelStyle: TextStyle(
                          color: selected ? colors.onPrimary : colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (_) => setState(() => _selectedSize = size),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 30),
              ProductReviewsSection(product: product),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          child: ResponsiveBottomBar(
            child: SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: canAddToCart && selectedSize != null
                    ? () {
                        final added = context.read<ShopProvider>().addToCart(
                              product,
                              size: selectedSize,
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              added
                                  ? '${product.name} ($selectedSize) added to cart.'
                                  : 'The available stock is already in your cart.',
                            ),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.shopping_bag_outlined),
                label: Text(
                  !product.isInStock
                      ? 'Out of stock'
                      : canAddToCart && selectedSize != null
                          ? 'Add to cart · ${formatPounds(product.priceInPence)}'
                          : selectedSize == null
                              ? 'No size available'
                              : 'Maximum stock in cart',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
