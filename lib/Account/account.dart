import 'package:ecommerence_project/Account/faqpage.dart';
import 'package:ecommerence_project/Account/helpcenter.dart';
import 'package:ecommerence_project/Login/login_page.dart';
import 'package:ecommerence_project/Account/myorder.dart';
import 'package:ecommerence_project/Account/notification_setting.dart';
import 'package:ecommerence_project/addresspage.dart';
import 'package:ecommerence_project/mydetails.dart';
import 'package:ecommerence_project/payment_page.dart';
import 'package:ecommerence_project/widgets/basicwidget.dart';
import 'package:flutter/material.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Account',
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Divider(
            thickness: 0.5,
            color: Colors.grey,
            indent: 20,
            endIndent: 20,
          ),
          buildMenuItem(Icons.local_shipping_outlined, "My Orders", onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Myorder()), // Replace SecondPage with your target widget
            );
          }),
          // Section 2
          Divider(
            color: Color(0xffE6E6E6),
            thickness: 8,
          ),
          buildMenuItem(Icons.person_outline, "My Details", onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Mydetails()), // Replace SecondPage with your target widget
            );
          }),
          divider(),
          buildMenuItem(Icons.home_outlined, "Address Book", onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Addresspage()), // Replace SecondPage with your target widget
            );
          }),
          divider(),
          buildMenuItem(Icons.credit_card_outlined, "Payment Methods",
              onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      PaymentPage()), // Replace SecondPage with your target widget
            );
          }),
          divider(),
          buildMenuItem(Icons.notifications_outlined, "Notifications",
              onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      NotificationSettingsPage()), // Replace SecondPage with your target widget
            );
          }),
          Divider(
            color: Color(0xffE6E6E6),
            thickness: 8,
          ),
          // Section 3
          buildMenuItem(Icons.help_outline, "FAQs", onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Faqpage()), // Replace SecondPage with your target widget
            );
          }),
          divider(),
          buildMenuItem(Icons.headset_mic_outlined, "Help Center", onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      HelpcenterPage()), // Replace SecondPage with your target widget
            );
          }),
          Divider(
            color: Color(0xffE6E6E6),
            thickness: 8,
          ),
          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: GestureDetector(
              onTap: () {
                showLogoutDialog(context);
              },
              child: Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'GeneralSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) => false,
              );

              // Handle logout
            },
          ),
        ],
      ),
    );
  }
}

Widget buildMenuItem(IconData icon, String title,
    {Color? iconColor, void Function()? onTap}) {
  return Column(
    children: [
      ListTile(
        leading: Icon(icon, size: 28, color: iconColor ?? Colors.black),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'GeneralSans',
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            color: Colors.grey, size: 16),
        onTap: onTap,
      ),
    ],
  );
}

Widget divider() {
  return Divider(
    thickness: 0.3,
    color: Colors.grey,
    indent: 60,
    endIndent: 25,
  );
}
