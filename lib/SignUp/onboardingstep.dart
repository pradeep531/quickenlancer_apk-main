import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Colors/colorfile.dart';
import 'onboardingStep2.dart';
import 'signIn.dart';

class OnboardingSignup extends StatefulWidget {
  const OnboardingSignup({Key? key}) : super(key: key);

  @override
  _OnboardingSignUpScreenState createState() => _OnboardingSignUpScreenState();
}

class _OnboardingSignUpScreenState extends State<OnboardingSignup> {
  bool isLookingForHire = true;
  bool _isContainerVisible = false;

  Widget _buildCheckCircle(bool isSelected) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? Colorfile.primaryColor : Color(0xFFD5D5D5),
      ),
      child: isSelected
          ? const Icon(
              Icons.check,
              size: 16,
              color: Colors.white,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colorfile.body,
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
      body: Container(
        color: Colorfile.body,
        child: SafeArea(
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
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Welcome to Onboarding Process.",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colorfile.textColor,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Looking for Hire
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isLookingForHire = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFB7D7F9),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/looking_for_hire.png',
                          width: 83,
                          height: 77,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Looking For Hire",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Effortlessly find top freelancers or agencies for your projects. Get instant proposals, and hire with verified experts.",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colorfile.lightText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildCheckCircle(isLookingForHire),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Looking for Project
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isLookingForHire = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFB7D7F9),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/looking_for_project.png',
                          width: 83,
                          height: 77,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Looking For Project",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Showcase your skills and connect with top clients. Whether you're a freelancer or a company, find matching projects, bid instantly, and communicate in real time—all in one place.",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colorfile.lightText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildCheckCircle(!isLookingForHire),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Next Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OnboardingSignUp2(),
                        ),
                      );
                      // TODO: Implement next screen navigation
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => NextScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colorfile.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "NEXT",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colorfile.darkgrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => SignUpPage(),
                        //   ),
                        // );
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
                          fontSize: 12,
                          color: Colorfile.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
