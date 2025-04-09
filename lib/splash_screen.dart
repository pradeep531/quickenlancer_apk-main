import 'package:flutter/material.dart';
import 'dart:async';
import 'package:quickenlancer_apk/Onboarding/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added SharedPreferences import

import 'home_page.dart'; // Add this import for MyHomePage

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _flipAnimation;
  bool _showSplash = false;
  bool _hideLogo = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _checkLoginStatus(); // Call the login status check
  }

  Future<void> _checkLoginStatus() async {
    // Get SharedPreferences instance
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? isLoggedIn = prefs.getInt('is_logged_in');

    _animationController.forward();

    _animationController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showSplash = true;
          _hideLogo = true;
        });

        Timer(const Duration(seconds: 2), () {
          // Check if user is logged in
          if (isLoggedIn == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MyHomePage(), // Navigate to HomePage if logged in
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OnboardingMain(),
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_showSplash)
              Image.asset(
                'assets/logo3.png',
                width: screenWidth * 1,
                height: screenHeight * 0.9,
                fit: BoxFit.contain,
              ),
            if (!_hideLogo)
              AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  return Transform(
                    transform: Matrix4.rotationY(_flipAnimation.value * 3.14),
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/logo2.png',
                      width: screenWidth * 2,
                      height: screenHeight * 1.5,
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
