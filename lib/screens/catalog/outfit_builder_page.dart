import 'package:ecommerence_project/models/product.dart';
import 'package:ecommerence_project/providers/shop_provider.dart';
import 'package:ecommerence_project/screens/catalog/product_detail_page.dart';
import 'package:ecommerence_project/services/outfit_recommendation_service.dart';
import 'package:ecommerence_project/utils/currency_formatter.dart';
import 'package:ecommerence_project/utils/responsive_layout.dart';
import 'package:ecommerence_project/widgets/product_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OutfitBuilderPage extends StatefulWidget {
  const OutfitBuilderPage({super.key});

  @override
  State<OutfitBuilderPage> createState() => _OutfitBuilderPageState();
}

class _OutfitBuilderPageState extends State<OutfitBuilderPage> {
  static const _recommendationService = OutfitRecommendationService();

  String _occasion = OutfitOccasion.formal;
  double _budgetInPounds = 250;
  final Map<String, String> _selectedSizes = {};

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final budgetInPence = (_budgetInPounds * 100).round();
    final recommendations = _recommendationService.recommend(
      products: shop.products,
      occasion: _occasion,
      budgetInPence: budgetInPence,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text(
          'Style My Look',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ResponsiveContent(
        maxWidth: 780,
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 32),
          children: [
            _IntroCard(occasion: _occasion),
            const SizedBox(height: 24),
            const Text(
              'Choose an occasion',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: OutfitOccasion.values.map((occasion) {
                final selected = occasion == _occasion;
                return ChoiceChip(
                  label: Text(occasion),
                  selected: selected,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _occasion = occasion),
                );
              }).toList(growable: false),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Maximum budget',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                Text(
                  formatPounds(budgetInPence),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            Slider(
              value: _budgetInPounds,
              min: 50,
              max: 400,
              divisions: 35,
              label: formatPounds(budgetInPence),
              onChanged: (value) => setState(() => _budgetInPounds = value),
            ),
            Text(
              'Every suggested combination stays within this budget and uses '
              'products that are currently in stock.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 26),
            if (recommendations.isEmpty)
              _EmptyRecommendation(
                occasion: _occasion,
                budgetInPence: budgetInPence,
              )
            else ...[
              Text(
                '${recommendations.length} look${recommendations.length == 1 ? '' : 's'} for you',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              ...List.generate(
                recommendations.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: _buildRecommendationCard(
                    context,
                    recommendation: recommendations[index],
                    lookNumber: index + 1,
                  ),
                ),
              ),
            ],
            Text(
              'Style suggestions are generated from product occasion tags, '
              'categories, live prices and stock. They are guidance rather '
              'than professional styling advice.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context, {
    required OutfitRecommendation recommendation,
    required int lookNumber,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$lookNumber',
                    style: TextStyle(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${recommendation.occasion} look',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${formatPounds(recommendation.remainingBudgetInPence)} remaining',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatPounds(recommendation.totalInPence),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...recommendation.products.map(
            (product) => _OutfitProductRow(
              product: product,
              selectedSize: _sizeFor(product),
              onSizeChanged: (size) {
                if (size == null) return;
                setState(() => _selectedSizes[product.id] = size);
              },
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailPage(product: product),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: () => _addLookToCart(recommendation),
                icon: const Icon(Icons.add_shopping_cart_rounded),
                label: Text(
                  'Add full look · ${formatPounds(recommendation.totalInPence)}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _sizeFor(Product product) => _selectedSizes.putIfAbsent(
        product.id,
        () => product.availableSizes.first,
      );

  void _addLookToCart(OutfitRecommendation recommendation) {
    final shop = context.read<ShopProvider>();
    var addedCount = 0;
    for (final product in recommendation.products) {
      if (shop.addToCart(product, size: _sizeFor(product))) {
        addedCount++;
      }
    }

    final message = addedCount == recommendation.products.length
        ? 'Complete ${recommendation.occasion.toLowerCase()} look added to your cart.'
        : addedCount == 0
            ? shop.cartError ?? 'This look could not be added to your cart.'
            : '$addedCount of ${recommendation.products.length} items were added. Check stock limits in your cart.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.occasion});

  final String occasion;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primaryContainer, colors.secondaryContainer],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.78),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome_rounded, color: colors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'A complete look, within budget',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Fashion Dome combines in-stock pieces into a coordinated '
                  '${occasion.toLowerCase()} outfit for you.',
                  style: const TextStyle(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OutfitProductRow extends StatelessWidget {
  const _OutfitProductRow({
    required this.product,
    required this.selectedSize,
    required this.onSizeChanged,
    required this.onTap,
  });

  final Product product;
  final String selectedSize;
  final ValueChanged<String?> onSizeChanged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 72,
                height: 72,
                child: ProductImage(product: product),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.colour} · ${formatPounds(product.priceInPence)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: selectedSize,
              underline: const SizedBox.shrink(),
              borderRadius: BorderRadius.circular(10),
              items: product.availableSizes
                  .map(
                    (size) => DropdownMenuItem(
                      value: size,
                      child: Text(size),
                    ),
                  )
                  .toList(growable: false),
              onChanged: onSizeChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRecommendation extends StatelessWidget {
  const _EmptyRecommendation({
    required this.occasion,
    required this.budgetInPence,
  });

  final String occasion;
  final int budgetInPence;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.style_outlined, size: 48, color: colors.primary),
          const SizedBox(height: 12),
          Text(
            'No $occasion look is available under '
            '${formatPounds(budgetInPence)}.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Increase your budget or try another occasion. Suggestions need '
            'at least a matching top and bottom; formal looks also need shoes.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant, height: 1.4),
          ),
        ],
      ),
    );
  }
}
