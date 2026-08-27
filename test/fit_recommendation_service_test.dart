import 'package:ecommerence_project/models/fit_profile.dart';
import 'package:ecommerence_project/models/product.dart';
import 'package:ecommerence_project/services/fit_recommendation_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = FitRecommendationService();

  Product product({
    String category = 'T-shirts',
    List<String> sizes = const ['XS', 'S', 'M', 'L', 'XL'],
  }) {
    return Product(
      id: 'test-product',
      name: 'Test product',
      description: 'Test description',
      category: category,
      priceInPence: 2000,
      assetImagePath: '',
      availableSizes: sizes,
      stock: 10,
    );
  }

  FitProfile profile({
    double height = 175,
    double chest = 100,
    double waist = 82,
    FitPreference preference = FitPreference.regular,
  }) {
    return FitProfile(
      heightCm: height,
      chestCm: chest,
      waistCm: waist,
      fitPreference: preference,
    );
  }

  test('recommends a letter size from the chest measurement', () {
    final result = service.recommend(
      profile: profile(),
      product: product(),
    );

    expect(result?.recommendedSize, 'M');
    expect(result?.confidence, FitConfidence.strongMatch);
    expect(result?.explanation, contains('100 cm chest'));
  });

  test('relaxed preference can move a recommendation up', () {
    final result = service.recommend(
      profile: profile(preference: FitPreference.relaxed),
      product: product(),
    );

    expect(result?.recommendedSize, 'L');
  });

  test('slim preference can move a recommendation down', () {
    final result = service.recommend(
      profile: profile(chest: 95, preference: FitPreference.slim),
      product: product(),
    );

    expect(result?.recommendedSize, 'S');
  });

  test('recommends a numeric jeans size from waist measurement', () {
    final result = service.recommend(
      profile: profile(waist: 81.28),
      product: product(
        category: 'Jeans',
        sizes: const ['28', '30', '32', '34', '36'],
      ),
    );

    expect(result?.recommendedSize, '32');
    expect(result?.idealSize, '32');
  });

  test('uses the closest available size when the ideal is unavailable', () {
    final result = service.recommend(
      profile: profile(chest: 112),
      product: product(sizes: const ['S', 'M', 'L', 'XXL']),
    );

    expect(result?.idealSize, 'XL');
    expect(result?.recommendedSize, 'L');
    expect(result?.confidence, FitConfidence.closestAvailable);
  });

  test('reduces confidence when product length needs checking', () {
    final result = service.recommend(
      profile: profile(height: 205),
      product: product(),
    );

    expect(result?.confidence, FitConfidence.measurementMatch);
    expect(result?.explanation, contains('length'));
  });

  test('returns no guidance for invalid measurements', () {
    final result = service.recommend(
      profile: profile(height: 80),
      product: product(),
    );

    expect(result, isNull);
  });

  test('returns no guidance for unsupported products or empty sizes', () {
    expect(
      service.recommend(
        profile: profile(),
        product: product(category: 'Shoes', sizes: const ['8', '9']),
      ),
      isNull,
    );
    expect(
      service.recommend(
        profile: profile(),
        product: product(sizes: const []),
      ),
      isNull,
    );
  });
}
