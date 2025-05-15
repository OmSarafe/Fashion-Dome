import 'package:ecommerence_project/login_page.dart';
import 'package:ecommerence_project/widgets/titlesubtitlewidget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _textController = TextEditingController();
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0, top: 25, right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleSubtitleText(
                  title: "Create an account",
                  subtitle: "Let’s create your account.",
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Full Name",
                  style: TextStyle(
                    letterSpacing: 0,
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                SizedBox(
                  height: 45,
                  child: TextFormField(
                    controller: _textController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r"^[a-zA-Z ]+$")),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Field cannot be empty';
                      }
                      if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                        return 'Only alphabetic characters are allowed';
                      }
                      if (value.length < 5) {
                        return 'Name must be at least 5 characters';
                      }
                      if (value.length > 20) {
                        return 'Name must not exceed 20 characters';
                      }
                      return null;
                    },
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      hintText: "Enter your name",
                      hintStyle: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                        fontSize: 14,
                      ),
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
                        borderSide:
                            const BorderSide(color: Colors.red, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
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
                SizedBox(
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
                        borderSide:
                            const BorderSide(color: Colors.red, width: 2),
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
                SizedBox(
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
                Text.rich(
                  TextSpan(
                    text: "By signing up you agree to our ",
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      fontSize: 14,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: "Terms",
                        style: TextStyle(
                          decoration: TextDecoration
                              .underline, // Underline the word "Terms"
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Action for tapping "Terms"
                          },
                      ),
                      TextSpan(text: ", "),
                      TextSpan(
                        text: "Privacy Policy",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          // Underline the word "Privacy Policy"
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Action for tapping "Privacy Policy"
                          },
                      ),
                      TextSpan(text: ", and "),
                      TextSpan(
                        text: "Cookie Use.",
                        style: TextStyle(
                          decoration: TextDecoration
                              .underline, // Underline the word "Cookie Use"
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Action for tapping "Cookie Use"
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
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey),
                    child: Center(
                      child: Text(
                        "Create an Account",
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
                          color: Colors.grey,
                        ),
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
                            "Sign Up with Google",
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
                            "Sign Up with Facebook",
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
                Center(
                  child: Text.rich(
                    TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: "Log In",
                          style: TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration
                                .underline, // Underline the word "Terms"
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        LoginPage()), // Replace SecondPage with your target widget
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
