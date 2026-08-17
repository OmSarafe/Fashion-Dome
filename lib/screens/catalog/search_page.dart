import 'dart:math' as math;

import 'package:ecommerence_project/screens/notifications/notifications_page.dart';
import 'package:ecommerence_project/screens/catalog/product_detail_page.dart';
import 'package:ecommerence_project/models/product.dart';
import 'package:ecommerence_project/providers/shop_provider.dart';
import 'package:ecommerence_project/utils/currency_formatter.dart';
import 'package:ecommerence_project/widgets/product_card.dart';
import 'package:ecommerence_project/utils/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum _ProductSort {
  newest,
  priceLowToHigh,
  priceHighToLow,
  nameAZ,
}

extension on _ProductSort {
  String get label => switch (this) {
        _ProductSort.newest => 'Newest',
        _ProductSort.priceLowToHigh => 'Price: low to high',
        _ProductSort.priceHighToLow => 'Price: high to low',
        _ProductSort.nameAZ => 'Name: A–Z',
      };
}

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final _searchController = TextEditingController();

  String _query = '';
  String _selectedCategory = 'All';
  String _selectedSize = 'All';
  RangeValues? _selectedPriceRange;
  _ProductSort _sort = _ProductSort.newest;

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final categories = _catalogValues(
      shop.products.map((product) => product.category),
    );
    final sizes = _catalogValues(
      shop.products.expand((product) => product.availableSizes),
    );
    final maximumPrice = _maximumPrice(shop.products);
    final priceRange = _effectivePriceRange(maximumPrice);
    final products = _filteredProducts(
      shop.products,
      priceRange: priceRange,
    );
    final activeFilterCount = _activeFilterCount(
      maximumPrice: maximumPrice,
      priceRange: priceRange,
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        toolbarHeight: 76,
        titleSpacing: 24,
        title: const Text(
          'Search',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            letterSpacing: -1.2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationPage(),
                ),
              );
            },
            icon: const Icon(Icons.notifications_none),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ResponsiveContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search clothes, categories, or descriptions',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showFilters(
                      categories: categories,
                      sizes: sizes,
                      maximumPrice: maximumPrice,
                      initialPriceRange: priceRange,
                    ),
                    icon: const Icon(Icons.tune),
                    label: Text(
                      activeFilterCount == 0
                          ? 'Filters'
                          : 'Filters ($activeFilterCount)',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PopupMenuButton<_ProductSort>(
                    initialValue: _sort,
                    onSelected: (value) => setState(() => _sort = value),
                    itemBuilder: (context) => _ProductSort.values
                        .map(
                          (sort) => PopupMenuItem(
                            value: sort,
                            child: Row(
                              children: [
                                if (_sort == sort)
                                  const Icon(Icons.check, size: 18)
                                else
                                  const SizedBox(width: 18),
                                const SizedBox(width: 8),
                                Flexible(child: Text(sort.label)),
                              ],
                            ),
                          ),
                        )
                        .toList(growable: false),
                    child: IgnorePointer(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.swap_vert),
                        label: Text(
                          _sort.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (activeFilterCount > 0) ...[
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _activeFilterChips(
                    maximumPrice: maximumPrice,
                    priceRange: priceRange,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              '${products.length} product${products.length == 1 ? '' : 's'}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: products.isEmpty
                  ? _EmptySearchResults(onClear: _clearAll)
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = ResponsiveLayout.productGridColumns(
                          constraints.maxWidth,
                        );
                        return GridView.builder(
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
                              onToggleFavorite: () => context
                                  .read<ShopProvider>()
                                  .toggleFavorite(product.id),
                              onTap: () => _openProduct(context, product),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _catalogValues(Iterable<String> values) {
    final result = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort(
          (left, right) => left.toLowerCase().compareTo(right.toLowerCase()));
    return ['All', ...result];
  }

  double _maximumPrice(List<Product> products) {
    final highest = products.fold<int>(
      0,
      (current, product) => math.max(current, product.priceInPence),
    );
    return math.max(500, ((highest + 499) ~/ 500) * 500).toDouble();
  }

  RangeValues _effectivePriceRange(double maximumPrice) {
    final selected = _selectedPriceRange;
    if (selected == null) return RangeValues(0, maximumPrice);
    final end = selected.end.clamp(0, maximumPrice).toDouble();
    final start = selected.start.clamp(0, end).toDouble();
    return RangeValues(start, end);
  }

  List<Product> _filteredProducts(
    List<Product> source, {
    required RangeValues priceRange,
  }) {
    final normalizedQuery = _query.trim().toLowerCase();
    final products = source.where((product) {
      final matchesQuery = normalizedQuery.isEmpty ||
          product.name.toLowerCase().contains(normalizedQuery) ||
          product.category.toLowerCase().contains(normalizedQuery) ||
          product.description.toLowerCase().contains(normalizedQuery);
      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;
      final matchesSize = _selectedSize == 'All' ||
          product.availableSizes.contains(_selectedSize);
      final matchesPrice = product.priceInPence >= priceRange.start.round() &&
          product.priceInPence <= priceRange.end.round();
      return matchesQuery && matchesCategory && matchesSize && matchesPrice;
    }).toList();

    products.sort((left, right) => switch (_sort) {
          _ProductSort.newest => _compareNewest(left, right),
          _ProductSort.priceLowToHigh =>
            left.priceInPence.compareTo(right.priceInPence),
          _ProductSort.priceHighToLow =>
            right.priceInPence.compareTo(left.priceInPence),
          _ProductSort.nameAZ =>
            left.name.toLowerCase().compareTo(right.name.toLowerCase()),
        });
    return products;
  }

  int _compareNewest(Product left, Product right) {
    final comparison = (right.createdAt ??
            DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(left.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0));
    return comparison != 0 ? comparison : left.name.compareTo(right.name);
  }

  int _activeFilterCount({
    required double maximumPrice,
    required RangeValues priceRange,
  }) {
    var count = 0;
    if (_selectedCategory != 'All') count++;
    if (_selectedSize != 'All') count++;
    if (priceRange.start > 0 || priceRange.end < maximumPrice) count++;
    return count;
  }

  List<Widget> _activeFilterChips({
    required double maximumPrice,
    required RangeValues priceRange,
  }) {
    final chips = <Widget>[];
    void addChip(String label, VoidCallback onDeleted) {
      if (chips.isNotEmpty) chips.add(const SizedBox(width: 8));
      chips.add(InputChip(label: Text(label), onDeleted: onDeleted));
    }

    if (_selectedCategory != 'All') {
      addChip(
        _selectedCategory,
        () => setState(() => _selectedCategory = 'All'),
      );
    }
    if (_selectedSize != 'All') {
      addChip(
        'Size $_selectedSize',
        () => setState(() => _selectedSize = 'All'),
      );
    }
    if (priceRange.start > 0 || priceRange.end < maximumPrice) {
      addChip(
        '${formatPounds(priceRange.start.round())}–${formatPounds(priceRange.end.round())}',
        () => setState(() => _selectedPriceRange = null),
      );
    }
    return chips;
  }

  Future<void> _showFilters({
    required List<String> categories,
    required List<String> sizes,
    required double maximumPrice,
    required RangeValues initialPriceRange,
  }) async {
    var category =
        categories.contains(_selectedCategory) ? _selectedCategory : 'All';
    var size = sizes.contains(_selectedSize) ? _selectedSize : 'All';
    var priceRange = initialPriceRange;

    final result = await showModalBottomSheet<_FilterResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  20 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Filter products',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setSheetState(() {
                            category = 'All';
                            size = 'All';
                            priceRange = RangeValues(0, maximumPrice);
                          }),
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Category',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories
                          .map(
                            (value) => ChoiceChip(
                              label: Text(value),
                              selected: category == value,
                              onSelected: (_) => setSheetState(
                                () => category = value,
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Size',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: sizes
                          .map(
                            (value) => ChoiceChip(
                              label: Text(value),
                              selected: size == value,
                              onSelected: (_) =>
                                  setSheetState(() => size = value),
                            ),
                          )
                          .toList(growable: false),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Price',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          '${formatPounds(priceRange.start.round())} – ${formatPounds(priceRange.end.round())}',
                        ),
                      ],
                    ),
                    RangeSlider(
                      values: priceRange,
                      min: 0,
                      max: maximumPrice,
                      divisions: math.max(1, (maximumPrice / 500).round()),
                      labels: RangeLabels(
                        formatPounds(priceRange.start.round()),
                        formatPounds(priceRange.end.round()),
                      ),
                      onChanged: (value) =>
                          setSheetState(() => priceRange = value),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(
                          sheetContext,
                          _FilterResult(
                            category: category,
                            size: size,
                            priceRange: priceRange,
                          ),
                        ),
                        child: const Text('Show products'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null || !mounted) return;
    setState(() {
      _selectedCategory = result.category;
      _selectedSize = result.size;
      _selectedPriceRange =
          result.priceRange.start == 0 && result.priceRange.end == maximumPrice
              ? null
              : result.priceRange;
    });
  }

  void _clearAll() {
    _searchController.clear();
    setState(() {
      _query = '';
      _selectedCategory = 'All';
      _selectedSize = 'All';
      _selectedPriceRange = null;
      _sort = _ProductSort.newest;
    });
  }

  void _openProduct(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(product: product),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _FilterResult {
  const _FilterResult({
    required this.category,
    required this.size,
    required this.priceRange,
  });

  final String category;
  final String size;
  final RangeValues priceRange;
}

class _EmptySearchResults extends StatelessWidget {
  const _EmptySearchResults({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 54,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          const Text(
            'No matching products',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Try changing your search or filters.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onClear, child: const Text('Clear everything')),
        ],
      ),
    );
  }
}
