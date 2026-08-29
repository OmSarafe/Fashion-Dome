import 'package:ecommerence_project/screens/notifications/notifications_page.dart';
import 'package:ecommerence_project/utils/responsive_layout.dart';
import 'package:flutter/material.dart';

class Faqpage extends StatelessWidget {
  const Faqpage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(context, "FAQs"),
      body: ResponsiveContent(
        maxWidth: 760,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
          children: const [
            _FaqItem(
              question: 'How do I reset my password?',
              answer:
                  'On the login page, choose Forgot password and enter the email address connected to your account. Firebase will send a secure reset link.',
            ),
            _FaqItem(
              question: 'How are card payments handled?',
              answer:
                  'Card payments use Stripe in test mode for this MSc prototype. Fashion Dome does not store full card numbers or security codes. Cash on delivery is also available.',
            ),
            _FaqItem(
              question: 'Where can I see or cancel an order?',
              answer:
                  'Open Account, then My Orders. You can view status and order details there. Cancellation is available only before the order moves into fulfilment.',
            ),
            _FaqItem(
              question: 'How do addresses work?',
              answer:
                  'Use Account, then Address Book to add a delivery address. Place suggestions and the map help confirm the location before checkout.',
            ),
            _FaqItem(
              question: 'What is My Fit Profile?',
              answer:
                  'It uses your height, chest, waist and fit preference to explain which available product size may suit you. The measurements stay locally on this device and are not uploaded to Firebase.',
            ),
            _FaqItem(
              question: 'How do I control notifications or delete my data?',
              answer:
                  'Notification preferences and the Delete account option are both under Account. You can also delete only your local Fit Profile from its page.',
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(answer, style: const TextStyle(height: 1.5))],
      ),
    );
  }
}

AppBar customAppBar(BuildContext context, String title,
    {Widget? action, Widget? leading}) {
  Widget defaultLeading = GestureDetector(
    onTap: () {
      Navigator.pop(context);
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
      action ??
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationPage()),
            ),
          ),
      const SizedBox(
        width: 5,
      ),
    ],
  );
}
