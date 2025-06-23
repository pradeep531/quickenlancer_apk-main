import 'package:flutter/material.dart';
import 'package:quickenlancer_apk/PostProject/post_project.dart';
import 'package:quickenlancer_apk/SignUp/signIn.dart';
import 'package:quickenlancer_apk/hire_company.dart';
import 'package:quickenlancer_apk/myconnection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Billing/billing_page.dart';
import 'Hire Freelancer/hire_freelancer.dart';
import 'notifications.dart';

class SideBarDrawer extends StatefulWidget {
  @override
  _SideBarDrawerState createState() => _SideBarDrawerState();
}

class _SideBarDrawerState extends State<SideBarDrawer> {
  String profilePicPath = '';
  String _firstName = '';
  String _lastName = '';
  int? isLoggedIn;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getInt('is_logged_in');
      profilePicPath = prefs.getString('profile_pic_path') ?? '';
      _firstName = prefs.getString('first_name') ?? '';
      _lastName = prefs.getString('last_name') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Drawer(
      width: screenWidth * 0.75,
      child: Container(
        color: Color(0xFF242424),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.black,
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.08,
                    bottom: screenHeight * 0.07,
                  ),
                ),
                Positioned(
                  bottom: -screenHeight * 0.08,
                  left: screenWidth * 0.450 - (screenWidth * 0.3),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black,
                            width: screenWidth * 0.025,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF509AC7),
                                Color(0xFF88398D),
                                Color(0xFFBA1A85),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          padding: EdgeInsets.all(screenWidth * 0.006),
                          child: CircleAvatar(
                            radius: screenWidth * 0.12, // Responsive radius
                            backgroundColor: Colors.black,
                            child: CircleAvatar(
                              radius: screenWidth * 0.098,
                              backgroundImage: profilePicPath.isNotEmpty
                                  ? NetworkImage(profilePicPath)
                                  : AssetImage('assets/profile_pic.png')
                                      as ImageProvider,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        _firstName.isEmpty && _lastName.isEmpty
                            ? 'Not Available'
                            : '$_firstName $_lastName'.trim(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.05, // Responsive font size
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: screenHeight * 0.10),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  SideBarItem(
                    text: 'Home',
                    onTap: () {},
                  ),
                  SideBarItem(
                    text: 'My Projects',
                    onTap: () {},
                  ),
                  SideBarItem(
                    text: 'Search Project',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InviteFriends()),
                      );
                    },
                  ),
                  SideBarItem(
                    text: 'Post Project',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PostProject()),
                      );
                    },
                  ),
                  SideBarItem(
                    text: 'Hire Freelancer',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HireFreelancer()),
                      );
                    },
                  ),
                  SideBarItem(
                    text: 'Hire Company',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HireCompany()),
                      );
                    },
                  ),
                  SideBarItem(
                    text: 'Billing',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BillingPage()),
                      );
                    },
                  ),
                  SideBarItem(
                    text: 'Notification',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationPage()),
                      );
                    },
                  ),
                  SideBarItem(
                    text: 'Logout',
                    onTap: () {
                      _showLogoutConfirmation(context);
                    },
                  ),
                ],
              ),
            ),
            Container(
              height: screenHeight * 0.2, // Responsive height
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF242424),
                    Color(0xFF242424),
                  ],
                ),
                image: DecorationImage(
                  image: AssetImage('assets/appicon.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment(0.5, -1.5),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1.0, 0.0),
                    end: Alignment(1.5, 0.0),
                    colors: [
                      Color(0xFF242424),
                      Color.fromRGBO(34, 34, 34, 0),
                    ],
                    stops: [0.0, 0.8],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.12),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        height: screenHeight * 0.025,
                      ),
                      SizedBox(height: screenHeight * 0.006),
                      Text(
                        '© 2025 Quickenlancer. All rights reserved.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: screenWidth * 0.02,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: EdgeInsets.all(screenWidth * 0.03),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2C2C2C), Color(0xFF181818)],
            ),
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: screenWidth * 0.03,
                offset: Offset(0, screenHeight * 0.007),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: screenHeight * 0.015),
                height: screenHeight * 0.005,
                width: screenWidth * 0.08,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Confirm Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Are you sure you want to log out?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: screenWidth * 0.035,
                  height: 1.4,
                ),
              ),
              SizedBox(height: screenHeight * 0.025),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.clear();
                          Navigator.pop(context);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignInPage()),
                            (Route<dynamic> route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE53935),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.015),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.025),
                          ),
                          elevation: 3,
                          shadowColor: Colors.black.withOpacity(0.3),
                        ),
                        child: Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.025),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: Colors.grey[700]!,
                              width: screenWidth * 0.004),
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.015),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.025),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.025),
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF313131),
            width: 1,
          ),
        ),
        color: Color(0xFF242424),
      ),
      child: ListTile(
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: screenWidth * 0.005),
          ),
          padding: EdgeInsets.all(screenWidth * 0.007),
          child: Icon(Icons.circle,
              color: Colors.transparent, size: screenWidth * 0.025),
        ),
        title: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.03,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
