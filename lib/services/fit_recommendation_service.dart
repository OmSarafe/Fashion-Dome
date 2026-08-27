import '../models/fit_profile.dart';
import '../models/product.dart';

enum FitConfidence { strongMatch, measurementMatch, closestAvailable }

extension FitConfidenceLabel on FitConfidence {
  String get label {
    switch (this) {
      case FitConfidence.strongMatch:
        return 'Strong match';
      case FitConfidence.measurementMatch:
        return 'Measurement match';
      case FitConfidence.closestAvailable:
        return 'Closest available';
    }
  }
}

class FitRecommendation {
  const FitRecommendation({
    required this.recommendedSize,
    required this.idealSize,
    required this.confidence,
    required this.explanation,
  });

  final String recommendedSize;
  final String idealSize;
  final FitConfidence confidence;
  final String explanation;
}

class FitRecommendationService {
  const FitRecommendationService();

  static const _letterSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  FitRecommendation? recommend({
    required FitProfile profile,
    required Product product,
  }) {
    if (!profile.isValid || product.availableSizes.isEmpty) return null;

    final category = product.category.toLowerCase();
    if (category.contains('jean') || category.contains('trouser')) {
      return _recommendNumericSize(profile, product.availableSizes);
    }

    if (category.contains('shirt') ||
        category.contains('jacket') ||
        category.contains('top')) {
      return _recommendLetterSize(profile, product.availableSizes);
    }

    return null;
  }

  FitRecommendation? _recommendLetterSize(
    FitProfile profile,
    List<String> availableSizes,
  ) {
    final fitAdjustment = switch (profile.fitPreference) {
      FitPreference.slim => -3.0,
      FitPreference.regular => 0.0,
      FitPreference.relaxed => 5.0,
    };
    final adjustedChest = profile.chestCm + fitAdjustment;
    final idealSize = switch (adjustedChest) {
      < 86 => 'XS',
      < 94 => 'S',
      < 102 => 'M',
      < 110 => 'L',
      < 118 => 'XL',
      _ => 'XXL',
    };

    final supportedAvailable = availableSizes
        .where((size) => _letterSizes.contains(size.toUpperCase()))
        .toList();
    if (supportedAvailable.isEmpty) return null;

    final idealIndex = _letterSizes.indexOf(idealSize);
    final recommendedSize = _closestLetterSize(
      supportedAvailable,
      idealIndex,
      profile.fitPreference,
    );
    final exactMatch = recommendedSize.toUpperCase() == idealSize;
    final heightWithinCoreRange =
        profile.heightCm >= 155 && profile.heightCm <= 195;
    final confidence = !exactMatch
        ? FitConfidence.closestAvailable
        : heightWithinCoreRange
            ? FitConfidence.strongMatch
            : FitConfidence.measurementMatch;

    final availabilityNote = exactMatch
        ? ''
        : ' The calculated size was $idealSize, so the closest available size was selected.';
    final heightNote = heightWithinCoreRange
        ? ''
        : ' Product-specific length measurements are not available, so '
            'check the item length as well.';

    return FitRecommendation(
      recommendedSize: recommendedSize,
      idealSize: idealSize,
      confidence: confidence,
      explanation: 'Based on your '
          '${_preferenceText(profile.fitPreference)} fit preference and '
          '${_format(profile.chestCm)} cm chest measurement.'
          '$availabilityNote$heightNote',
    );
  }

  FitRecommendation? _recommendNumericSize(
    FitProfile profile,
    List<String> availableSizes,
  ) {
    final numericSizes = <({String label, int value})>[];
    for (final size in availableSizes) {
      final value = int.tryParse(size.trim());
      if (value != null) numericSizes.add((label: size, value: value));
    }
    if (numericSizes.isEmpty) return null;

    final fitAdjustment = switch (profile.fitPreference) {
      FitPreference.slim => -1.0,
      FitPreference.regular => 0.0,
      FitPreference.relaxed => 1.0,
    };
    final adjustedWaistInches = (profile.waistCm / 2.54) + fitAdjustment;
    final idealValue = ((adjustedWaistInches / 2).round() * 2).clamp(24, 44);

    numericSizes.sort((first, second) {
      final firstDistance = (first.value - idealValue).abs();
      final secondDistance = (second.value - idealValue).abs();
      if (firstDistance != secondDistance) {
        return firstDistance.compareTo(secondDistance);
      }
      if (profile.fitPreference == FitPreference.relaxed) {
        return second.value.compareTo(first.value);
      }
      return first.value.compareTo(second.value);
    });

    final recommended = numericSizes.first;
    final exactMatch = recommended.value == idealValue;
    final availabilityNote = exactMatch
        ? ''
        : ' The calculated size was $idealValue, so the closest available size was selected.';

    return FitRecommendation(
      recommendedSize: recommended.label,
      idealSize: idealValue.toString(),
      confidence: exactMatch
          ? FitConfidence.strongMatch
          : FitConfidence.closestAvailable,
      explanation: 'Based on your '
          '${_preferenceText(profile.fitPreference)} fit preference and '
          '${_format(profile.waistCm)} cm waist measurement.'
          '$availabilityNote',
    );
  }

  String _closestLetterSize(
    List<String> availableSizes,
    int idealIndex,
    FitPreference preference,
  ) {
    final sorted = [...availableSizes]..sort((first, second) {
        final firstIndex = _letterSizes.indexOf(first.toUpperCase());
        final secondIndex = _letterSizes.indexOf(second.toUpperCase());
        final firstDistance = (firstIndex - idealIndex).abs();
        final secondDistance = (secondIndex - idealIndex).abs();
        if (firstDistance != secondDistance) {
          return firstDistance.compareTo(secondDistance);
        }
        if (preference == FitPreference.relaxed) {
          return secondIndex.compareTo(firstIndex);
        }
        return firstIndex.compareTo(secondIndex);
      });
    return sorted.first;
  }

  String _preferenceText(FitPreference preference) =>
      preference.label.toLowerCase();

  String _format(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}
