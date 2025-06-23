import 'dart:developer';

import 'package:crypto/crypto.dart';
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
import '../Kyc Verification/kyc_verification.dart';
import '../api/network/uri.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert';

class FreelancerProfile extends StatefulWidget {
  final String freelancerId;

  const FreelancerProfile({super.key, required this.freelancerId});
  @override
  _FreelancerProfilePageState createState() => _FreelancerProfilePageState();
}

class _FreelancerProfilePageState extends State<FreelancerProfile> {
  int _selectedIndex = 4;
  String kycStatus = '';
  Map<String, dynamic>? profileData;
  Map<String, dynamic>? basicDetails;
  List<dynamic>? portfolios;
  List<dynamic>? languages;
  List<dynamic>? skills;
  List<dynamic>? certificates;
  Map<String, dynamic>? counts;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('Freelancer ID: ${widget.freelancerId}');
    fetchProfileDetails();
    getKycDetails();
  }

  Future<void> getKycDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = widget.freelancerId;
    final authToken = prefs.getString('auth_token') ?? '';

    final url = Uri.parse(URLS().get_kyc_details);
    final requestBody = jsonEncode({'user_id': userId});

    // Print request
    print('POST $url');
    print(
        'Request Headers: {Content-Type: application/json, Authorization: Bearer $authToken}');
    print('Request Body of kyc: $requestBody');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: requestBody,
    );

    // Print response
    print('Response Status Code: ${response.statusCode}');
    print('Response Body of kyc: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log('KYC Details: $data');

      final kycStatusCode = data['data']['kyc_status'].toString();

      switch (kycStatusCode) {
        case '0':
          kycStatus = 'Pending';
          break;
        case '1':
          kycStatus = 'Approved';
          break;
        case '2':
          kycStatus = 'Rejected';
          break;
        case '3':
          kycStatus = 'Submitted';
          break;
        default:
          kycStatus = 'unknown';
      }

      log('KYC Status stored: $kycStatus');
    } else {
      print('Error: ${response.statusCode} ${response.body}');
    }
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
      FreelancerProfile(freelancerId: widget.freelancerId),
    ];
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => routes[index]),
    );
  }

  Future<void> fetchProfileDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = widget.freelancerId;
      final String? authToken = prefs.getString('auth_token');

      final url = Uri.parse(URLS().get_profile_details);
      final body = jsonEncode({'user_id': userId});

      print('Request URL: $url');
      print('Request Headers: ${{
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      }}');
      print('Request Body: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: body,
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
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

  Future<String> getPresignedUrl(String locOfFile) async {
    print('Fetching presigned URL for: $locOfFile');
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getString('user_id') ?? '';
    final String? authToken = prefs.getString('auth_token');

    if (authToken == null || userId.isEmpty) {
      return 'User not authenticated';
    }

    final url = Uri.parse(URLS().user_fetch_file);
    final body = jsonEncode({
      'user_id': userId,
      'loc_of_file': locOfFile,
    });

    final headers = {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json',
    };

    log('Request Body: $body');
    print('Request Headers: $headers');

    try {
      final response = await http.post(url, headers: headers, body: body);
      print('Response Status Code: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      print('Exception: $e');
      return 'Exception: $e';
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
    final poppins = GoogleFonts.poppins().fontFamily;
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
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                ),
                SizedBox(height: screenHeight * 0.03),
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
    final poppins = GoogleFonts.poppins().fontFamily;
    final textColor = Colorfile.textColor;
    final currency = basicDetails?['currency'] as String? ?? 'INR';

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Freelancer Profile',
            style: GoogleFonts.poppins(
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

    String truncateWithEllipsis(String text, int maxLength) {
      if (text.length <= maxLength) {
        return text;
      }
      return '${text.substring(0, maxLength - 3)}...';
    }

    final countItems = [
      {
        'name': 'Skills',
        'key': 'skills_count',
        'description': 'Total number of skills listed in your profile.',
      },
      {
        'name': 'Proposals Sent',
        'key': 'proposal_sent_count',
        'description': 'Number of project proposals you have submitted.',
      },
      {
        'name': 'Projects Posted',
        'key': 'project_posted_count',
        'description': 'Total projects you have posted.',
      },
      {
        'name': 'Projects Received',
        'key': 'received_project_count',
        'description': 'Projects assigned to you.',
      },
      {
        'name': 'Projects Proposed',
        'key': 'proposed_project_count',
        'description': 'Projects you have proposed to work on.',
      },
      {
        'name': 'Connections',
        'key': 'connection_count',
        'description': 'Total connections in your network.',
      },
    ];

    Widget _buildAbilityIcon(IconData icon, String label) => Row(
          children: [
            Icon(icon, color: textColor, size: 12),
            SizedBox(width: screenWidth * 0.02),
            Text(
              label,
              style: TextStyle(
                  fontSize: 12, color: textColor, fontFamily: poppins),
            ),
          ],
        );

    Widget _sectionTitle(String title) => Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textColor,
            fontFamily: poppins,
          ),
        );

    Widget _divider() => Divider(color: Color(0xFFD9D9D9), thickness: 1);

    Widget _noDataWidget() => Center(
          child: Text(
            'No Data',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontFamily: poppins,
              fontWeight: FontWeight.w500,
            ),
          ),
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Freelancer Profile',
          style: GoogleFonts.poppins(
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
          ),
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
                  margin: EdgeInsets.only(top: screenHeight * 0.15),
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  decoration: BoxDecoration(color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.10),
                      Align(
                        alignment: Alignment
                            .centerLeft, // Aligns the button to the left
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width:
                                120, // Set a fixed width to prevent full-width
                            child: ElevatedButton(
                              onPressed: () {
                                // Add your hire me functionality here
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                minimumSize:
                                    Size(80, 24), // Slightly thinner height
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                elevation: 0, // Optional: remove any shadow
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    transform: GradientRotation(
                                        140.96 * 3.14159 / 180),
                                    colors: [
                                      Color(0xFFB7D7F9),
                                      Color(0xFFE5ACCB),
                                    ],
                                    stops: [0.0256, 0.9932],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 2,
                                    horizontal: 12), // Reduced vertical padding
                                alignment: Alignment.center,
                                child: Text(
                                  'Hire Me',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          13), // Optional: reduce font size
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _sectionTitle('Profile Overview :'),
                          Container(
                            child: kycStatus == 'Approved'
                                ? Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green[600],
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.shield_outlined,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Verified',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        basicDetails?['profile_description'] as String? ?? '',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontFamily: poppins),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      _divider(),
                      SizedBox(height: screenHeight * 0.02),
                      _sectionTitle('Skills Overview :'),
                      SizedBox(height: screenHeight * 0.02),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: screenWidth * 0.05,
                          mainAxisSpacing: screenHeight * 0.02,
                          childAspectRatio: 1,
                        ),
                        itemCount: countItems.length,
                        itemBuilder: (context, index) {
                          final item = countItems[index];
                          final countValue = counts != null
                              ? counts![item['key']]?.toString() ?? '0'
                              : '0';
                          return Container(
                            padding: EdgeInsets.all(screenWidth * 0.002),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [Color(0xFFE5ACCB), Color(0xFFB7D7F9)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFF5F7FA),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.all(screenWidth * 0.04),
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: screenWidth * 0.2,
                                            child: Text(
                                              item['name'] as String,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: textColor,
                                                fontFamily: poppins,
                                              ),
                                              softWrap: true,
                                            ),
                                          ),
                                          Container(
                                            width: screenWidth * 0.08,
                                            height: screenWidth * 0.08,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFFE5ACCB),
                                                  Color(0xFFB7D7F9)
                                                ],
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                countValue,
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.04,
                                                  color: Colors.black,
                                                  fontFamily: poppins,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.015),
                                      Text(
                                        item['description'] as String,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.black54,
                                          fontFamily: poppins,
                                        ),
                                        maxLines: 5,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      _divider(),
                      SizedBox(height: screenHeight * 0.02),
                      _sectionTitle('Portfolio:'),
                      SizedBox(height: screenHeight * 0.02),
                      portfolios == null || portfolios!.isEmpty
                          ? _noDataWidget()
                          : Column(
                              children: portfolios!.map((item) {
                                final imagePathMap = profileData != null &&
                                        profileData!['data'] != null &&
                                        profileData!['data']['image_path']
                                            is Map
                                    ? profileData!['data']['image_path']
                                        as Map<String, dynamic>
                                    : null;
                                final portfolioPath = imagePathMap != null &&
                                        imagePathMap['portfolio_path'] is String
                                    ? imagePathMap['portfolio_path'] as String
                                    : 'images/portfolio/';
                                final file = item['file'] as String?;
                                final portfolioImageFuture =
                                    file != null && file.isNotEmpty
                                        ? getPresignedUrl('$portfolioPath$file')
                                        : Future.value('assets/test.jpg');

                                String? imageUrl;

                                return Container(
                                  padding: EdgeInsets.all(screenWidth * 0.02),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                  margin: EdgeInsets.only(
                                      bottom: screenHeight * 0.01),
                                  child: Row(
                                    children: [
                                      FutureBuilder<String>(
                                        future: portfolioImageFuture,
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return _buildSkeletonLoader(
                                                screenWidth * 0.4,
                                                screenWidth * 0.35);
                                          }

                                          if (snapshot.hasError ||
                                              !snapshot.hasData) {
                                            imageUrl = null;
                                            return Container(
                                              width: screenWidth * 0.4,
                                              height: screenWidth * 0.35,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  size: 40,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            );
                                          }

                                          try {
                                            final responseData =
                                                jsonDecode(snapshot.data!);
                                            if (responseData is Map &&
                                                responseData['status'] ==
                                                    'true' &&
                                                responseData['data']
                                                    is String) {
                                              imageUrl = responseData['data'];
                                            } else {
                                              imageUrl = null;
                                            }
                                          } catch (e) {
                                            print(
                                                'Error parsing presigned URL: $e');
                                            imageUrl = null;
                                          }

                                          if (imageUrl == null ||
                                              imageUrl!.isEmpty) {
                                            return Container(
                                              width: screenWidth * 0.4,
                                              height: screenWidth * 0.35,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  size: 40,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            );
                                          }

                                          return Container(
                                            width: screenWidth * 0.4,
                                            height: screenWidth * 0.35,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(imageUrl!),
                                                fit: BoxFit.cover,
                                                onError:
                                                    (exception, stackTrace) =>
                                                        AssetImage(
                                                            'assets/test.jpg'),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          );
                                        },
                                      ),
                                      SizedBox(width: screenWidth * 0.05),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['name'] as String? ?? '',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: poppins,
                                              ),
                                            ),
                                            Html(
                                              data: truncateWithEllipsis(
                                                  item['description']
                                                          as String? ??
                                                      'Description not available',
                                                  100),
                                              style: {
                                                '*': Style(
                                                  fontSize: FontSize(12),
                                                  color: Colors.grey,
                                                  fontFamily: poppins,
                                                ),
                                                'p':
                                                    Style(margin: Margins.zero),
                                                'ul': Style(
                                                  margin: Margins(
                                                    left: Margin(16),
                                                    top: Margin(8),
                                                    bottom: Margin(8),
                                                  ),
                                                ),
                                                'li': Style(
                                                    margin: Margins(
                                                        bottom: Margin(4))),
                                              },
                                              shrinkWrap: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                      SizedBox(height: screenHeight * 0.03),
                      _divider(),
                      SizedBox(height: screenHeight * 0.02),
                      _sectionTitle('Language Known :'),
                      SizedBox(height: screenHeight * 0.02),
                      languages == null || languages!.isEmpty
                          ? _noDataWidget()
                          : Column(
                              children: languages!.map((item) {
                                final known = (item['known'] as String?)
                                    ?.split(',')
                                    .map((e) => e.trim())
                                    .toList();
                                final proficientValue =
                                    item['proficient'] != null
                                        ? (item['proficient'] is num
                                            ? item['proficient'] as num
                                            : double.tryParse(
                                                item['proficient'].toString()))
                                        : 0;
                                return Container(
                                  padding: EdgeInsets.all(screenWidth * 0.03),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Color(0xFFD9D9D9), width: 1.5),
                                  ),
                                  margin: EdgeInsets.only(
                                      bottom: screenHeight * 0.01),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 49,
                                        height: 49,
                                        child: CircularProgressIndicator(
                                          value: proficientValue != null
                                              ? proficientValue / 100
                                              : 0,
                                          strokeWidth: 6,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.green),
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.05),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['language'] as String? ??
                                                  'English',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: poppins,
                                              ),
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.01),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                if (known != null &&
                                                    known.contains('1'))
                                                  _buildAbilityIcon(
                                                      Icons
                                                          .remove_red_eye_outlined,
                                                      'Read'),
                                                if (known != null &&
                                                    known.contains('2'))
                                                  _buildAbilityIcon(
                                                      Icons
                                                          .mode_edit_outline_outlined,
                                                      'Write'),
                                                if (known != null &&
                                                    known.contains('3'))
                                                  _buildAbilityIcon(
                                                      Icons.mic_none_outlined,
                                                      'Speak'),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                      SizedBox(height: screenHeight * 0.03),
                      _divider(),
                      SizedBox(height: screenHeight * 0.02),
                      _sectionTitle('Skills & Price :'),
                      SizedBox(height: screenHeight * 0.02),
                      skills == null || skills!.isEmpty
                          ? _noDataWidget()
                          : Table(
                              border: TableBorder.all(
                                color: Color(0xFFD9D9D9),
                                width: 1,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                              children: [
                                TableRow(
                                  decoration:
                                      BoxDecoration(color: Color(0xFFF5F7FA)),
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text(
                                        'Skill',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text(
                                        'Cost',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                ...skills!
                                    .where((skill) =>
                                        skill['skill'] != null &&
                                        skill['skill'] is String)
                                    .map((skill) => TableRow(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Text(
                                                skill['skill'] as String,
                                                style: GoogleFonts.poppins(
                                                    fontSize: 11,
                                                    color: textColor),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Text(
                                                '$currency ${skill['rate'] ?? 'N/A'}',
                                                style: GoogleFonts.poppins(
                                                    fontSize: 11,
                                                    color: textColor),
                                              ),
                                            ),
                                          ],
                                        ))
                                    .toList(),
                              ],
                            ),
                      SizedBox(height: screenHeight * 0.02),
                      ...[
                        {
                          'title': 'Certificate',
                          'data': certificates ?? <dynamic>[],
                        },
                        {
                          'title': 'Experience in Year',
                          'data': basicDetails != null &&
                                  basicDetails!['experience'] != null
                              ? [basicDetails!['experience']]
                              : <dynamic>[],
                        },
                      ].map((section) {
                        final isCertificate = section['title'] == 'Certificate';
                        final data = section['data'] as List<dynamic>;
                        return Container(
                          margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            border:
                                Border.all(color: Color(0xFFD9D9D9), width: 1),
                          ),
                          child: Column(
                            children: [
                              Table(
                                columnWidths: {
                                  0: FixedColumnWidth(screenWidth * 0.9),
                                },
                                children: [
                                  TableRow(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 8),
                                        child: Text(
                                          section['title'] as String,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: textColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              _divider(),
                              data.isEmpty
                                  ? Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8),
                                      child: _noDataWidget(),
                                    )
                                  : Table(
                                      columnWidths: {
                                        0: FixedColumnWidth(screenWidth * 0.9),
                                      },
                                      children: isCertificate
                                          ? data.map<TableRow>((cert) {
                                              return TableRow(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5,
                                                            vertical: 8),
                                                    child: Text(
                                                      cert['name'] as String? ??
                                                          '',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 11,
                                                        color: textColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList()
                                          : [
                                              TableRow(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5,
                                                            vertical: 8),
                                                    child: Text(
                                                      data.isNotEmpty &&
                                                              data[0] != null
                                                          ? data[0] as String
                                                          : 'N/A',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 11,
                                                        color: textColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                    ),
                            ],
                          ),
                        );
                      }),
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
                          fontFamily: poppins,
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
                              fontFamily: poppins,
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
