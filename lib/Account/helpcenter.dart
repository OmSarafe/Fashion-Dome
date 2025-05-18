import 'package:ecommerence_project/customer_service_page.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
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
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
          SizedBox(
            width: 5,
          ),
        ],
      ),
      body: Column(
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
                Navigator.push(context, MaterialPageRoute(builder: (context)=>CustomerServicePage()));
              }),
          profileMenuItem(icon: Icons.chat, title: "Whatsapp", onTap: () {}),
          profileMenuItem(
              icon: Icons.credit_card_outlined, title: "Website", onTap: () {}),
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
    );
  }
}

Widget profileMenuItem({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          width: 0.85 *
              MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                  .size
                  .width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: Row(
            children: [
              const SizedBox(width: 20),
              Icon(icon, color: Colors.black, size: 20),
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
    ),
  );
}
