import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickenlancer_apk/BottomBar/bottom_bar.dart';
import 'package:quickenlancer_apk/Call/callpage.dart';
import 'package:quickenlancer_apk/Chat/buychat.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import 'package:quickenlancer_apk/home_page.dart';
import 'package:quickenlancer_apk/editprofilepage.dart';

class Chatpage extends StatefulWidget {
  const Chatpage({super.key});

  @override
  _ChatpageState createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {
  int _selectedIndex = 3;
  bool _isChecked1 = false;
  bool _isChecked2 = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    }
    if (index == 2) {
      // Check if the 3rd index is selected
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const Callpage()), // Navigate to the new page
      );
    }
    if (index == 4) {
      // Check if the 3rd index is selected
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const Editprofilepage()), // Navigate to the new page
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF), // Applying the color
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF), // Applying the color
        title: Text(
          'Unlock Your Chat',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 23.4 /
                18, // line-height: 23.4px (calculated as height/line-height)
            textBaseline: TextBaseline.alphabetic,
            letterSpacing: 0, // for no text-underline-position
            color: Colorfile.textColor, // Applying the color
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Container just below the AppBar, no gap
            Container(
              width: double.infinity, // Full width
              height: 75,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFB7D7F9), Color(0xFFE5ACCB)],
                  stops: [0.0256, 0.9932], // gradient angles
                ),
              ),
              child: Text(
                'By unlocking chat you can easily chat with [person name].',
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 26 / 15, // line-height: 26px
                  decoration: TextDecoration.none,
                  color: Colors.black,
                ),
              ),
            ),
            // New container with checkmark items
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(
                  vertical: 10, horizontal: 15), // Added margin
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Feature 1
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isChecked1 = !_isChecked1;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            10), // Border radius for feature
                        border: Border.all(
                          color: Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40, // Avatar size width
                          height: 40, // Avatar size height
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFB7D7F9),
                                Color(0xFFE5ACCB),
                              ], // Gradient colors
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ClipOval(
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  6.0), // Padding inside the circle
                              child: Image.asset(
                                'assets/chat.png', // Replace with your PNG file path
                                fit: BoxFit
                                    .cover, // Make sure the image covers the circle
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          'Buy Chat for this Project',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 20 / 13, // Line height based on font size
                            letterSpacing: 0.01,
                            color: Colorfile.textColor,
                            decoration: TextDecoration
                                .none, // To ensure no text decoration
                          ),
                        ),
                        subtitle: Text(
                          'You can buy a chat just for this project.',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            height: 20 / 11, // Line height based on font size
                            decoration: TextDecoration
                                .none, // To ensure no text decoration
                          ),
                        ),
                        trailing: Checkbox(
                          value: _isChecked1,
                          onChanged: (bool? value) {
                            setState(() {
                              _isChecked1 = value ?? false;
                            });
                          },
                          activeColor: Colors.green, // Green color when checked
                          checkColor: Colors.white, // White tick when checked
                          fillColor:
                              MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.green; // Green color when selected
                            }
                            return Color(
                                0xFFD9D9D9); // Transparent when not selected, no border
                          }),
                          shape: CircleBorder(), // Make the checkbox round
                          side: BorderSide.none, // Remove border
                        ),
                      ),
                    ),
                  ),
                  // Feature 2
                  SizedBox(height: 10), // Added space between features
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isChecked2 = !_isChecked2;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            10), // Border radius for feature
                        border: Border.all(
                          color: Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40, // Avatar size width
                          height: 40, // Avatar size height
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFB7D7F9),
                                Color(0xFFE5ACCB),
                              ], // Gradient colors
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ClipOval(
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  6.0), // Padding inside the circle
                              child: Image.asset(
                                'assets/chat.png', // Replace with your PNG file path
                                fit: BoxFit
                                    .cover, // Make sure the image covers the circle
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          'Buy hassle free chat for multiple projects',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 20 / 13, // Line height based on font size
                            letterSpacing: 0.01,
                            color: Colorfile.textColor,
                            decoration: TextDecoration
                                .none, // To ensure no text decoration
                          ),
                        ),
                        subtitle: Text(
                          'Simplify payments with a chat bundle avoid multiple transactions.',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            height: 20 / 11, // Line height based on font size
                            decoration: TextDecoration
                                .none, // To ensure no text decoration
                          ),
                        ),
                        trailing: Checkbox(
                          value: _isChecked2,
                          onChanged: (bool? value) {
                            setState(() {
                              _isChecked2 = value ?? false;
                            });
                          },
                          activeColor: Colors.green, // Green color when checked
                          checkColor: Colors.white, // White tick when checked
                          fillColor:
                              MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.green; // Green color when selected
                            }
                            return Color(
                                0xFFD9D9D9); // Transparent when not selected, no border
                          }),
                          shape: CircleBorder(), // Make the checkbox round
                          side: BorderSide.none, // Remove border
                        ),
                      ),
                    ),
                  ),
                  // New container below second GestureDetector
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                        decoration: BoxDecoration(
                          color: Color(0xFFFAF8D6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Warning: ',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight
                                      .bold, // Make only "Warning" bold
                                  color: Colorfile.textColor,
                                ),
                              ),
                              TextSpan(
                                text:
                                    'Your profile is currently incomplete with regard to KYC, and this could potentially result in a negative impact, leading to it being labeled as unverified by the project owner. We kindly ask you to undergo the KYC process for completion.',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colorfile.textColor,
                                  height: 1.5, // Adjust the line height here
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity, // Ensures button is full width
                        height: 48,
                        child: CupertinoButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const Buychat()), // Navigate to the new page
                            );
                            // Action to perform when the button is pressed
                          },
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          color: Colorfile.textColor, // Background color
                          borderRadius: BorderRadius.circular(8),
                          child: Text(
                            'Unlock Your Chat Now',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Other widgets go here
          ],
        ),
      ),
      bottomNavigationBar: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: MyBottomBar(
          key: ValueKey<int>(_selectedIndex),
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}
