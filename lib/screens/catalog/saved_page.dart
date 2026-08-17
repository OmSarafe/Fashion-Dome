import 'package:ecommerence_project/screens/catalog/product_detail_page.dart';
import 'package:ecommerence_project/models/product.dart';
import 'package:ecommerence_project/providers/shop_provider.dart';
import 'package:ecommerence_project/widgets/product_card.dart';
import 'package:ecommerence_project/utils/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Savedpage extends StatelessWidget {
  const Savedpage({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final products = shop.favoriteProducts;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: false,
        toolbarHeight: 76,
        titleSpacing: 24,
        title: const Text(
          'Saved Items',
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 32,
            fontWeight: FontWeight.w600,
            letterSpacing: -1.2,
          ),
        ),
      ),
      body: products.isEmpty
          ? const _EmptySavedItems()
          : ResponsiveContent(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columns = ResponsiveLayout.productGridColumns(
                    constraints.maxWidth,
                  );
                  return GridView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 24),
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      childAspectRatio: columns == 1 ? 0.66 : 0.52,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ProductCard(
                              product: product,
                              isFavorite: true,
                              onToggleFavorite: () => context
                                  .read<ShopProvider>()
                                  .toggleFavorite(product.id),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductDetailPage(product: product),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          FilledButton.icon(
                            onPressed: product.isInStock
                                ? () => _addToCart(context, product)
                                : null,
                            icon: const Icon(Icons.add_shopping_cart, size: 18),
                            label: Text(
                              product.isInStock
                                  ? 'Add to cart'
                                  : 'Out of stock',
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
    );
  }

  Future<void> _addToCart(BuildContext context, Product product) async {
    final sizes = product.availableSizes;
    if (sizes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No size is available for this item.')),
      );
      return;
    }

    final selectedSize = sizes.length == 1
        ? sizes.first
        : await showModalBottomSheet<String>(
            context: context,
            showDragHandle: true,
            builder: (sheetContext) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Choose a size',
                      style: Theme.of(sheetContext).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.name,
                      style: Theme.of(sheetContext).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: sizes
                          .map(
                            (size) => ActionChip(
                              label: Text(size),
                              onPressed: () =>
                                  Navigator.pop(sheetContext, size),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ],
                ),
              ),
            ),
          );

    if (selectedSize == null || !context.mounted) return;
    final added = context.read<ShopProvider>().addToCart(
          product,
          size: selectedSize,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? '${product.name} ($selectedSize) added to your cart.'
              : 'Unable to add this item. Check the available stock.',
        ),
      ),
    );
  }
}

class _EmptySavedItems extends StatelessWidget {
  const _EmptySavedItems();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 58, color: Colors.grey),
            SizedBox(height: 14),
            Text(
              'No saved items yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the heart on a product to save it here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
