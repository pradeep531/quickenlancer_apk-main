import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import '../api/network/uri.dart';

class ReceivedProjectsTab extends StatefulWidget {
  const ReceivedProjectsTab({super.key});

  @override
  _ReceivedProjectsTabState createState() => _ReceivedProjectsTabState();
}

class _ReceivedProjectsTabState extends State<ReceivedProjectsTab> {
  final String apiUrl = URLS().recieved_project;
  List<dynamic> projects = [];
  int offset = 0;
  final int limit = 10;
  bool isLoading = false;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchPostedProjects();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isLoading &&
          hasMore) {
        fetchPostedProjects();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchPostedProjects() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('user_id');
      final String? authToken = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authToken ?? ''}',
        },
        body: jsonEncode({
          "user_id": userId ?? "0",
          "limit": limit,
          "offset": offset,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('Response: $jsonResponse'); // Debug log
        if (jsonResponse['status'] == 'true') {
          setState(() {
            projects.addAll(jsonResponse['data']);
            offset += limit;
            hasMore = jsonResponse['data'].length == limit;
            isLoading = false;
          });
        } else {
          print('API Error: ${jsonResponse['message']}');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshProjects() async {
    setState(() {
      projects.clear();
      offset = 0;
      hasMore = true;
    });
    await fetchPostedProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: RefreshIndicator(
        onRefresh: _refreshProjects,
        color: Colorfile.primaryColor,
        backgroundColor: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: Text(
                'Received Projects',
                style: GoogleFonts.montserrat(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colorfile.textColor ?? Colors.black87,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: projects.isEmpty && !isLoading
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: projects.length + (hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == projects.length && hasMore) {
                          return _buildLoadingIndicator();
                        }
                        final project = projects[index];
                        return FadeInUp(
                          duration: Duration(milliseconds: 400 + (index * 150)),
                          child: _buildProjectCard(project, index),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 90,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            'No Projects Found',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Pull down to refresh and try again',
            style: GoogleFonts.montserrat(
              fontSize: 15,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            strokeWidth: 5,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colorfile.primaryColor ?? Colors.blueAccent,
            ),
            backgroundColor: Colors.grey[100],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(dynamic project, int index) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[100]!, width: 1),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          leading: CircleAvatar(
            radius: 28,
            backgroundColor:
                Colorfile.primaryColor?.withOpacity(0.15) ?? Colors.blue[50],
            child: Icon(
              Icons.work_outline,
              color: Colorfile.primaryColor ?? Colors.blueAccent,
              size: 28,
            ),
          ),
          title: Text(
            project['project_name'] ?? 'Untitled Project',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                RegExp(r'<[^>]+>').hasMatch(project['description'] ?? '')
                    ? project['description'].replaceAll(RegExp(r'<[^>]+>'), '')
                    : project['description'] ?? 'No description available',
                style: GoogleFonts.montserrat(
                  color: Colors.grey[600],
                  fontSize: 14,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Amount: ',
                    style: GoogleFonts.montserrat(
                      color: Colors.grey[800],
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${project['amount'] ?? 'N/A'}',
                    style: GoogleFonts.montserrat(
                      color: Colorfile.primaryColor ?? Colors.blueAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Posted on: ${project['created_on'] ?? 'N/A'}',
                style: GoogleFonts.montserrat(
                  color: Colors.grey[500],
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 10),
              _buildStatusChip(project['status'] ?? 'Active'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor;
    switch (status.toLowerCase()) {
      case 'active':
        chipColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'completed':
        chipColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        break;
      default:
        chipColor = Colors.grey[200]!;
        textColor = Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: chipColor.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
