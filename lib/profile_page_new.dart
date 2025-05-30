import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:quickenlancer_apk/BottomBar/bottom_bar.dart';
import 'package:quickenlancer_apk/Call/callpage.dart';
import 'package:quickenlancer_apk/Chat/chatpage.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import 'package:quickenlancer_apk/Projects/all_projects.dart';
import 'package:quickenlancer_apk/Update%20Profile%20New/portfolio_new.dart';
import 'package:quickenlancer_apk/home_page.dart';
import 'Kyc Verification/kyc_verification.dart';
import 'Update Profile New/certification_new.dart';
import 'Update Profile New/change_password.dart';
import 'Update Profile New/experience_new.dart';
import 'Update Profile New/language_new.dart';
import 'Update Profile New/profile_update.dart';
import 'Update Profile New/skills_new.dart';
import 'Update Profile/tabs/update_profile_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'api/network/uri.dart';

//save the new changes
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 4;
  List<int> portfolioItems = [1];
  List<int> languagesItems = [1];
  String kycStatus = '';
  // State variables to store API response data
  Map<String, dynamic>? profileData;
  Map<String, dynamic>? basicDetails;
  List<dynamic>? portfolios;
  List<dynamic>? languages;
  List<dynamic>? skills;
  List<dynamic>? certificates;
  Map<String, dynamic>? counts;

  @override
  void initState() {
    super.initState();
    fetchProfileDetails();
  }

  Future<void> _onRefresh() async {
    await fetchProfileDetails();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    final routes = [
      MyHomePage(),
      AllProjects(),
      Buycallpage(),
      Buychatpage(),
      ProfilePage(),
    ];
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => routes[index]),
    );
  }

  Future<void> fetchProfileDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final String? authToken = prefs.getString('auth_token');

      final url = Uri.parse(URLS().get_profile_details);
      final body = jsonEncode({'user_id': userId});

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        log('Profile details: $responseData');
        setState(() {
          profileData = responseData;
          basicDetails = responseData['data']['basic_details'];
          portfolios = responseData['data']['portfolios'];
          languages = responseData['data']['languages'];
          skills = responseData['data']['skills'];
          certificates = responseData['data']['certificates'];
          counts = responseData['data']['counts'];
        });
      } else {
        print('Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  @override
  Widget build(context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final montserrat = GoogleFonts.montserrat().fontFamily;
    final textColor = Colorfile.textColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Profile',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: textColor,
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          Visibility(
            visible: kycStatus == 'Pending',
            child: Padding(
              padding: EdgeInsets.only(right: 15),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KYCVerificationPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Color(0xFF466AA5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  minimumSize: Size(80, 32),
                ),
                child: Text(
                  kycStatus,
                  style: TextStyle(color: Color(0xFF466AA5)),
                ),
              ),
            ),
          )
        ],
      ),
      body: CupertinoScrollbar(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  width: screenWidth,
                  height: screenHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(255, 235, 202, 220),
                        Color(0xFFB7D7F9)
                      ],
                    ),
                  ),
                ),
                Container(
                  width: screenWidth,
                  // height: screenHeight,
                  margin: EdgeInsets.only(top: screenHeight * 0.15),
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  decoration: BoxDecoration(color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.15),
                      // Edit Options Section
                      _buildEditOption(
                        imagePath: 'assets/Group 237841.png',
                        label: 'Profile',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePageNew(),
                          ),
                        ),
                        isTappable: true,
                      ),
                      _buildEditOption(
                        imagePath: 'assets/Group 237841.png',
                        label: 'Skills',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SkillsNew(),
                          ),
                        ),
                        isTappable: true,
                      ),
                      _buildEditOption(
                        imagePath: 'assets/Group 237841.png',
                        label: 'Portfolio',
                        isTappable: true,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PortfolioNew(),
                          ),
                        ),
                      ),
                      _buildEditOption(
                        imagePath: 'assets/Group 237841.png',
                        label: 'Language',
                        isTappable: true,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LanguagePageNew(),
                          ),
                        ),
                      ),
                      _buildEditOption(
                        imagePath: 'assets/Group 237841.png',
                        label: 'Certification',
                        isTappable: true,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CertificationNew(),
                          ),
                        ),
                      ),
                      _buildEditOption(
                        imagePath: 'assets/Group 237841.png',
                        label: 'Experience',
                        isTappable: true,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExperienceNew(),
                          ),
                        ),
                      ),
                      _buildEditOption(
                        imagePath: 'assets/Group 237841.png',
                        label: 'Change Password',
                        isTappable: true,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PasswordNew(),
                          ),
                        ),
                      ),
                      SizedBox(height: 60),
                    ],
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.08,
                  left: screenWidth * 0.05,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: CircleAvatar(
                      radius: screenWidth * 0.15,
                      backgroundImage: NetworkImage(
                        basicDetails?['profile_pic_path'] as String? ??
                            'https://images.pexels.com/photos/14653174/pexels-photo-14653174.jpeg',
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.23,
                  left: screenWidth * 0.05,
                  child: ElevatedButton(
                    // onPressed: () => Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) =>
                    //           UpdateProfilePage(initialTab: 0)),
                    // ),
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: textColor,
                      padding: EdgeInsets.symmetric(
                          vertical: 6, horizontal: screenWidth * 0.12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      minimumSize: Size(screenWidth * 0.25, 32),
                    ),
                    child: Text(
                      'Update',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.white,
                        fontFamily: montserrat,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.16,
                  left: screenWidth * 0.4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${basicDetails?['f_name'] as String? ?? ''} ${basicDetails?['l_name'] as String? ?? ''}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontFamily: montserrat,
                        ),
                      ),
                      Row(
                        children: [
                          Image.network(
                            basicDetails?['country_flag_path'] as String? ??
                                'assets/india.png',
                            height: screenHeight * 0.03,
                            width: screenHeight * 0.03,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset('assets/india.png',
                                    height: screenHeight * 0.03,
                                    width: screenHeight * 0.03),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Text(
                            '${basicDetails?['city_name'] as String? ?? ''}, ${basicDetails?['country_name'] as String? ?? ''}',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.black54,
                              fontFamily: montserrat,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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

  Widget _buildEditOption({
    required String imagePath,
    required String label,
    VoidCallback? onTap,
    required bool isTappable,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final montserrat = GoogleFonts.montserrat().fontFamily;
    final textColor = Colorfile.textColor;

    return GestureDetector(
      onTap: isTappable ? onTap : null, // Only tappable if isTappable is true
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: Color(0xFFE0C9DB), // Added border with color #E0C9DB
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.error,
                color: textColor,
                size: screenWidth * 0.06,
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: montserrat,
                  color: isTappable ? textColor : Colors.grey,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0, // Added 1px letter spacing
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: isTappable ? Color(0xFF757575) : Color(0xFF757575),
              size: screenWidth * 0.06,
              weight: 700,
            ),
          ],
        ),
      ),
    );
  }
}
