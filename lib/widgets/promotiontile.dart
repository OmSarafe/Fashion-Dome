import 'package:flutter/material.dart';

class PromotionTile extends StatelessWidget {
  final String title1;
  final String subtitle1;
  final String title2;
  final String subtitle2;
  final String heading;
  final IconData icon1;
  final IconData icon2;

  const PromotionTile({
    Key? key,
    required this.title1,
    required this.subtitle1,
    required this.title2,
    required this.subtitle2,
    required this.icon1,
    required this.icon2,
    required this.heading,
  }) : super(key: key);

  Widget _buildRow(String title, String subtitle, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Icon(icon, color: Colors.black),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'GeneralSans',
                color: Colors.grey,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 15),
        _buildRow(title1, subtitle1, icon1),
        const SizedBox(height: 15),
        _buildRow(title2, subtitle2, icon2),
        const SizedBox(height: 15),
        const Divider(
          color: Colors.grey,
          thickness: 0.5,
        ),
      ],
    );
  }
}
