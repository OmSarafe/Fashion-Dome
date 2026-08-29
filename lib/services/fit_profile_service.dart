import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/fit_profile.dart';

class FitProfileService {
  static const _legacyProfileKey = 'local_fit_profile';

  String _profileKey(String userId) {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      throw ArgumentError('A signed-in user ID is required.');
    }
    return 'local_fit_profile_$normalizedUserId';
  }

  Future<FitProfile?> loadProfile({required String userId}) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_legacyProfileKey);
    final storedProfile = preferences.getString(_profileKey(userId));
    if (storedProfile == null) return null;

    try {
      final decoded = jsonDecode(storedProfile);
      if (decoded is! Map<String, dynamic>) return null;
      final profile = FitProfile.fromJson(decoded);
      return profile.isValid ? profile : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProfile({
    required String userId,
    required FitProfile profile,
  }) async {
    if (!profile.isValid) {
      throw ArgumentError('Fit profile measurements are outside valid ranges.');
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_legacyProfileKey);
    await preferences.setString(
      _profileKey(userId),
      jsonEncode(profile.toJson()),
    );
  }

  Future<void> deleteProfile({required String userId}) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_legacyProfileKey);
    await preferences.remove(_profileKey(userId));
  }
}
