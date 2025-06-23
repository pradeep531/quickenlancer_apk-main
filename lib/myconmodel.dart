import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';

class Myconnection extends StatelessWidget {
  final String name;
  final String designation;
  final String project;
  final VoidCallback onChatPressed;

  Myconnection({
    required this.name,
    required this.designation,
    required this.project,
    required this.onChatPressed,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.01,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 0.8,
              color: Color(0xFFDDDDDD),
            ),
          ),
        ),
        child: SizedBox(
          height: screenHeight * 0.1,
          child: Stack(
            children: [
              Positioned(
                top: screenHeight * 0.02,
                left: screenWidth * 0,
                child: Row(
                  children: [
                    Container(
                      width: 53,
                      height: 53,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xFFD9D9D9),
                          width: 1,
                        ),
                        image: DecorationImage(
                          image: AssetImage('assets/profile_pic.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            letterSpacing: 0.02,
                            color: Color(0xFF424752),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          designation,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            letterSpacing: 0.02,
                            color: Color(0xFF424752),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          project,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            letterSpacing: 0.02,
                            color: Color(0xFF424752),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: screenWidth * 0.04,
                top: 0,
                bottom: 0, // Center vertically using top:0 and bottom:0
                child: Center(
                  child: ElevatedButton(
                    onPressed: onChatPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colorfile.textColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        side: BorderSide(
                          width: 1.0,
                          color: Colorfile.textColor,
                        ),
                      ),
                      minimumSize: Size(60, 32), // More reasonable button size
                    ),
                    child: Text(
                      'Chat',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
