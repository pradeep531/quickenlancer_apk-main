import 'dart:developer';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/network/uri.dart';
import '../Colors/colorfile.dart';
import '../chat_page.dart';

class ReceivedProjectsTab extends StatefulWidget {
  const ReceivedProjectsTab({super.key});

  @override
  _ReceivedProjectsTabState createState() => _ReceivedProjectsTabState();
}

class _ReceivedProjectsTabState extends State<ReceivedProjectsTab> {
  List<dynamic> projects = [];
  final int limit = 10;
  int offset = 0;
  bool isLoading = false;
  bool hasMore = true;
  Map<String, bool> descriptionExpandedMap = {};

  @override
  void initState() {
    super.initState();
    _fetchProjects();
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
      log('Request Body: $requestBody');

      final response = await http.post(
        Uri.parse(URLS().recieved_project),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('auth_token') ?? ''}',
        },
        body: requestBody,
      );

      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'true') {
          setState(() {
            projects.addAll(jsonResponse['data']);
            offset += limit;
            hasMore = jsonResponse['data'].length == limit;
            isLoading = false;
          });
          log('Offset: $offset, HasMore: $hasMore');
        } else {
          setState(() {
            isLoading = false;
            hasMore = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
          hasMore = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasMore = false;
      });
      log('Error: $e');
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      projects.clear();
      offset = 0;
      hasMore = true;
      descriptionExpandedMap.clear();
    });
    await _fetchProjects();
  }

  Future<void> _openPhoneDialer(String mobileNo) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: mobileNo);
    log('Opening phone dialer: $mobileNo');
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
        log('Phone dialer launched successfully');
      } else {
        throw 'Cannot launch phone dialer';
      }
    } catch (e) {
      log('Failed to launch phone dialer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open phone dialer',
              style: GoogleFonts.montserrat()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _downloadImage(String url) async {
    log('Opening URL: $url');
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        log('URL opened successfully');
      } else {
        throw 'Could not launch URL';
      }
    } catch (e) {
      log('Failed to open URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to open image',
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendNotification({
    required String projectId,
    required String bidderId,
    required String connectType,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final requestBody = jsonEncode({
        "user_id": prefs.getString('user_id') ?? "0",
        "bidder_id": bidderId,
        "project_id": projectId,
        "connect_type": connectType,
      });

      log('Sending notification with body: $requestBody');

      final response = await http.post(
        Uri.parse(URLS().notify_bidder),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('auth_token') ?? ''}',
        },
        body: requestBody,
      );

      log('Notification response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'true') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Notification Sent!',
                style: GoogleFonts.montserrat(),
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw 'Failed to send notification: ${jsonResponse['message']}';
        }
      } else {
        throw 'Failed to send notification: ${response.statusCode}';
      }
    } catch (e) {
      log('Error sending notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to send notification',
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDialog({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget> actions = const [],
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            color: Colorfile.textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: content,
        actions: actions.isEmpty
            ? [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Close',
                    style: GoogleFonts.montserrat(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ]
            : actions,
      ),
    );
  }

  void _showAddAvailabilityDialog(BuildContext context, String projectId) {
    _showDialog(
      context: context,
      title: 'Availability for this project',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No Time availability for this project',
            style: GoogleFonts.montserrat(
              color: Colorfile.textColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCallAction(
      Map<String, dynamic> purchasedBy, String projectId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final authToken = prefs.getString('auth_token');

    if (purchasedBy['call_button_redirections'] == 'open_call_dial') {
      try {
        final requestBody = jsonEncode({
          'user_id': userId,
          'project_id': projectId,
          'project_owner_id': purchasedBy['user_id']?.toString(),
          'used_token_id':
              purchasedBy['check_call_assin_to_project']['id']?.toString(),
        });
        log('Call API Request Body: $requestBody');

        final response = await http.post(
          Uri.parse(URLS().set_call_entry),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
          body: requestBody,
        );

        log('Call API Response: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = jsonDecode(response.body);
          if (responseData['status'] == 'true' &&
              responseData['data'] != null) {
            final String receiverMobileNo =
                responseData['data']['receiver_mobile_no'];

            // Only send notification if bidder_id is available
            if (purchasedBy['bidder_id'] != null) {
              await _sendNotification(
                projectId: projectId,
                bidderId: purchasedBy['bidder_id'].toString(),
                connectType: '1', // Call
              );
            } else {
              log('Skipping notification: bidder_id is null');
            }

            // Open phone dialer
            await _openPhoneDialer(receiverMobileNo);
          } else {
            throw 'Mobile number not available';
          }
        } else {
          throw 'Failed to initiate call: ${response.statusCode}';
        }
      } catch (e) {
        log('Error initiating call: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to initiate call',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        Text(
                          'No Data Found',
                          style: GoogleFonts.montserrat(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: projects.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == projects.length && hasMore) {
                        _fetchProjects();
                        return const Center(child: CircularProgressIndicator());
                      }

                      final job = projects[index];
                      final purchasedBy =
                          job['owner_details'] as Map<String, dynamic>?;
                      final projectId = job['project_id'].toString();
                      final chatSender = job['chat_sender'].toString();
                      final chatReceiver = job['chat_receiver'].toString();
                      final imagePath =
                          job['imagePath'] as List<dynamic>? ?? [];

                      log('purchasedBy: $purchasedBy');

                      Map<String, dynamic>? proposals;
                      if (job['proposals'] is List<dynamic> &&
                          (job['proposals'] as List<dynamic>).isNotEmpty) {
                        proposals = (job['proposals'] as List<dynamic>)[0]
                            as Map<String, dynamic>?;
                      } else if (job['proposals'] is Map<String, dynamic>) {
                        proposals = job['proposals'] as Map<String, dynamic>?;
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFB7D7F9), Color(0xFFE5ACCB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(1),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job['project_name'] ?? 'No Title',
                                style: GoogleFonts.montserrat(
                                  color: Colorfile.textColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(2),
                                  1: FlexColumnWidth(1),
                                  2: FlexColumnWidth(3),
                                },
                                children: [
                                  TableRow(
                                    children: [
                                      Text(
                                        'Posted On',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.black54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Text(
                                        ':',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                      Text(
                                        job['created_on'] != null &&
                                                job['created_on'].isNotEmpty
                                            ? () {
                                                try {
                                                  final date = DateTime.parse(
                                                      job['created_on']);
                                                  final formatter =
                                                      DateFormat('dd/MM/yyyy');
                                                  return formatter.format(date);
                                                } catch (e) {
                                                  log('Error parsing created_on date: $e');
                                                  return job['created_on'];
                                                }
                                              }()
                                            : 'N/A',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.black54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      Text(
                                        'How to Pay',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.black54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Text(
                                        ':',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                      Text(
                                        job['project_type'] == '0'
                                            ? 'Fixed'
                                            : job['project_type'] == '1'
                                                ? 'Hourly'
                                                : 'N/A',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.black54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      Text(
                                        'Requirement Type',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.black54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Text(
                                        ':',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                      Text(
                                        job['requirement_type'] == '0'
                                            ? 'Cold'
                                            : job['requirement_type'] == '1'
                                                ? 'Hot'
                                                : 'N/A',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.black54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      Text(
                                        'Looking For',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.black54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Text(
                                        ':',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                      Text(
                                        job['looking_for'] == '1'
                                            ? 'Company'
                                            : job['looking_for'] == '2'
                                                ? 'Freelancer'
                                                : 'Company/Freelancer',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.black54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (proposals != null &&
                                      proposals.isNotEmpty) ...[
                                    TableRow(
                                      children: [
                                        Text(
                                          'Maximum Proposal Cost',
                                          style: GoogleFonts.montserrat(
                                            color: Colors.black54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Text(
                                          ':',
                                          textAlign: TextAlign.center,
                                          style:
                                              TextStyle(color: Colors.black54),
                                        ),
                                        Text(
                                          proposals['max_mston_amount']
                                                  ?.toString() ??
                                              'N/A',
                                          style: GoogleFonts.montserrat(
                                            color: Colors.black54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        Text(
                                          'Minimum Proposal Cost',
                                          style: GoogleFonts.montserrat(
                                            color: Colors.black54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Text(
                                          ':',
                                          textAlign: TextAlign.center,
                                          style:
                                              TextStyle(color: Colors.black54),
                                        ),
                                        Text(
                                          proposals['min_mston_amount']
                                                  ?.toString() ??
                                              'N/A',
                                          style: GoogleFonts.montserrat(
                                            color: Colors.black54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        Text(
                                          'Average Proposal Cost',
                                          style: GoogleFonts.montserrat(
                                            color: Colors.black54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Text(
                                          ':',
                                          textAlign: TextAlign.center,
                                          style:
                                              TextStyle(color: Colors.black54),
                                        ),
                                        Text(
                                          proposals['average_mston_amount']
                                                  ?.toString() ??
                                              'N/A',
                                          style: GoogleFonts.montserrat(
                                            color: Colors.black54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        Text(
                                          'Total Proposal',
                                          style: GoogleFonts.montserrat(
                                            color: Colors.black54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Text(
                                          ':',
                                          textAlign: TextAlign.center,
                                          style:
                                              TextStyle(color: Colors.black54),
                                        ),
                                        Text(
                                          proposals['total_proposal']
                                                  ?.toString() ??
                                              'N/A',
                                          style: GoogleFonts.montserrat(
                                            color: Colors.black54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    job['amount'] ?? 'No Amount',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.black54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  TextButton(
                                    onPressed: () {
                                      final availability =
                                          job['time_availability']
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
                                        _showAddAvailabilityDialog(
                                            context, projectId);
                                      } else {
                                        final days = [
                                          'monday',
                                          'tuesday',
                                          'wednesday',
                                          'thursday',
                                          'friday',
                                          'saturday',
                                          'sunday'
                                        ];
                                        final result = days
                                            .where((day) =>
                                                availability[day] == '1')
                                            .map((day) =>
                                                '${day.capitalize()}: ${availability['from_$day'] ?? 'N/A'} - ${availability['to_$day'] ?? 'N/A'}')
                                            .join('\n');
                                        _showDialog(
                                          context: context,
                                          title: 'Availability',
                                          content: Text(
                                            result.isEmpty
                                                ? 'No availability specified'
                                                : result,
                                            style: GoogleFonts.montserrat(
                                              color: Colorfile.textColor,
                                              fontSize: 12,
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
                                            style: GoogleFonts.montserrat(
                                              color: Colorfile.textColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: (job['time_availability']
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
                                            style: GoogleFonts.montserrat(
                                              color: Colorfile.textColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                descriptionExpandedMap[projectId] == true
                                    ? 'Description: ${job['description']?.replaceAll(RegExp(r'<[^>]+>'), '') ?? 'No Description'}'
                                    : 'Description: ${(job['description']?.replaceAll(RegExp(r'<[^>]+>'), '') ?? 'No Description').length > 100 ? (job['description']?.replaceAll(RegExp(r'<[^>]+>'), '') ?? 'No Description').substring(0, 100) + '...' : job['description']?.replaceAll(RegExp(r'<[^>]+>'), '') ?? 'No Description'}',
                                style: GoogleFonts.montserrat(
                                  color: Colorfile.textColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if ((job['description']?.replaceAll(
                                              RegExp(r'<[^>]+>'), '') ??
                                          '')
                                      .length >
                                  100)
                                GestureDetector(
                                  onTap: () => setState(() {
                                    descriptionExpandedMap[projectId] =
                                        !(descriptionExpandedMap[projectId] ??
                                            false);
                                  }),
                                  child: Text(
                                    descriptionExpandedMap[projectId] == true
                                        ? 'Show Less'
                                        : 'Show More',
                                    style: const TextStyle(
                                        color: Colors.blue, fontSize: 10),
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE8F1FC),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              skill['skill'] ?? '',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: Colorfile.textColor,
                                              ),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                              const SizedBox(height: 10),
                              if (purchasedBy != null) ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundImage: NetworkImage(
                                              purchasedBy['profile_pic'] ?? ''),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${purchasedBy['f_name'] ?? ''} ${purchasedBy['l_name'] ?? ''}',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colorfile.textColor,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                purchasedBy['country_flag_path'] !=
                                                        null
                                                    ? Image.network(
                                                        purchasedBy[
                                                            'country_flag_path'],
                                                        height: 20,
                                                        width: 20,
                                                        errorBuilder: (context,
                                                                error,
                                                                stackTrace) =>
                                                            const Icon(
                                                                Icons.image,
                                                                size: 20,
                                                                color: Colors
                                                                    .grey),
                                                      )
                                                    : const Icon(Icons.image,
                                                        size: 20,
                                                        color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${purchasedBy['city_name'] ?? ''}, ${purchasedBy['country_name'] ?? ''}',
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                  ),
                                                ),
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
                                                log('Navigating to Chatpage for project: $projectId');
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChatPage(
                                                      projectId: projectId,
                                                      chatSender: chatSender,
                                                      chatReceiver:
                                                          chatReceiver,
                                                    ),
                                                  ),
                                                );
                                              } else if (purchasedBy[
                                                      'chat_button_redirections'] ==
                                                  'send_chat_notification') {
                                                _showDialog(
                                                  context: context,
                                                  title: 'Send Notification',
                                                  content: Text(
                                                    'Do you want to send a chat notification?',
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      color:
                                                          Colorfile.textColor,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                      child: Text(
                                                        'No',
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          color: Colors.blue,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        _sendNotification(
                                                          projectId: projectId,
                                                          bidderId: purchasedBy[
                                                                      'bidder_id']
                                                                  ?.toString() ??
                                                              '',
                                                          connectType:
                                                              '2', // Chat
                                                        );
                                                      },
                                                      child: Text(
                                                        'Yes',
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          color: Colors.blue,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }
                                            },
                                            child: Image.asset(
                                              'assets/Group 2237886.png',
                                              height: 30,
                                              width: 30,
                                            ),
                                          ),
                                        const SizedBox(width: 8),
                                        if (purchasedBy[
                                                    'call_button_redirections']
                                                ?.isNotEmpty ??
                                            false)
                                          GestureDetector(
                                            onTap: () => _handleCallAction(
                                                purchasedBy, projectId),
                                            child: Image.asset(
                                              'assets/Group 2237887.png',
                                              height: 30,
                                              width: 30,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Table(
                                  children: [
                                    TableRow(
                                      children: [
                                        Text(
                                          'Hired on',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const Text(
                                          ':',
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          purchasedBy['confirmed_date'] !=
                                                      null &&
                                                  purchasedBy['confirmed_date']
                                                      .isNotEmpty
                                              ? () {
                                                  try {
                                                    final date = DateTime.parse(
                                                        purchasedBy[
                                                            'confirmed_date']);
                                                    final formatter =
                                                        DateFormat(
                                                            'dd/MM/yyyy');
                                                    return formatter
                                                        .format(date);
                                                  } catch (e) {
                                                    log('Error parsing date: $e');
                                                    return purchasedBy[
                                                        'confirmed_date'];
                                                  }
                                                }()
                                              : 'N/A',
                                          textAlign: TextAlign.right,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        Text(
                                          'Hired Status',
                                          style: GoogleFonts.montserrat(
                                              fontSize: 12,
                                              color: Colors.black54),
                                        ),
                                        const Text(':',
                                            textAlign: TextAlign.center),
                                        Text(
                                          purchasedBy['hired_status'] ?? 'N/A',
                                          textAlign: TextAlign.right,
                                          style: GoogleFonts.montserrat(
                                              fontSize: 12,
                                              color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                    if (imagePath.isNotEmpty)
                                      TableRow(
                                        children: [
                                          Text(
                                            'Project Attachments',
                                            style: GoogleFonts.montserrat(
                                                fontSize: 12,
                                                color: Colors.black54),
                                          ),
                                          const Text(':',
                                              textAlign: TextAlign.center),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Transform.rotate(
                                                angle: 0.6,
                                                child: const Icon(
                                                  Icons.attach_file,
                                                  color: Colorfile.textColor,
                                                  size: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // Timeline View for last_chat_text and last_call_text
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Activity Timeline',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colorfile.textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (purchasedBy['last_chat_text'] != null &&
                                        purchasedBy['last_chat_text']
                                            .isNotEmpty)
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            children: [
                                              const Icon(
                                                  Icons.chat_bubble_outline,
                                                  size: 20,
                                                  color: Colors.blue),
                                              Container(
                                                width: 2,
                                                height: purchasedBy[
                                                                'last_call_text'] !=
                                                            null &&
                                                        purchasedBy[
                                                                'last_call_text']
                                                            .isNotEmpty
                                                    ? 20
                                                    : 0,
                                                color: Colors.grey,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Last Chat',
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                Text(
                                                  purchasedBy['last_chat_text'],
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (purchasedBy['last_call_text'] != null &&
                                        purchasedBy['last_call_text']
                                            .isNotEmpty)
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.call_outlined,
                                              size: 20, color: Colors.green),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Last Call',
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                Text(
                                                  purchasedBy['last_call_text'],
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (purchasedBy['last_chat_text'] == null &&
                                        purchasedBy['last_call_text'] == null)
                                      Text(
                                        'No recent activity',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ] else ...[
                                Text(
                                  'No owner details available',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
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
