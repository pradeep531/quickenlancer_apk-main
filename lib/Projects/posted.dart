import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../api/network/uri.dart';
import '../Colors/colorfile.dart';
import '../chat_page.dart';
import 'schedule_availability.dart';

class PostedProjectsTab extends StatefulWidget {
  const PostedProjectsTab({super.key});

  @override
  State<PostedProjectsTab> createState() => _PostedProjectsPageState();
}

class _PostedProjectsPageState extends State<PostedProjectsTab>
    with SingleTickerProviderStateMixin {
  List<dynamic> projects = [];
  int offset = 0;
  bool isLoading = false, hasMore = true;
  final int limit = 10;
  Map<String, bool> descriptionExpandedMap = {};
  Map<String, TabController> tabControllers = {};

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  @override
  void dispose() {
    tabControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _fetchProjects() async {
    if (isLoading || !hasMore) return;
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await http.post(
        Uri.parse(URLS().posted_project),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('auth_token') ?? ''}',
        },
        body: jsonEncode({
          "user_id": prefs.getString('user_id') ?? "0",
          "limit": limit,
          "offset": offset,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'true') {
          setState(() {
            projects.addAll(jsonResponse['data']);
            jsonResponse['data'].forEach((project) {
              tabControllers[project['project_id'].toString()] =
                  TabController(length: 4, vsync: this);
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
    final Uri phoneUri = Uri(scheme: 'tel', path: mobileNo);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Cannot launch phone dialer';
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
        throw 'Could not launch URL';
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
        backgroundColor: color,
      ),
    );
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
        title: Text(title,
            style: GoogleFonts.montserrat(
                color: Colorfile.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        content: content,
        actions: actions.isEmpty
            ? [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close',
                      style: GoogleFonts.montserrat(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ),
              ]
            : actions,
      ),
    );
  }

  void _showAddAvailabilityDialog(BuildContext context, String projectId) {
    _showDialog(
      context: context,
      title: 'Your availability for this project',
      content: Text('No Time availability for this project.',
          style:
              GoogleFonts.montserrat(color: Colorfile.textColor, fontSize: 12)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel',
              style: GoogleFonts.montserrat(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    ScheduleAvailabilityPage(projectId: projectId),
              ),
            );
          },
          child: Text('Add availability',
              style: GoogleFonts.montserrat(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ),
      ],
    );
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
                        Text('No Data Found',
                            style: GoogleFonts.montserrat(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
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
                      final purchasedBy = job['purchased_by'];
                      final projectId = job['project_id'].toString();
                      final chatSender = job['chat_sender'].toString();
                      final chatReceiver = job['chat_receiver'].toString();
                      final imagePath =
                          job['imagePath'] as List<dynamic>? ?? [];
                      Map<String, dynamic>? proposals =
                          job['proposals'] is Map<String, dynamic>
                              ? job['proposals']
                              : job['proposals'] is List<dynamic> &&
                                      job['proposals'].isNotEmpty
                                  ? job['proposals'][0]
                                  : null;

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
                              Text(job['project_name'] ?? 'No Title',
                                  style: GoogleFonts.montserrat(
                                      color: Colorfile.textColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(2),
                                  1: FlexColumnWidth(1),
                                  2: FlexColumnWidth(3),
                                },
                                children: [
                                  TableRow(children: [
                                    Text('Posted On',
                                        style: GoogleFonts.montserrat(
                                            color: Colors.black54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500)),
                                    const Text(':',
                                        textAlign: TextAlign.center,
                                        style:
                                            TextStyle(color: Colors.black54)),
                                    Text(
                                        job['created_on']?.isNotEmpty == true
                                            ? DateFormat('dd/MM/yyyy')
                                                .format(DateTime.parse(
                                                    job['created_on']))
                                                .toString()
                                            : 'N/A',
                                        style: GoogleFonts.montserrat(
                                            color: Colors.black54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500)),
                                  ]),
                                  TableRow(children: [
                                    Text('How to Pay',
                                        style: GoogleFonts.montserrat(
                                            color: Colors.black54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500)),
                                    const Text(':',
                                        style:
                                            TextStyle(color: Colors.black54)),
                                    Text(
                                        job['project_type'] == '0'
                                            ? 'Fixed'
                                            : job['project_type'] == '1'
                                                ? 'Hourly'
                                                : 'N/A',
                                        style: GoogleFonts.montserrat(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500)),
                                  ]),
                                  TableRow(children: [
                                    Text('Requirement Type',
                                        style: GoogleFonts.montserrat(
                                            color: Colors.black54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500)),
                                    const Text(':',
                                        style:
                                            TextStyle(color: Colors.black54)),
                                    Text(
                                        job['requirement_type'] == '0'
                                            ? 'Cold'
                                            : job['requirement_type'] == '1'
                                                ? 'Hot'
                                                : 'N/A',
                                        style: GoogleFonts.montserrat(
                                            color: Colors.black54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500)),
                                  ]),
                                  TableRow(children: [
                                    Text('Looking For',
                                        style: GoogleFonts.montserrat(
                                            color: Colors.black54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500)),
                                    const Text(':',
                                        style:
                                            TextStyle(color: Colors.black54)),
                                    Text(
                                        job['looking_for'] == '1'
                                            ? 'Company'
                                            : job['looking_for'] == '2'
                                                ? 'Freelancer'
                                                : 'Company/Freelancer',
                                        style: GoogleFonts.montserrat(
                                            color: Colors.black54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500)),
                                  ]),
                                  if (proposals != null) ...[
                                    TableRow(children: [
                                      Text('Maximum Proposal Cost',
                                          style: GoogleFonts.montserrat(
                                              color: Colors.black54,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                      const Text(':',
                                          style:
                                              TextStyle(color: Colors.black54)),
                                      Text(
                                          proposals['max_mston_amount']
                                                  ?.toString() ??
                                              'N/A',
                                          style: GoogleFonts.montserrat(
                                              color: Colors.black54,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                    ]),
                                    TableRow(children: [
                                      Text('Minimum Proposal Cost',
                                          style: GoogleFonts.montserrat(
                                              color: Colors.black54,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                      const Text(':',
                                          style:
                                              TextStyle(color: Colors.black54)),
                                      Text(
                                          proposals['min_mston_amount']
                                                  ?.toString() ??
                                              'N/A',
                                          style: GoogleFonts.montserrat(
                                              color: Colors.black54,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                    ]),
                                    TableRow(children: [
                                      Text('Average Proposal Cost',
                                          style: GoogleFonts.montserrat(
                                              color: Colors.black54,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                      const Text(':',
                                          style:
                                              TextStyle(color: Colors.black54)),
                                      Text(
                                          proposals['average_mston_amount']
                                                  ?.toString() ??
                                              'N/A',
                                          style: GoogleFonts.montserrat(
                                              color: Colors.black54,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                    ]),
                                    TableRow(children: [
                                      Text('Total Proposal',
                                          style: GoogleFonts.montserrat(
                                              color: Colors.black54,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                      const Text(':',
                                          style:
                                              TextStyle(color: Colors.black54)),
                                      Text(
                                          proposals['total_proposal']
                                                  ?.toString() ??
                                              'N/A',
                                          style: GoogleFonts.montserrat(
                                              color: Colors.black54,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                    ]),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(job['amount'] ?? 'No Amount',
                                      style: GoogleFonts.montserrat(
                                          color: Colors.black54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500)),
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
                                                  fontSize: 12)),
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
                                                  fontWeight: FontWeight.bold)),
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
                                                  decoration: TextDecoration
                                                      .underline)),
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
                                      fontWeight: FontWeight.w500)),
                              if ((job['description']?.replaceAll(
                                              RegExp(r'<[^>]+>'), '') ??
                                          '')
                                      .length >
                                  100)
                                GestureDetector(
                                  onTap: () => setState(() =>
                                      descriptionExpandedMap[projectId] =
                                          !(descriptionExpandedMap[projectId] ??
                                              false)),
                                  child: Text(
                                      descriptionExpandedMap[projectId] == true
                                          ? 'Show Less'
                                          : 'Show More',
                                      style: const TextStyle(
                                          color: Colors.blue, fontSize: 10)),
                                ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                children: (job['skills'] as List<dynamic>? ??
                                        [])
                                    .map((skill) => Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE8F1FC),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(skill['skill'] ?? '',
                                                style: GoogleFonts.montserrat(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        Colorfile.textColor)),
                                          ),
                                        ))
                                    .toList(),
                              ),
                              const SizedBox(height: 10),
                              TabBar(
                                controller: tabControllers[projectId],
                                labelColor: Colorfile.textColor,
                                unselectedLabelColor: Colors.black54,
                                indicatorColor: Colorfile.textColor,
                                labelStyle: GoogleFonts.montserrat(
                                    fontSize: 12, fontWeight: FontWeight.w600),
                                unselectedLabelStyle: GoogleFonts.montserrat(
                                    fontSize: 12, fontWeight: FontWeight.w500),
                                tabs: const [
                                  Tab(text: 'Hired On'),
                                  Tab(text: 'Call'),
                                  Tab(text: 'Chat'),
                                  Tab(text: 'Proposal'),
                                ],
                              ),
                              const SizedBox(height: 10),
                              IndexedStack(
                                index: tabControllers[projectId]?.index ?? 0,
                                children: [
                                  // Hired On Tab
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (purchasedBy
                                          is Map<String, dynamic>) ...[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 20,
                                                  backgroundImage: NetworkImage(
                                                      purchasedBy[
                                                              'profile_pic'] ??
                                                          'https://www.quickensol.com/quickenlancer-new/images/profile_pic/profile.png'),
                                                ),
                                                const SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        '${purchasedBy['f_name'] ?? ''} ${purchasedBy['l_name'] ?? ''}',
                                                        style: GoogleFonts
                                                            .montserrat(
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
                                                                height: 20,
                                                                width: 20,
                                                                errorBuilder: (context,
                                                                        error,
                                                                        stackTrace) =>
                                                                    const Icon(
                                                                        Icons
                                                                            .image,
                                                                        size:
                                                                            20,
                                                                        color: Colors
                                                                            .grey),
                                                              )
                                                            : const Icon(
                                                                Icons.image,
                                                                size: 20,
                                                                color: Colors
                                                                    .grey),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          '${purchasedBy['city_name'] ?? ''}, ${purchasedBy['country_name'] ?? ''}',
                                                          style: GoogleFonts
                                                              .montserrat(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black54),
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
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => ChatPage(
                                                                projectId:
                                                                    projectId,
                                                                chatSender:
                                                                    chatSender,
                                                                chatReceiver:
                                                                    chatReceiver),
                                                          ),
                                                        );
                                                      } else if (purchasedBy[
                                                              'chat_button_redirections'] ==
                                                          'send_chat_notification') {
                                                        _showDialog(
                                                          context: context,
                                                          title:
                                                              'Send Notification',
                                                          content: Text(
                                                              'Do you want to send a chat notification?',
                                                              style: GoogleFonts
                                                                  .montserrat(
                                                                      color: Colorfile
                                                                          .textColor,
                                                                      fontSize:
                                                                          12)),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(),
                                                              child: Text('No',
                                                                  style: GoogleFonts.montserrat(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500)),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                _sendNotification(
                                                                    projectId:
                                                                        projectId,
                                                                    bidderId: purchasedBy[
                                                                            'bidder_id']!
                                                                        .toString(),
                                                                    connectType:
                                                                        '2');
                                                              },
                                                              child: Text('Yes',
                                                                  style: GoogleFonts.montserrat(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500)),
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
                                                          context: context,
                                                          title:
                                                              'Send Notification',
                                                          content: Text(
                                                              'Do you want to send a call notification?',
                                                              style: GoogleFonts
                                                                  .montserrat(
                                                                      color: Colorfile
                                                                          .textColor,
                                                                      fontSize:
                                                                          12)),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(),
                                                              child: Text('No',
                                                                  style: GoogleFonts.montserrat(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500)),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                _sendNotification(
                                                                    projectId:
                                                                        projectId,
                                                                    bidderId: purchasedBy[
                                                                            'bidder_id']!
                                                                        .toString(),
                                                                    connectType:
                                                                        '1');
                                                              },
                                                              child: Text('Yes',
                                                                  style: GoogleFonts.montserrat(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500)),
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
                                                  style: GoogleFonts.montserrat(
                                                      fontSize: 12,
                                                      color: Colors.black54)),
                                              const Text(':',
                                                  textAlign: TextAlign.center),
                                              Text(
                                                  purchasedBy['confirmed_date']
                                                              ?.isNotEmpty ==
                                                          true
                                                      ? DateFormat('dd/MM/yyyy')
                                                          .format(DateTime.parse(
                                                              purchasedBy[
                                                                  'confirmed_date']))
                                                          .toString()
                                                      : '',
                                                  textAlign: TextAlign.right,
                                                  style: GoogleFonts.montserrat(
                                                      fontSize: 12,
                                                      color: Colors.black54)),
                                            ]),
                                            TableRow(children: [
                                              Text('Hired Status',
                                                  style: GoogleFonts.montserrat(
                                                      fontSize: 12,
                                                      color: Colors.black54)),
                                              const Text(':',
                                                  textAlign: TextAlign.center),
                                              Text(
                                                  purchasedBy['hired_status'] ??
                                                      '',
                                                  textAlign: TextAlign.right,
                                                  style: GoogleFonts.montserrat(
                                                      fontSize: 12,
                                                      color: Colors.black54)),
                                            ]),
                                            if (imagePath.isNotEmpty)
                                              TableRow(children: [
                                                Text('Project Attachments',
                                                    style:
                                                        GoogleFonts.montserrat(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .black54)),
                                                const Text(':',
                                                    textAlign:
                                                        TextAlign.center),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Transform.rotate(
                                                      angle: 0.6,
                                                      child: const Icon(
                                                          Icons.attach_file,
                                                          color: Colorfile
                                                              .textColor,
                                                          size: 15),
                                                    ),
                                                  ],
                                                ),
                                              ]),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: TextButton(
                                                onPressed: () => _showDialog(
                                                  context: context,
                                                  title: 'Attachments',
                                                  content: imagePath.isEmpty
                                                      ? Text(
                                                          'No attachments available',
                                                          style: GoogleFonts
                                                              .montserrat(
                                                                  color: Colorfile
                                                                      .textColor,
                                                                  fontSize: 12))
                                                      : SizedBox(
                                                          height: 300,
                                                          width: 250,
                                                          child:
                                                              ListView.builder(
                                                            itemCount: imagePath
                                                                .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              final url =
                                                                  imagePath[
                                                                      index];
                                                              return Column(
                                                                children: [
                                                                  Image.network(
                                                                      url,
                                                                      height:
                                                                          150,
                                                                      width:
                                                                          200,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                                                          Icons
                                                                              .file_copy,
                                                                          size:
                                                                              100,
                                                                          color:
                                                                              Colors.grey)),
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        _showDialog(
                                                                      context:
                                                                          context,
                                                                      title:
                                                                          'Confirm Download',
                                                                      content: Text(
                                                                          'Download this file?',
                                                                          style: GoogleFonts.montserrat(
                                                                              color: Colorfile.textColor,
                                                                              fontSize: 12)),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed: () =>
                                                                              Navigator.of(context).pop(),
                                                                          child: Text(
                                                                              'No',
                                                                              style: GoogleFonts.montserrat(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w500)),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                            Navigator.of(context).pop();
                                                                            _downloadImage(url);
                                                                          },
                                                                          child: Text(
                                                                              'Yes',
                                                                              style: GoogleFonts.montserrat(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w500)),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child: Text(
                                                                        'Download',
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
                                                            },
                                                          ),
                                                        ),
                                                ),
                                                style: TextButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFFFAFAFA),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    side: const BorderSide(
                                                        color:
                                                            Color(0xFFD9D9D9)),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Transform.rotate(
                                                      angle: 0.6,
                                                      child: const Icon(
                                                          Icons.attach_file,
                                                          color: Colorfile
                                                              .textColor),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text('Attachment',
                                                        style: GoogleFonts
                                                            .montserrat(
                                                                color: Colorfile
                                                                    .textColor,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: TextButton(
                                                onPressed: job['status'] == '0'
                                                    ? () {}
                                                    : () {},
                                                style: TextButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFFCAEA95),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4)),
                                                ),
                                                child: Text(
                                                    job['status'] == '0'
                                                        ? 'Waiting for Approval'
                                                        : 'Go to Proposals',
                                                    style:
                                                        GoogleFonts.montserrat(
                                                            color: const Color(
                                                                0xFF5C8A3C),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 12)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ] else
                                        Text('No hired information available',
                                            style: GoogleFonts.montserrat(
                                                color: Colors.black54,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  // Call Tab
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (purchasedBy is Map<String, dynamic> &&
                                          purchasedBy['call_button_redirections']
                                                  ?.isNotEmpty ==
                                              true)
                                        TextButton(
                                          onPressed: () {
                                            if (purchasedBy[
                                                    'call_button_redirections'] ==
                                                'open_call_dial') {
                                              final mobileNo =
                                                  purchasedBy['mobile_no'] ??
                                                      '';
                                              if (mobileNo.isNotEmpty) {
                                                _openPhoneDialer(mobileNo);
                                              } else {
                                                _showSnackBar(
                                                    'Mobile number not available',
                                                    Colors.red);
                                              }
                                            } else if (purchasedBy[
                                                    'call_button_redirections'] ==
                                                'send_call_notification') {
                                              _showDialog(
                                                context: context,
                                                title: 'Send Notification',
                                                content: Text(
                                                    'Do you want to send a call notification?',
                                                    style:
                                                        GoogleFonts.montserrat(
                                                            color: Colorfile
                                                                .textColor,
                                                            fontSize: 12)),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                    child: Text('No',
                                                        style: GoogleFonts
                                                            .montserrat(
                                                                color:
                                                                    Colors.blue,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500)),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                      _sendNotification(
                                                          projectId: projectId,
                                                          bidderId: purchasedBy[
                                                                  'bidder_id']!
                                                              .toString(),
                                                          connectType: '1');
                                                    },
                                                    child: Text('Yes',
                                                        style: GoogleFonts
                                                            .montserrat(
                                                                color:
                                                                    Colors.blue,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500)),
                                                  ),
                                                ],
                                              );
                                            }
                                          },
                                          child: Text('Initiate Call',
                                              style: GoogleFonts.montserrat(
                                                  color: Colors.blue,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500)),
                                        )
                                      else
                                        Text('No call options available',
                                            style: GoogleFonts.montserrat(
                                                color: Colors.black54,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  // Chat Tab
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (purchasedBy is Map<String, dynamic> &&
                                          purchasedBy['chat_button_redirections']
                                                  ?.isNotEmpty ==
                                              true)
                                        TextButton(
                                          onPressed: () {
                                            if (purchasedBy[
                                                    'chat_button_redirections'] ==
                                                'chat_page') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatPage(
                                                          projectId: projectId,
                                                          chatSender:
                                                              chatSender,
                                                          chatReceiver:
                                                              chatReceiver),
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
                                                            color: Colorfile
                                                                .textColor,
                                                            fontSize: 12)),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                    child: Text('No',
                                                        style: GoogleFonts
                                                            .montserrat(
                                                                color:
                                                                    Colors.blue,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500)),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                      _sendNotification(
                                                          projectId: projectId,
                                                          bidderId: purchasedBy[
                                                                  'bidder_id']!
                                                              .toString(),
                                                          connectType: '2');
                                                    },
                                                    child: Text('Yes',
                                                        style: GoogleFonts
                                                            .montserrat(
                                                                color:
                                                                    Colors.blue,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500)),
                                                  ),
                                                ],
                                              );
                                            }
                                          },
                                          child: Text('Start Chat',
                                              style: GoogleFonts.montserrat(
                                                  color: Colors.blue,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500)),
                                        )
                                      else
                                        Text('No chat options available',
                                            style: GoogleFonts.montserrat(
                                                color: Colors.black54,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  // Proposal Tab
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextButton(
                                        onPressed: job['status'] == '0'
                                            ? () {}
                                            : () {},
                                        style: TextButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFCAEA95),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                        ),
                                        child: Text(
                                            job['status'] == '0'
                                                ? 'Waiting for Approval'
                                                : 'Go to Proposals',
                                            style: GoogleFonts.montserrat(
                                                color: const Color(0xFF5C8A3C),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
