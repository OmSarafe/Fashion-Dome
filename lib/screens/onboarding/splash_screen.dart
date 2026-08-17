import 'package:ecommerence_project/screens/navigation/bottom_nav_bar_page.dart';
import 'package:ecommerence_project/screens/auth/login_page.dart';
import 'package:ecommerence_project/services/auth_service.dart';
import 'package:ecommerence_project/services/onboarding_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ecommerence_project/screens/onboarding/onboarding_page.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black, // White background
      statusBarIconBrightness: Brightness.light, // Black icons for Android
      statusBarBrightness: Brightness.dark, // Required for iOS
    ));

    _openNextScreen();
  }

  Future<void> _openNextScreen() async {
    await Future<void>.delayed(const Duration(seconds: 3));

    final currentUser = AuthService().currentUser;
    final hasSeenOnboarding = await OnboardingService().hasSeenOnboarding();

    if (!mounted) return;
    final Widget destination;
    if (currentUser != null) {
      destination = BottomNavBar();
    } else if (hasSeenOnboarding) {
      destination = const LoginPage();
    } else {
      destination = const OnBoarding();
    }

    Navigator.of(context).pushReplacement(_createFadeRoute(destination));
  }

  Route _createFadeRoute(Widget destination) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 800),
      pageBuilder: (context, animation, secondaryAnimation) => destination,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Image.asset(
            "assets/splashcreen1.png",
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fill,
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/splashscreen2.png",
            ),
          ),
        ],
      ),
    );
  }
}
