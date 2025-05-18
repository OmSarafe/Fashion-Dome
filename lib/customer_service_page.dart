import 'package:ecommerence_project/Account/faqpage.dart';
import 'package:flutter/material.dart';

class CustomerServicePage extends StatefulWidget {
  const CustomerServicePage({super.key});

  @override
  State<CustomerServicePage> createState() => _CustomerServicePageState();
}

class _CustomerServicePageState extends State<CustomerServicePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, "Customer Service",icon: Icons.phone_outlined),
      backgroundColor: Colors.white,
      body: Column(
        children: [],
      ),
    );
  }
}
