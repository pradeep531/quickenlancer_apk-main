import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import 'package:quickenlancer_apk/SignUp/signIn.dart';
import 'package:quickenlancer_apk/home_page.dart';

class Signupcompany extends StatefulWidget {
  @override
  _SignUpCompanyPageState createState() => _SignUpCompanyPageState();
}

class _SignUpCompanyPageState extends State<Signupcompany> {
  bool _isContainerVisible = false;
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Sign Up",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colorfile.body,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isContainerVisible = !_isContainerVisible;
                  });
                },
                child: Container(
                  height: 60,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFFB7D7F9),
                        Color(0xFFE5ACCB),
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Looking for hire?",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colorfile.textColor,
                        ),
                      ),
                      Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colorfile.textColor, width: 1),
                        ),
                        child: Center(
                          child: Transform.rotate(
                            angle: _isContainerVisible ? 1.58 : 4.67,
                            child: Icon(
                              Icons.chevron_right,
                              color: Colorfile.textColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Register As Company',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colorfile.textColor,
                  ),
                ),
              ),
              buildCustomTextField("Name", "Enter Your Name"),
              buildCustomTextField("Email ID", "Enter Your Email"),
              buildCustomTextField("Password", "Create Password",
                  isPassword: true),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  Transform.scale(
                    scale: 0.8,
                    child: Checkbox(
                      value: false,
                      onChanged: (value) {},
                    ),
                  ),
                  Text(
                    'By signing up, you agree to our terms of use and\nprivacy policy.',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: Colorfile.textColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyHomePage(),
                      ),
                    );
                  },
                  child: Text(
                    'Next',
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
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Or',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colorfile.lightgrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: ClipOval(
                      child: Image.asset(
                        'assets/google.png',
                        width: screenWidth * 0.08,
                        height: screenWidth * 0.08,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  GestureDetector(
                    onTap: () {},
                    child: ClipOval(
                      child: Image.asset(
                        'assets/facebook.png',
                        width: screenWidth * 0.08,
                        height: screenWidth * 0.08,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  GestureDetector(
                    onTap: () {},
                    child: ClipOval(
                      child: Image.asset(
                        'assets/linkedin.png',
                        width: screenWidth * 0.08,
                        height: screenWidth * 0.08,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: Colorfile.darkgrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignInPage(),
                        ),
                      );
                    },
                    child: Text(
                      "SignIn",
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colorfile.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

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
                borderSide: BorderSide(color: Colorfile.lightgrey),
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
