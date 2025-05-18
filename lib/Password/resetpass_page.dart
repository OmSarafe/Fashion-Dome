import 'package:ecommerence_project/widgets/basicwidget.dart';
import 'package:ecommerence_project/widgets/titlesubtitlewidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResetpassPage extends StatefulWidget {
  const ResetpassPage({super.key});

  @override
  State<ResetpassPage> createState() => _ResetpassPageState();
}

class _ResetpassPageState extends State<ResetpassPage> {
  final _passController = TextEditingController();
  final _confirmpassController = TextEditingController();
  bool appPinObscurepassText = true;
  bool appPinObscureconfirmpassText = true; // add this line
  final _loginFormKey = GlobalKey<FormState>();
  void _toggleAppPinpassView() {
    // add this method
    setState(() {
      appPinObscurepassText = !appPinObscurepassText;
    });
  }

  void _toggleAppPinconfirmpassView() {
    // add this method
    setState(() {
      appPinObscureconfirmpassText = !appPinObscureconfirmpassText;
    });
  }

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
                          title: "Reset Password",
                          subtitle:
                              "Set the new password for your account so you can login and access all the features."),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Password",
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 45,
                        child: TextFormField(
                          obscureText: appPinObscurepassText,
                          controller: _passController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(
                                r'[A-Za-z0-9@#$&*%! ]')), // Allowing certain characters
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password cannot be empty';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            if (value.length > 20) {
                              return 'Password must not exceed 20 characters';
                            }
                            if (!RegExp(r'^(?=.*[a-z])').hasMatch(value)) {
                              return 'Password must contain at least one lowercase letter';
                            }
                            if (!RegExp(r'^(?=.*[A-Z])').hasMatch(value)) {
                              return 'Password must contain at least one uppercase letter';
                            }
                            if (!RegExp(r'^(?=.*\d)').hasMatch(value)) {
                              return 'Password must contain at least one digit';
                            }
                            if (!RegExp(r'^(?=.*[@#$&*%!])').hasMatch(value)) {
                              return 'Password must contain at least one special character (@ # \$ & * % !)';
                            }
                            return null;
                          },
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                appPinObscurepassText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed:
                                  _toggleAppPinpassView, // Call the toggle method
                            ),
                            hintText: "Enter your password",
                            hintStyle: TextStyle(
                                fontFamily: 'GeneralSans',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Colors.grey),
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
                      SizedBox(
                        height: 12.5,
                      ),
                      Text(
                        "Confirm Password",
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 45,
                        child: TextFormField(
                          obscureText: appPinObscureconfirmpassText,
                          controller: _confirmpassController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(
                                r'[A-Za-z0-9@#$&*%! ]')), // Allowing certain characters
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password cannot be empty';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            if (value.length > 20) {
                              return 'Password must not exceed 20 characters';
                            }
                            if (!RegExp(r'^(?=.*[a-z])').hasMatch(value)) {
                              return 'Password must contain at least one lowercase letter';
                            }
                            if (!RegExp(r'^(?=.*[A-Z])').hasMatch(value)) {
                              return 'Password must contain at least one uppercase letter';
                            }
                            if (!RegExp(r'^(?=.*\d)').hasMatch(value)) {
                              return 'Password must contain at least one digit';
                            }
                            if (!RegExp(r'^(?=.*[@#$&*%!])').hasMatch(value)) {
                              return 'Password must contain at least one special character (@ # \$ & * % !)';
                            }
                            return null;
                          },
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                appPinObscureconfirmpassText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed:
                                  _toggleAppPinconfirmpassView, // ✅ fix here
                            ),
                            hintText: "Enter your confirm password",
                            hintStyle: TextStyle(
                                fontFamily: 'GeneralSans',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Colors.grey),
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
                      SizedBox(
                        height: 12.5,
                      ),
                    ],
                  ),
                  // Add padding to ensure the button is always visible above the keyboard
                  Padding(
                    padding: EdgeInsets.only(bottom: keyboardHeight + 80),
                    child: GestureDetector(
                      onTap: () {
                        showFavDialog(context);
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const ValidatecodePage(),
                        //   ),
                        // );
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

  // @override
  // void dispose() {
  //   pinController.dispose();
  //   super.dispose();
  // }
}
