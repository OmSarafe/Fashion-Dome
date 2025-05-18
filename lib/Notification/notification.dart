import 'package:ecommerence_project/widgets/promotiontile.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
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
          'Notifications',
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PromotionTile(
              title1: "30% Special Discount!",
              subtitle1: "Special promotion only valid today.",
              title2: 'Top Up E-wallet Successfully!',
              subtitle2: 'You have top up your e-wallet.',
              heading: 'Today',
              icon1: Icons.discount_outlined,
              icon2: Icons.account_balance_wallet_outlined,
            ),
            PromotionTile(
              title1: "New Service Available!",
              subtitle1: "Now you can track order in real-time.",
              title2: 'Credit Card Connected!',
              subtitle2: 'Credit card has been linked.',
              heading: 'Yesterday',
              icon1: Icons.location_on_outlined,
              icon2: Icons.credit_card_outlined,
            ),
            PromotionTile(
              title1: "Account Setup Successfully!",
              subtitle1: "Your account has been created..",
              title2: 'Credit Card Connected!',
              subtitle2: 'Credit card has been linked.',
              heading: 'June 7, 2023',
              icon1: Icons.account_circle_outlined,
              icon2: Icons.credit_card_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
