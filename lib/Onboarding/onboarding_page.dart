import 'package:ecommerence_project/Signup/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white, // White background
      statusBarIconBrightness: Brightness.dark, // Black icons for Android
      statusBarBrightness: Brightness.light, // Required for iOS
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 30,
            left: 20,
            child: Text(
                style: GoogleFonts.manrope(
                    wordSpacing: 1, fontSize: 56, fontWeight: FontWeight.w900),
                "Define"),
          ),
          Positioned(
            top: 72.5,
            left: 20,
            child: Text(
                style: GoogleFonts.manrope(
                    wordSpacing: 1, fontSize: 52, fontWeight: FontWeight.w900),
                "yourself in"),
          ),
          Positioned(
            top: 117.5,
            left: 20,
            child: Text(
                style: GoogleFonts.manrope(
                    wordSpacing: 1, fontSize: 52, fontWeight: FontWeight.w900),
                "your unique"),
          ),
          Positioned(
            top: 162.5,
            left: 20,
            child: Text(
                style: GoogleFonts.manrope(
                    wordSpacing: 1, fontSize: 52, fontWeight: FontWeight.w900),
                "way."),
          ),
          Positioned(
            top: 100,
            child: Image.asset(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.88,
              "assets/onboardinglines.png",
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            top: 45,
            right: 0,
            child: Image.asset(
              // width: MediaQuery.of(context).size.width,
              // height: MediaQuery.of(context).size.height * 0.88,
              "assets/person.png",
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      SignupPage()), // Replace SecondPage with your target widget
            );
          },
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.black),
            child: Row(
              children: [
                Expanded(child: Container()),
                Text(
                  "Get Started ",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
