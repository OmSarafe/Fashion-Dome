import 'package:ecommerence_project/BottomNavBar/bottom_nav_bar_page.dart';
import 'package:ecommerence_project/password/forgotpassword.dart';
import 'package:ecommerence_project/Signup/signup_page.dart';
import 'package:ecommerence_project/widgets/titlesubtitlewidget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool appPinObscureText = true; // add this line
  final _loginFormKey = GlobalKey<FormState>();
  void _toggleAppPinView() {
    // add this method
    setState(() {
      appPinObscureText = !appPinObscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(left: 15.0, top: 25, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleSubtitleText(
              title: "Login in your account",
              subtitle: "It’s great to see you again.",
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Email",
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
                  hintStyle: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(width: 0.5, color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 1.5),
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
            ),
            SizedBox(
              height: 20,
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
                      appPinObscureText
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.black,
                    ),
                    onPressed: () =>
                        _toggleAppPinView(), // Call the toggle method
                  ),
                  hintText: "Enter your password",
                  hintStyle: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(width: 0.5, color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 1.5),
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
            ),
            SizedBox(
              height: 12.5,
            ),
            Text.rich(
              TextSpan(
                text: "Forgot your password? ",
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                  fontSize: 14,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: "Reset your password",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration
                          .underline, // Underline the word "Terms"
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Forgotpassword()), // Replace SecondPage with your target widget
                        );
                      },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          BottomNavBar()), // Replace SecondPage with your target widget
                );
              },
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey),
                child: Center(
                  child: Text(
                    "Login",
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
            SizedBox(
              height: 17.5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Or',
                    style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0XFF808080)),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 17.5,
            ),
            GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) =>
                //           SignupPage()), // Replace SecondPage with your target widget
                // );
              },
              child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/google.svg', // Correct path for SVG image
                        height: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Login with Google",
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'GeneralSans',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  )),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) =>
                //           SignupPage()), // Replace SecondPage with your target widget
                // );
              },
              child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      // border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blueAccent),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/facebook.svg', // Correct path for SVG image
                        height: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Login with Facebook",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'GeneralSans',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  )),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Center(
          child: Text.rich(
            TextSpan(
              text: "Don’t have an account? ",
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w400,
                color: Colors.grey,
                fontSize: 16,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: "Join",
                  style: TextStyle(
                    color: Colors.black,
                    decoration:
                        TextDecoration.underline, // Underline the word "Terms"
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SignupPage()), // Replace SecondPage with your target widget
                      );
                    },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
