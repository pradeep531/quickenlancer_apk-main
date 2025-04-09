import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen3 extends StatelessWidget {
  final int currentPage;

  OnboardingScreen3({required this.currentPage});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05), // Padding for responsiveness
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/onboarding2.png', height: 300),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(
                    horizontal: 4), // Adjusted spacing between dots
                height: 8, // Thinner height for the dots
                width: currentPage == index
                    ? 60
                    : 8, // Thinner and larger active dot
                decoration: BoxDecoration(
                  color: currentPage == index
                      ? Color(0xFFB7D7F9) // Active dot color changed to #B7D7F9
                      : Colors.grey
                          .withOpacity(0.5), // Inactive dot color remains grey
                  borderRadius: BorderRadius.circular(
                      6), // Rounded corners for smoother look
                  boxShadow: [
                    if (currentPage == index)
                      BoxShadow(
                        color: Color(0xFFB7D7F9).withOpacity(0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                        offset: Offset(0, 2),
                      ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 20),
          Text(
            "Hire & Engage Directly",
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF466AA5),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            "Connect and start your collaboration seamlessly. Start your project today and achieve exceptional results through efficient and effective hiring.",
            style: GoogleFonts.montserrat(fontSize: 16, height: 1.5),
            textAlign: TextAlign.center,
          ),
          // Progress Dots (below image)
          SizedBox(height: 20), // Space between text and dots
          // Progress Dots (below image)
        ],
      ),
    );
  }
}
