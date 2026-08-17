import 'package:ecommerence_project/models/product.dart';
import 'package:ecommerence_project/providers/shop_provider.dart';
import 'package:ecommerence_project/utils/currency_formatter.dart';
import 'package:ecommerence_project/utils/responsive_layout.dart';
import 'package:ecommerence_project/widgets/product_image.dart';
import 'package:ecommerence_project/widgets/product_reviews_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late String _selectedSize;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.product.availableSizes.first;
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
              const Text(
                'Select size',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: product.availableSizes.map((size) {
                  final selected = _selectedSize == size;
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
                onPressed: canAddToCart
                    ? () {
                        final added = context.read<ShopProvider>().addToCart(
                              product,
                              size: _selectedSize,
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              added
                                  ? '${product.name} ($_selectedSize) added to cart.'
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
                      : canAddToCart
                          ? 'Add to cart · ${formatPounds(product.priceInPence)}'
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
