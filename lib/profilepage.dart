import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickenlancer_apk/editprofilepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'BottomBar/bottom_bar.dart';
import 'Call/callpage.dart';
import 'Chat/chatpage.dart';
import 'Update Profile/tabs/update_profile_page.dart';
import 'edit_profile_page.dart';
import 'home_page.dart';

class ProfilePage2 extends StatefulWidget {
  const ProfilePage2({super.key}); // Added const constructor for consistency

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage2> {
  int _selectedIndex = 4;
  int? isLoggedIn;
  String profilePicPath = '';

  @override
  void initState() {
    super.initState();
    _initializeData(); // Call initializeData in initState
  }

  Future<void> _initializeData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getInt('is_logged_in'); // Store as int?
      profilePicPath = prefs.getString('profile_pic_path') ?? '';
    });
    await _loadPreferences();
    await _fetchProjects();
  }

  Future<void> _loadPreferences() async {
    // Implement your preferences loading logic here
  }

  Future<void> _fetchProjects() async {
    // Implement your project fetching logic here
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Buycallpage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Buychatpage()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage2()),
        );
        break;
      default:
        break;
    }
  }

  void _showLogoutConfirmation() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      // Handle logout action here
                      Navigator.pop(context);
                      print("Logged out");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE5ACCB), // Pinkish color
                    ),
                    child: const Text("Yes"),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the bottom sheet
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey, // Grey color for cancel
                    ),
                    child: const Text("Cancel"),
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
            fontWeight: FontWeight.w600,
            fontSize: 18,
            height: 1.3,
            letterSpacing: 0,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFB7D7F9), // Light Blue
                Color(0xFFE5ACCB), // Pinkish
              ],
              stops: [0.0256, 0.9932],
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(),
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
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFB7D7F9), // Light Blue
                          Color(0xFFE5ACCB), // Pinkish
                        ],
                        stops: [0.0256, 0.9932],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -60,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xFFE5ACCB),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: profilePicPath.isNotEmpty
                            ? NetworkImage(profilePicPath)
                            : const AssetImage('assets/profile_pic.png')
                                as ImageProvider,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 70),
              const Text(
                'Vaibhav Danve',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UpdateProfilePage(
                        initialTab: 0,
                      ),
                    ),
                  );
                  print("Edit Profile tapped");
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/edit.png',
                        width: 25,
                        height: 25,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Edit Profile',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: const Color(0xFF424752),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _showLogoutConfirmation();
                  print("Logout tapped");
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.exit_to_app,
                        color: Color(0xFF424752),
                        size: 25,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Logout',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: const Color(0xFF424752),
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
        duration: const Duration(milliseconds: 300),
        child: MyBottomBar(
          key: ValueKey<int>(_selectedIndex),
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
          isLoggedIn: isLoggedIn,
        ),
      ),
    );
  }
}
