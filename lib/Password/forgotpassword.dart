
import 'package:ecommerence_project/Password/validatecode_page.dart';
import 'package:ecommerence_project/widgets/titlesubtitlewidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Get the keyboard height
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    // Get the available screen height (excluding system UI)
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent default resizing
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: const Icon(
          Icons.arrow_back,
          color: Colors.black,
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 10, right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TitleSubtitleText(
                        title: "Forgot password",
                        subtitle:
                            "Enter your email for the verification process. We will send 4 digits code to your email.",
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Email",
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 45,
                        child: TextFormField(
                          controller: _emailController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email cannot be empty';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Enter a valid email address';
                            }
                            if (value.length > 50) {
                              return 'Email must not exceed 50 characters';
                            }
                            return null;
                          },
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            hintText: "Enter your email",
                            hintStyle: const TextStyle(
                              fontFamily: 'GeneralSans',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 0.5, color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.black, width: 1.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.red, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Add padding to ensure the button is always visible above the keyboard
                  Padding(
                    padding: EdgeInsets.only(bottom: keyboardHeight + 80),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ValidatecodePage(),
                          ),
                        );
                      },
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black,
                        ),
                        child: const Center(
                          child: Text(
                            "Send Code",
                            style: TextStyle(
                              fontFamily: 'GeneralSans',
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
