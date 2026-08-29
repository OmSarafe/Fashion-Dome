import 'package:ecommerence_project/screens/account/faq_page.dart';
import 'package:ecommerence_project/utils/responsive_layout.dart';
import 'package:flutter/material.dart';

class CustomerServicePage extends StatelessWidget {
  const CustomerServicePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Customer Service'),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ResponsiveContent(
        maxWidth: 760,
        child: SelectionArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 32),
            children: [
              Icon(
                Icons.support_agent_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                'How can we help?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'For account, order, payment or privacy questions, email the project support address below.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email support'),
                  subtitle: const Text('omsarafe@gmail.com'),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 12),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    'Please include your account email, order number (if applicable), and a short description of the issue. Never send a password or full card details.',
                    style: TextStyle(height: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
