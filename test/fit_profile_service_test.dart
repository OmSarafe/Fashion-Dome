import 'package:ecommerence_project/models/fit_profile.dart';
import 'package:ecommerence_project/services/fit_profile_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saves and loads a fit profile locally', () async {
    final service = FitProfileService();
    const profile = FitProfile(
      heightCm: 178,
      chestCm: 101.5,
      waistCm: 84,
      fitPreference: FitPreference.regular,
    );

    await service.saveProfile(userId: 'user-a', profile: profile);
    final loaded = await service.loadProfile(userId: 'user-a');

    expect(loaded?.heightCm, 178);
    expect(loaded?.chestCm, 101.5);
    expect(loaded?.waistCm, 84);
    expect(loaded?.fitPreference, FitPreference.regular);
  });

  test('deletes the saved fit profile', () async {
    final service = FitProfileService();
    const profile = FitProfile(
      heightCm: 178,
      chestCm: 101,
      waistCm: 84,
      fitPreference: FitPreference.relaxed,
    );

    await service.saveProfile(userId: 'user-a', profile: profile);
    await service.deleteProfile(userId: 'user-a');

    expect(await service.loadProfile(userId: 'user-a'), isNull);
  });

  test('refuses measurements outside the accepted ranges', () async {
    final service = FitProfileService();
    const profile = FitProfile(
      heightCm: 80,
      chestCm: 101,
      waistCm: 84,
      fitPreference: FitPreference.regular,
    );

    expect(
      () => service.saveProfile(userId: 'user-a', profile: profile),
      throwsArgumentError,
    );
  });

  test('keeps fit profiles isolated between signed-in users', () async {
    final service = FitProfileService();
    const firstProfile = FitProfile(
      heightCm: 178,
      chestCm: 101,
      waistCm: 84,
      fitPreference: FitPreference.regular,
    );
    const secondProfile = FitProfile(
      heightCm: 165,
      chestCm: 88,
      waistCm: 72,
      fitPreference: FitPreference.slim,
    );

    await service.saveProfile(userId: 'user-a', profile: firstProfile);
    await service.saveProfile(userId: 'user-b', profile: secondProfile);

    expect(
      (await service.loadProfile(userId: 'user-a'))?.waistCm,
      firstProfile.waistCm,
    );
    expect(
      (await service.loadProfile(userId: 'user-b'))?.waistCm,
      secondProfile.waistCm,
    );
  });
}
