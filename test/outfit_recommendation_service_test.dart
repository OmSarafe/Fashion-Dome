import 'package:ecommerence_project/models/product.dart';
import 'package:ecommerence_project/services/outfit_recommendation_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = OutfitRecommendationService();

  const formalProducts = [
    Product(
      id: 'shirt',
      name: 'Formal Shirt',
      description: 'White formal shirt',
      category: 'Shirts',
      priceInPence: 3000,
      assetImagePath: 'shirt.png',
      availableSizes: ['M'],
      stock: 4,
      outfitCategory: OutfitCategory.top,
      occasionTags: [OutfitOccasion.formal],
    ),
    Product(
      id: 'trousers',
      name: 'Formal Trousers',
      description: 'Tailored trousers',
      category: 'Trousers',
      priceInPence: 4500,
      assetImagePath: 'trousers.png',
      availableSizes: ['32'],
      stock: 4,
      outfitCategory: OutfitCategory.bottom,
      occasionTags: [OutfitOccasion.formal],
    ),
    Product(
      id: 'shoes',
      name: 'Oxford Shoes',
      description: 'Formal leather shoes',
      category: 'Shoes',
      priceInPence: 6000,
      assetImagePath: 'shoes.png',
      availableSizes: ['9'],
      stock: 4,
      outfitCategory: OutfitCategory.footwear,
      occasionTags: [OutfitOccasion.formal],
    ),
    Product(
      id: 'blazer',
      name: 'Tailored Blazer',
      description: 'Formal navy blazer',
      category: 'Blazers',
      priceInPence: 9000,
      assetImagePath: 'blazer.png',
      availableSizes: ['M'],
      stock: 4,
      outfitCategory: OutfitCategory.outerwear,
      occasionTags: [OutfitOccasion.formal],
    ),
  ];

  test('builds a complete formal look within the selected budget', () {
    final recommendations = service.recommend(
      products: formalProducts,
      occasion: OutfitOccasion.formal,
      budgetInPence: 25000,
    );

    expect(recommendations, isNotEmpty);
    expect(recommendations.first.products, hasLength(4));
    expect(recommendations.first.totalInPence, 22500);
    expect(recommendations.first.remainingBudgetInPence, 2500);
  });

  test('keeps the required formal pieces when the blazer exceeds budget', () {
    final recommendations = service.recommend(
      products: formalProducts,
      occasion: OutfitOccasion.formal,
      budgetInPence: 14000,
    );

    expect(recommendations, isNotEmpty);
    expect(
      recommendations.first.products.map((product) => product.id),
      containsAll(['shirt', 'trousers', 'shoes']),
    );
    expect(recommendations.first.products, hasLength(3));
    expect(recommendations.first.totalInPence, lessThanOrEqualTo(14000));
  });

  test('returns no formal look when a required category is unavailable', () {
    final recommendations = service.recommend(
      products: formalProducts.where((product) => product.id != 'shoes'),
      occasion: OutfitOccasion.formal,
      budgetInPence: 25000,
    );

    expect(recommendations, isEmpty);
  });

  test('excludes out-of-stock products from recommendations', () {
    const unavailableShoes = Product(
      id: 'unavailable-shoes',
      name: 'Unavailable Oxford Shoes',
      description: 'Out of stock',
      category: 'Shoes',
      priceInPence: 5000,
      assetImagePath: 'shoes.png',
      availableSizes: ['9'],
      stock: 0,
      outfitCategory: OutfitCategory.footwear,
      occasionTags: [OutfitOccasion.formal],
    );

    final recommendations = service.recommend(
      products: [...formalProducts, unavailableShoes],
      occasion: OutfitOccasion.formal,
      budgetInPence: 25000,
    );

    expect(
      recommendations.expand((look) => look.products),
      isNot(contains(unavailableShoes)),
    );
  });
}
