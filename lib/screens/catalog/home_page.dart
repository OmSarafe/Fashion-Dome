import 'package:ecommerence_project/screens/notifications/notifications_page.dart';
import 'package:ecommerence_project/screens/catalog/product_detail_page.dart';
import 'package:ecommerence_project/screens/catalog/outfit_builder_page.dart';
import 'package:ecommerence_project/models/product.dart';
import 'package:ecommerence_project/providers/shop_provider.dart';
import 'package:ecommerence_project/screens/catalog/search_page.dart';
import 'package:ecommerence_project/utils/responsive_layout.dart';
import 'package:ecommerence_project/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String _query = '';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    const preferredCategories = [
      'All',
      'T-shirts',
      'Shirts',
      'Jeans',
      'Jackets',
    ];
    final availableCategories = <String>{
      ...shop.products.map((product) => product.category),
    };
    final otherCategories = availableCategories
        .where((category) => !preferredCategories.contains(category))
        .toList()
      ..sort();
    final categories = [
      'All',
      ...preferredCategories.skip(1).where(availableCategories.contains),
      ...otherCategories,
    ];
    final products = shop.products.where((product) {
      final matchesSearch =
          product.name.toLowerCase().contains(_query.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList(growable: false);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: false,
        toolbarHeight: 76,
        titleSpacing: 24,
        title: const Text(
          'Discover',
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 32,
            fontWeight: FontWeight.w600,
            letterSpacing: -1.2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationPage(),
                ),
              );
            },
            icon: const Icon(Icons.notifications_none),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ResponsiveContent(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = ResponsiveLayout.productGridColumns(
              constraints.maxWidth,
            );

            return Column(
              children: [
                SizedBox(
                  height: 52,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) =>
                              setState(() => _query = value.trim()),
                          textInputAction: TextInputAction.search,
                          decoration: const InputDecoration(
                            hintText: 'Search clothes',
                            prefixIcon: Icon(Icons.search_rounded, size: 22),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox.square(
                        dimension: 52,
                        child: FilledButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const Search()),
                            );
                          },
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Icon(Icons.tune_rounded, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _StyleMyLookBanner(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OutfitBuilderPage(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = _selectedCategory == category;
                      final colors = Theme.of(context).colorScheme;
                      return ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        showCheckmark: false,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected ? colors.primary : colors.outline,
                          ),
                        ),
                        selectedColor: colors.primary,
                        backgroundColor: colors.surface,
                        labelStyle: TextStyle(
                          color:
                              isSelected ? colors.onPrimary : colors.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        onSelected: (_) {
                          setState(() => _selectedCategory = category);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: products.isEmpty
                      ? const _EmptyProducts()
                      : GridView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: products.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            childAspectRatio:
                                ResponsiveLayout.productCardAspectRatio(
                              constraints.maxWidth,
                            ),
                            mainAxisSpacing: 24,
                            crossAxisSpacing: 16,
                          ),
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return ProductCard(
                              product: product,
                              isFavorite: shop.isFavorite(product.id),
                              onToggleFavorite: () {
                                context
                                    .read<ShopProvider>()
                                    .toggleFavorite(product.id);
                              },
                              onTap: () => _openProduct(context, product),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openProduct(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(product: product),
      ),
    );
  }
}

class _StyleMyLookBanner extends StatelessWidget {
  const _StyleMyLookBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.primaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.auto_awesome_rounded, color: colors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Style My Look',
                      style: TextStyle(
                        color: colors.onPrimaryContainer,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Build a complete outfit for your occasion and budget.',
                      style: TextStyle(
                        color: colors.onPrimaryContainer,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: colors.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 52, color: Colors.grey),
          SizedBox(height: 12),
          Text('No products match your search.'),
        ],
      ),
    );
  }
}
