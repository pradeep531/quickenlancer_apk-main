import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import 'package:quickenlancer_apk/SignUp/signIn.dart';
import 'package:quickenlancer_apk/home_page.dart';

import 'onboarding_screen1.dart';
import 'onboarding_screen2.dart';
import 'onboarding_screen3.dart';

class OnboardingMain extends StatefulWidget {
  @override
  _OnboardingMainState createState() => _OnboardingMainState();
}

class _OnboardingMainState extends State<OnboardingMain> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  void _onNext() {
    if (_currentPage < 2) {
      _controller.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MyHomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  OnboardingScreen1(currentPage: _currentPage),
                  OnboardingScreen2(currentPage: _currentPage),
                  OnboardingScreen3(currentPage: _currentPage),
                ],
              ),
            ),
            if (_currentPage == 2)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: GestureDetector(
                  onTap: () {
                    _finishOnboarding();
                  },
                  child: Container(
                    width: screenWidth * 0.5,
                    height: screenWidth * 0.12,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFB7D7F9), Color(0xFFE5ACCB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        width: 1.5,
                        color: Colors
                            .transparent, // Border color is set to transparent for gradient effect
                      ),
                      borderRadius:
                          BorderRadius.circular(25), // Rounded corners
                    ),
                    child: Center(
                      child: Text(
                        'Get Started',
                        style: GoogleFonts.poppins(
                          color: Colorfile.textColor, // Text color
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Hide the Skip button on the last page
                if (_currentPage != 2)
                  GestureDetector(
                    onTap: _finishOnboarding,
                    child: Container(
                      width: screenWidth * 0.3,
                      height: screenWidth * 0.12,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          width: 1.5,
                          color: Color(0xFFE5ACCB),
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          "Skip",
                          style: GoogleFonts.poppins(
                            color: Colorfile.textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                // Hide the Tick icon on the last page
                if (_currentPage != 2)
                  GestureDetector(
                    onTap: _onNext,
                    child: Container(
                      width: screenWidth * 0.15,
                      height: screenWidth * 0.12,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFB7D7F9), Color(0xFFE5ACCB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: Colorfile.textColor,
                        size: 30,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(
                height: screenHeight *
                    0.05), // Add padding here for more space from bottom
          ],
        ),
      ),
    );
  }
}
