import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickenlancer_apk/BottomBar/bottom_bar.dart';
import 'package:quickenlancer_apk/Call/buycall.dart';
import 'package:quickenlancer_apk/Chat/buychat.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import 'package:quickenlancer_apk/home_page.dart';
import 'package:quickenlancer_apk/editprofilepage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../Chat/chatpage.dart';
import '../Projects/all_projects.dart';
import '../api/network/uri.dart';

class Buycallpage extends StatefulWidget {
  final String? id;

  const Buycallpage({super.key, this.id});

  @override
  _CallpageState createState() => _CallpageState();
}

class _CallpageState extends State<Buycallpage> {
  int _selectedIndex = 2;
  bool _isChecked1 = false;
  bool _isChecked2 = false;
  bool _isLoading = false; // Track loading state for the button

  @override
  void initState() {
    super.initState();
    // Check if id has data, set _isChecked1; if null, set _isChecked2
    if (widget.id != null && widget.id!.isNotEmpty) {
      _isChecked1 = true;
    } else {
      _isChecked2 = true;
    }
    print('ID: ${widget.id}');
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
    if (index == 1) {
      // Check if the 3rd index is selected
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const AllProjects()), // Navigate to the new page
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
                const Editprofilepage()), // Navigate to the new page
      );
    }
  }

  // Function to call the buy_tokens API
  Future<void> _buyTokens() async {
    setState(() {
      _isLoading = true; // Show loader
    });

    final String apiUrl = URLS().buy_tokens; // Your API URL
    final prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('auth_token');
    final String userId = prefs.getString('user_id') ?? '';
    final String country = prefs.getString('country') ?? '';

    // Determine paid_via based on country
    final String paidVia = country == "101" ? "2" : "1";

    // Construct the request body
    final Map<String, dynamic> requestBody = {
      "user_id": userId,
      "token_for": "2", // Set to 2 for calls
      "quantity": "1",
      "paid_via": paidVia,
      "purchase_type": "1",
      "project_id": _isChecked1 ? widget.id ?? "" : "",
    };

    // Print the request body
    print('Request Body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(requestBody),
      );

      // Print the response body
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // Parse the response body
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == "true") {
        // Handle successful response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Call unlocked successfully!")),
        );
        // Navigate to the chat page (MyHomePage)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      } else {
        // Handle failure (either non-200 or status: false)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error occurred")),
        );
      }
    } catch (e) {
      // Handle network or other errors
      print('Error during API call: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error occurred")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loader
      });
    }
  }

  // Function to show confirmation dialog
  Future<void> _showConfirmationDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Purchase',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colorfile.textColor,
            ),
          ),
          content: Text(
            'Are you sure you want to purchase?',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colorfile.textColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog on "No"
              },
              child: Text(
                'No',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _buyTokens(); // Proceed with API call
              },
              child: Text(
                'Yes',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        title: Text(
          'Unlock Your Call',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 23.4 / 18,
            textBaseline: TextBaseline.alphabetic,
            letterSpacing: 0,
            color: Colorfile.textColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              // height: 75,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFB7D7F9), Color(0xFFE5ACCB)],
                  stops: [0.0256, 0.9932],
                ),
              ),
              child: Text(
                'By unlocking call you can easily connect',
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 26 / 15,
                  decoration: TextDecoration.none,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.id?.isNotEmpty ?? false)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isChecked1 = !_isChecked1;
                          if (_isChecked1) _isChecked2 = false;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Color(0xFFE0E0E0),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFB7D7F9),
                                  Color(0xFFE5ACCB),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: ClipOval(
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Image.asset(
                                  'assets/call.png', // Use a call-related icon
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            'Buy Call for this Project',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 20 / 13,
                              letterSpacing: 0.01,
                              color: Colorfile.textColor,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          subtitle: Text(
                            'You can buy calls just for this project.',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              height: 20 / 11,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          trailing: Checkbox(
                            value: _isChecked1,
                            onChanged: (bool? value) {
                              setState(() {
                                _isChecked1 = value ?? false;
                                if (_isChecked1) _isChecked2 = false;
                              });
                            },
                            activeColor: Colors.green,
                            checkColor: Colors.white,
                            fillColor:
                                MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.selected)) {
                                return Colors.green;
                              }
                              return Color(0xFFD9D9D9);
                            }),
                            shape: CircleBorder(),
                            side: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  if (widget.id?.isNotEmpty ?? false) SizedBox(height: 10),
                  if (widget.id == null ||
                      widget.id!.isEmpty ||
                      (widget.id?.isNotEmpty ?? false))
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isChecked2 = !_isChecked2;
                          if (_isChecked2) _isChecked1 = false;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Color(0xFFE0E0E0),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFB7D7F9),
                                  Color(0xFFE5ACCB),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: ClipOval(
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Image.asset(
                                  'assets/call.png', // Use a call-related icon
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            'Buy hassle free call for multiple projects',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 20 / 13,
                              letterSpacing: 0.01,
                              color: Colorfile.textColor,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          subtitle: Text(
                            'Simplify payments with a call bundle avoid multiple transactions.',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              height: 20 / 11,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          trailing: Checkbox(
                            value: _isChecked2,
                            onChanged: (bool? value) {
                              setState(() {
                                _isChecked2 = value ?? false;
                                if (_isChecked2) _isChecked1 = false;
                              });
                            },
                            activeColor: Colors.green,
                            checkColor: Colors.white,
                            fillColor:
                                MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.selected)) {
                                return Colors.green;
                              }
                              return Color(0xFFD9D9D9);
                            }),
                            shape: CircleBorder(),
                            side: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
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
                                  fontWeight: FontWeight.bold,
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
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 48,
                        child: CupertinoButton(
                          onPressed: _isLoading
                              ? null // Disable button during loading
                              : () {
                                  if (_isChecked1) {
                                    // Show confirmation dialog for first option
                                    _showConfirmationDialog();
                                  } else if (_isChecked2) {
                                    // Navigate to Buycall for second option
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Buycall()),
                                    );
                                  } else {
                                    // Show message if no option is selected
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Please select an option to proceed."),
                                      ),
                                    );
                                  }
                                },
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          color: Colorfile.textColor,
                          borderRadius: BorderRadius.circular(8),
                          child: _isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Unlock Your Call Now',
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
