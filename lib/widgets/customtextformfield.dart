import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String name;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[a-z@#$&]")),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Field cannot be empty';
            }
            if (!RegExp(r"^[a-z@#$&]+$").hasMatch(value)) {
              return 'Only lowercase a-z and @ # \$ & allowed';
            }
            return null;
          },
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: "Full name",
            hintStyle: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
