import 'package:ecommerence_project/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfile roles', () {
    test('recognises an administrator account', () {
      final profile = UserProfile.fromMap('admin-1', const {
        'name': 'Store Admin',
        'email': 'admin@example.com',
        'role': 'admin',
      });

      expect(profile.isAdmin, true);
    });

    test('recognises a customer account', () {
      final profile = UserProfile.fromMap('customer-1', const {
        'name': 'Test Customer',
        'email': 'customer@example.com',
        'role': 'customer',
      });

      expect(profile.isAdmin, false);
    });

    test('missing role safely defaults to customer', () {
      final profile = UserProfile.fromMap('customer-2', const {
        'name': 'New Customer',
        'email': 'new@example.com',
      });

      expect(profile.role, 'customer');
      expect(profile.isAdmin, false);
    });
  });
}
