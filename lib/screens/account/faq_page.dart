import 'package:ecommerence_project/screens/notifications/notifications_page.dart';
import 'package:flutter/material.dart';

class Faqpage extends StatefulWidget {
  const Faqpage({super.key});

  @override
  State<Faqpage> createState() => _FaqpageState();
}

class _FaqpageState extends State<Faqpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(context, "FAQs"),
    );
  }
}

AppBar customAppBar(BuildContext context, String title,
    {IconData? icon, Widget? action, Widget? leading}) {
  Widget defaultLeading = GestureDetector(
    onTap: () {
      Navigator.pop(context);
    },
    child: const Icon(Icons.arrow_back),
  );

  Widget defaultaction = GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                NotificationPage()), // Replace SecondPage with your target widget
      );
    },
    child: const Icon(Icons.arrow_back),
  );

  return AppBar(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    elevation: 0,
    leading: leading ?? defaultLeading,
    centerTitle: true,
    title: Text(
      title,
      style: TextStyle(
          fontFamily: 'GeneralSans',
          fontWeight: FontWeight.w600,
          fontSize: 32,
          letterSpacing: -2),
    ),
    actions: [
      IconButton(
          icon: Icon(icon ?? Icons.notifications_none),
          onPressed: () {
            action ?? defaultaction;
          }),
      const SizedBox(
        width: 5,
      ),
    ],
  );
}
