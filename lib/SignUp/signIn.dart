import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import 'package:quickenlancer_apk/SignUp/forgotPassword.dart';
import 'package:quickenlancer_apk/SignUp/signup.dart';
import 'package:quickenlancer_apk/home_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../api/network/uri.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Error message variables
  String? _emailError;
  String? _passwordError;
  bool _isLoading = false; // Add loading state

  // Function to validate inputs
  bool _validateInputs() {
    setState(() {
      _emailError = null;
      _passwordError = null;

      if (_emailController.text.isEmpty) {
        _emailError = 'Email cannot be empty';
      } else if (!_emailRegExp.hasMatch(_emailController.text)) {
        _emailError = 'Please enter a valid email address';
      }

      if (_passwordController.text.isEmpty) {
        _passwordError = 'Password cannot be empty';
      }
    });

    return _emailError == null && _passwordError == null;
  }

  Future<void> signIn() async {
    if (!_validateInputs()) {
      return;
    }

    setState(() {
      _isLoading = true; // Show loader
    });

    final String url = URLS().agent_login_apiUrl;
    final requestBody = jsonEncode({
      "email": _emailController.text,
      "password": _passwordController.text,
    });

    log('Request body: $requestBody');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      print('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('is_logged_in', 1);

        // Print the stored value
        int? isLoggedIn = prefs.getInt('is_logged_in');
        print('Shared Preference is_logged_in set to: $isLoggedIn');

        showDialog(
          context: context,
          barrierDismissible: false, // Prevents tapping outside to dismiss
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async =>
                  false, // Prevents back button from dismissing
              child: AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                contentPadding: EdgeInsets.all(20),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 50,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Success',
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Login successful!\nRedirecting to homepage...',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                elevation: 8,
              ),
            );
          },
        );

        await Future.delayed(Duration(seconds: 2));
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      } else {
        setState(() {
          _emailError = 'Login failed. Please check your credentials';
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _emailError = 'An error occurred. Please try again';
      });
    } finally {
      setState(() {
        _isLoading = false; // Hide loader
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                SizedBox(height: screenHeight * 0.1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Sign In',
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
                    'Sign In To Your Account',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colorfile.textColor,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Email ID',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: '',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.7),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (_emailError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            _emailError!,
                            style: GoogleFonts.montserrat(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Password',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: '',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.7),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (_passwordError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            _passwordError!,
                            style: GoogleFonts.montserrat(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  children: [
                    Transform.scale(
                      scale: 0.8,
                      child: Checkbox(
                        value: true,
                        onChanged: (value) {},
                      ),
                    ),
                    Text(
                      'Remember me',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: Colorfile.textColor,
                      ),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Forgotpassword(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerRight,
                      ),
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          height: 16.5 / 11,
                          letterSpacing: 0.5,
                          color: Colorfile.textColor,
                        ).copyWith(
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.solid,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: screenHeight * 0.05),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : signIn, // Disable button when loading
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colorfile.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Sign In',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
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
                SizedBox(height: screenHeight * 0.08),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
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
                            builder: (context) => SignUpPage(),
                          ),
                        );
                      },
                      child: Text(
                        "SignUp",
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
      ),
    );
  }
}
