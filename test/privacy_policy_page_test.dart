import 'package:ecommerence_project/screens/account/privacy_policy_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('privacy policy shows identity and contact details',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PrivacyPolicyPage()),
    );

    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Fashion Dome Privacy Policy'), findsOneWidget);
    expect(find.textContaining(PrivacyPolicyPage.contactEmail), findsWidgets);
  });
}
