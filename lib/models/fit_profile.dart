enum FitPreference { slim, regular, relaxed }

extension FitPreferenceLabel on FitPreference {
  String get label {
    switch (this) {
      case FitPreference.slim:
        return 'Slim';
      case FitPreference.regular:
        return 'Regular';
      case FitPreference.relaxed:
        return 'Relaxed';
    }
  }
}

class FitProfile {
  const FitProfile({
    required this.heightCm,
    required this.chestCm,
    required this.waistCm,
    required this.fitPreference,
  });

  final double heightCm;
  final double chestCm;
  final double waistCm;
  final FitPreference fitPreference;

  bool get isValid =>
      heightCm >= 120 &&
      heightCm <= 230 &&
      chestCm >= 60 &&
      chestCm <= 160 &&
      waistCm >= 50 &&
      waistCm <= 150;

  Map<String, dynamic> toJson() => {
        'heightCm': heightCm,
        'chestCm': chestCm,
        'waistCm': waistCm,
        'fitPreference': fitPreference.name,
      };

  factory FitProfile.fromJson(Map<String, dynamic> json) {
    final preferenceName = json['fitPreference'] as String?;
    final preference = FitPreference.values.firstWhere(
      (item) => item.name == preferenceName,
      orElse: () => FitPreference.regular,
    );

    return FitProfile(
      heightCm: (json['heightCm'] as num).toDouble(),
      chestCm: (json['chestCm'] as num).toDouble(),
      waistCm: (json['waistCm'] as num).toDouble(),
      fitPreference: preference,
    );
  }
}
