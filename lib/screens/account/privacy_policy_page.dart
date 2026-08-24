import 'package:ecommerence_project/utils/responsive_layout.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const contactEmail = 'omsarafe@gmail.com';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ResponsiveContent(
        maxWidth: 780,
        child: SelectionArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 32),
            children: const [
              Text(
                'Fashion Dome Privacy Policy',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6),
              Text('Last updated: 25 August 2026'),
              SizedBox(height: 22),
              _PolicySection(
                title: 'Who we are',
                body:
                    'Fashion Dome is a clothing e-commerce application developed by Om Sarafe as an MSc project. Privacy questions and account-deletion requests can be sent to $contactEmail.',
              ),
              _PolicySection(
                title: 'Information we process',
                body:
                    'Depending on the features you use, we process your Firebase user ID, name, email address, sign-in provider, optional phone number, gender and date of birth; delivery address and a map pin you choose; cart, favourites, orders, selected sizes, payment status and method; reviews, ratings and comments; notification preferences and device messaging tokens. Theme and onboarding preferences are stored locally on your device. Administrators may upload product images and catalogue information.',
              ),
              _PolicySection(
                title: 'How we use information',
                body:
                    'We use this information to create and secure accounts, provide the catalogue, save preferences, process and track orders, calculate stock, support test payments, deliver notifications, show addresses and map suggestions, publish reviews, provide customer support and administer the service. Processing is based on providing the service you request, your choices and consent where applicable, and legitimate interests in security, fraud prevention and service administration.',
              ),
              _PolicySection(
                title: 'Service providers and sharing',
                body:
                    'The app uses Google Firebase and Google Cloud for authentication, database storage, product images, server functions and notifications; Google Sign-In, Maps, Places and geocoding for account and address features; and Stripe for test-mode payment processing. These providers process data under their own terms and privacy notices and may process data internationally using their applicable safeguards. We do not sell personal information or use third-party advertising SDKs.',
              ),
              _PolicySection(
                title: 'Payments',
                body:
                    'Card entry is handled by Stripe. Fashion Dome does not store full card numbers, security codes or complete card credentials in Firestore. We store only order and payment status information needed for the checkout and order-management flow. Stripe may retain payment records under its own legal and security obligations. Cash on delivery does not send card information to Stripe.',
              ),
              _PolicySection(
                title: 'Retention and account deletion',
                body:
                    'Application data is kept while your account is active and as needed to provide the service. You can choose Account > Delete account and confirm your identity. This removes the Firebase Authentication account and associated profile, notification tokens, cart, favourites and reviews from the application database. Historical orders are retained only as anonymised transaction and inventory records: the customer identifier and delivery address are replaced with non-identifying deletion markers. You may also contact us for assistance. External providers may retain limited transaction, security, backup or legal records under their own retention obligations.',
              ),
              _PolicySection(
                title: 'Security',
                body:
                    'We use authenticated access, role-based Firestore and Storage rules, encrypted network connections, restricted API keys and managed server secrets. No online system can be guaranteed completely secure, so users should protect their account credentials and report suspected misuse.',
              ),
              _PolicySection(
                title: 'Your rights',
                body:
                    'Subject to applicable UK data-protection law, you may request access, correction, deletion, restriction or portability of your personal data, object to certain processing, or withdraw consent for optional notifications. You may also complain to the UK Information Commissioner’s Office. Contact $contactEmail to exercise these rights.',
              ),
              _PolicySection(
                title: 'Children',
                body:
                    'Fashion Dome is not directed to children under 13, and we do not knowingly collect their personal data. A parent or guardian who believes a child has provided information should contact us so it can be removed.',
              ),
              _PolicySection(
                title: 'Changes and contact',
                body:
                    'We may update this policy when the app, its providers or legal requirements change. The updated date will be shown above. For privacy questions, contact $contactEmail.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 7),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
