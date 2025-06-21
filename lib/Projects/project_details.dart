import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:quickenlancer_apk/Call/buycall.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProjectDetailsPage extends StatefulWidget {
  const ProjectDetailsPage({super.key});

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool descriptionExpanded = false;
  final Map<String, dynamic> project = {
    'project_id': '12345',
    'project_name': 'Mobile App Development',
    'created_on': '2025-06-01T10:00:00Z',
    'amount': '₹5000', // changed
    'project_type': '0',
    'requirement_type': '1',
    'looking_for': '2',
    'project_status': '1',
    'button_label': 'Active',
    'description':
        'Develop a cross-platform mobile application for task management...',
    'skills': [
      {'skill': 'Flutter'},
      {'skill': 'Dart'},
      {'skill': 'API Integration'},
      {'skill': 'UI/UX Design'},
    ],
    'imagePath': [
      'https://example.com/doc1.pdf',
      'https://example.com/doc2.pdf'
    ],
    'proposals': {
      'max_mston_amount': '₹5500', // changed
      'min_mston_amount': '₹4500', // changed
      'average_mston_amount': '₹5000', // changed
      'total_proposal': '5',
    },
    'project_calls': [
      {
        'profile_pic_url':
            'https://www.quickensol.com/quickenlancer-new/images/profile_pic/profile.png',
        'f_name': 'Alice',
        'l_name': 'Smith',
        'sent_on_text': '2025-06-05 14:30',
        'is_hire_me_button': 1,
        'mobile_no': '+1234567891',
      },
    ],
    'project_chats': [
      {
        'profile_pic_url':
            'https://www.quickensol.com/quickenlancer-new/images/profile_pic/profile.png',
        'f_name': 'Bob',
        'l_name': 'Johnson',
        'sent_on_text': '2025-06-06 09:15',
        'is_hire_me_button': 1,
      },
    ],
    'project_proposals': [
      {
        'profile_pic_url':
            'https://www.quickensol.com/quickenlancer-new/images/profile_pic/profile.png',
        'f_name': 'Charlie',
        'l_name': 'Brown',
        'sent_on_text': '2025-06-07 11:00',
        'is_hire_me_button': 1,
      },
    ],
    'time_availability': {
      'monday': '1',
      'from_monday': '09:00',
      'to_monday': '17:00',
      'tuesday': '1',
      'from_tuesday': '09:00',
      'to_tuesday': '17:00',
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message, style: GoogleFonts.montserrat()),
          backgroundColor: color),
    );
  }

  void _showDialog(
      {required String title,
      required Widget content,
      List<Widget> actions = const []}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.2),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(title,
                  style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
            ),
            InkWell(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close, size: 24, color: Colors.black54),
            ),
          ],
        ),
        content: DefaultTextStyle(
          style: GoogleFonts.montserrat(
              color: Colors.black.withOpacity(0.6), fontSize: 15, height: 1.5),
          child: content,
        ),
        actions: actions,
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16, left: 16),
      ),
    );
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
      _showSnackBar('Unable to open image', Colors.red);
    }
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
      _showSnackBar('Unable to open phone dialer', Colors.red);
    }
  }

  Future<void> _sendNotification(
      {required String projectId,
      required String bidderId,
      required String connectType}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await http.post(
        Uri.parse('https://api.example.com/notify_bidder'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('auth_token') ?? ''}'
        },
        body: jsonEncode({
          "user_id": prefs.getString('user_id') ?? "0",
          "bidder_id": bidderId,
          "project_id": projectId,
          "connect_type": connectType
        }),
      );
      if (response.statusCode == 200 &&
          jsonDecode(response.body)['status'] == 'true') {
        _showSnackBar('Notification Sent!', Colors.green);
      } else {
        throw 'Failed to send notification';
      }
    } catch (e) {
      _showSnackBar('Failed to send notification', Colors.red);
    }
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
                child: Text('$count',
                    style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabContent(String type, List<dynamic> items) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('No ${type}s available',
                  style: GoogleFonts.montserrat(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            )
          else
            ...items.take(3).map((item) => Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                  color: Colors.white,
                  shape: const Border(
                      bottom: BorderSide(color: Color(0xFFDDDDDD))),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(item[
                                  'profile_pic_url'] ??
                              'https://www.quickensol.com/quickenlancer-new/images/profile_pic/profile.png'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '${item['f_name'] ?? ''} ${item['l_name'] ?? ''}',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              Text(
                                  '${type == 'call' ? 'Last Call' : type == 'chat' ? 'Last Chat' : 'Sent'} On: ${item['sent_on_text'] ?? 'N/A'}',
                                  style: GoogleFonts.montserrat(
                                      color: Colorfile.textColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  SizedBox(
                                    height: 30,
                                    child: TextButton(
                                      onPressed: () {
                                        if (type == 'call') {
                                          _openPhoneDialer(
                                              item['mobile_no'] ?? '');
                                        } else if (type == 'chat') {
                                          _showSnackBar('Chat action triggered',
                                              Colors.green);
                                        } else {
                                          _showSnackBar(
                                              'Milestone action triggered',
                                              Colors.green);
                                        }
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        side: const BorderSide(
                                            color: Colors.black),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                              type == 'call'
                                                  ? Icons.phone
                                                  : type == 'chat'
                                                      ? Icons.chat
                                                      : Icons.attach_file,
                                              size: 15),
                                          const SizedBox(width: 4),
                                          Text(
                                              type == 'call'
                                                  ? 'Call'
                                                  : type == 'chat'
                                                      ? 'Chat'
                                                      : 'Milestone',
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 10)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (item['is_hire_me_button'] == 1) ...[
                                    const SizedBox(width: 16),
                                    SizedBox(
                                      height: 30,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: [
                                                Color(0xFFB7D7F9),
                                                Color(0xFFE6ACCB)
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4)),
                                        ),
                                        child: TextButton(
                                          onPressed: () => _showSnackBar(
                                              'Hire Me action triggered',
                                              Colors.green),
                                          style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16)),
                                          child: Text('Hire Me',
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colorfile.textColor)),
                                        ),
                                      ),
                                    ),
                                  ],
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
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  backgroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View All',
                        style: GoogleFonts.montserrat(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobTextStyle = GoogleFonts.montserrat(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.47,
        color: Colors.black);
    final imagePath = project['imagePath'] as List<dynamic>? ?? [];
    final proposals = project['proposals'] is Map<String, dynamic>
        ? project['proposals']
        : null;
    final callCount = (project['project_calls'] as List<dynamic>?)?.length ?? 0;
    final chatCount = (project['project_chats'] as List<dynamic>?)?.length ?? 0;
    final proposalCount =
        (project['project_proposals'] as List<dynamic>?)?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Posted Details',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0, // Removes default shadow
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Color(0xFFD9D9D9), // #D9D9D9
            height: 1.0,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, right: 16, left: 16),
              child: SizedBox(
                height: 40,
                width: double.infinity, // Makes the SizedBox take full width
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFB7D7F9), Color(0xFFE6ACCB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8), // Add some padding
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Views',
                        style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '15',
                        style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
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
                      Text(project['project_name'] ?? 'No Title',
                          style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
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
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      'Posted On: ${project['created_on'] != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(project['created_on'])) : 'N/A'}',
                                      style: jobTextStyle),
                                  Text(
                                      'Project Cost: ${project['amount'] ?? 'No Amount'}',
                                      style: jobTextStyle),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      'How to Pay: ${project['project_type'] == '0' ? 'Fixed' : project['project_type'] == '1' ? 'Hourly' : 'N/A'}',
                                      style: jobTextStyle),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                        minimumSize: Size.zero,
                                        padding: EdgeInsets.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap),
                                    onPressed: () {
                                      final availability =
                                          project['time_availability']
                                              as Map<String, dynamic>?;
                                      if (availability == null ||
                                          ![
                                            'monday',
                                            'tuesday',
                                            'wednesday',
                                            'thursday',
                                            'friday',
                                            'saturday',
                                            'sunday'
                                          ].any((day) =>
                                              availability[day] == '1')) {
                                        _showDialog(
                                          title: 'Project Availability',
                                          content: Text('No availability set.',
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 14,
                                                  color: Colors.black
                                                      .withOpacity(0.6))),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8),
                                                backgroundColor: Colors.grey
                                                    .withOpacity(0.1),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6)),
                                              ),
                                              child: Text('Cancel',
                                                  style: GoogleFonts.montserrat(
                                                      color: const Color(
                                                          0xFF0288D1),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8),
                                                backgroundColor:
                                                    const Color(0xFF0288D1)
                                                        .withOpacity(0.1),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6)),
                                              ),
                                              child: Text('Add',
                                                  style: GoogleFonts.montserrat(
                                                      color: const Color(
                                                          0xFF0288D1),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ),
                                          ],
                                        );
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
                                            .where((day) =>
                                                availability[day] == '1')
                                            .map((day) => {
                                                  'day': day.capitalize(),
                                                  'from': availability[
                                                          'from_$day'] ??
                                                      'N/A',
                                                  'to':
                                                      availability['to_$day'] ??
                                                          'N/A'
                                                })
                                            .toList();
                                        _showDialog(
                                          title: 'Availability',
                                          content: result.isEmpty
                                              ? Text(
                                                  'No availability specified',
                                                  style: jobTextStyle)
                                              : SingleChildScrollView(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: result
                                                        .map((slot) => Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          4.0),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  SizedBox(
                                                                    width: 80,
                                                                    child: Text(
                                                                        slot[
                                                                            'day'],
                                                                        style: jobTextStyle.copyWith(
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w500)),
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        Container(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .all(
                                                                              8),
                                                                      decoration: BoxDecoration(
                                                                          color: Colors
                                                                              .white,
                                                                          border:
                                                                              Border.all(color: const Color(0xFFDADADA)),
                                                                          borderRadius: BorderRadius.circular(6)),
                                                                      child: Text(
                                                                          slot[
                                                                              'from'],
                                                                          style: jobTextStyle.copyWith(
                                                                              fontSize: 12,
                                                                              color: Colors.black87)),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 8),
                                                                  Expanded(
                                                                    child:
                                                                        Container(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .all(
                                                                              8),
                                                                      decoration: BoxDecoration(
                                                                          color: Colors
                                                                              .white,
                                                                          border:
                                                                              Border.all(color: const Color(0xFFDADADA)),
                                                                          borderRadius: BorderRadius.circular(6)),
                                                                      child: Text(
                                                                          slot[
                                                                              'to'],
                                                                          style: jobTextStyle.copyWith(
                                                                              fontSize: 12,
                                                                              color: Colors.black87)),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ))
                                                        .toList(),
                                                  ),
                                                ),
                                        );
                                      }
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                              text: 'Availability Time: ',
                                              style: jobTextStyle),
                                          TextSpan(
                                            text: (project['time_availability']
                                                            as Map<String,
                                                                dynamic>?)
                                                        ?.entries
                                                        .any((entry) =>
                                                            [
                                                              'monday',
                                                              'tuesday',
                                                              'wednesday',
                                                              'thursday',
                                                              'friday',
                                                              'saturday',
                                                              'sunday'
                                                            ].contains(
                                                                entry.key) &&
                                                            entry.value ==
                                                                '1') ==
                                                    true
                                                ? 'Schedule'
                                                : 'Add Schedule',
                                            style: jobTextStyle.copyWith(
                                                decoration:
                                                    TextDecoration.underline,
                                                color: Colors.blue),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        'Requirement Type: ${project['requirement_type'] == '0' ? 'Cold' : project['requirement_type'] == '1' ? 'Hot' : 'N/A'}',
                                        style: jobTextStyle)
                                  ]),
                              Text(
                                  'Looking For: ${project['looking_for'] == '1' ? 'Company' : project['looking_for'] == '2' ? 'Freelancer' : 'Company/Freelancer'}',
                                  style: jobTextStyle),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                        text: 'Status: ', style: jobTextStyle),
                                    TextSpan(
                                      text: project['button_label'],
                                      style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: project['project_status'] ==
                                                  '0'
                                              ? Colors.grey
                                              : project['project_status'] == '1'
                                                  ? Colors.green
                                                  : Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                              if (proposals != null) ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        'Max Proposal Cost: ${proposals['max_mston_amount'] ?? 'N/A'}',
                                        style: jobTextStyle),
                                    Text(
                                        'Min Proposal Cost: ${proposals['min_mston_amount'] ?? 'N/A'}',
                                        style: jobTextStyle),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        'Avg Proposal Cost: ${proposals['average_mston_amount'] ?? 'N/A'}',
                                        style: jobTextStyle),
                                    Text(
                                        'Total Proposals: ${proposals['total_proposal'] ?? 'N/A'}',
                                        style: jobTextStyle),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Note: Approval is currently pending. The proposal/milestone will proceed upon receiving the necessary authorization from the designated stakeholders.',
                          style: GoogleFonts.montserrat(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF8B8636),
                          ),
                          textAlign: TextAlign.left,
                          softWrap: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: (project['skills'] as List<dynamic>? ?? [])
                            .map((skill) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFE8F1FC),
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Text(skill['skill'] ?? '',
                                        style: GoogleFonts.montserrat(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black)),
                                  ),
                                ))
                            .toList(),
                      ),
                      Text(
                        descriptionExpanded
                            ? 'Description: ${project['description']?.replaceAll(RegExp(r'<[^>]+>'), '') ?? 'No Description'}'
                            : 'Description: ${(project['description']?.replaceAll(RegExp(r'<[^>]+>'), '') ?? 'No Description').length > 100 ? project['description'].replaceAll(RegExp(r'<[^>]+>'), '').substring(0, 100) + '...' : project['description']?.replaceAll(RegExp(r'<[^>]+>'), '') ?? 'No Description'}',
                        style: GoogleFonts.montserrat(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w500),
                      ),
                      if ((project['description']
                                      ?.replaceAll(RegExp(r'<[^>]+>'), '') ??
                                  '')
                              .length >
                          100)
                        GestureDetector(
                          onTap: () => setState(
                              () => descriptionExpanded = !descriptionExpanded),
                          child: Text(
                              descriptionExpanded ? 'Show Less' : 'Show More',
                              style: const TextStyle(
                                  color: Colors.blue, fontSize: 10)),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => _showDialog(
                                title: 'Attachment',
                                content: imagePath.isEmpty
                                    ? Text('No attachments available',
                                        style: GoogleFonts.montserrat(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black))
                                    : SizedBox(
                                        height: 300,
                                        width: 250,
                                        child: ListView.builder(
                                          itemCount: imagePath.length,
                                          itemBuilder: (context, index) {
                                            final url = imagePath[index];
                                            return Container(
                                              height: 50,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 2),
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Color(0xFFDADADA)),
                                                  borderRadius:
                                                      BorderRadius.circular(6)),
                                              child: Row(
                                                children: [
                                                  Text('Document ${index + 1}',
                                                      style: GoogleFonts
                                                          .montserrat(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: Colors
                                                                  .black)),
                                                  const Spacer(),
                                                  GestureDetector(
                                                    onTap: () => _showDialog(
                                                      title: 'Confirm Download',
                                                      content: Text(
                                                          'Download this file?',
                                                          style: GoogleFonts
                                                              .montserrat(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black)),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                          child: Text('No',
                                                              style: GoogleFonts.montserrat(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500)),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            Navigator.pop(
                                                                context);
                                                            _downloadImage(url);
                                                          },
                                                          child: Text('Yes',
                                                              style: GoogleFonts.montserrat(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500)),
                                                        ),
                                                      ],
                                                    ),
                                                    child: const Icon(
                                                        Icons.download,
                                                        color: Colors.grey,
                                                        size: 24),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFFFAFAFA),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    side: const BorderSide(
                                        color: Color(0xFFD9D9D9))),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      '${imagePath.length} Attachment${imagePath.length == 1 ? '' : 's'}',
                                      style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black)),
                                  Transform.rotate(
                                      angle: 0.6,
                                      child: const Icon(Icons.attach_file,
                                          color: Colors.black)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TabBar(
                        indicator: GradientTabIndicator(
                            gradient: const LinearGradient(colors: [
                          Color(0xFF51A5D1),
                          Color(0xFF82399C),
                          Color(0xFFF04E80)
                        ])),
                        controller: _tabController,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.black54,
                        labelStyle: GoogleFonts.montserrat(
                            fontSize: 12, fontWeight: FontWeight.w600),
                        unselectedLabelStyle: GoogleFonts.montserrat(
                            fontSize: 12, fontWeight: FontWeight.w500),
                        labelPadding:
                            const EdgeInsets.symmetric(horizontal: 6.0),
                        tabs: [
                          Tab(child: _buildTab('Call', callCount)),
                          Tab(child: _buildTab('Chat', chatCount)),
                          Tab(
                              child: _buildTab('Proposal', proposalCount,
                                  maxWidth: 90)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 110,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildTabContent(
                                'call', project['project_calls'] ?? []),
                            _buildTabContent(
                                'chat', project['project_chats'] ?? []),
                            _buildTabContent(
                                'proposal', project['project_proposals'] ?? []),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Project Description',
                      style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black)),
                  const SizedBox(height: 8),
                  Text(
                    'I need a very specific mobile app. The app will be very similar to that of the Uber business model where there is a "Driver", a "Customer", and a "Destination". '
                    'My app will be very similar if not the same. The app process will be as follows:\n\n'
                    '(1) DRIVERS will sign up for an account to perform pick-up items from customers.\n'
                    '(2) CUSTOMERS will sign up for an account to request a pick-up for an item.\n'
                    '(3) Once the DRIVER accepts the request from the CUSTOMER, the app will navigate the driver where to deliver the package.',
                    style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(
                        'List of Freelancers Who Have Bidded This Project',
                        style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1)}";
}
