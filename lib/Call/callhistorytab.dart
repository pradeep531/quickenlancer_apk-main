import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import 'package:quickenlancer_apk/Models/history_model.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Added for date formatting

import '../api/network/uri.dart';

class Callhistorytab extends StatefulWidget {
  const Callhistorytab({super.key});

  @override
  _CallHistoryTabState createState() => _CallHistoryTabState();
}

class _CallHistoryTabState extends State<Callhistorytab> {
  late Future<List<History>> history;

  @override
  void initState() {
    super.initState();
    history = _fetchHistoryData(); // Using a function to fetch history data
  }

  // Function to format date to Indian format (DD-MM-YYYY)
  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == 'Not Yet Allocated') {
      return dateStr ?? 'Not Yet Allocated';
    }
    try {
      final date = DateTime.parse(dateStr);
      final formatter = DateFormat('dd-MM-yyyy');
      return formatter.format(date);
    } catch (e) {
      return dateStr; // Return original string if parsing fails
    }
  }

  // Fetching history data function
  Future<List<History>> _fetchHistoryData() async {
    try {
      // Get user ID and auth token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final String? authToken = prefs.getString('auth_token');

      // API URL
      final String apiUrl = URLS().get_history;

      // Request body
      final Map<String, dynamic> requestBody = {
        "user_id": userId,
        "token_for": 2
      };

      // Make the POST request with Bearer token
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(requestBody),
      );

      // Print the raw response
      log('API Response: ${response.body}');

      // Check if the response is successful
      if (response.statusCode == 200) {
        // Parse the response JSON
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 'true' && jsonData['data'] != null) {
          final List<dynamic> resultObject = jsonData['data']['result_object'];
          // Map the API data to a list of History objects
          return resultObject
              .map((data) => History.fromJson({
                    'allocatedOn': (data['allocate_date'] == null ||
                            data['allocate_date'].toString().isEmpty)
                        ? 'Not Yet Allocated'
                        : data['allocate_date'],
                    'purchasedOn': data['created_on'] ?? '',
                    'tokenNo': data['token_no'] ?? '',
                    'allocatedProject': data['project_name'] ?? 'Not Assigned',
                    'projectDescription':
                        data['project_name'] ?? 'No Description',
                  }))
              .toList();
        } else {
          throw Exception('Invalid response: ${jsonData['message']}');
        }
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching history: $e');
      throw Exception('Error fetching history: $e');
    }
  }

  // Function to handle refresh
  Future<void> _refreshData() async {
    setState(() {
      history = _fetchHistoryData(); // Trigger a refresh by updating the future
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData, // Add swipe-to-refresh functionality
      child: FutureBuilder<List<History>>(
        future: history,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Skeleton loader during loading state
            return Center(
              child: SingleChildScrollView(
                child: SkeletonLoader(
                  builder: Column(
                    children: List.generate(
                      5, // Show skeleton for 5 items
                      (_) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          height: 250,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final historyDataList = snapshot.data!;
            // Check if the data list is empty
            if (historyDataList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 50,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No Data Available',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  children: historyDataList.map((historyData) {
                    return Container(
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
                        borderRadius: BorderRadius.circular(6),
                      ),
                      width: double.infinity,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(0.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Payment Status',
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF424752),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          // Text(
                                          //   _formatDate(
                                          //       historyData.allocatedOn),
                                          //   style: GoogleFonts.poppins(
                                          //     fontSize: 13,
                                          //     fontWeight: FontWeight.w500,
                                          //     color: Color(0xFF424752),
                                          //   ),
                                          // ),
                                          Text(
                                            'NA',
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF424752),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 50,
                                      color: Color(0xFFB7D7F9),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Purchased On',
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF424752),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            _formatDate(
                                                historyData.purchasedOn),
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF424752),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 1,
                                  width: double.infinity,
                                  color: Color(0xFFB7D7F9),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Text(
                                      //   'Token No. : ${historyData.tokenNo}',
                                      //   style: GoogleFonts.poppins(
                                      //     fontSize: 13,
                                      //     fontWeight: FontWeight.w600,
                                      //     color: Colorfile.textColor,
                                      //   ),
                                      // ),
                                      // SizedBox(height: 8),
                                      Text(
                                        'Allocated Project: ${historyData.allocatedProject}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colorfile.textColor,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        historyData.projectDescription,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF424752),
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
                    );
                  }).toList(),
                ),
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 50,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Data Available',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
