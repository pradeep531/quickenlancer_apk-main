import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:quickenlancer_apk/Call/buycall.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../api/network/uri.dart';
import '../Colors/colorfile.dart';
import '../chat_page.dart';
import 'all_proposals.dart';
import 'calls_list.dart';
import 'chat_list.dart';
import 'schedule_availability.dart';

class PostedProjectsTab extends StatefulWidget {
  const PostedProjectsTab({super.key});

  @override
  State<PostedProjectsTab> createState() => _PostedProjectsPageState();
}

class _PostedProjectsPageState extends State<PostedProjectsTab>
    with TickerProviderStateMixin {
  List<dynamic> projects = [];
  int offset = 0;
  bool isLoading = false, hasMore = true;
  final int limit = 10;
  Map<String, bool> descriptionExpandedMap = {};
  Map<String, TabController> tabControllers = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchProjects();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.9 &&
          !isLoading &&
          hasMore) {
        _fetchProjects();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    tabControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _fetchProjects() async {
    if (isLoading || !hasMore) return;
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final requestBody = jsonEncode({
        "user_id": prefs.getString('user_id') ?? "0",
        "limit": limit,
        "offset": offset,
      });
      print('Request Body: $requestBody');

      final response = await http.post(
        Uri.parse(URLS().posted_project),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('auth_token') ?? ''}',
        },
        body: requestBody,
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        log('Decoded Response: $jsonResponse');

        if (jsonResponse['status'] == 'true') {
          setState(() {
            projects.addAll(jsonResponse['data']);
            jsonResponse['data'].forEach((project) {
              final hasHiredData =
                  project['purchased_by'] is Map<String, dynamic> &&
                      project['purchased_by'].isNotEmpty;
              tabControllers[project['project_id'].toString()] =
                  TabController(length: hasHiredData ? 4 : 3, vsync: this);
            });
            offset += limit;
            hasMore = jsonResponse['data'].length == limit;
            isLoading = false;
          });
        } else {
          setState(() => isLoading = hasMore = false);
        }
      } else {
        setState(() => isLoading = hasMore = false);
      }
    } catch (e) {
      setState(() => isLoading = hasMore = false);
      log('Error: $e');
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      projects.clear();
      offset = 0;
      hasMore = true;
      descriptionExpandedMap.clear();
      tabControllers.forEach((_, controller) => controller.dispose());
      tabControllers.clear();
    });
    await _fetchProjects();
  }

  Future<void> _openPhoneDialer(String mobileNo) async {
    final uri = Uri(scheme: 'tel', path: mobileNo);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Cannot launch phone dialer', Colors.red);
      }
    } catch (e) {
      log('Failed to launch phone dialer: $e');
      _showSnackBar('Unable to open phone dialer', Colors.red);
    }
  }

  Future<void> _downloadImage(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Could not launch URL', Colors.red);
      }
    } catch (e) {
      log('Failed to open URL: $e');
      _showSnackBar('Unable to open image', Colors.red);
    }
  }

  Future<void> _sendNotification({
    required String projectId,
    required String bidderId,
    required String connectType,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await http.post(
        Uri.parse(URLS().notify_bidder),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('auth_token') ?? ''}',
        },
        body: jsonEncode({
          "user_id": prefs.getString('user_id') ?? "0",
          "bidder_id": bidderId,
          "project_id": projectId,
          "connect_type": connectType,
        }),
      );

      if (response.statusCode == 200 &&
          jsonDecode(response.body)['status'] == 'true') {
        _showSnackBar('Notification Sent!', Colors.green);
      } else {
        throw 'Failed to send notification';
      }
    } catch (e) {
      log('Error sending notification: $e');
      _showSnackBar('Failed to send notification', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message, style: GoogleFonts.montserrat()),
          backgroundColor: color),
    );
  }

  void _showDialog({
    required String title,
    required Widget content,
    List<Widget> actions = const [],
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.2),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 20),

        // Replace title Text with Row containing title and close button
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.montserrat(
                  color: Colors.black.withOpacity(0.87),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  size: 24,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),

        content: Container(
          padding: const EdgeInsets.only(top: 12),
          child: DefaultTextStyle(
            style: GoogleFonts.montserrat(
              color: Colors.black.withOpacity(0.6),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            child: content,
          ),
        ),

        actions: actions.isEmpty ? [] : actions,
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16, left: 16),
        actionsAlignment: MainAxisAlignment.end,
      ),
    );
  }

  void _showAddAvailabilityDialog(String projectId) {
    _showDialog(
      title: 'Project Availability',
      content: Text(
        'No availability set.',
        style: GoogleFonts.montserrat(
          color: Colors.black.withOpacity(0.6),
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            backgroundColor: Colors.grey.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            'Cancel',
            style: GoogleFonts.montserrat(
              color: const Color(0xFF0288D1),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ScheduleAvailabilityPage(projectId: projectId),
              ),
            );
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            backgroundColor: const Color(0xFF0288D1).withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            'Add',
            style: GoogleFonts.montserrat(
              color: const Color(0xFF0288D1),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String title, int count, {double maxWidth = 70}) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(title, overflow: TextOverflow.ellipsis)),
          if (count > 0)
            Padding(
              padding: const EdgeInsets.only(left: 3),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                    color: Colors.grey, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                child: Text('$count',
                    style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCallTab(Map<String, dynamic> project) {
    final calls = project['project_calls'] as List<dynamic>? ?? [];
    return SingleChildScrollView(
      child: Column(
        children: [
          if (calls.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No calls available',
                style: GoogleFonts.montserrat(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            ...calls.take(3).map((call) => Card(
                  // Limit to 3 calls
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                  color: Colors.white,
                  shape: const Border(
                      bottom: BorderSide(color: Color(0xFFDDDDDD), width: 1)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: call['profile_pic_url'] != null &&
                                  call['profile_pic_url'].isNotEmpty
                              ? NetworkImage(call['profile_pic_url'])
                              : const NetworkImage(
                                  'https://www.quickensol.com/quickenlancer-new/images/profile_pic/profile.png'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${call['f_name'] ?? ''} ${call['l_name'] ?? ''}',
                                style: GoogleFonts.montserrat(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Last Call On: ${call['sent_on_text'] ?? 'N/A'}',
                                style: GoogleFonts.montserrat(
                                  color: Colors.black54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  SizedBox(
                                    height: 36,
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
                                          'project_id':
                                              project['project_id'].toString(),
                                          'project_owner_id':
                                              project['user_id']?.toString() ??
                                                  userId,
                                          'used_token_id': call['used_token_id']
                                                  ?.toString() ??
                                              '',
                                        });
                                        debugPrint(
                                            'API Request Body: $requestBody');

                                        try {
                                          final callResponse = await http.post(
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

                                          if (callResponse.statusCode == 200 ||
                                              callResponse.statusCode == 201) {
                                            final responseData =
                                                jsonDecode(callResponse.body);
                                            if (responseData['status'] ==
                                                    'true' &&
                                                responseData['data'] != null) {
                                              final String receiverMobileNo =
                                                  responseData['data']
                                                      ['receiver_mobile_no'];
                                              _openPhoneDialer(
                                                  receiverMobileNo);
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
                                        foregroundColor: Colorfile.textColor,
                                        side: const BorderSide(
                                            color: Colorfile.textColor,
                                            width: 1),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 0),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.phone,
                                              size: 15,
                                              color: Colorfile.textColor),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Call',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  if (call['is_hire_me_button'] == 1)
                                    SizedBox(
                                      height: 36,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFFB7D7F9),
                                              Color(0xFFE6ACCB)
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4)),
                                        ),
                                        child: TextButton(
                                          onPressed: () {
                                            _showSnackBar(
                                                'Hire Me action triggered',
                                                Colors.green);
                                          },
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 0),
                                          ),
                                          child: Text(
                                            'Hire Me',
                                            style: GoogleFonts.montserrat(
                                              color: Colorfile.textColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
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
                )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CallsList(
                            calls: calls, // Pass the calls list
                            projectId: project['project_id']
                                .toString(), // Pass projectId
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colorfile.textColor,
                      side: const BorderSide(
                          color: Colorfile.textColor, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(6), // Changed from 4 to 6
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View All',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                            width: 8), // spacing between text and arrow
                        const Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Colorfile.textColor,
                        ),
                      ],
                    ),
                  ),
                ),

                // const SizedBox(height: 8),
                // SizedBox(
                //   width: double.infinity,
                //   height: 48,
                //   child: ElevatedButton(
                //     onPressed: () {},
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Color(0xFF51A5D1),
                //       shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(4)),
                //     ),
                //     child: Row(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         Text(
                //           'Send Proposal',
                //           style: GoogleFonts.montserrat(
                //             color: Colors.white,
                //             fontSize: 14,
                //             fontWeight: FontWeight.w500,
                //           ),
                //         ),
                //         const SizedBox(width: 8),
                //         Image.asset(
                //           'assets/send1.png',
                //           height: 18,
                //           width: 18,
                //           color: Colors.white,
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab(Map<String, dynamic> project) {
    final chats = project['project_chats'] as List<dynamic>? ?? [];
    return SingleChildScrollView(
      child: Column(
        children: [
          if (chats.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No chats available',
                style: GoogleFonts.montserrat(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            ...chats.take(3).map((chat) => Card(
                  // Limit to 3 chats
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                  color: Colors.white,
                  shape: const Border(
                      bottom: BorderSide(color: Color(0xFFDDDDDD), width: 1)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: chat['profile_pic_url'] != null &&
                                  chat['profile_pic_url'].isNotEmpty
                              ? NetworkImage(chat['profile_pic_url'])
                              : const NetworkImage(
                                  'https://www.quickensol.com/quickenlancer-new/images/profile_pic/profile.png'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${chat['f_name'] ?? ''} ${chat['l_name'] ?? ''}',
                                style: GoogleFonts.montserrat(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Last Chat On: ${chat['sent_on_text'] ?? 'N/A'}',
                                style: GoogleFonts.montserrat(
                                  color: Colors.black54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  SizedBox(
                                    height: 36,
                                    child: TextButton(
                                      onPressed: () async {
                                        final prefs = await SharedPreferences
                                            .getInstance();
                                        final String? userId =
                                            prefs.getString('user_id');

                                        if (userId == null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text('User ID not available'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }

                                        final String? receiverId =
                                            chat['receiver_id']?.toString();

                                        if (receiverId == null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Receiver ID not available'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatPage(
                                              projectId: project['project_id']
                                                  .toString(),
                                              chatSender:
                                                  project['user_id'].toString(),
                                              chatReceiver:
                                                  receiverId.toString(),
                                            ),
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colorfile.textColor,
                                        side: const BorderSide(
                                            color: Colorfile.textColor,
                                            width: 1),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 0),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.chat,
                                              size: 15,
                                              color: Colorfile.textColor),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Chat',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  if (chat['is_hire_me_button'] == 1)
                                    SizedBox(
                                      height: 36,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFFB7D7F9),
                                              Color(0xFFE6ACCB)
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4)),
                                        ),
                                        child: TextButton(
                                          onPressed: () {
                                            _showSnackBar(
                                                'Hire Me action triggered',
                                                Colors.green);
                                          },
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 0),
                                          ),
                                          child: Text(
                                            'Hire Me',
                                            style: GoogleFonts.montserrat(
                                              color: Colorfile.textColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
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
                )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatList(
                            projectId: project['project_id'].toString(),
                            chatSender: project['user_id']?.toString() ?? '',
                            chatReceiver:
                                project['chat_receiver']?.toString() ?? '',
                            chats: chats, // Pass the chats list
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colorfile.textColor,
                      side: const BorderSide(
                          color: Colorfile.textColor, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(6), // Changed from 4 to 6
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'View All',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8), // space between text and icon
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ),
                // const SizedBox(height: 8),
                // SizedBox(
                //   width: double.infinity,
                //   height: 48,
                //   child: ElevatedButton(
                //     onPressed: () {},
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Color(0xFF51A5D1),
                //       shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(4)),
                //     ),
                //     child: Row(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         Text(
                //           'Send Proposal',
                //           style: GoogleFonts.montserrat(
                //             color: Colors.white,
                //             fontSize: 14,
                //             fontWeight: FontWeight.w500,
                //           ),
                //         ),
                //         const SizedBox(width: 8),
                //         Image.asset(
                //           'assets/send1.png',
                //           height: 18,
                //           width: 18,
                //           color: Colors.white,
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _proposalTab(Map<String, dynamic> project) {
    final proposals = project['project_proposals'] as List<dynamic>? ?? [];
    return SingleChildScrollView(
      child: Column(
        children: [
          if (proposals.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No proposals available',
                style: GoogleFonts.montserrat(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            ...proposals.take(3).map((proposal) => Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                  color: Colors.white,
                  shape: const Border(
                      bottom: BorderSide(color: Color(0xFFDDDDDD), width: 1)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: proposal['profile_pic_url'] !=
                                      null &&
                                  proposal['profile_pic_url'].isNotEmpty
                              ? NetworkImage(proposal['profile_pic_url'])
                              : const NetworkImage(
                                  'https://www.quickensol.com/quickenlancer-new/images/profile_pic/profile.png'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${proposal['f_name'] ?? ''} ${proposal['l_name'] ?? ''}',
                                style: GoogleFonts.montserrat(
                                  color: Colorfile.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sent On: ${proposal['sent_on_text'] ?? 'N/A'}',
                                style: GoogleFonts.montserrat(
                                  color: Colorfile.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 36,
                                      child: TextButton(
                                        onPressed: () {
                                          _showSnackBar(
                                              'Milestone action triggered',
                                              Colors.green);
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Color(0xFF000000),
                                          side: const BorderSide(
                                              color: Color(0xFF000000),
                                              width: 1),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 0),
                                        ),
                                        child: Text(
                                          'Milestone',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    if (proposal['is_hire_me_button'] == 1)
                                      SizedBox(
                                        height: 36,
                                        child: TextButton(
                                          onPressed: () {
                                            _showSnackBar(
                                                'Hire Me action triggered',
                                                Colors.green);
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: Color(0xFF000000),
                                            side: const BorderSide(
                                                color: Color(0xFF000000),
                                                width: 1),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4)),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 0),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.asset(
                                                'assets/attachment.png',
                                                height: 18,
                                                width: 18,
                                                color: Color(0xFF000000),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Attachment',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
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
                )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllProposals(
                            projectId: project['project_id'].toString(),
                            proposals: proposals,
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF000000),
                      side:
                          const BorderSide(color: Color(0xFF000000), width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(6), // changed from 4 to 6
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'View All',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8), // space between text and icon
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ),
                // const SizedBox(height: 8),
                // SizedBox(
                //   width: double.infinity,
                //   height: 48,
                //   child: ElevatedButton(
                //     onPressed: () {},
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Color(0xFF51A5D1),
                //       shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(4)),
                //     ),
                //     child: Row(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         Text(
                //           'Send Proposal',
                //           style: GoogleFonts.montserrat(
                //             color: Colors.white,
                //             fontSize: 14,
                //             fontWeight: FontWeight.w500,
                //           ),
                //         ),
                //         const SizedBox(width: 8),
                //         Image.asset(
                //           'assets/send1.png',
                //           height: 18,
                //           width: 18,
                //           color: Colors.white,
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required TextStyle style,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: style,
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ?? style,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityRow(
      Map<String, dynamic> job, TextStyle jobTextStyle, String projectId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Availability Time',
            style: jobTextStyle,
          ),
          const Spacer(), // Pushes the button to the rightmost side
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              final availability =
                  job['time_availability'] as Map<String, dynamic>?;
              if (availability == null ||
                  ![
                    'monday',
                    'tuesday',
                    'wednesday',
                    'thursday',
                    'friday',
                    'saturday',
                    'sunday'
                  ].any((day) => availability[day] == '1')) {
                _showAddAvailabilityDialog(projectId);
              } else {
                final result = [
                  'monday',
                  'tuesday',
                  'wednesday',
                  'thursday',
                  'friday',
                  'saturday',
                  'sunday'
                ]
                    .where((day) => availability[day] == '1')
                    .map((day) => {
                          'day': day.capitalize(),
                          'from': availability['from_$day'] ?? 'N/A',
                          'to': availability['to_$day'] ?? 'N/A',
                        })
                    .toList();

                _showDialog(
                  title: 'Availability',
                  content: result.isEmpty
                      ? Text(
                          'No availability specified',
                          style: jobTextStyle,
                        )
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: result.map((slot) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 80.0,
                                      child: Text(
                                        slot['day'],
                                        style: jobTextStyle.copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFFFFF),
                                          border: Border.all(
                                              color: const Color(0xFFDADADA)),
                                          borderRadius:
                                              BorderRadius.circular(6.0),
                                        ),
                                        child: Text(
                                          slot['from'],
                                          style: jobTextStyle.copyWith(
                                            fontSize: 12.0,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFFFFF),
                                          border: Border.all(
                                              color: const Color(0xFFDADADA)),
                                          borderRadius:
                                              BorderRadius.circular(6.0),
                                        ),
                                        child: Text(
                                          slot['to'],
                                          style: jobTextStyle.copyWith(
                                            fontSize: 12.0,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                );
              }
            },
            child: Text(
              (job['time_availability'] as Map<String, dynamic>?)?.entries.any(
                          (entry) =>
                              [
                                'monday',
                                'tuesday',
                                'wednesday',
                                'thursday',
                                'friday',
                                'saturday',
                                'sunday'
                              ].contains(entry.key) &&
                              entry.value == '1') ==
                      true
                  ? 'Schedule'
                  : 'Add Schedule',
              style: jobTextStyle.copyWith(
                decoration: TextDecoration.underline,
                color: Colors.blue,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobTextStyle = GoogleFonts.montserrat(
        color: Colorfile.textColor,
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        height: 1.47);
    return Scaffold(
      backgroundColor: const Color(0xFFE8F1FC),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: projects.isEmpty && isLoading
            ? const Center(child: CircularProgressIndicator())
            : projects.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inbox_outlined,
                            size: 60, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text('No Data Found',
                            style: GoogleFonts.montserrat(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: projects.length + (isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == projects.length && isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final job = projects[index];
                      final projectId = job['project_id'].toString();
                      final purchasedBy = job['purchased_by'];
                      final imagePath =
                          job['imagePath'] as List<dynamic>? ?? [];
                      final proposals = job['proposals'] is Map<String, dynamic>
                          ? job['proposals']
                          : job['proposals'] is List &&
                                  job['proposals'].isNotEmpty
                              ? job['proposals'][0]
                              : null;
                      final callCount =
                          (job['project_calls'] as List<dynamic>?)?.length ?? 0;
                      final chatCount =
                          (job['project_chats'] as List<dynamic>?)?.length ?? 0;
                      final proposalCount =
                          (job['project_proposals'] as List<dynamic>?)
                                  ?.length ??
                              0;
                      final hasHiredData =
                          purchasedBy is Map<String, dynamic> &&
                              purchasedBy.isNotEmpty;

                      return DefaultTabController(
                        length: hasHiredData ? 4 : 3,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                                colors: [Color(0xFFB7D7F9), Color(0xFFE5ACCB)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(0.5),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(job['project_name'] ?? 'No Title',
                                    style: GoogleFonts.montserrat(
                                        color: Colorfile.textColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [
                                      Color(0xFF51A5D1),
                                      Color(0xFF82399C),
                                      Color(0xFFF04E80)
                                    ]),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.all(1),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildInfoRow(
                                          label: 'Posted On',
                                          value:
                                              job['created_on']?.isNotEmpty ==
                                                      true
                                                  ? DateFormat('dd/MM/yyyy')
                                                      .format(DateTime.parse(
                                                          job['created_on']))
                                                  : 'N/A',
                                          style: jobTextStyle,
                                        ),
                                        _buildInfoRow(
                                          label: 'Project Cost',
                                          value: job['amount'] ?? 'No Amount',
                                          style: jobTextStyle,
                                        ),
                                        _buildInfoRow(
                                          label: 'How to Pay',
                                          value: job['project_type'] == '0'
                                              ? 'Fixed'
                                              : job['project_type'] == '1'
                                                  ? 'Hourly'
                                                  : 'N/A',
                                          style: jobTextStyle,
                                        ),
                                        _buildAvailabilityRow(
                                            job, jobTextStyle, projectId),
                                        _buildInfoRow(
                                          label: 'Requirement Type',
                                          value: job['requirement_type'] == '0'
                                              ? 'Cold'
                                              : job['requirement_type'] == '1'
                                                  ? 'Hot'
                                                  : 'N/A',
                                          style: jobTextStyle,
                                        ),
                                        _buildInfoRow(
                                          label: 'Looking For:',
                                          value: job['looking_for'] == '1'
                                              ? 'Company'
                                              : job['looking_for'] == '2'
                                                  ? 'Freelancer'
                                                  : 'Company/Freelancer',
                                          style: jobTextStyle,
                                        ),
                                        _buildInfoRow(
                                          label: 'Status',
                                          value: job['button_label'],
                                          valueStyle: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                            color: job['project_status'] == '0'
                                                ? Colors.grey
                                                : job['project_status'] == '1'
                                                    ? Colors.green
                                                    : Colors.red,
                                          ),
                                          style: jobTextStyle,
                                        ),
                                        if (proposals != null) ...[
                                          _buildInfoRow(
                                            label: 'Max Proposal Cost',
                                            value: proposals['max_mston_amount']
                                                    ?.toString() ??
                                                'N/A',
                                            style: jobTextStyle,
                                          ),
                                          _buildInfoRow(
                                            label: 'Min Proposal Cost',
                                            value: proposals['min_mston_amount']
                                                    ?.toString() ??
                                                'N/A',
                                            style: jobTextStyle,
                                          ),
                                          _buildInfoRow(
                                            label: 'Avg Proposal Cost',
                                            value: proposals[
                                                        'average_mston_amount']
                                                    ?.toString() ??
                                                'N/A',
                                            style: jobTextStyle,
                                          ),
                                          _buildInfoRow(
                                            label: 'Total Proposals',
                                            value: proposals['total_proposal']
                                                    ?.toString() ??
                                                'N/A',
                                            style: jobTextStyle,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  children: (job['skills'] as List<dynamic>? ??
                                          [])
                                      .map((skill) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8.0),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFE8F1FC),
                                                  borderRadius:
                                                      BorderRadius.circular(4)),
                                              child: Text(skill['skill'] ?? '',
                                                  style: GoogleFonts.montserrat(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          Colorfile.textColor)),
                                            ),
                                          ))
                                      .toList(),
                                ),
                                Text(
                                  descriptionExpandedMap[projectId] == true
                                      ? 'Description: ${job['description']?.replaceAll(RegExp(r'<[^>]+>'), '') ?? 'No Description'}'
                                      : 'Description: ${(job['description']?.replaceAll(RegExp(r'<[^>]+>'), '') ?? 'No Description').length > 100 ? job['description'].replaceAll(RegExp(r'<[^>]+>'), '').substring(0, 100) + '...' : job['description']?.replaceAll(RegExp(r'<[^>]+>'), '') ?? 'No Description'}',
                                  style: GoogleFonts.montserrat(
                                      color: Colorfile.textColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500),
                                ),
                                if ((job['description']?.replaceAll(
                                                RegExp(r'<[^>]+>'), '') ??
                                            '')
                                        .length >
                                    100)
                                  GestureDetector(
                                    onTap: () => setState(() =>
                                        descriptionExpandedMap[projectId] =
                                            !(descriptionExpandedMap[
                                                    projectId] ??
                                                false)),
                                    child: Text(
                                        descriptionExpandedMap[projectId] ==
                                                true
                                            ? 'Show Less'
                                            : 'Show More',
                                        style: const TextStyle(
                                            color: Colors.blue, fontSize: 10)),
                                  ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () => _showDialog(
                                          title: 'Attachment',
                                          content: imagePath.isEmpty
                                              ? Text(
                                                  'No attachments available',
                                                  style: GoogleFonts.montserrat(
                                                    color: Colorfile.textColor,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                                )
                                              : SizedBox(
                                                  height: 300,
                                                  width: 250,
                                                  child: ListView.builder(
                                                    itemCount: imagePath.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final url =
                                                          imagePath[index];
                                                      return Container(
                                                        height: 50,
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            vertical: 2),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12),
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color: Color(
                                                                  0xFFDADADA)), // 1px solid #DADADA
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              'Document ${index + 1}',
                                                              style: GoogleFonts
                                                                  .montserrat(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colorfile
                                                                    .textColor,
                                                              ),
                                                            ),
                                                            const Spacer(), // Push the icon to the right
                                                            GestureDetector(
                                                              onTap: () =>
                                                                  _showDialog(
                                                                title:
                                                                    'Confirm Download',
                                                                content: Text(
                                                                  'Download this file?',
                                                                  style: GoogleFonts
                                                                      .montserrat(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colorfile
                                                                        .textColor,
                                                                  ),
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            context),
                                                                    child: Text(
                                                                      'No',
                                                                      style: GoogleFonts
                                                                          .montserrat(
                                                                        color: Colors
                                                                            .blue,
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                      Navigator.pop(
                                                                          context);
                                                                      _downloadImage(
                                                                          url);
                                                                    },
                                                                    child: Text(
                                                                      'Yes',
                                                                      style: GoogleFonts
                                                                          .montserrat(
                                                                        color: Colors
                                                                            .blue,
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: const Icon(
                                                                Icons.download,
                                                                color:
                                                                    Colors.grey,
                                                                size:
                                                                    24, // You can fine-tune the size if needed
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                        ),
                                        style: TextButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFFAFAFA),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            side: const BorderSide(
                                                color: Color(0xFFD9D9D9)),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${imagePath.length} Attachment${imagePath.length == 1 ? '' : 's'}',
                                              style: GoogleFonts.montserrat(
                                                color: Colorfile.textColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Transform.rotate(
                                              angle: 0.6,
                                              child: const Icon(
                                                Icons.attach_file,
                                                color: Colorfile.textColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                TabBar(
                                  indicator: GradientTabIndicator(
                                      gradient: LinearGradient(colors: [
                                    Color(0xFF51A5D1),
                                    Color(0xFF82399C),
                                    Color(0xFFF04E80)
                                  ])),
                                  controller: tabControllers[projectId],
                                  labelColor: Colorfile.textColor,
                                  unselectedLabelColor: Colors.black54,
                                  labelStyle: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                  unselectedLabelStyle: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                  labelPadding: const EdgeInsets.symmetric(
                                      horizontal: 6.0),
                                  tabs: [
                                    if (hasHiredData)
                                      const Tab(text: 'Hired On'),
                                    Tab(child: _buildTab('Call', callCount)),
                                    Tab(child: _buildTab('Chat', chatCount)),
                                    Tab(
                                        child: _buildTab(
                                            'Proposal', proposalCount,
                                            maxWidth: 90)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 110,
                                  child: TabBarView(
                                    controller: tabControllers[projectId],
                                    children: [
                                      if (hasHiredData)
                                        SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      CircleAvatar(
                                                          radius: 20,
                                                          backgroundImage:
                                                              NetworkImage(purchasedBy[
                                                                      'profile_pic'] ??
                                                                  'https://www.quickensol.com/quickenlancer-new/images/profile_pic/profile.png')),
                                                      const SizedBox(width: 10),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              '${purchasedBy['f_name'] ?? ''} ${purchasedBy['l_name'] ?? ''}',
                                                              style: GoogleFonts.montserrat(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colorfile
                                                                      .textColor)),
                                                          Row(
                                                            children: [
                                                              purchasedBy['country_flag_path'] !=
                                                                      null
                                                                  ? Image.network(
                                                                      purchasedBy[
                                                                          'country_flag_path'],
                                                                      height:
                                                                          20,
                                                                      width: 20,
                                                                      errorBuilder: (_, __, ___) => const Icon(
                                                                          Icons
                                                                              .image,
                                                                          size:
                                                                              20,
                                                                          color: Colors
                                                                              .grey))
                                                                  : const Icon(
                                                                      Icons
                                                                          .image,
                                                                      size: 20,
                                                                      color: Colors
                                                                          .grey),
                                                              const SizedBox(
                                                                  width: 4),
                                                              Text(
                                                                  '${purchasedBy['city_name'] ?? ''}, ${purchasedBy['country_name'] ?? ''}',
                                                                  style: GoogleFonts.montserrat(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .black54)),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      if (purchasedBy[
                                                                  'chat_button_redirections']
                                                              ?.isNotEmpty ??
                                                          false)
                                                        GestureDetector(
                                                          onTap: () {
                                                            if (purchasedBy[
                                                                    'chat_button_redirections'] ==
                                                                'chat_page') {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) => ChatPage(
                                                                          projectId:
                                                                              projectId,
                                                                          chatSender: job['chat_sender']
                                                                              .toString(),
                                                                          chatReceiver:
                                                                              job['chat_receiver'].toString())));
                                                            } else if (purchasedBy[
                                                                    'chat_button_redirections'] ==
                                                                'send_chat_notification') {
                                                              _showDialog(
                                                                title:
                                                                    'Send Notification',
                                                                content: Text(
                                                                    'Do you want to send a chat notification?',
                                                                    style: GoogleFonts.montserrat(
                                                                        color: Colorfile
                                                                            .textColor,
                                                                        fontSize:
                                                                            12)),
                                                                actions: [
                                                                  TextButton(
                                                                      onPressed: () =>
                                                                          Navigator.pop(
                                                                              context),
                                                                      child: Text(
                                                                          'No',
                                                                          style: GoogleFonts.montserrat(
                                                                              color: Colors.blue,
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w500))),
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                      _sendNotification(
                                                                          projectId:
                                                                              projectId,
                                                                          bidderId: purchasedBy['bidder_id']
                                                                              .toString(),
                                                                          connectType:
                                                                              '2');
                                                                    },
                                                                    child: Text(
                                                                        'Yes',
                                                                        style: GoogleFonts.montserrat(
                                                                            color: Colors
                                                                                .blue,
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w500)),
                                                                  ),
                                                                ],
                                                              );
                                                            }
                                                          },
                                                          child: Image.asset(
                                                              'assets/Group 2237886.png',
                                                              height: 30,
                                                              width: 30),
                                                        ),
                                                      const SizedBox(width: 8),
                                                      if (purchasedBy[
                                                                  'call_button_redirections']
                                                              ?.isNotEmpty ??
                                                          false)
                                                        GestureDetector(
                                                          onTap: () {
                                                            if (purchasedBy[
                                                                    'call_button_redirections'] ==
                                                                'open_call_dial') {
                                                              final mobileNo =
                                                                  purchasedBy[
                                                                          'mobile_no'] ??
                                                                      '';
                                                              if (mobileNo
                                                                  .isNotEmpty) {
                                                                _openPhoneDialer(
                                                                    mobileNo);
                                                              } else {
                                                                _showSnackBar(
                                                                    'Mobile number not available',
                                                                    Colors.red);
                                                              }
                                                            } else if (purchasedBy[
                                                                    'call_button_redirections'] ==
                                                                'send_call_notification') {
                                                              _showDialog(
                                                                title:
                                                                    'Send Notification',
                                                                content: Text(
                                                                    'Do you want to send a call notification?',
                                                                    style: GoogleFonts.montserrat(
                                                                        color: Colorfile
                                                                            .textColor,
                                                                        fontSize:
                                                                            12)),
                                                                actions: [
                                                                  TextButton(
                                                                      onPressed: () =>
                                                                          Navigator.pop(
                                                                              context),
                                                                      child: Text(
                                                                          'No',
                                                                          style: GoogleFonts.montserrat(
                                                                              color: Colors.blue,
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w500))),
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                      _sendNotification(
                                                                          projectId:
                                                                              projectId,
                                                                          bidderId: purchasedBy['bidder_id']
                                                                              .toString(),
                                                                          connectType:
                                                                              '1');
                                                                    },
                                                                    child: Text(
                                                                        'Yes',
                                                                        style: GoogleFonts.montserrat(
                                                                            color: Colors
                                                                                .blue,
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w500)),
                                                                  ),
                                                                ],
                                                              );
                                                            }
                                                          },
                                                          child: Image.asset(
                                                              'assets/Group 2237887.png',
                                                              height: 30,
                                                              width: 30),
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const Divider(),
                                              Table(
                                                children: [
                                                  TableRow(children: [
                                                    Text('Hired on',
                                                        style: GoogleFonts
                                                            .montserrat(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .black54)),
                                                    const Text(':',
                                                        textAlign:
                                                            TextAlign.center),
                                                    Text(
                                                        purchasedBy['confirmed_date']
                                                                    ?.isNotEmpty ==
                                                                true
                                                            ? DateFormat(
                                                                    'dd/MM/yyyy')
                                                                .format(DateTime.parse(
                                                                    purchasedBy[
                                                                        'confirmed_date']))
                                                            : '',
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: GoogleFonts
                                                            .montserrat(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .black54)),
                                                  ]),
                                                  TableRow(children: [
                                                    Text('Hired Status',
                                                        style: GoogleFonts
                                                            .montserrat(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .black54)),
                                                    const Text(':',
                                                        textAlign:
                                                            TextAlign.center),
                                                    Text(
                                                        purchasedBy[
                                                                'hired_status'] ??
                                                            '',
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: GoogleFonts
                                                            .montserrat(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .black54)),
                                                  ]),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      _buildCallTab(job),
                                      _buildChatTab(job),
                                      _proposalTab(job),
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
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1)}";
}
