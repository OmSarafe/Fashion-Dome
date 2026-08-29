import 'package:ecommerence_project/models/product.dart';

class OutfitRecommendation {
  OutfitRecommendation({
    required this.occasion,
    required this.budgetInPence,
    required List<Product> products,
  }) : products = List<Product>.unmodifiable(products);

  final String occasion;
  final int budgetInPence;
  final List<Product> products;

  int get totalInPence => products.fold(
        0,
        (total, product) => total + product.priceInPence,
      );

  int get remainingBudgetInPence => budgetInPence - totalInPence;
}

class OutfitRecommendationService {
  const OutfitRecommendationService();

  List<OutfitRecommendation> recommend({
    required Iterable<Product> products,
    required String occasion,
    required int budgetInPence,
    int limit = 3,
  }) {
    if (!OutfitOccasion.values.contains(occasion) ||
        budgetInPence <= 0 ||
        limit <= 0) {
      return const [];
    }

    final availableProducts = products
        .where(
          (product) =>
              product.isInStock &&
              product.availableSizes.isNotEmpty &&
              product.priceInPence <= budgetInPence &&
              product.supportsOccasion(occasion) &&
              product.resolvedOutfitCategory != OutfitCategory.other,
        )
        .toList(growable: false);

    final grouped = <String, List<Product>>{};
    for (final product in availableProducts) {
      grouped
          .putIfAbsent(product.resolvedOutfitCategory, () => [])
          .add(product);
    }
    for (final group in grouped.values) {
      group.sort((left, right) => left.priceInPence.compareTo(right.priceInPence));
    }

    final slots = _slotsFor(occasion);
    if (slots
        .where((slot) => slot.isRequired)
        .any((slot) => grouped[slot.category]?.isNotEmpty != true)) {
      return const [];
    }

    final recommendations = <OutfitRecommendation>[];
    final selected = <Product>[];

    void buildCombination(int slotIndex, int runningTotal) {
      if (slotIndex == slots.length) {
        recommendations.add(
          OutfitRecommendation(
            occasion: occasion,
            budgetInPence: budgetInPence,
            products: selected,
          ),
        );
        return;
      }

      final slot = slots[slotIndex];
      final candidates = grouped[slot.category] ?? const <Product>[];
      if (!slot.isRequired) {
        buildCombination(slotIndex + 1, runningTotal);
      }

      for (final product in candidates) {
        final nextTotal = runningTotal + product.priceInPence;
        if (nextTotal > budgetInPence) continue;
        selected.add(product);
        buildCombination(slotIndex + 1, nextTotal);
        selected.removeLast();
      }
    }

    buildCombination(0, 0);
    recommendations.sort((left, right) {
      final completeness = right.products.length.compareTo(left.products.length);
      if (completeness != 0) return completeness;
      return right.totalInPence.compareTo(left.totalInPence);
    });

    final uniqueRecommendations = <OutfitRecommendation>[];
    final signatures = <String>{};
    for (final recommendation in recommendations) {
      final productIds = recommendation.products.map((product) => product.id).toList()
        ..sort();
      if (!signatures.add(productIds.join('|'))) continue;
      uniqueRecommendations.add(recommendation);
      if (uniqueRecommendations.length == limit) break;
    }
    return uniqueRecommendations;
  }

  List<_OutfitSlot> _slotsFor(String occasion) {
    if (occasion == OutfitOccasion.formal) {
      return const [
        _OutfitSlot(OutfitCategory.top, isRequired: true),
        _OutfitSlot(OutfitCategory.bottom, isRequired: true),
        _OutfitSlot(OutfitCategory.footwear, isRequired: true),
        _OutfitSlot(OutfitCategory.outerwear),
        _OutfitSlot(OutfitCategory.accessory),
      ];
    }
    return const [
      _OutfitSlot(OutfitCategory.top, isRequired: true),
      _OutfitSlot(OutfitCategory.bottom, isRequired: true),
      _OutfitSlot(OutfitCategory.outerwear),
      _OutfitSlot(OutfitCategory.footwear),
      _OutfitSlot(OutfitCategory.accessory),
    ];
  }
}

class _OutfitSlot {
  const _OutfitSlot(this.category, {this.isRequired = false});

  final String category;
  final bool isRequired;
}
