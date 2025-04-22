import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickenlancer_apk/BottomBar/bottom_bar.dart';
import 'package:quickenlancer_apk/Call/callpage.dart';
import 'package:quickenlancer_apk/Chat/chatpage.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import 'package:quickenlancer_apk/home_page.dart';

import 'profilepage.dart';

class Editprofilepage extends StatefulWidget {
  const Editprofilepage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<Editprofilepage> {
  // List to hold the portfolio itemsint _selectedIndex = 0;
  int _selectedIndex = 4;

  // Add a method to handle the refresh
  Future<void> _onRefresh() async {
    // Simulate a network call or some data update here
    await Future.delayed(Duration(seconds: 2));
    // You can update the state or data here after refreshing
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      // Check if the 3rd index is selected
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const MyHomePage()), // Navigate to the new page
      );
    }
    if (index == 2) {
      // Check if the 3rd index is selected
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const Buycallpage()), // Navigate to the new page
      );
    }
    if (index == 3) {
      // Check if the 3rd index is selected
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const Buychatpage()), // Navigate to the new page
      );
    }
    if (index == 4) {
      // Check if the 3rd index is selected
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const Buycallpage()), // Navigate to the new page
      );
    }
    if (index == 4) {
      // Check if the 3rd index is selected
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage()), // Navigate to the new page
      );
    }
  }

  List<int> portfolioItems = [1]; // Start with one item
  List<int> languagesItems = [1];
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    Widget _buildAbilityIcon(IconData icon, String label) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: Colorfile.textColor, size: 12),
          SizedBox(width: screenWidth * 0.02), // Space between icon and label
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colorfile.textColor,
              fontFamily: GoogleFonts.montserrat().fontFamily,
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Profile',
          style: GoogleFonts.montserrat(
            // Use GoogleFonts here
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colorfile.textColor,
          ),
        ),
        backgroundColor: const Color(0xFFFFFFFF),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
                right: 15.0), // Adjust this value as needed
            child: ElevatedButton(
              onPressed: () {
                // Add your verification logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFFFF),
                side: BorderSide(color: Color(0xFF466AA5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal:
                        12.0), // Reduce vertical padding for less height
                minimumSize: Size(80, 32), // Set a specific height if needed
              ),
              child: Text(
                'Verify',
                style: TextStyle(
                  color: Color(0xFF466AA5),
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
                        Color(0xFFB7D7F9),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: screenWidth,
                  margin: EdgeInsets.only(top: screenHeight * 0.15),
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    // borderRadius: BorderRadius.only(
                    //   topLeft: Radius.circular(30),
                    //   topRight: Radius.circular(30),
                    // ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: screenHeight * 0.15,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: screenWidth * 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile Overview :',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colorfile.textColor,
                                fontFamily: GoogleFonts.montserrat().fontFamily,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              'I am web Developer and Designer also handling experience of multiple project. I am web Developer and Designer also handling experience of multiple project.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                fontFamily: GoogleFonts.montserrat().fontFamily,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Divider(
                              color: Color(0xFFD9D9D9),
                              thickness: 1,
                            ),
                          ],
                        ),
                      ),
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
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.all(screenWidth * 0.002),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFE5ACCB),
                                  Color(0xFFB7D7F9),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F7FA),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.all(screenWidth * 0.03),
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Skills ${index + 1}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colorfile.textColor,
                                          fontFamily: GoogleFonts.montserrat()
                                              .fontFamily,
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 20.0),
                                        child: Text(
                                          'Your skills represent the capacity to accomplish milestone competently in various areas ${index + 1}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.black54,
                                            fontFamily: GoogleFonts.montserrat()
                                                .fontFamily,
                                          ),
                                          maxLines:
                                              6, // Limit the number of lines
                                          overflow: TextOverflow
                                              .ellipsis, // Add ellipsis (...) if text overflows
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    top: screenHeight * 0.0,
                                    right: screenWidth * 0.00,
                                    child: Container(
                                      width: screenWidth * 0.08,
                                      height: screenWidth * 0.08,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFE5ACCB),
                                            Color(0xFFB7D7F9),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.04,
                                            color: Colors.black,
                                            fontFamily: GoogleFonts.montserrat()
                                                .fontFamily,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Divider(
                        color: Color(0xFFD9D9D9),
                        thickness: 1,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      // Portfolio Section with dynamic boxes
                      Text(
                        'Portfolio:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colorfile.textColor,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Column(
                        children: portfolioItems.map((item) {
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
                            margin:
                                EdgeInsets.only(bottom: screenHeight * 0.01),
                            child: Row(
                              children: [
                                // Left side - Square Image
                                Container(
                                  width: screenWidth * 0.4,
                                  height: screenWidth * 0.35,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/test.jpg'), // Use AssetImage
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),

                                SizedBox(width: screenWidth * 0.05),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Title and Subtitle Row with Edit Icon
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Title
                                          Text(
                                            'Test',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              fontFamily:
                                                  GoogleFonts.montserrat()
                                                      .fontFamily,
                                            ),
                                          ),
                                          // Edit Icon
                                          IconButton(
                                            onPressed: () {
                                              // Handle Edit action
                                            },
                                            icon: Icon(
                                              CupertinoIcons.square_pencil_fill,
                                              color: Colorfile.textColor,
                                              size: screenWidth * 0.05,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Subtitle
                                      Text(
                                        'Lorem Ipsum is simply dummy text',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontFamily: GoogleFonts.montserrat()
                                              .fontFamily,
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      OutlinedButton(
                                        onPressed: () {
                                          // Handle View action
                                        },
                                        child: Text(
                                          'View',
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.04,
                                            color: Colorfile.textColor,
                                            fontFamily: GoogleFonts.montserrat()
                                                .fontFamily,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Color(
                                              0xFFF4F6F8), // Background color
                                          side: BorderSide(
                                            color: Colorfile.textColor,
                                            width: 1, // Border color and width
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                4), // Border radius
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: 6.0,
                                            horizontal: screenWidth * 0,
                                          ),
                                          minimumSize:
                                              Size(screenWidth * 0.25, 32),
                                        ),
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

                      DottedBorder(
                        color: Color(0xFFD3DFED), // Dotted border color
                        strokeWidth: 2, // Border width
                        dashPattern: [
                          6,
                          3
                        ], // Dotted pattern (length and space)
                        borderType:
                            BorderType.RRect, // Rounded rectangle border
                        radius: Radius.circular(5), // Border radius
                        child: TextButton(
                          onPressed: () {
                            // Add a new portfolio item when clicked
                            setState(() {
                              portfolioItems.add(portfolioItems.length + 1);
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor:
                                Color(0xFFF5F7FA), // Updated background color
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.01,
                              horizontal: screenWidth *
                                  0.05, // Added horizontal padding
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            shadowColor:
                                Colors.transparent, // No shadow for flat button
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8), // Circle padding
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFD3DFED), // Circle color
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: Colorfile.textColor, // Icon color
                                  size: screenWidth * 0.06,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10), // Padding inside the text
                                child: Text(
                                  'Add More',
                                  style: TextStyle(
                                    color: Colorfile.textColor, // Text color
                                    fontWeight: FontWeight.w500,
                                    fontFamily:
                                        GoogleFonts.montserrat().fontFamily,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Divider(
                        color: Color(0xFFD9D9D9),
                        thickness: 1,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'Language Known :',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colorfile.textColor,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                      ),
                      Column(
                        children: [
                          // Other widgets like 'Languages Known' go here

                          SizedBox(height: screenHeight * 0.02),

                          // Color block with percentage ranges
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // 0% - 25%
                              Container(
                                width: 12,
                                height: 12,
                                color: Color(0xFFEB5757), // Red for 0% - 25%
                              ),
                              SizedBox(
                                  width: screenWidth *
                                      0.02), // Space between color block and text
                              Text(
                                '0% - 25%',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontFamily:
                                      GoogleFonts.montserrat().fontFamily,
                                ),
                              ),
                              SizedBox(
                                  width: screenWidth *
                                      0.05), // Space between blocks
                              // 26% - 50%
                              Container(
                                width: 12,
                                height: 12,
                                color:
                                    Color(0xFFF2C94C), // Yellow for 26% - 50%
                              ),
                              SizedBox(
                                  width: screenWidth *
                                      0.02), // Space between color block and text
                              Text(
                                '26% - 50%',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontFamily:
                                      GoogleFonts.montserrat().fontFamily,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Column(
                        children: languagesItems.map((item) {
                          return Container(
                            padding: EdgeInsets.all(screenWidth * 0.03),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Color(0xFFD9D9D9), // Border color
                                width: 1.5, // Border width
                              ),
                            ),
                            margin:
                                EdgeInsets.only(bottom: screenHeight * 0.01),
                            child: Row(
                              children: [
                                // Left side - Square Image (Placeholder)
                                Container(
                                  width:
                                      49, // Adjust the size as per your requirement
                                  height:
                                      49, // Adjust the size as per your requirement

                                  child: CircularProgressIndicator(
                                    value: 0.75, // Set the progress value here
                                    strokeWidth:
                                        6, // Reduced stroke width for a smaller progress indicator
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.green),
                                  ),
                                ),

                                SizedBox(width: screenWidth * 0.05),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Language Name Row with Edit Icon
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Language Name
                                          Text(
                                            'English',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              fontFamily:
                                                  GoogleFonts.montserrat()
                                                      .fontFamily,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      // Abilities (Read, Write, Speak)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildAbilityIcon(
                                              Icons.remove_red_eye_outlined,
                                              'Read'),
                                          _buildAbilityIcon(
                                              Icons.mode_edit_outline_outlined,
                                              'Write'),
                                          _buildAbilityIcon(
                                              Icons.mic_none_outlined, 'Speak'),
                                        ],
                                      ),
                                      // Circular Progress Indicator for Learning Progress
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      DottedBorder(
                        color: Color(0xFFD3DFED), // Dotted border color
                        strokeWidth: 2, // Border width
                        dashPattern: [
                          6,
                          3
                        ], // Dotted pattern (length and space)
                        borderType:
                            BorderType.RRect, // Rounded rectangle border
                        radius: Radius.circular(5), // Border radius
                        child: TextButton(
                          onPressed: () {
                            // Add a new portfolio item when clicked
                            setState(() {
                              languagesItems.add(languagesItems.length + 1);
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor:
                                Color(0xFFF5F7FA), // Updated background color
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.01,
                              horizontal: screenWidth *
                                  0.05, // Added horizontal padding
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            shadowColor:
                                Colors.transparent, // No shadow for flat button
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8), // Circle padding
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFD3DFED), // Circle color
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: Colorfile.textColor, // Icon color
                                  size: screenWidth * 0.06,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10), // Padding inside the text
                                child: Text(
                                  'Add More',
                                  style: TextStyle(
                                    color: Colorfile.textColor, // Text color
                                    fontWeight: FontWeight.w500,
                                    fontFamily:
                                        GoogleFonts.montserrat().fontFamily,
                                    fontSize: screenWidth * 0.04,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Divider(
                        color: Color(0xFFD9D9D9),
                        thickness: 1,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'Skills & Price :',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colorfile.textColor,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
// Table Container

                      Container(
                        // decoration: BoxDecoration(
                        //   border: Border.all(color: Color(0xFFD9D9D9), width: 1),
                        //   borderRadius: BorderRadius.circular(8),
                        // ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Table(
                              border: TableBorder.all(
                                color: Color(0xFFD9D9D9),
                                width: 1,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                              children: [
                                TableRow(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF5F7FA),
                                  ),
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Skill',
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colorfile.textColor,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Cost',
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colorfile.textColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Bootstrap',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11,
                                          color: Colorfile.textColor,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        '\USD 20',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11,
                                          color: Colorfile.textColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Paid social media advertising',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11,
                                          color: Colorfile.textColor,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        '\USD 15',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11,
                                          color: Colorfile.textColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Hibernate',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11,
                                          color: Colorfile.textColor,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        '\USD 25',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11,
                                          color: Colorfile.textColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                border: Border.all(
                                  color: Color(0xFFD9D9D9),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Table to separate the certificate title and add a line below it
                                  Table(
                                    columnWidths: {
                                      0: FixedColumnWidth(MediaQuery.of(context)
                                              .size
                                              .width *
                                          0.7), // Adjust width with MediaQuery
                                      1: FixedColumnWidth(
                                          MediaQuery.of(context).size.width *
                                              0.3),
                                    },
                                    children: [
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5.0, vertical: 8.0),
                                            child: Text(
                                              'Certificate',
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: Colorfile.textColor,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top:
                                                    4.0), // Add top padding to give some space above the image
                                            child: Image.asset(
                                              'assets/Group 237842.png',
                                              height:
                                                  25, // Set the height of the image
                                              width:
                                                  50, // Set the width of the image
                                              fit: BoxFit
                                                  .contain, // Ensures the image fits inside the specified size
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    // This Divider is outside of the Table but inside the Column
                                    color: Color(0xFFD9D9D9),
                                    height: 1,
                                    thickness: 1,
                                    indent: 0,
                                    endIndent: 0,
                                  ),
                                  Table(
                                    columnWidths: {
                                      0: FixedColumnWidth(MediaQuery.of(context)
                                              .size
                                              .width *
                                          0.7), // Adjust width with MediaQuery
                                      1: FixedColumnWidth(
                                          MediaQuery.of(context).size.width *
                                              0.3),
                                    },
                                    children: [
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5.0, vertical: 8.0),
                                            child: Text(
                                              'Web Designing',
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 11,
                                                color: Colorfile.textColor,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top:
                                                    4.0), // Add top padding to give some space above the image
                                            child: Image.asset(
                                              'assets/trash 1.png',
                                              height:
                                                  20, // Set the height of the image
                                              width:
                                                  20, // Set the width of the image
                                              fit: BoxFit
                                                  .contain, // Ensures the image fits inside the specified size
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                border: Border.all(
                                  color: Color(0xFFD9D9D9),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Table to separate the certificate title and add a line below it
                                  Table(
                                    columnWidths: {
                                      0: FixedColumnWidth(MediaQuery.of(context)
                                              .size
                                              .width *
                                          0.7), // Adjust width with MediaQuery
                                      1: FixedColumnWidth(
                                          MediaQuery.of(context).size.width *
                                              0.3),
                                    },
                                    children: [
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5.0, vertical: 8.0),
                                            child: Text(
                                              'Experience in Year',
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    13, // Adjust font size with MediaQuery
                                                color: Colorfile.textColor,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top:
                                                    4.0), // Add top padding to give some space above the image
                                            child: Image.asset(
                                              'assets/Group 237842.png',
                                              height:
                                                  20, // Set the height of the image
                                              width:
                                                  20, // Set the width of the image
                                              fit: BoxFit
                                                  .contain, // Ensures the image fits inside the specified size
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    // This Divider is outside of the Table but inside the Column
                                    color: Color(0xFFD9D9D9),
                                    height: 1,
                                    thickness: 1,
                                    indent: 0,
                                    endIndent: 0,
                                  ),
                                  Table(
                                    columnWidths: {
                                      0: FixedColumnWidth(MediaQuery.of(context)
                                              .size
                                              .width *
                                          0.7), // Adjust width with MediaQuery
                                      1: FixedColumnWidth(
                                          MediaQuery.of(context).size.width *
                                              0.3),
                                    },
                                    children: [
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5.0, vertical: 8.0),
                                            child: Text(
                                              '2 Year- Web developer',
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w500,
                                                fontSize:
                                                    11, // Adjust font size with MediaQuery
                                                color: Colorfile.textColor,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top:
                                                    4.0), // Add top padding to give some space above the image
                                            child: Image.asset(
                                              'assets/trash 1.png',
                                              height:
                                                  25, // Set the height of the image
                                              width:
                                                  50, // Set the width of the image
                                              fit: BoxFit
                                                  .contain, // Ensures the image fits inside the specified size
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.08,
                  left: screenWidth * 0.05,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white, width: 4), // White border
                    ),
                    child: CircleAvatar(
                      radius: screenWidth * 0.15,
                      backgroundImage: NetworkImage(
                        'https://images.pexels.com/photos/14653174/pexels-photo-14653174.jpeg',
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.23,
                  left: screenWidth * 0.05,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle edit profile action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colorfile.textColor,
                      padding: EdgeInsets.symmetric(
                        vertical:
                            6.0, // Set a fixed vertical padding for consistent height
                        horizontal: screenWidth * 0.12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      minimumSize: Size(screenWidth * 0.25,
                          32), // Set a fixed height (32) and width
                    ),
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.white,
                        fontFamily: GoogleFonts.montserrat().fontFamily,
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
                        'Vaibhav Danve',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colorfile.textColor,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                      ),
                      // SizedBox(height: screenHeight * 0.01),
                      Row(
                        children: [
                          Image.asset(
                            'assets/india.png',
                            height: screenHeight * 0.03,
                            width: screenHeight * 0.03,
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Text(
                            'Gondia, India',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.black54,
                              fontFamily: GoogleFonts.montserrat().fontFamily,
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
