import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/network/uri.dart';
import '../home_page.dart';

class BuyChatTab extends StatefulWidget {
  const BuyChatTab({super.key});

  @override
  _BuyChatTabState createState() => _BuyChatTabState();
}

class _BuyChatTabState extends State<BuyChatTab> {
  int itemCount = 0; // Tracks the count of items
  bool _isLoading = false; // Tracks loading state
  double chatAmountInInr = 1.0; // Default INR amount
  double chatAmountInDollar = 1.0; // Default USD amount
  String currency = 'USD'; // Default currency
  String country = ''; // Store country from SharedPreferences

  @override
  void initState() {
    super.initState();
    _fetchPaymentAmounts(); // Fetch payment amounts on initialization
  }

  // API call to fetch payment amounts
  Future<void> _fetchPaymentAmounts() async {
    final String apiUrl = URLS().payment_amounts;
    final prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('auth_token');
    final String userId = prefs.getString('user_id') ?? '';
    country =
        prefs.getString('country') ?? ''; // Get country from SharedPreferences

    // Set currency based on country
    setState(() {
      currency = country == "101" ? 'INR' : 'USD';
    });

    final Map<String, dynamic> requestBody = {
      "user_id": userId,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(requestBody),
      );

      print('Payment Amounts API Response Status: ${response.statusCode}');
      print('Payment Amounts API Response Body: ${response.body}');

      // Parse the response
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        if (responseData['status'] == "true") {
          setState(() {
            chatAmountInInr =
                double.parse(responseData['data']['chat_amount_in_inr']);
            chatAmountInDollar =
                double.parse(responseData['data']['chat_amount_in_dollar']);
          });
        }
      }
    } catch (e) {
      print('Error during payment amounts API call: $e');
    }
  }

  void _increaseItem() {
    setState(() {
      itemCount++;
    });
  }

  void _decreaseItem() {
    if (itemCount > 0) {
      setState(() {
        itemCount--;
      });
    }
  }

  // Calculate total amount based on currency
  double _calculateTotalAmount() {
    if (currency == 'INR') {
      return itemCount * chatAmountInInr;
    } else {
      return itemCount * chatAmountInDollar;
    }
  }

  // API call to buy tokens
  Future<void> _buyTokens() async {
    setState(() {
      _isLoading = true;
    });

    final String apiUrl = URLS().buy_tokens;
    final prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('auth_token');
    final String userId = prefs.getString('user_id') ?? '';
    final String country = prefs.getString('country') ?? '';

    final String paidVia = country == "101" ? "2" : "1";

    final Map<String, dynamic> requestBody = {
      "user_id": userId,
      "token_for": "1", // Assuming "1" is for chat tokens (adjust if different)
      "quantity": itemCount,
      "paid_via": paidVia,
      "purchase_type": "0",
      "project_id": "",
    };

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

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == "true") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Chat unlocked successfully!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error occurred")),
        );
      }
    } catch (e) {
      print('Error during API call: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error occurred")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Show confirmation dialog
  void _showConfirmationDialog() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Confirm Purchase'),
          content: Text(
              'Are you sure you want to purchase $itemCount chat token(s) for ${currency == 'INR' ? '₹' : '\$'}${_calculateTotalAmount().toStringAsFixed(2)}?'),
          actions: [
            CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                _buyTokens();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(16.0),
          padding: EdgeInsets.all(1.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFB7D7F9),
                Color(0xFFE5ACCB),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          width: double.infinity,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/grp.png',
                        width: 100,
                        height: 100,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        margin: EdgeInsets.all(16.0),
                        padding: EdgeInsets.all(1.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFB7D7F9),
                              Color(0xFFE5ACCB),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: double.infinity,
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFFB7D7F9),
                                                Color(0xFFE5ACCB),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                            ),
                                          ),
                                          child: IconButton(
                                            icon: Icon(Icons.remove,
                                                color: Color(0xFF191E3E)),
                                            onPressed: _decreaseItem,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 8.0),
                                          child: Text(
                                            '$itemCount',
                                            style: GoogleFonts.montserrat(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFFB7D7F9),
                                                Color(0xFFE5ACCB),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                            ),
                                          ),
                                          child: IconButton(
                                            icon: Icon(Icons.add,
                                                color: Color(0xFF191E3E)),
                                            onPressed: _increaseItem,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Display total amount below the counter
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Total: ${currency == 'INR' ? '₹' : '\$'}${_calculateTotalAmount().toStringAsFixed(2)}',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colorfile.textColor,
                        ),
                      ),
                    ),
                    Container(
                      width: 250,
                      height: 48,
                      margin: EdgeInsets.only(top: 16.0),
                      child: CupertinoButton(
                        onPressed: _isLoading || itemCount == 0
                            ? null
                            : () {
                                _showConfirmationDialog();
                              },
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        color: Colorfile.textColor,
                        borderRadius: BorderRadius.circular(8),
                        child: _isLoading
                            ? CupertinoActivityIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Update Profile To Buy Token',
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
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(15),
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buy Hassle Free Chat',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colorfile.textColor,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'With Hassle-Free Chat, you can purchase bulk chats that grant you pre-approved access to projects. This allows you to seamlessly connect with project partners without encountering any obstacles in the process.',
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
        Container(
          width: double.infinity,
          height: 400,
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          decoration: BoxDecoration(
            color: Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(2, (index) {
                  List<String> imagePaths = [
                    'assets/Group 237731.png',
                    'assets/Group 237732.png',
                  ];
                  List<String> labels = [
                    'Pre-Approved Entry',
                    'Seamless Connection',
                  ];

                  return Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: (MediaQuery.of(context).size.width - 40) / 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          imagePaths[index],
                          width: 75,
                          height: 75,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 8),
                        Text(
                          labels[index],
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.43,
                            color: Colorfile.textColor,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(2, (index) {
                  List<String> imagePaths = [
                    'assets/Group 237733.png',
                    'assets/Group 237734.png',
                  ];
                  List<String> labels = [
                    'Time Efficiency',
                    'Open Convenience',
                  ];

                  return Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: (MediaQuery.of(context).size.width - 40) / 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          imagePaths[index],
                          width: 75,
                          height: 75,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 8),
                        Text(
                          labels[index],
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.43,
                            color: Colorfile.textColor,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        )
      ],
    );
  }
}
