import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import 'package:quickenlancer_apk/SignUp/forgotPassword.dart';
import 'package:quickenlancer_apk/SignUp/signIn.dart';
import 'package:quickenlancer_apk/SignUp/signup.dart';
import 'package:quickenlancer_apk/home_page.dart';

class Newpassword extends StatefulWidget {
  @override
  _NewpasswordPageState createState() => _NewpasswordPageState();
}

class _NewpasswordPageState extends State<Newpassword> {
  @override
  Widget build(BuildContext context) {
    // Get screen size from MediaQuery
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Adjust the top padding based on screen height
                SizedBox(height: screenHeight * 0.25),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Create New Password',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colorfile.textColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Create your new password to login',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colorfile.morelightgrey,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                buildCustomTextField(
                    "Enter New Password", "Enter Your New Password"),
                buildCustomTextField("Confirmed Password", "Confirmed Password",
                    isPassword: true),

                SizedBox(height: screenHeight * 0.02),

                SizedBox(height: screenHeight * 0.01),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyHomePage(),
                        ),
                      );
                    },
                    child: Text(
                      'Continue',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colorfile.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Custom TextField Design
  Widget buildCustomTextField(String label, String hintText,
      {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colorfile.textColor,
            ),
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colorfile.lightgrey,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colorfile.lightgrey), // Border color
                borderRadius: BorderRadius.circular(4),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colorfile.lightgrey),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
