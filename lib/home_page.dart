import 'dart:convert';
import 'dart:developer' show log;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:quickenlancer_apk/Projects/all_projects.dart';
import 'package:quickenlancer_apk/api/network/uri.dart';
import 'package:quickenlancer_apk/filter_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quickenlancer_apk/BottomBar/bottom_bar.dart';
import 'package:quickenlancer_apk/Call/callpage.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import 'package:quickenlancer_apk/Chat/chatpage.dart';
import 'package:quickenlancer_apk/side_bar_drawer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'SignUp/signIn.dart';
import 'chat_page.dart';
import 'editprofilepage.dart';
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
  int? isLoggedIn;
  String profilePicPath = '';
  @override
  void initState() {
    super.initState();
    _initializeData(); // Call async operations in a separate method
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

  Future<void> _initializeData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn =
          prefs.getInt('is_logged_in'); // Assign value after async call
      profilePicPath =
          prefs.getString('profile_pic_path') ?? ''; // Store profile_pic_path
    });
    await _loadPreferences();
    // await initiateSearchProjectData();
    await _fetchProjects();
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
    // Skip login check for homepage (index 0)
    if (index != 0 && isLoggedIn != 1) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: Text(
              'Login Required',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Colors.black87,
              ),
            ),
            content: Text(
              'You need to log in to access this feature. Would you like to log in now?',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            actionsPadding:
                EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                },
                child: Text(
                  'No',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SignInPage()),
                  );
                },
                child: Text(
                  'Yes',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  backgroundColor: Colors.blue[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          );
        },
      );
      return;
    }

    final routes = {
      0: MyHomePage(),
      1: AllProjects(),
      2: Buycallpage(),
      3: Buychatpage(),
      4: Editprofilepage(),
    };

    if (routes.containsKey(index)) {
      // Only update _selectedIndex if navigation is successful
      setState(() => _selectedIndex = index);
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

    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  // Background color
                  backgroundColor: Colors.white,
                  // Rounded corners
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  // Title styling
                  title: Text(
                    'Exit App',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black87,
                    ),
                  ),
                  // Content styling
                  content: Text(
                    'Are you sure you want to exit?',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black54,
                      height: 1.5, // Line height
                    ),
                  ),
                  // Actions padding and alignment
                  actionsPadding:
                      EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'No',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        'Yes',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.red[700], // Red for exit action
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        backgroundColor: Colors
                            .red[50], // Subtle background for "Yes" button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ) ??
            false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFE8F1FC),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              profilePicPath.isEmpty &&
                      (_firstName?.isEmpty != false &&
                          _lastName?.isEmpty != false)
                  ? ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SignInPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colorfile.textColor, // Button background color
                        foregroundColor: Colors.white, // Text/icon color
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ), // Button padding
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(4), // Rounded corners
                          side: BorderSide(
                            color: Colors.white, // Border color
                            width: 0.5, // Border width
                          ),
                        ),
                        elevation: 3, // Shadow elevation
                        // Shadow color
                        textStyle: GoogleFonts.montserrat(
                          fontSize: size.width * 0.042,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white, // Text color
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: profilePicPath.isNotEmpty
                              ? NetworkImage(
                                  profilePicPath) // Use profile picture URL
                              : null, // No background image when using icon
                          child: profilePicPath.isEmpty
                              ? const Icon(
                                  Icons.person, // Default profile icon
                                  size: 24,
                                  color: Colors.grey, // Customize icon color
                                )
                              : null, // No child when image is present
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (_firstName?.isNotEmpty == true ||
                                      _lastName?.isNotEmpty == true)
                                  ? '$_firstName $_lastName'.trim()
                                  : 'Not Available', // Show "Not Available" if names are empty
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
          // prefixIcon: const Icon(
          //   CupertinoIcons.search,
          //   color: Color(0xFFA5A5A5),
          //   size: 22,
          // ),
          suffixIcon: _searchController.text.isNotEmpty
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Clear button
                    IconButton(
                      icon: const Icon(Icons.clear, color: Color(0xFFA5A5A5)),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchKeyword = '';
                        });
                        _fetchProjects();
                      },
                    ),
                    // Search icon button
                    IconButton(
                      icon: const Icon(CupertinoIcons.search,
                          color: Color(0xFF3A3A3A)),
                      onPressed: () {
                        setState(() {
                          _searchKeyword = _searchController.text.trim();
                        });
                        _fetchProjects();
                      },
                    ),
                  ],
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
            _searchController.clear(); // Clear the text field
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
  // Track loading state for each job's buttons
  final Map<String, bool> _chatLoadingStates = {};
  final Map<String, bool> _callLoadingStates = {};

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

  // API call to allocate chat/call
  Future<bool> _allocateChatCall({
    required BuildContext context,
    required BuildContext dialogContext, // Added for navigation and SnackBars
    required String userId,
    required String projectId,
    required String chatSender,
    required String chatReceiver,
    required int tokenFor,
    required String dontAskAgain,
  }) async {
    try {
      final String apiUrl = URLS().allocate_chat_call;
      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('auth_token');

      if (authToken == null) {
        log('Allocate Chat/Call Error: No auth token found');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in again')),
          );
        }
        return false;
      }

      final requestBody = jsonEncode({
        'user_id': userId,
        'project_id': projectId,
        'token_for': tokenFor,
        'dont_ask_again': dontAskAgain,
      });

      log('Allocate Chat/Call API Request Body: $requestBody');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: requestBody,
      );

      log('Allocate Chat/Call API Response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'true') {
          // Success handling based on tokenFor
          if (tokenFor == 1) {
            // Chat action
            if (dialogContext.mounted) {
              Navigator.push(
                dialogContext,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    projectId: projectId,
                    chatSender: chatSender,
                    chatReceiver: chatReceiver,
                  ),
                ),
              );
            }
          } else if (tokenFor == 2) {
            // Call action
            final String callApiUrl = URLS().set_call_entry;
            final callResponse = await http.post(
              Uri.parse(callApiUrl),
              headers: {
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'user_id': userId,
                'project_id': projectId,
                'project_owner_id': '',
                'used_token_id': '',
              }),
            );

            if (callResponse.statusCode == 200) {
              final callResponseData = jsonDecode(callResponse.body);
              if (callResponseData['status'] == 'true') {
                final receiverMobileNo =
                    callResponseData['data']['receiver_mobile_no'];
                _openPhoneDialer(receiverMobileNo);
              } else {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error: ${callResponseData['message']}',
                        style: TextStyle(fontFamily: 'Roboto'),
                      ),
                      backgroundColor: Colors.red.shade400,
                    ),
                  );
                }
                return false;
              }
            } else {
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to connect to the server',
                      style: TextStyle(fontFamily: 'Roboto'),
                    ),
                    backgroundColor: Colors.red.shade400,
                  ),
                );
              }
              return false;
            }
          }
          return true;
        } else {
          log('Allocate Chat/Call Failed: ${jsonResponse['message']}');
          if (dialogContext.mounted) {
            ScaffoldMessenger.of(dialogContext).showSnackBar(
              SnackBar(
                content: Text(jsonResponse['message'] ?? 'Action failed'),
                backgroundColor: Colors.red.shade400,
              ),
            );
          }
          return false;
        }
      } else {
        log('Allocate Chat/Call HTTP Error: ${response.statusCode}');
        if (dialogContext.mounted) {
          ScaffoldMessenger.of(dialogContext).showSnackBar(
            SnackBar(
              content: Text('HTTP Error: ${response.statusCode}'),
              backgroundColor: Colors.red.shade400,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      log('Allocate Chat/Call Error: $e');
      if (dialogContext.mounted) {
        ScaffoldMessenger.of(dialogContext).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
      return false;
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
              // Get loading states for this job
              final isChatLoading = _chatLoadingStates[job.id] ?? false;
              final isCallLoading = _callLoadingStates[job.id] ?? false;

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
                                    job.chatButtonRedirection == 'chat_page'
                                        ? 'Chat Now'
                                        : 'Chat${job.chatDontAskAgain == '0' ? '' : ''}', // Add star if chatDontAskAgain is '0'
                                    'assets/chat.png',
                                    size,
                                    isLoading: isChatLoading,
                                    onPressed: () async {
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      final int? isLoggedIn =
                                          prefs.getInt('is_logged_in');
                                      final String? userId =
                                          prefs.getString('user_id');

                                      if (isLoggedIn == 1) {
                                        if (job.chatButtonRedirection ==
                                            'deduct_from_coin_balance') {
                                          if (job.chatDontAskAgain == '1') {
                                            setState(() =>
                                                _chatLoadingStates[job.id] =
                                                    true);
                                            final success =
                                                await _allocateChatCall(
                                              context: context,
                                              userId: userId ?? '',
                                              projectId: job.id,
                                              chatReceiver: job.chatReceiver,
                                              chatSender: job.chatSender,
                                              tokenFor: 1, // Chat
                                              dontAskAgain: '0',
                                              dialogContext:
                                                  context, // Direct call
                                            );
                                            setState(() =>
                                                _chatLoadingStates[job.id] =
                                                    false);
                                            if (success) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatPage(
                                                    projectId: job.id,
                                                    chatSender: job.chatSender,
                                                    chatReceiver:
                                                        job.chatReceiver,
                                                  ),
                                                ),
                                              );
                                            }
                                          } else {
                                            _showCoinBalanceDialog(
                                              context,
                                              job: job,
                                              isChat: true,
                                              userId: userId ?? '0',
                                            );
                                          }
                                        } else if (job.chatButtonRedirection ==
                                            'buy_for_this_project') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Buychatpage(id: job.id),
                                            ),
                                          );
                                        } else if (job.chatButtonRedirection ==
                                            'chat_page') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ChatPage(
                                                projectId: job.id,
                                                chatSender: job.chatSender,
                                                chatReceiver: job.chatReceiver,
                                              ),
                                            ),
                                          );
                                        }
                                      } else {
                                        if (job.chatDontAskAgain == '1') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SignInPage(),
                                            ),
                                          );
                                        } else {
                                          bool? confirm =
                                              await _showConfirmationDialog(
                                                  context);
                                          if (confirm == true) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SignInPage(),
                                              ),
                                            );
                                          }
                                        }
                                      }
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
                                    job.callButtonRedirection ==
                                            'open_call_dial'
                                        ? 'Call Now' // Show "Call Now" for open_call_dial
                                        : 'Call${job.callDontAskAgain == '0' ? '' : ''}', // Original label for other cases
                                    'assets/call.png',
                                    size,
                                    isLoading: isCallLoading,
                                    onPressed: () async {
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      final int? isLoggedIn =
                                          prefs.getInt('is_logged_in');
                                      final String? userId =
                                          prefs.getString('user_id');
                                      final String? authToken =
                                          prefs.getString('auth_token');

                                      if (isLoggedIn == 1) {
                                        if (job.callButtonRedirection ==
                                            'deduct_from_coin_balance') {
                                          if (job.callDontAskAgain == '1') {
                                            setState(() =>
                                                _callLoadingStates[job.id] =
                                                    true);
                                            final success =
                                                await _allocateChatCall(
                                              context: context,
                                              userId: userId ?? '',
                                              projectId: job.id,
                                              chatReceiver: job.chatReceiver,
                                              chatSender: job.chatSender,
                                              tokenFor: 2,
                                              dontAskAgain: '0',
                                              dialogContext: context,
                                            );
                                            setState(() =>
                                                _callLoadingStates[job.id] =
                                                    false);
                                            if (success) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      Buycallpage(id: job.id),
                                                ),
                                              );
                                            }
                                          } else {
                                            _showCoinBalanceDialog(
                                              context,
                                              job: job,
                                              isChat: false,
                                              userId: userId ?? '0',
                                            );
                                          }
                                        } else if (job.callButtonRedirection ==
                                            'buy_for_this_project') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Buycallpage(id: job.id),
                                            ),
                                          );
                                        } else if (job.callButtonRedirection ==
                                            'open_call_dial') {
                                          try {
                                            final String callApiUrl =
                                                URLS().set_call_entry;
                                            final requestBody = jsonEncode({
                                              'user_id': userId,
                                              'project_id': job.id,
                                              'project_owner_id': job.userId,
                                              'used_token_id': job.usedTokenId,
                                            });
                                            debugPrint(
                                                'API Request Body: $requestBody');

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
                                              // Parse the API response
                                              final responseData =
                                                  jsonDecode(callResponse.body);
                                              if (responseData['status'] ==
                                                      'true' &&
                                                  responseData['data'] !=
                                                      null) {
                                                final String receiverMobileNo =
                                                    responseData['data']
                                                        ['receiver_mobile_no'];
                                                // Open phone dialer with receiver_mobile_no
                                                _openPhoneDialer(
                                                    receiverMobileNo);
                                              } else {
                                                // Handle invalid response format
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Invalid response from server. Please try again.'),
                                                  ),
                                                );
                                              }
                                            } else {
                                              // Handle API failure
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Failed to initiate call. Please try again.'),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            // Handle network or other errors
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content:
                                                    Text('Error occurred: $e'),
                                              ),
                                            );
                                          }
                                        }
                                      } else {
                                        if (job.callDontAskAgain == '1') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SignInPage(),
                                            ),
                                          );
                                        } else {
                                          bool? confirm =
                                              await _showConfirmationDialog(
                                                  context);
                                          if (confirm == true) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SignInPage(),
                                              ),
                                            );
                                          }
                                        }
                                      }
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
                                    onPressed: () async {
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      final int? isLoggedIn =
                                          prefs.getInt('is_logged_in');
                                      if (isLoggedIn == 1) {
                                        // Add proposal button logic here
                                      } else {
                                        bool? confirm =
                                            await _showConfirmationDialog(
                                                context);
                                        if (confirm == true) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SignInPage(),
                                            ),
                                          );
                                        }
                                      }
                                    },
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

  Future<bool?> _showConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // Customize dialog shape and background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.white, // Light background
          elevation: 8.0, // Shadow for depth
          // Title styling
          title: const Text(
            'Sign In Required',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          // Content styling
          content: const Text(
            'You need to sign in to continue. Would you like to proceed to the sign-in page?',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black54,
              height: 1.5, // Line spacing
            ),
          ),
          // Actions (buttons)
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false for "No"
              },
              child: const Text(
                'No',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey, // Subtle color for cancel
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true for "Yes"
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Button background
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Yes',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white, // White text for contrast
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCoinBalanceDialog(
    BuildContext context, {
    required Job job,
    required bool isChat,
    required String userId,
  }) async {
    bool dontAskAgain = false; // State for the checkbox

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Use a distinct name for clarity
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 12,
              backgroundColor: Colors.transparent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.blueGrey.shade50.withOpacity(0.95),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confirm Action',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.blueGrey.shade900,
                        letterSpacing: 0.8,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Would you like to deduct from the Hustlfree bucket?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blueGrey.shade700,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Transform.scale(
                          scale: 1.2,
                          child: Checkbox(
                            value: dontAskAgain,
                            onChanged: (bool? value) {
                              setDialogState(() {
                                dontAskAgain = value ?? false;
                              });
                            },
                            activeColor: Colors.teal.shade400,
                            checkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            side: BorderSide(
                              color: Colors.blueGrey.shade300,
                              width: 2,
                            ),
                          ),
                        ),
                        Text(
                          'Don\'t ask again',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.blueGrey.shade800,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                              backgroundColor: Colors.grey.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              shadowColor: Colors.black.withOpacity(0.1),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blueGrey.shade700,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              Navigator.of(dialogContext).pop(); // Close dialog
                              setDialogState(() {
                                // Use setDialogState for local state
                                if (isChat) {
                                  _chatLoadingStates[job.id] = true;
                                } else {
                                  _callLoadingStates[job.id] = true;
                                }
                              });

                              // Handle chat or call
                              final success = await _allocateChatCall(
                                context: context,
                                userId: userId,
                                projectId: job.id,
                                chatReceiver: job.chatReceiver,
                                chatSender: job.chatSender,
                                tokenFor: isChat ? 1 : 2,
                                dontAskAgain: dontAskAgain ? '1' : '0',
                                dialogContext: context, // Direct call
                              );

                              setDialogState(() {
                                // Update state again
                                if (isChat) {
                                  _chatLoadingStates[job.id] = false;
                                } else {
                                  _callLoadingStates[job.id] = false;
                                }
                              });

                              if (success) {
                                if (isChat) {
                                  Navigator.push(
                                    dialogContext, // Use dialogContext
                                    MaterialPageRoute(
                                      builder: (context) => ChatPage(
                                        projectId: job.id,
                                        chatSender: job.chatSender,
                                        chatReceiver: job.chatReceiver,
                                      ),
                                    ),
                                  );
                                } else {
                                  final String apiUrl = URLS().set_call_entry;
                                  final response = await http.post(
                                    Uri.parse(apiUrl),
                                    headers: {
                                      'Content-Type': 'application/json'
                                    },
                                    body: jsonEncode({
                                      'user_id': userId,
                                      'project_id': job.id,
                                      'project_owner_id': job.userId,
                                      'used_token_id': job.usedTokenId,
                                    }),
                                  );

                                  if (response.statusCode == 200) {
                                    final responseData =
                                        jsonDecode(response.body);
                                    if (responseData['status'] == 'true') {
                                      final receiverMobileNo =
                                          responseData['data']
                                              ['receiver_mobile_no'];
                                      _openPhoneDialer(receiverMobileNo);
                                    } else {
                                      ScaffoldMessenger.of(dialogContext)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error: ${responseData['message']}',
                                            style:
                                                TextStyle(fontFamily: 'Roboto'),
                                          ),
                                          backgroundColor: Colors.red.shade400,
                                        ),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(dialogContext)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to connect to the server',
                                          style:
                                              TextStyle(fontFamily: 'Roboto'),
                                        ),
                                        backgroundColor: Colors.red.shade400,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                              backgroundColor: Colors.teal.shade400,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              shadowColor: Colors.black.withOpacity(0.1),
                            ),
                            child: Text(
                              'Yes, Deduct',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openPhoneDialer(String? phoneNumber) async {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number is not available')),
      );
    }
  }

  Widget _buildActionButton(
    String label,
    String? iconPath,
    Size size, {
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) =>
      CupertinoButton(
        onPressed: isLoading ? null : onPressed,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        color: Colorfile.textColor,
        borderRadius: BorderRadius.circular(4),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
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
  final String ownerNumber;
  final List<String> tags;
  final String chatButtonRedirection;
  final String callButtonRedirection;
  final String proposalButtonRedirection;
  final String callDontAskAgain;
  final String chatDontAskAgain;
  final String chatReceiver;
  final String chatSender;
  final String usedTokenId; // New field for used_token_id

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
    required this.ownerNumber,
    required this.tags,
    required this.chatButtonRedirection,
    required this.callButtonRedirection,
    required this.proposalButtonRedirection,
    required this.callDontAskAgain,
    required this.chatDontAskAgain,
    required this.chatReceiver,
    required this.chatSender,
    required this.usedTokenId, // Initialize new field
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

    // Extract used_token_id from check_call_assin_to_project
    String usedTokenId = '';
    if (json['check_call_assin_to_project'] != null &&
        json['check_call_assin_to_project'] is Map) {
      usedTokenId = json['check_call_assin_to_project']['id']?.toString() ?? '';
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
      ownerNumber: json['owner_mobile_no']?.toString() ?? '',
      tags: tags,
      chatButtonRedirection: json['chat_button_redirection']?.toString() ?? '',
      callButtonRedirection: json['call_button_redirection']?.toString() ?? '',
      proposalButtonRedirection:
          json['proposal_button_redirection']?.toString() ?? '',
      callDontAskAgain: json['call_dont_ask_again']?.toString() ?? '0',
      chatDontAskAgain: json['chat_dont_ask_again']?.toString() ?? '0',
      chatReceiver: json['chat_receiver']?.toString() ?? '',
      chatSender: json['chat_sender']?.toString() ?? '',
      usedTokenId: usedTokenId, // Set new field
    );
  }
}
