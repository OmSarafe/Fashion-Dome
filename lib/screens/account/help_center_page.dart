import 'package:ecommerence_project/screens/account/customer_service_page.dart';
import 'package:ecommerence_project/utils/responsive_layout.dart';
import 'package:flutter/material.dart';

class HelpcenterPage extends StatefulWidget {
  const HelpcenterPage({super.key});

  @override
  State<HelpcenterPage> createState() => _HelpcenterPageState();
}

class _HelpcenterPageState extends State<HelpcenterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back),
        ),
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
            onPressed: () {},
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
            Divider(
              thickness: 0.3,
              color: Colors.grey,
              indent: 25,
              endIndent: 25,
            ),
            SizedBox(
              height: 30,
            ),
            profileMenuItem(
                icon: Icons.headset_mic_outlined,
                title: "Customer Service",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CustomerServicePage()));
                }),
            profileMenuItem(icon: Icons.chat, title: "Whatsapp", onTap: () {}),
            profileMenuItem(
                icon: Icons.credit_card_outlined,
                title: "Website",
                onTap: () {}),
            profileMenuItem(
                icon: Icons.facebook_outlined, title: "Facebook", onTap: () {}),
            profileMenuItem(
                icon: Icons.flag_outlined, title: "Twitter", onTap: () {}),
            profileMenuItem(
                icon: Icons.account_balance_wallet_outlined,
                title: "Instagram",
                onTap: () {}),
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
          ],
        ),
      ),
    ),
  );
}
