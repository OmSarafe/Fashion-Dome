import 'package:ecommerence_project/resetpass_page.dart';
import 'package:ecommerence_project/widgets/basicwidget.dart';
import 'package:ecommerence_project/widgets/titlesubtitlewidget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ValidatecodePage extends StatefulWidget {
  const ValidatecodePage({super.key});

  @override
  State<ValidatecodePage> createState() => _ValidatecodePageState();
}

class _ValidatecodePageState extends State<ValidatecodePage> {
  final pinController = TextEditingController();
  @override
  Widget build(BuildContext context) {
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
                      TitleSubtitleText(
                          title: "Enter 4 Digit Code",
                          subtitle:
                              "Enter 4 digit code that your receive on your email (cody.fisher45@example.com)."),
                      SizedBox(
                        height: 30,
                      ),
                      PinCodeInput(),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: "Email not received? ",
                            style: TextStyle(
                              fontFamily: 'GeneralSans',
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: "Resend code",
                                style: TextStyle(
                                  color: Colors.black,
                                  decoration: TextDecoration
                                      .underline, // Underline the word "Terms"
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //       builder: (context) =>
                                    //           LoginPage()), // Replace SecondPage with your target widget
                                    // );
                                  },
                              ),
                            ],
                          ),
                        ),
                      )
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
                            builder: (context) => const ResetpassPage(),
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
                            "Continue",
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
    pinController.dispose();
    super.dispose();
  }
}
