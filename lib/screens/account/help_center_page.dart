import 'package:ecommerence_project/screens/account/customer_service_page.dart';
import 'package:ecommerence_project/screens/account/faq_page.dart';
import 'package:ecommerence_project/screens/account/privacy_policy_page.dart';
import 'package:ecommerence_project/screens/notifications/notifications_page.dart';
import 'package:ecommerence_project/utils/responsive_layout.dart';
import 'package:flutter/material.dart';

class HelpcenterPage extends StatelessWidget {
  const HelpcenterPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Help Center',
          style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w600,
              fontSize: 32,
              letterSpacing: -2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Notifications',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationPage()),
            ),
          ),
          SizedBox(
            width: 5,
          ),
        ],
      ),
      body: ResponsiveContent(
        maxWidth: 760,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            const Divider(
              thickness: 0.3,
              color: Colors.grey,
              indent: 25,
              endIndent: 25,
            ),
            const SizedBox(
              height: 30,
            ),
            profileMenuItem(
              icon: Icons.quiz_outlined,
              title: 'Frequently Asked Questions',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Faqpage()),
              ),
            ),
            profileMenuItem(
              icon: Icons.headset_mic_outlined,
              title: 'Customer Service',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CustomerServicePage(),
                ),
              ),
            ),
            profileMenuItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget profileMenuItem({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Icon(icon, size: 20),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right),
            const SizedBox(width: 14),
          ],
        ),
      ),
    ),
  );
}
