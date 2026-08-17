import 'package:ecommerence_project/utils/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Email validation', () {
    test('rejects an empty email', () {
      expect(AuthValidators.email(''), isNotNull);
    });

    test('rejects an invalid email', () {
      expect(AuthValidators.email('customer-at-example.com'), isNotNull);
    });

    test('accepts a valid email and surrounding spaces', () {
      expect(AuthValidators.email(' customer@example.com '), isNull);
    });
  });

  group('Full-name validation', () {
    test('rejects an empty name', () {
      expect(AuthValidators.fullName(''), isNotNull);
    });

    test('rejects names containing numbers', () {
      expect(AuthValidators.fullName('Test Customer 2'), isNotNull);
    });

    test('accepts a valid full name', () {
      expect(AuthValidators.fullName('Test Customer'), isNull);
    });
  });

  group('Password validation', () {
    test('login rejects an empty password', () {
      expect(AuthValidators.loginPassword(''), isNotNull);
    });

    test('login rejects a short password', () {
      expect(AuthValidators.loginPassword('Short1!'), isNotNull);
    });

    test('signup rejects a password missing required character types', () {
      expect(AuthValidators.strongPassword('onlylowercase'), isNotNull);
      expect(AuthValidators.strongPassword('ONLYUPPERCASE1!'), isNotNull);
      expect(AuthValidators.strongPassword('NoNumber!'), isNotNull);
      expect(AuthValidators.strongPassword('NoSpecial1'), isNotNull);
    });

    test('accepts a strong signup password', () {
      expect(AuthValidators.strongPassword('Secure1!'), isNull);
    });
  });
}
