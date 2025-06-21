import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../Colors/colorfile.dart';
import '../api/network/uri.dart';

class CallsList extends StatelessWidget {
  final List<dynamic> calls;
  final String projectId;

  const CallsList({super.key, required this.calls, required this.projectId});

  Future<void> _openPhoneDialer(String mobileNo, BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: mobileNo);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot launch phone dialer',
                style: GoogleFonts.montserrat()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to launch phone dialer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open phone dialer',
              style: GoogleFonts.montserrat()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Softer background for minimal look
      appBar: AppBar(
        title: Text(
          'Call List',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colorfile.textColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        // centerTitle: true, // Centered title for cleaner look
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0), // Thin border height
          child: Container(
            color: Colors.grey.shade300, // Light grey border
            height: 1.0, // Border thickness
          ),
        ),
      ),
      body: calls.isEmpty
          ? Center(
              child: Text(
                'No calls available',
                style: GoogleFonts.montserrat(
                  color: Colors.black45,
                  fontSize: 14, // Smaller font for subtlety
                  fontWeight: FontWeight.w400,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12), // Reduced padding
              itemCount: calls.length,
              itemBuilder: (context, index) {
                final call = calls[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 6), // Tighter spacing
                  elevation: 0, // No shadow for flat design
                  color: Colors.white,

                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFE2E2E2),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10), // Reduced padding
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // Center alignment
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 35.0),
                            child: CircleAvatar(
                              radius: 20, // Smaller avatar
                              backgroundImage: call['profile_pic_url'] !=
                                          null &&
                                      call['profile_pic_url'].isNotEmpty
                                  ? NetworkImage(call['profile_pic_url'])
                                  : const NetworkImage(
                                      'https://www.quickensol.com/quickenlancer-new/images/profile_pic/profile.png'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${call['f_name'] ?? ''} ${call['l_name'] ?? ''}',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.black87,
                                    fontSize: 14, // Smaller, cleaner font
                                    fontWeight:
                                        FontWeight.w600, // Lighter weight
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Last Call: ${call['sent_on_text'] ?? 'N/A'}',
                                  style: GoogleFonts.montserrat(
                                    color: Colorfile.textColor, // Softer color
                                    fontSize: 11, // Smaller font
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 32, // Smaller button
                                      child: TextButton(
                                        onPressed: () async {
                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          final String? userId =
                                              prefs.getString('user_id');
                                          final String? authToken =
                                              prefs.getString('auth_token');

                                          if (userId == null ||
                                              authToken == null) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'User ID or auth token not available'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }

                                          final String callApiUrl =
                                              URLS().set_call_entry;
                                          final requestBody = jsonEncode({
                                            'user_id': userId,
                                            'project_id': projectId,
                                            'project_owner_id':
                                                call['user_id']?.toString() ??
                                                    userId,
                                            'used_token_id':
                                                call['used_token_id']
                                                        ?.toString() ??
                                                    '',
                                          });
                                          debugPrint(
                                              'API Request Body: $requestBody');

                                          try {
                                            final callResponse =
                                                await http.post(
                                              Uri.parse(callApiUrl),
                                              headers: {
                                                'Content-Type':
                                                    'application/json',
                                                'Authorization':
                                                    'Bearer $authToken',
                                              },
                                              body: requestBody,
                                            );

                                            debugPrint(
                                                'API Response Status: ${callResponse.statusCode}');
                                            debugPrint(
                                                'API Response Body: ${callResponse.body}');

                                            if (callResponse.statusCode ==
                                                    200 ||
                                                callResponse.statusCode ==
                                                    201) {
                                              final responseData =
                                                  jsonDecode(callResponse.body);
                                              if (responseData['status'] ==
                                                      'true' &&
                                                  responseData['data'] !=
                                                      null) {
                                                final String receiverMobileNo =
                                                    responseData['data']
                                                        ['receiver_mobile_no'];
                                                _openPhoneDialer(
                                                    receiverMobileNo, context);
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Invalid response from server. Please try again.'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Failed to initiate call. Please try again.'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            debugPrint(
                                                'Error during API call: $e');
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'An error occurred. Please try again.'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Color(0xFF191E3E),
                                          backgroundColor: Color(0xFFFFFFFF),
                                          side: BorderSide(
                                            color: Color(0xFF191E3E),
                                            width: 1.0,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                6), // Softer corners
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 0),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.phone,
                                                size: 14,
                                                color: Color(0xFF191E3E)),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Call',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 12, // Smaller font
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF191E3E),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (call['is_hire_me_button'] == 1)
                                      SizedBox(
                                        height: 32, // Smaller button
                                        child: TextButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Hire Me action triggered',
                                                  style: GoogleFonts.montserrat(
                                                    color: Colors
                                                        .black, // Black text
                                                  ),
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors
                                                .black, // Black text for interaction states
                                            backgroundColor: Colors
                                                .transparent, // Transparent to show gradient
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 0),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFFB7D7F9), // #B7D7F9
                                                  Color(0xFFE6ACCB), // #E6ACCB
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                transform: GradientRotation(127.3 *
                                                    3.1415927 /
                                                    180), // Convert degrees to radians
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Hire Me',
                                                  style: GoogleFonts.montserrat(
                                                    fontSize:
                                                        12, // Smaller font
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors
                                                        .black, // Black text
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
