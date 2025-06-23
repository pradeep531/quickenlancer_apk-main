import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickenlancer_apk/editprofilepage.dart';

import 'BottomBar/bottom_bar.dart';
import 'Call/callpage.dart';
import 'Chat/chatpage.dart';
import 'Update Profile/tabs/update_profile_page.dart';
import 'edit_profile_page.dart';
import 'home_page.dart';

class ProfilePage2 extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage2> {
  int _selectedIndex = 4;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => const MyHomePage()),
      // );
    } else if (index == 2) {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => const Callpage()),
      // );
    } else if (index == 3) {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => const Chatpage()),
      // );
    } else if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage2()),
      );
    }
  }

  void _showLogoutConfirmation() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Are you sure you want to logout?',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      // Handle logout action here
                      Navigator.pop(context);
                      print("Logged out");
                    },
                    child: Text("Yes"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE5ACCB), // Pinkish color
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the bottom sheet
                    },
                    child: Text("Cancel"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey, // Grey color for cancel
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, // Font weight 600
            fontSize: 18, // Font size 18px
            height: 1.3, // Line height 130%
            letterSpacing: 0, // Letter spacing 0px
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFB7D7F9), // Light Blue
                Color(0xFFE5ACCB), // Pinkish
              ],
              stops: [0.0256, 0.9932], // Match the given percentage
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFB7D7F9), // Light Blue
                          Color(0xFFE5ACCB), // Pinkish
                        ],
                        stops: [0.0256, 0.9932], // Match the given percentage
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -60, // Half of the radius to overlap
                    child: Container(
                      padding:
                          EdgeInsets.all(4), // Adjust thickness of the border
                      decoration: BoxDecoration(
                        color: Colors.white, // Background color of the circle
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xFFE5ACCB), // Border color
                          width: 2, // Border thickness
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage('assets/profile_pic.png'),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 70), // Adjusted spacing
              Text(
                'Vaibhav Danve',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateProfilePage(
                        initialTab: 0,
                      ),
                    ),
                  );
                  print("Edit Profile tapped");
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/edit.png',
                        width: 25,
                        height: 25,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Edit Profile',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Color(0xFF424752),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  _showLogoutConfirmation(); // Show bottom sheet for logout confirmation
                  print("Logout tapped");
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.exit_to_app, // Logout icon
                        color: Color(0xFF424752),
                        size: 25,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Logout',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Color(0xFF424752),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
