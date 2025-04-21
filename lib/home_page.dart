import 'dart:convert';
import 'dart:developer' show log;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:quickenlancer_apk/api/network/uri.dart';
import 'package:quickenlancer_apk/filter_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quickenlancer_apk/BottomBar/bottom_bar.dart';
import 'package:quickenlancer_apk/Call/callpage.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import 'package:quickenlancer_apk/Chat/chatpage.dart';
import 'package:quickenlancer_apk/side_bar_drawer.dart';
import 'package:shimmer/shimmer.dart';
import 'profilepage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  List<dynamic> _currentFilters = [];
  List<Job> _jobs = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _offset = 0;
  final int _limit = 10;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();
  String _firstName = '';
  String _lastName = '';
  String _country = '';
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    initiateSearchProjectData();
    _fetchProjects();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.9 &&
          !_isLoading &&
          !_isLoadingMore &&
          _hasMoreData) {
        _fetchMoreProjects();
      }
    });

    _searchController.addListener(() {
      setState(() {
        _searchKeyword = _searchController.text.trim();
      });
    });
  }

  Future<void> initiateSearchProjectData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('auth_token');
      final userId = prefs.getString('user_id') ?? '';

      final String searchUrl = URLS().initiate_search_project_data_api;
      final searchRequestBody = jsonEncode({
        "user_id": userId,
      });

      log('Search API Request body: $searchRequestBody');

      final searchResponse = await http.post(
        Uri.parse(searchUrl),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: searchRequestBody,
      );

      print('Search API Response status: ${searchResponse.statusCode}');
      print('Search API Response body: ${searchResponse.body}');
    } catch (e) {
      print('Search API Error: $e');
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    print(
        'SharedPreferences: first_name=${prefs.getString('first_name')}, last_name=${prefs.getString('last_name')}, country=${prefs.getString('country')}');
    setState(() {
      _firstName = prefs.getString('first_name') ?? '';
      _lastName = prefs.getString('last_name') ?? '';
      _country = prefs.getString('country') ?? '';
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProjects({bool isLoadMore = false}) async {
    if (isLoadMore) {
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _offset = 0;
        _jobs.clear();
        _hasMoreData = true;
      });
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final String? authToken = prefs.getString('auth_token');

      final body = jsonEncode({
        "user_id": userId,
        "search_keyword": _searchKeyword,
        "limit": _limit,
        "offset": _offset,
        "filters": _currentFilters,
      });

      print('API URL: ${URLS().search_project_apiUrl}');
      print('Request Body: $body');
      log('Request Body: $body', name: 'fetchProjects');

      final response = await http.post(
        Uri.parse(URLS().search_project_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: body,
      );

      print('Response Status: ${response.statusCode}');
      print(
          'Response Body: ${response.body.isEmpty ? "EMPTY" : response.body}');
      log('Response Body: ${response.body}', name: 'fetchProjects');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          log('Error: Empty response body', name: 'fetchProjects');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Empty response from server')),
          );
          setState(() => _hasMoreData = false);
          return;
        }

        final jsonResponse = jsonDecode(response.body);
        print('JSON Response: $jsonResponse'); // Debug log
        if (jsonResponse is Map<String, dynamic> &&
            jsonResponse['status'] == "true") {
          final data = jsonResponse['data'];
          if (data is List) {
            final newJobs = data.map((json) => Job.fromJson(json)).toList();

            setState(() {
              if (isLoadMore) {
                _jobs.addAll(newJobs);
              } else {
                _jobs = newJobs;
              }
              _offset += _limit;
              _hasMoreData = newJobs.length == _limit;
            });
          } else {
            log('Error: Data is not a list', name: 'fetchProjects');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid data format from server')),
            );
            setState(() => _hasMoreData = false);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No more data available')),
          );
          setState(() => _hasMoreData = false);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('HTTP Error: ${response.statusCode}')),
        );
        setState(() => _hasMoreData = false);
      }
    } catch (e) {
      log('Error fetching projects: $e', name: 'fetchProjects');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch projects')),
      );
      setState(() => _hasMoreData = false);
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _fetchMoreProjects() async {
    await _fetchProjects(isLoadMore: true);
  }

  Future<void> _onRefresh() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyHomePage()),
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    final routes = {
      2: Callpage(),
      3: Chatpage(),
      4: ProfilePage(),
    };
    if (routes.containsKey(index)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => routes[index]!),
      );
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => FilterBottomSheet(
        onApplyFilters: (List<dynamic> filters) {
          print('Filters applied in _showFilterSheet: $filters');
          setState(() {
            _currentFilters = filters;
          });
          _fetchProjects();
        },
        onClearFilters: () {
          print('Filters cleared in _showFilterSheet');
          setState(() {
            _currentFilters = [];
          });
          _fetchProjects();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.04;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F1FC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/profile_pic.png'),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_firstName $_lastName'.trim(),
                  style: GoogleFonts.montserrat(
                    fontSize: size.width * 0.042,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
              child: Row(
                children: [
                  Expanded(child: _buildSearchField(size)),
                  const SizedBox(width: 8),
                  _buildFilterButton(),
                ],
              ),
            ),
            Expanded(
              child: _isLoading && _jobs.isEmpty
                  ? _buildShimmerList(size)
                  : ListContainer(
                      jobs: _jobs,
                      scrollController: _scrollController,
                    ),
            ),
            if (_isLoadingMore)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
      endDrawer: SideBarDrawer(),
      bottomNavigationBar: MyBottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildSearchField(Size size) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Color(0xFFB7D7F9), Color(0xFFE5ACCB)],
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.montserrat(
          fontSize: size.width * 0.038,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search projects...',
          hintStyle: GoogleFonts.montserrat(
            fontSize: size.width * 0.038,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
          prefixIcon: const Icon(
            CupertinoIcons.search,
            color: Color(0xFFA5A5A5),
            size: 22,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFFA5A5A5)),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchKeyword = '';
                    });
                    _fetchProjects();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (value) {
          setState(() {
            _searchKeyword = value.trim();
          });
          _fetchProjects();
        },
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Color(0xFFB7D7F9), Color(0xFFE5ACCB)],
        ),
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
          icon: Image.asset('assets/filter 1.png', height: 22),
          onPressed: _showFilterSheet,
        ),
      ),
    );
  }

  Widget _buildShimmerList(Size size) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: size.height * 0.15,
              width: size.width,
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ListContainer extends StatefulWidget {
  final List<Job> jobs;
  final ScrollController? scrollController;

  const ListContainer({
    super.key,
    required this.jobs,
    this.scrollController,
  });

  @override
  _ListContainerState createState() => _ListContainerState();
}

class _ListContainerState extends State<ListContainer> {
  final Map<int, bool> _expandedStates = {};

  String getLookingForText(String lookingFor) {
    switch (lookingFor) {
      case '1':
        return 'Looking for Company';
      case '2':
        return 'Looking for Freelancer';
      case '3':
        return 'Looking for Freelancer & Company';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final jobs = widget.jobs;

    return jobs.isEmpty
        ? const Center(child: Text('No data available'))
        : ListView.builder(
            controller: widget.scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              final isExpanded = _expandedStates[index] ?? false;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB7D7F9), Color(0xFFE5ACCB)],
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.projectName,
                              style: GoogleFonts.montserrat(
                                fontSize: size.width * 0.040,
                                fontWeight: FontWeight.w600,
                                color: Colorfile.textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                job.countryFlagPath.isNotEmpty
                                    ? Image.network(
                                        job.countryFlagPath,
                                        width: size.width * 0.035,
                                        height: size.width * 0.03,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            Icons.image_not_supported,
                                            size: size.width * 0.035,
                                            color: Colors.grey,
                                          );
                                        },
                                      )
                                    : Image.asset(
                                        'assets/placeholder_flag.png',
                                        width: size.width * 0.035,
                                      ),
                                const SizedBox(width: 6),
                                Text(
                                  '${job.country} | ${job.requirementType == '0' ? 'Cold 🧊' : 'Hot 🔥'}',
                                  style: GoogleFonts.montserrat(
                                    fontSize: size.width * 0.032,
                                    fontWeight: FontWeight.w500,
                                    color: Colorfile.textColor,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              getLookingForText(job.lookingFor),
                              style: GoogleFonts.montserrat(
                                fontSize: size.width * 0.032,
                                fontWeight: FontWeight.w500,
                                color: Colorfile.textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () => setState(
                                () => _expandedStates[index] = !isExpanded,
                              ),
                              child: Html(
                                data: isExpanded
                                    ? job.description
                                    : job.description.length > 80
                                        ? '${job.description.substring(0, 80)}...'
                                        : job.description,
                                style: {
                                  '*': Style(
                                    fontSize: FontSize(size.width * 0.034),
                                    fontWeight: FontWeight.w500,
                                    color: Colorfile.textColor,
                                    maxLines: isExpanded ? null : 2,
                                    textOverflow: isExpanded
                                        ? null
                                        : TextOverflow.ellipsis,
                                  ),
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: job.tags
                              .map(
                                (tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F1FC),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    tag,
                                    style: GoogleFonts.montserrat(
                                      fontSize: size.width * 0.030,
                                      fontWeight: FontWeight.w500,
                                      color: Colorfile.textColor,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${job.currency} ${job.amount}',
                              style: GoogleFonts.montserrat(
                                fontSize: size.width * 0.036,
                                fontWeight: FontWeight.w600,
                                color: Colorfile.textColor,
                              ),
                            ),
                            Text(
                              job.projectType == '0' ? 'Fixed' : 'Hourly',
                              style: GoogleFonts.montserrat(
                                fontSize: size.width * 0.036,
                                fontWeight: FontWeight.w600,
                                color: Colorfile.textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 5),
                        color: const Color(0xFFD9D9D9),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (job.chatButtonRedirection.isNotEmpty)
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: _buildActionButton(
                                    'Chat',
                                    'assets/chat.png',
                                    size,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Chatpage(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            if (job.callButtonRedirection.isNotEmpty)
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: _buildActionButton(
                                    'Call',
                                    'assets/call.png',
                                    size,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Callpage(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            if (job.proposalButtonRedirection.isNotEmpty)
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: _buildActionButton(
                                    'Proposal',
                                    null,
                                    size,
                                    onPressed: () {},
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildActionButton(
    String label,
    String? iconPath,
    Size size, {
    required VoidCallback? onPressed,
  }) =>
      CupertinoButton(
        onPressed: onPressed,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
        color: Colorfile.textColor,
        borderRadius: BorderRadius.circular(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconPath != null) ...[
              ColorFiltered(
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                child: Image.asset(iconPath, width: 18, height: 18),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: size.width * 0.032,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
}

class Job {
  final String id;
  final String userId;
  final String projectName;
  final String description;
  final String currency;
  final String amount;
  final String lookingFor;
  final String requirementType;
  final String projectType;
  final String country;
  final String countryFlagPath;
  final List<String> tags;
  final String chatButtonRedirection;
  final String callButtonRedirection;
  final String proposalButtonRedirection;

  Job({
    required this.id,
    required this.userId,
    required this.projectName,
    required this.description,
    required this.currency,
    required this.amount,
    required this.lookingFor,
    required this.requirementType,
    required this.projectType,
    required this.country,
    required this.countryFlagPath,
    required this.tags,
    required this.chatButtonRedirection,
    required this.callButtonRedirection,
    required this.proposalButtonRedirection,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    List<String> tags = [];

    if (json['skills_names'] != null && json['skills_names'] is List) {
      for (var skill in json['skills_names']) {
        if (skill is Map &&
            skill['skill'] != null &&
            skill['skill'].toString().isNotEmpty) {
          tags.add(skill['skill'].toString().trim());
        }
      }
    }

    if (tags.isEmpty) {
      if (json['other_skills'] != null &&
          json['other_skills'] is String &&
          json['other_skills'].isNotEmpty) {
        tags.addAll(
          (json['other_skills'] as String)
              .split(' ')
              .where((tag) => tag.trim().isNotEmpty),
        );
      }

      if (json['skill'] != null &&
          json['skill'] is String &&
          json['skill'].isNotEmpty) {
        tags.addAll(
          (json['skill'] as String)
              .split(',')
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty),
        );
      }
    }

    String currency = '';
    if (json['currency_label'] != null && json['currency_label'] is Map) {
      currency = json['currency_label']['currency']?.toString() ?? '';
    }

    return Job(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      projectName: json['project_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      currency: currency,
      amount: json['amount']?.toString() ?? '0',
      lookingFor: json['looking_for']?.toString() ?? '',
      requirementType: json['requirement_type']?.toString() ?? '0',
      projectType: json['project_type']?.toString() ?? '0',
      country: json['country_name']?.toString() ?? 'N/A',
      countryFlagPath: json['country_flag_path']?.toString() ?? '',
      tags: tags,
      chatButtonRedirection: json['chat_button_redirection']?.toString() ?? '',
      callButtonRedirection: json['call_button_redirection']?.toString() ?? '',
      proposalButtonRedirection:
          json['proposal_button_redirection']?.toString() ?? '',
    );
  }
}
