import 'package:flutter/material.dart';
import 'package:quickenlancer_apk/PostProject/post_project.dart';
import 'package:quickenlancer_apk/PostProject/posted_projects.dart';
import 'package:quickenlancer_apk/SignUp/signIn.dart';
import 'package:quickenlancer_apk/myconnection.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this for SharedPreferences
import 'notifications.dart';

class SideBarDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color(0xFF242424),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Image.asset(
                    'assets/logo.png',
                    height: 50,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
            SideBarItem(
                text: 'Search Project',
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => InviteFriends()),
                  // );
                }),
            SideBarItem(
                text: 'Hire Freelancer',
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => InviteFriends()),
                  // );
                }),
            SideBarItem(
                text: 'My Connection',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InviteFriends()),
                  );
                }),
            SideBarItem(
                text: 'Notifications',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationPage()),
                  );
                }),
            SideBarItem(
                text: 'Post Project',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PostProject()),
                  );
                }),
            SideBarItem(
                text: 'Posted Projects',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PostedProjects()),
                  );
                }),
            SideBarItem(
              text: 'Logout',
              onTap: () {
                _showLogoutConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF242424),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Confirm Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Are you sure you want to logout?',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Clear SharedPreferences and navigate to signup
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.clear(); // Clears all preferences
                      Navigator.pop(context); // Close bottom sheet
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SignInPage()), // Replace with your signup page class
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: Text(
                      'Yes',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close bottom sheet
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: Text(
                      'No',
                      style: TextStyle(color: Colors.white),
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
}

class SideBarItem extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const SideBarItem({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                padding: EdgeInsets.all(3),
                child: Icon(Icons.circle, color: Colors.transparent, size: 10),
              ),
              SizedBox(width: 10),
              Text(text, style: TextStyle(color: Colors.white)),
            ],
          ),
          onTap: onTap,
        ),
        Divider(color: Colors.black),
      ],
    );
  }
}
