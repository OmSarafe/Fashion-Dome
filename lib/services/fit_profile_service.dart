import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/fit_profile.dart';

class FitProfileService {
  static const _profileKey = 'local_fit_profile';

  Future<FitProfile?> loadProfile() async {
    final preferences = await SharedPreferences.getInstance();
    final storedProfile = preferences.getString(_profileKey);
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

  Future<void> saveProfile(FitProfile profile) async {
    if (!profile.isValid) {
      throw ArgumentError('Fit profile measurements are outside valid ranges.');
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<void> deleteProfile() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_profileKey);
  }
}
