import 'dart:developer';
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
  final counts = {'call': 5, 'chat': 3, 'milestone': 10, 'attachment': 8};

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
                    onPressed: () => Navigator.pop(context),
                    child: Text('Close',
                        style: GoogleFonts.montserrat(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)))
              ]
            : actions,
      ),
    );
  }

  void _showAddAvailabilityDialog(String projectId) {
    _showDialog(
      title: 'Your availability for this project',
      content: Text('No Time availability for this project.',
          style:
              GoogleFonts.montserrat(color: Colorfile.textColor, fontSize: 12)),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.montserrat(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w500))),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ScheduleAvailabilityPage(projectId: projectId)));
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

  Widget _buildCallTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 0,
            color: Colors.white,
            shape: const Border(
                bottom: BorderSide(color: Color(0xFFDDDDDD), width: 1)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(
                        'https://www.quickensol.com/quickenlancer-new/images/profile_pic/profile.png'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vaibhav Danve',
                          style: GoogleFonts.montserrat(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last Call On: 01 Jan, 1970  |  05:30 AM',
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
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  foregroundColor: Colorfile.textColor,
                                  side: const BorderSide(
                                      color: Colorfile.textColor, width: 1),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.phone,
                                        size: 15, color: Colorfile.textColor),
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                ),
                                child: TextButton(
                                  onPressed: () {},
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
          ),
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
                          builder: (context) => CallsList(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colorfile.textColor,
                      side: const BorderSide(
                          color: Colorfile.textColor, width: 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      'View All',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF51A5D1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Send Proposal',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Image.asset(
                          'assets/send1.png',
                          height: 18,
                          width: 18,
                          color: Colors.white,
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
    );
  }

  Widget _proposalTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 0,
            color: Colors.white,
            shape: const Border(
                bottom: BorderSide(color: Color(0xFFDDDDDD), width: 1)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(
                        'https://www.quickensol.com/quickenlancer-new/images/profile_pic/profile.png'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vaibhav Danve',
                          style: GoogleFonts.montserrat(
                            color: Colorfile.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last Call On: 01 Jan, 1970  |  05:30 AM',
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
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    foregroundColor: Color(0xFF000000),
                                    side: const BorderSide(
                                        color: Color(0xFF000000), width: 1),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4)),
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
                              SizedBox(
                                height: 36,
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    foregroundColor: Color(0xFF000000),
                                    side: const BorderSide(
                                        color: Color(0xFF000000), width: 1),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4)),
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
          ),
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
                          builder: (context) => AllProposals(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xFF000000),
                      side:
                          const BorderSide(color: Color(0xFF000000), width: 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      'View All',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color(0xFF51A5D1), // Updated background color
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Send Proposal',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Image.asset(
                          'assets/send1.png', // Replace with your PNG path
                          height: 18,
                          width: 18,
                          color: Colors.white, // Tint to match text color
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
    );
  }
  // Reusable widget for Chat Tab

  // Reusable widget for Milestone Tab

  // Reusable widget for Attachment Tab

  @override
  Widget build(BuildContext context) {
    final jobTextStyle = GoogleFonts.poppins(
        color: Colorfile.textColor,
        fontSize: 10,
        fontWeight: FontWeight.w500,
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
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: projects.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == projects.length && hasMore) {
                        _fetchProjects();
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

                      return DefaultTabController(
                        length: 4,
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
                                        borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                'Posted On: ${job['created_on']?.isNotEmpty == true ? DateFormat('dd/MM/yyyy').format(DateTime.parse(job['created_on'])) : 'N/A'}',
                                                style: jobTextStyle),
                                            Text(
                                                'Project Cost: ${job['amount'] ?? 'No Amount'}',
                                                style: jobTextStyle),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                'How to Pay: ${job['project_type'] == '0' ? 'Fixed' : job['project_type'] == '1' ? 'Hourly' : 'N/A'}',
                                                style: jobTextStyle),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                  minimumSize: Size.zero,
                                                  padding: EdgeInsets.zero,
                                                  tapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap),
                                              onPressed: () {
                                                final availability = job[
                                                        'time_availability']
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
                                                        availability[day] ==
                                                        '1')) {
                                                  _showAddAvailabilityDialog(
                                                      projectId);
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
                                                          availability[day] ==
                                                          '1')
                                                      .map((day) =>
                                                          '${day.capitalize()}: ${availability['from_$day'] ?? 'N/A'} - ${availability['to_$day'] ?? 'N/A'}')
                                                      .join('\n');
                                                  _showDialog(
                                                      title: 'Availability',
                                                      content: Text(
                                                          result.isEmpty
                                                              ? 'No availability specified'
                                                              : result,
                                                          style: jobTextStyle));
                                                }
                                              },
                                              child: RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                        text:
                                                            'Availability Time: ',
                                                        style: jobTextStyle),
                                                    TextSpan(
                                                      text: (job['time_availability']
                                                                      as Map<
                                                                          String,
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
                                                                          entry
                                                                              .key) &&
                                                                      entry.value ==
                                                                          '1') ==
                                                              true
                                                          ? 'Schedule'
                                                          : 'Add Schedule',
                                                      style:
                                                          jobTextStyle.copyWith(
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                              color:
                                                                  Colors.blue),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                            'Requirement Type: ${job['requirement_type'] == '0' ? 'Cold' : job['requirement_type'] == '1' ? 'Hot' : 'N/A'}',
                                            style: jobTextStyle),
                                        Text(
                                            'Looking For: ${job['looking_for'] == '1' ? 'Company' : job['looking_for'] == '2' ? 'Freelancer' : 'Company/Freelancer'}',
                                            style: jobTextStyle),
                                        if (proposals != null) ...[
                                          Text(
                                              'Max Proposal Cost: ${proposals['max_mston_amount']?.toString() ?? 'N/A'}',
                                              style: jobTextStyle),
                                          Text(
                                              'Min Proposal Cost: ${proposals['min_mston_amount']?.toString() ?? 'N/A'}',
                                              style: jobTextStyle),
                                          Text(
                                              'Avg Proposal Cost: ${proposals['average_mston_amount']?.toString() ?? 'N/A'}',
                                              style: jobTextStyle),
                                          Text(
                                              'Total Proposals: ${proposals['total_proposal']?.toString() ?? 'N/A'}',
                                              style: jobTextStyle),
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
                                      .map((skill) => Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 8),
                                            decoration: BoxDecoration(
                                                color: const Color(0xFFE8F1FC),
                                                borderRadius:
                                                    BorderRadius.circular(4)),
                                            child: Text(skill['skill'] ?? '',
                                                style: GoogleFonts.montserrat(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        Colorfile.textColor)),
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
                                    const Tab(text: 'Hired On'),
                                    Tab(
                                        child:
                                            _buildTab('Call', counts['call']!)),
                                    Tab(
                                        child:
                                            _buildTab('Chat', counts['chat']!)),
                                    Tab(
                                        child: _buildTab(
                                            'Proposal', counts['milestone']!,
                                            maxWidth: 90)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 150,
                                  child: TabBarView(
                                    controller: tabControllers[projectId],
                                    children: [
                                      // Hired On Tab
                                      SingleChildScrollView(
                                        child: purchasedBy
                                                is Map<String, dynamic>
                                            ? Column(
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
                                                                  NetworkImage(
                                                                      purchasedBy[
                                                                              'profile_pic'] ??
                                                                          'https://www.quickensol.com/quickenlancer-new/images/profile_pic/profile.png')),
                                                          const SizedBox(
                                                              width: 10),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  '${purchasedBy['f_name'] ?? ''} ${purchasedBy['l_name'] ?? ''}',
                                                                  style: GoogleFonts.montserrat(
                                                                      fontSize:
                                                                          12,
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
                                                                          width:
                                                                              20,
                                                                          errorBuilder: (_, __, ___) => const Icon(Icons.image,
                                                                              size:
                                                                                  20,
                                                                              color: Colors
                                                                                  .grey))
                                                                      : const Icon(
                                                                          Icons
                                                                              .image,
                                                                          size:
                                                                              20,
                                                                          color:
                                                                              Colors.grey),
                                                                  const SizedBox(
                                                                      width: 4),
                                                                  Text(
                                                                      '${purchasedBy['city_name'] ?? ''}, ${purchasedBy['country_name'] ?? ''}',
                                                                      style: GoogleFonts.montserrat(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.black54)),
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
                                                                              projectId: projectId,
                                                                              chatSender: job['chat_sender'].toString(),
                                                                              chatReceiver: job['chat_receiver'].toString())));
                                                                } else if (purchasedBy[
                                                                        'chat_button_redirections'] ==
                                                                    'send_chat_notification') {
                                                                  _showDialog(
                                                                    title:
                                                                        'Send Notification',
                                                                    content: Text(
                                                                        'Do you want to send a chat notification?',
                                                                        style: GoogleFonts.montserrat(
                                                                            color:
                                                                                Colorfile.textColor,
                                                                            fontSize: 12)),
                                                                    actions: [
                                                                      TextButton(
                                                                          onPressed: () => Navigator.pop(
                                                                              context),
                                                                          child: Text(
                                                                              'No',
                                                                              style: GoogleFonts.montserrat(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w500))),
                                                                      TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                          _sendNotification(
                                                                              projectId: projectId,
                                                                              bidderId: purchasedBy['bidder_id'].toString(),
                                                                              connectType: '2');
                                                                        },
                                                                        child: Text(
                                                                            'Yes',
                                                                            style: GoogleFonts.montserrat(
                                                                                color: Colors.blue,
                                                                                fontSize: 12,
                                                                                fontWeight: FontWeight.w500)),
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
                                                          const SizedBox(
                                                              width: 8),
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
                                                                        Colors
                                                                            .red);
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
                                                                            color:
                                                                                Colorfile.textColor,
                                                                            fontSize: 12)),
                                                                    actions: [
                                                                      TextButton(
                                                                          onPressed: () => Navigator.pop(
                                                                              context),
                                                                          child: Text(
                                                                              'No',
                                                                              style: GoogleFonts.montserrat(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w500))),
                                                                      TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                          _sendNotification(
                                                                              projectId: projectId,
                                                                              bidderId: purchasedBy['bidder_id'].toString(),
                                                                              connectType: '1');
                                                                        },
                                                                        child: Text(
                                                                            'Yes',
                                                                            style: GoogleFonts.montserrat(
                                                                                color: Colors.blue,
                                                                                fontSize: 12,
                                                                                fontWeight: FontWeight.w500)),
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
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .black54)),
                                                        const Text(':',
                                                            textAlign: TextAlign
                                                                .center),
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
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .black54)),
                                                      ]),
                                                      TableRow(children: [
                                                        Text('Hired Status',
                                                            style: GoogleFonts
                                                                .montserrat(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .black54)),
                                                        const Text(':',
                                                            textAlign: TextAlign
                                                                .center),
                                                        Text(
                                                            purchasedBy[
                                                                    'hired_status'] ??
                                                                '',
                                                            textAlign:
                                                                TextAlign.right,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .black54)),
                                                      ]),
                                                      if (imagePath.isNotEmpty)
                                                        TableRow(children: [
                                                          Text(
                                                              'Project Attachments',
                                                              style: GoogleFonts
                                                                  .montserrat(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .black54)),
                                                          const Text(':',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center),
                                                          Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Transform.rotate(
                                                                    angle: 0.6,
                                                                    child: const Icon(
                                                                        Icons
                                                                            .attach_file,
                                                                        color: Colorfile
                                                                            .textColor,
                                                                        size:
                                                                            15))
                                                              ]),
                                                        ]),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: TextButton(
                                                          onPressed: () =>
                                                              _showDialog(
                                                            title:
                                                                'Attachments',
                                                            content: imagePath
                                                                    .isEmpty
                                                                ? Text(
                                                                    'No attachments available',
                                                                    style: GoogleFonts.montserrat(
                                                                        color: Colorfile
                                                                            .textColor,
                                                                        fontSize:
                                                                            12))
                                                                : SizedBox(
                                                                    height: 300,
                                                                    width: 250,
                                                                    child: ListView
                                                                        .builder(
                                                                      itemCount:
                                                                          imagePath
                                                                              .length,
                                                                      itemBuilder:
                                                                          (context,
                                                                              index) {
                                                                        final url =
                                                                            imagePath[index];
                                                                        return Column(
                                                                          children: [
                                                                            Image.network(url,
                                                                                height: 150,
                                                                                width: 200,
                                                                                fit: BoxFit.cover,
                                                                                errorBuilder: (_, __, ___) => const Icon(Icons.file_copy, size: 100, color: Colors.grey)),
                                                                            TextButton(
                                                                              onPressed: () => _showDialog(
                                                                                title: 'Confirm Download',
                                                                                content: Text('Download this file?', style: GoogleFonts.montserrat(color: Colorfile.textColor, fontSize: 12)),
                                                                                actions: [
                                                                                  TextButton(onPressed: () => Navigator.pop(context), child: Text('No', style: GoogleFonts.montserrat(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w500))),
                                                                                  TextButton(
                                                                                    onPressed: () {
                                                                                      Navigator.pop(context);
                                                                                      Navigator.pop(context);
                                                                                      _downloadImage(url);
                                                                                    },
                                                                                    child: Text('Yes', style: GoogleFonts.montserrat(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w500)),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              child: Text('Download', style: GoogleFonts.montserrat(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w500)),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                          ),
                                                          style: TextButton.styleFrom(
                                                              backgroundColor:
                                                                  const Color(
                                                                      0xFFFAFAFA),
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                  side: const BorderSide(
                                                                      color: Color(
                                                                          0xFFD9D9D9)))),
                                                          child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Transform.rotate(
                                                                    angle: 0.6,
                                                                    child: const Icon(
                                                                        Icons
                                                                            .attach_file,
                                                                        color: Colorfile
                                                                            .textColor)),
                                                                const SizedBox(
                                                                    width: 8),
                                                                Text(
                                                                    'Attachment',
                                                                    style: GoogleFonts.montserrat(
                                                                        color: Colorfile
                                                                            .textColor,
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w500)),
                                                              ]),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: TextButton(
                                                          onPressed:
                                                              job['status'] ==
                                                                      '0'
                                                                  ? () {}
                                                                  : () {},
                                                          style: TextButton.styleFrom(
                                                              backgroundColor:
                                                                  const Color(
                                                                      0xFFCAEA95),
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4))),
                                                          child: Text(
                                                              job['status'] ==
                                                                      '0'
                                                                  ? 'Waiting for Approval'
                                                                  : 'Go to Proposals',
                                                              style: GoogleFonts.montserrat(
                                                                  color: const Color(
                                                                      0xFF5C8A3C),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize:
                                                                      12)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            : Text(
                                                'No hired information available',
                                                style: GoogleFonts.montserrat(
                                                    color: Colors.black54,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                      ),
                                      // Call Tab
                                      _buildCallTab(),
                                      // Chat Tab
                                      _buildCallTab(),
                                      _proposalTab(),
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
