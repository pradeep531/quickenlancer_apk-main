import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickenlancer_apk/BottomBar/bottom_bar.dart';
import 'package:quickenlancer_apk/Call/callpage.dart';
import 'package:quickenlancer_apk/Chat/chatpage.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import 'package:quickenlancer_apk/Projects/all_projects.dart';
import 'package:quickenlancer_apk/home_page.dart';
import 'Kyc Verification/kyc_verification.dart';
import 'Update Profile/tabs/languagelist.dart';
import 'Update Profile/tabs/portfolio_edit.dart';
import 'Update Profile/tabs/portfolio_form.dart';
import 'Update Profile/tabs/update_profile_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
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
  // State variables to store API response data
  Map<String, dynamic>? profileData;
  Map<String, dynamic>? basicDetails;
  List<dynamic>? portfolios;
  List<dynamic>? languages;
  List<dynamic>? skills;
  List<dynamic>? certificates;
  Map<String, dynamic>? counts;
  bool _isLoading = true; // Loading state for skeleton

  @override
  void initState() {
    super.initState();
    fetchProfileDetails();
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
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
          _isLoading = false;
        });
      } else {
        print('Failed to fetch profile: ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching profile: $e');
      setState(() => _isLoading = false);
    }
  }

  Widget _buildSkeletonLoader(double width, double height) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildSkeletonScreen(double screenWidth, double screenHeight) {
    final montserrat = GoogleFonts.montserrat().fontFamily;
    return SingleChildScrollView(
      child: Stack(
        children: [
          Container(
            width: screenWidth,
            height: screenHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.fromARGB(255, 235, 202, 220), Color(0xFFB7D7F9)],
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.08,
            left: screenWidth * 0.05,
            child: _buildSkeletonLoader(screenWidth * 0.3, screenWidth * 0.3),
          ),
          Positioned(
            top: screenHeight * 0.16,
            left: screenWidth * 0.4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSkeletonLoader(screenWidth * 0.4, 20),
                SizedBox(height: screenHeight * 0.01),
                _buildSkeletonLoader(screenWidth * 0.3, 15),
              ],
            ),
          ),
          Positioned(
            top: screenHeight * 0.23,
            left: screenWidth * 0.05,
            child: _buildSkeletonLoader(screenWidth * 0.25, 32),
          ),
          Container(
            width: screenWidth,
            margin: EdgeInsets.only(top: screenHeight * 0.15),
            padding: EdgeInsets.all(screenWidth * 0.05),
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.15),
                _buildSkeletonLoader(screenWidth * 0.3, 20),
                SizedBox(height: screenHeight * 0.01),
                _buildSkeletonLoader(screenWidth * 0.8, 40),
                SizedBox(height: screenHeight * 0.02),
                Divider(color: Color(0xFFD9D9D9), thickness: 1),
                SizedBox(height: screenHeight * 0.02),
                _buildSkeletonLoader(screenWidth * 0.3, 20),
                SizedBox(height: screenHeight * 0.02),
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: screenWidth * 0.05,
                  mainAxisSpacing: screenHeight * 0.02,
                  childAspectRatio: 1,
                  children: List.generate(
                      6,
                      (index) => _buildSkeletonLoader(
                          screenWidth * 0.45, screenWidth * 0.45)),
                ),
                SizedBox(height: screenHeight * 0.02),
                Divider(color: Color(0xFFD9D9D9), thickness: 1),
                SizedBox(height: screenHeight * 0.02),
                _buildSkeletonLoader(screenWidth * 0.3, 20),
                SizedBox(height: screenHeight * 0.02),
                Column(
                  children: List.generate(
                      2,
                      (index) => Padding(
                            padding:
                                EdgeInsets.only(bottom: screenHeight * 0.01),
                            child: Row(
                              children: [
                                _buildSkeletonLoader(
                                    screenWidth * 0.4, screenWidth * 0.35),
                                SizedBox(width: screenWidth * 0.05),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildSkeletonLoader(
                                          screenWidth * 0.3, 20),
                                      SizedBox(height: screenHeight * 0.01),
                                      _buildSkeletonLoader(
                                          screenWidth * 0.4, 40),
                                      SizedBox(height: screenHeight * 0.01),
                                      _buildSkeletonLoader(
                                          screenWidth * 0.25, 32),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                ),
                SizedBox(height: screenHeight * 0.03),
                _buildSkeletonLoader(screenWidth * 0.9, 40),
                SizedBox(height: screenHeight * 0.02),
                Divider(color: Color(0xFFD9D9D9), thickness: 1),
                SizedBox(height: screenHeight * 0.02),
                _buildSkeletonLoader(screenWidth * 0.3, 20),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  children: [
                    _buildSkeletonLoader(12, 12),
                    SizedBox(width: screenWidth * 0.02),
                    _buildSkeletonLoader(screenWidth * 0.2, 15),
                    SizedBox(width: screenWidth * 0.05),
                    _buildSkeletonLoader(12, 12),
                    SizedBox(width: screenWidth * 0.02),
                    _buildSkeletonLoader(screenWidth * 0.2, 15),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Column(
                  children: List.generate(
                      2,
                      (index) => Padding(
                            padding:
                                EdgeInsets.only(bottom: screenHeight * 0.01),
                            child: Row(
                              children: [
                                _buildSkeletonLoader(49, 49),
                                SizedBox(width: screenWidth * 0.05),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildSkeletonLoader(
                                          screenWidth * 0.3, 20),
                                      SizedBox(height: screenHeight * 0.01),
                                      _buildSkeletonLoader(
                                          screenWidth * 0.4, 15),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                ),
                SizedBox(height: screenHeight * 0.03),
                _buildSkeletonLoader(screenWidth * 0.9, 40),
                SizedBox(height: screenHeight * 0.02),
                Divider(color: Color(0xFFD9D9D9), thickness: 1),
                SizedBox(height: screenHeight * 0.02),
                _buildSkeletonLoader(screenWidth * 0.3, 20),
                SizedBox(height: screenHeight * 0.02),
                _buildSkeletonLoader(screenWidth * 0.9, 80),
                SizedBox(height: screenHeight * 0.02),
                Column(
                  children: List.generate(
                      2,
                      (index) => Padding(
                            padding:
                                EdgeInsets.only(bottom: screenHeight * 0.02),
                            child: _buildSkeletonLoader(screenWidth * 0.9, 60),
                          )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final montserrat = GoogleFonts.montserrat().fontFamily;
    final textColor = Colorfile.textColor;

    if (_isLoading) {
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
            Padding(
              padding: EdgeInsets.only(right: 15),
              child: _buildSkeletonLoader(80, 32),
            ),
          ],
        ),
        body: _buildSkeletonScreen(screenWidth, screenHeight),
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
                  height: screenHeight,
                  margin: EdgeInsets.only(top: screenHeight * 0.15),
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  decoration: BoxDecoration(color: Colors.white),
                  child: Column(),
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
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              UpdateProfilePage(initialTab: 0)),
                    ),
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
}
