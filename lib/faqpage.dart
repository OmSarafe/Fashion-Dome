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
      backgroundColor: Colors.white,
      appBar: customAppBar(context, "FAQs"),
    );
  }
}

AppBar customAppBar(BuildContext context, String title, {Widget? leading}) {
  Widget defaultLeading = GestureDetector(
    onTap: () {
      Navigator.pop(context);
    },
    child: const Icon(
      Icons.arrow_back,
      color: Colors.black,
    ),
  );

  return AppBar(
    backgroundColor: Colors.white,
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
        icon: const Icon(Icons.notifications_none, color: Colors.black),
        onPressed: () {},
      ),
      const SizedBox(
        width: 5,
      ),
    ],
  );
}
