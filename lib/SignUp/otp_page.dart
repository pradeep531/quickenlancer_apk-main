import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import 'package:quickenlancer_apk/SignUp/newpassword.dart';
import 'package:quickenlancer_apk/SignUp/signup.dart';
import 'package:quickenlancer_apk/home_page.dart';
import 'package:pinput/pinput.dart'; // Import the pinput package

class OtpPage extends StatefulWidget {
  @override
  _OtpPagePageState createState() => _OtpPagePageState();
}

class _OtpPagePageState extends State<OtpPage> {
  @override
  Widget build(BuildContext context) {
    // Get screen size from MediaQuery
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpg', // Replace with your image asset
              fit: BoxFit.fill, // Makes sure the image covers the whole screen
            ),
          ),

          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Adjust the top padding based on screen height
                  SizedBox(height: screenHeight * 0.2),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Enter Verification Code?',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colorfile.textColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      'Enter code that we have sent to your email ID',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colorfile.morelightgrey,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.06),

                  // Center the Pinput widget
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Pinput(
                        length: 4, // 4 fields
                        defaultPinTheme: PinTheme(
                          width: 50, // Width of each square
                          height: 50, // Height of each square
                          textStyle: TextStyle(fontSize: 20),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(4), // Border radius
                            border: Border.all(
                              color: Color(0xFF757575), // Border color
                            ),
                          ),
                          // Adjust margin to add spacing between fields
                          margin: EdgeInsets.symmetric(
                              horizontal: 8), // Adjust spacing
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.05),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Newpassword(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colorfile.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        minimumSize: Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        'Reset Password',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn’t receive the code? ",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colorfile.lightgrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Handle the SignUp action
                        },
                        child: Text(
                          "Resend",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colorfile
                                .darkPrimary, // You can change this color to make it look like a link
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
