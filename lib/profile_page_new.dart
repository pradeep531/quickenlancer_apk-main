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
import 'package:skeletonizer/skeletonizer.dart';
import 'dart:convert';

import 'api/network/uri.dart';

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
  Map<String, dynamic>? profileData;
  Map<String, dynamic>? basicDetails;
  List<dynamic>? portfolios;
  List<dynamic>? languages;
  List<dynamic>? skills;
  List<dynamic>? certificates;
  Map<String, dynamic>? counts;
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    fetchProfileDetails();
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true; // Show skeleton during refresh
    });
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
      setState(() {
        isLoading = true; // Set loading to true before API call
      });
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
          isLoading = false; // Set loading to false after success
        });
      } else {
        print('Failed to fetch profile: ${response.statusCode}');
        setState(() {
          isLoading = false; // Set loading to false on failure
        });
      }
    } catch (e) {
      print('Error fetching profile: $e');
      setState(() {
        isLoading = false; // Set loading to false on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        elevation: 0,
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade300,
            height: 1.0,
          ),
        ),
      ),
      body: Skeletonizer(
        enabled: isLoading, // Enable skeleton when loading
        effect: ShimmerEffect(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
        ),
        child: CupertinoScrollbar(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Container(
                    width: screenWidth,
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: screenWidth * 0.3,
                              height: screenWidth * 0.3,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 4),
                              ),
                              child: ClipOval(
                                child: Builder(
                                  builder: (context) {
                                    final imageUrl =
                                        basicDetails?['profile_pic_path']
                                            as String?;
                                    if (imageUrl == null || imageUrl.isEmpty) {
                                      return Center(
                                        child: Icon(
                                          Icons.person_off,
                                          size: screenWidth * 0.15,
                                          color: Colors.grey,
                                        ),
                                      );
                                    }
                                    return Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    (loadingProgress
                                                            .expectedTotalBytes ??
                                                        1)
                                                : null,
                                            strokeWidth: 2,
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Center(
                                          child: Icon(
                                            Icons.person_off,
                                            size: screenWidth * 0.15,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Text(
                              '${basicDetails?['f_name'] as String? ?? 'First Name'} ${basicDetails?['l_name'] as String? ?? 'Last Name'}',
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                fontFamily: montserrat,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  basicDetails?['country_flag_path']
                                          as String? ??
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
                                  '${basicDetails?['city_name'] as String? ?? 'City'}, ${basicDetails?['country_name'] as String? ?? 'Country'}',
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
                        SizedBox(height: screenHeight * 0.03),
                        _buildEditOption(
                          imagePath: 'assets/Group 237841.png',
                          label: 'Profile',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePageNew(),
                            ),
                          ),
                          isTappable: !isLoading, // Disable tap during loading
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
                          isTappable: !isLoading,
                        ),
                        _buildEditOption(
                          imagePath: 'assets/Group 237841.png',
                          label: 'Portfolio',
                          isTappable: !isLoading,
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
                          isTappable: !isLoading,
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
                          isTappable: !isLoading,
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
                          isTappable: !isLoading,
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
                          isTappable: !isLoading,
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
                ],
              ),
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
      onTap: isTappable ? onTap : null,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: Color(0xFFE0C9DB),
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
                  letterSpacing: 1.0,
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
