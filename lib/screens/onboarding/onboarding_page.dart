import 'package:ecommerence_project/screens/auth/signup_page.dart';
import 'package:ecommerence_project/services/onboarding_service.dart';
import 'package:ecommerence_project/utils/responsive_layout.dart';
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
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFF7F5F2),
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compactHeight = constraints.maxHeight < 650;
            final titleSize = constraints.maxWidth < 360
                ? 39.0
                : constraints.maxWidth < 600
                    ? 50.0
                    : 62.0;
            final horizontal = ResponsiveLayout.horizontalPadding(
              constraints.maxWidth,
            );

            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  top: compactHeight ? 90 : 130,
                  child: Image.asset(
                    'assets/onboardinglines.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth < 600
                          ? constraints.maxWidth * 0.88
                          : 560,
                      maxHeight:
                          constraints.maxHeight * (compactHeight ? 0.70 : 0.78),
                    ),
                    child: Image.asset(
                      'assets/person.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned(
                  left: horizontal,
                  right: horizontal,
                  top: compactHeight ? 8 : 20,
                  child: Text(
                    'Define yourself in\nyour unique way.',
                    style: GoogleFonts.manrope(
                      color: Colors.black,
                      fontSize: titleSize,
                      height: 0.91,
                      letterSpacing: -2.2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: ColoredBox(
          color: const Color(0xFFF7F5F2),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: () async {
                      await OnboardingService().markOnboardingAsSeen();
                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SignupPage()),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text(
                      'Get Started',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
