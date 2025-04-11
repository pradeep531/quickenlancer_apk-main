import 'dart:convert';
import 'dart:developer' show log;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:quickenlancer_apk/api/network/uri.dart';
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
  List<dynamic> _currentFilters = []; // Changed to List<dynamic>
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
  @override
  void initState() {
    super.initState();
    _loadPreferences();
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
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstName = prefs.getString('first_name') ?? '';
      _lastName = prefs.getString('last_name') ?? '';
      _country = prefs.getString('country') ?? '';
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
      final userId = prefs.getString('user_id') ?? '0';

      final body = jsonEncode({
        "user_id": userId,
        "limit": _limit,
        "offset": _offset,
        "filters": _currentFilters,
      });

      print('Request Body: $body');
      log('Request Body: $body', name: 'fetchProjects');
      final response = await http.get(
        Uri.parse(URLS().search_project_apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}', name: 'fetchProjects');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == "true") {
          final newJobs = (jsonResponse['data'] as List<dynamic>)
              .map((json) => Job.fromJson(json))
              .toList();

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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No more Data available')),
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
      2: const Callpage(),
      3: const Chatpage(),
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
          _fetchProjects(); // Fetch projects with new filters
        },
        onClearFilters: () {
          print('Filters cleared in _showFilterSheet');
          setState(() {
            _currentFilters = [];
          });
          _fetchProjects(); // Fetch projects without filters
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
                  '$_firstName $_lastName'.trim(), // Dynamic name
                  style: GoogleFonts.montserrat(
                    fontSize: size.width * 0.042,
                    fontWeight: FontWeight.w700,
                    color: Colors.black, // Replace Colorfile.textColor
                  ),
                ),
                Row(
                  children: [
                    Image.asset(
                      'assets/india.png',
                      height: size.height * 0.018,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _country.isNotEmpty
                          ? _country
                          : 'Unknown', // Dynamic country
                      style: GoogleFonts.montserrat(
                        fontSize: size.width * 0.032,
                        color: Colors.black54,
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
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
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
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: size.width * 0.6,
                  height: 16,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                Container(
                  width: size.width * 0.3,
                  height: 12,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 40,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(
                    3,
                    (_) => Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 60,
                      height: 20,
                      color: Colors.grey[300],
                    ),
                  ),
                ),
              ],
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
                                Image.asset(
                                  'assets/india.png',
                                  width: size.width * 0.035,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  job.country,
                                  style: GoogleFonts.montserrat(
                                    fontSize: size.width * 0.032,
                                    fontWeight: FontWeight.w500,
                                    color: Colorfile.textColor,
                                  ),
                                ),
                              ],
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
                              '\₹${job.amount}',
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
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: const Color(0xFFD9D9D9),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton('Chat', 'assets/chat.png', size),
                            _buildActionButton('Call', 'assets/call.png', size),
                            _buildActionButton('Proposal', null, size),
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

  Widget _buildActionButton(String label, String? iconPath, Size size) =>
      CupertinoButton(
        onPressed: () {},
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
  final String amount;
  final String projectType;
  final String country;
  final List<String> tags;

  Job({
    required this.id,
    required this.userId,
    required this.projectName,
    required this.description,
    required this.amount,
    required this.projectType,
    required this.country,
    required this.tags,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    List<String> tags = [];

    if (json['other_skills'] != null && json['other_skills'].isNotEmpty) {
      tags.addAll(
        (json['other_skills'] as String)
            .split(' ')
            .where((tag) => tag.trim().isNotEmpty),
      );
    }

    if (json['skill'] != null && json['skill'].isNotEmpty) {
      tags.addAll(
        (json['skill'] as String)
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty),
      );
    }

    return Job(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      projectName: json['project_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0',
      projectType: json['project_type']?.toString() ?? '0',
      country: json['country']?.toString() ?? 'Unknown',
      tags: tags,
    );
  }
}

// FilterBottomSheet.dart
class FilterBottomSheet extends StatefulWidget {
  final Function(List<dynamic>) onApplyFilters;
  final VoidCallback onClearFilters;

  const FilterBottomSheet({
    required this.onApplyFilters,
    required this.onClearFilters,
    super.key,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  Map<String, dynamic> filters = {
    'tags': [],
    'location': '',
    'locationName': '',
    'skills': <Map<String, dynamic>>{},
    'currency': <String>{},
    'projectType': <String>{},
    'requirementType': <String>{},
    'connectType': <String>{},
    'adminProfile': <String>{},
    'biddingCriteria': null,
    'freshness': null,
  };

  List<Map<String, dynamic>> locationSuggestions = [];
  List<Map<String, dynamic>> allSkills = [], skillSuggestions = [];
  List<Map<String, dynamic>> availableCurrencies = [];
  bool isLoadingSuggestions = false,
      isLoadingSkills = false,
      isLoadingCurrencies = false;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _skillsSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _locationController.text = filters['locationName'];
    _fetchSkills();
    _fetchCurrencies();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _skillsSearchController.dispose();
    super.dispose();
  }

  List<dynamic> _encodeFilters(Map<String, dynamic> filters) {
    final List<dynamic> encoded = [];

    if (filters['skills'].isNotEmpty) {
      final skillsList = (filters['skills'] as Set<Map<String, dynamic>>)
          .map((skill) => 'searchbar@@${skill['id']}')
          .toList();
      if (skillsList.isNotEmpty) encoded.add(skillsList);
    }

    if (filters['location'].toString().isNotEmpty) {
      encoded.add('location@@${filters['location']}');
    }

    if (filters['currency'].isNotEmpty) {
      (filters['currency'] as Set<String>)
          .forEach((id) => encoded.add('currency@@$id'));
    }

    if (filters['projectType'].isNotEmpty) {
      (filters['projectType'] as Set<String>).forEach((type) {
        encoded.add(type == 'Fixed' ? 'type@@0' : 'type@@1');
      });
    }

    if (filters['requirementType'].isNotEmpty) {
      (filters['requirementType'] as Set<String>).forEach((req) {
        encoded.add(req == 'Cold' ? 'req_type@@0' : 'req_type@@1');
      });
    }

    if (filters['connectType'].isNotEmpty) {
      (filters['connectType'] as Set<String>).forEach((conn) {
        encoded.add(conn == 'Chat'
            ? 'conn_type@@1'
            : conn == 'Call'
                ? 'conn_type@@2'
                : 'conn_type@@3');
      });
    }

    if (filters['adminProfile'].isNotEmpty) {
      (filters['adminProfile'] as Set<String>).forEach((profile) {
        encoded
            .add(profile == 'Verified' ? 'profile_type@@1' : 'profile_type@@0');
      });
    }

    if (filters['biddingCriteria'] != null) {
      encoded.add(filters['biddingCriteria'] == 'High to Low'
          ? 'bidding@@high_to_low'
          : 'bidding@@low_to_high');
    }

    if (filters['freshness'] != null) {
      final freshnessMap = {
        'Today': 'freshness@@today',
        'This Week': 'freshness@@this_week',
        'This Month': 'freshness@@one_month',
        'Any Time': 'freshness@@long_time',
      };
      encoded.add(freshnessMap[filters['freshness']]!);
    }

    return encoded;
  }

  Future<void> _fetchSkills() async {
    setState(() => isLoadingSkills = true);
    try {
      final response = await http.get(Uri.parse(URLS().get_skills_api),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200 &&
          jsonDecode(response.body)['status'] == 'true') {
        setState(() {
          allSkills = skillSuggestions =
              (jsonDecode(response.body)['data'] as List)
                  .cast<Map<String, dynamic>>();
        });
      } else {
        _showSnackBar('Failed to load skills');
      }
    } catch (_) {
      _showSnackBar('Error fetching skills');
    } finally {
      setState(() => isLoadingSkills = false);
    }
  }

  Future<void> _fetchCurrencies() async {
    setState(() => isLoadingCurrencies = true);
    try {
      final response = await http.get(Uri.parse(URLS().get_currency_api),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200 &&
          jsonDecode(response.body)['status'] == 'true') {
        setState(() => availableCurrencies =
            (jsonDecode(response.body)['data'] as List)
                .cast<Map<String, dynamic>>());
      } else {
        _showSnackBar('Failed to load currencies');
      }
    } catch (_) {
      _showSnackBar('Error fetching currencies');
    } finally {
      setState(() => isLoadingCurrencies = false);
    }
  }

  void _onSkillsSearchChanged(String query) {
    setState(() => skillSuggestions = query.isEmpty
        ? allSkills
        : allSkills
            .where((skill) => skill['skill']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList());
  }

  void _toggleSkill(Map<String, dynamic> skill) {
    setState(() {
      final skills = filters['skills'] as Set<Map<String, dynamic>>;
      skills.any((s) => s['id'] == skill['id'])
          ? skills.removeWhere((s) => s['id'] == skill['id'])
          : skills.add(skill);
    });
  }

  void _showSkillsDialog() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setDialogState) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                TextField(
                  controller: _skillsSearchController,
                  decoration: InputDecoration(
                    hintText: 'Search skills...',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    suffixIcon: _skillsSearchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setDialogState(() {
                                _skillsSearchController.clear();
                                _onSkillsSearchChanged('');
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) =>
                      setDialogState(() => _onSkillsSearchChanged(value)),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: isLoadingSkills
                      ? const Center(child: CircularProgressIndicator())
                      : skillSuggestions.isEmpty
                          ? const Center(child: Text('No skills found'))
                          : ListView.builder(
                              itemCount: skillSuggestions.length,
                              itemBuilder: (_, index) {
                                final skill = skillSuggestions[index];
                                final isSelected = (filters['skills']
                                        as Set<Map<String, dynamic>>)
                                    .any((s) => s['id'] == skill['id']);
                                return CheckboxListTile(
                                  title: Text(skill['skill'],
                                      style:
                                          GoogleFonts.montserrat(fontSize: 14)),
                                  value: isSelected,
                                  onChanged: (_) {
                                    setDialogState(() => _toggleSkill(skill));
                                    setState(() {});
                                  },
                                );
                              },
                            ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text('Done',
                      style: GoogleFonts.montserrat(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> _fetchLocationSuggestions(String keyword) async {
    setState(() => isLoadingSuggestions = true);
    try {
      final response = await http.post(
        Uri.parse(URLS().get_location_api),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'keyword': keyword}),
      );
      if (response.statusCode == 200 &&
          jsonDecode(response.body)['status'] == 'true') {
        setState(() => locationSuggestions =
            (jsonDecode(response.body)['data'] as List)
                .cast<Map<String, dynamic>>());
      } else {
        setState(() => locationSuggestions.clear());
        _showSnackBar('Failed to load suggestions');
      }
    } catch (_) {
      setState(() => locationSuggestions.clear());
      _showSnackBar('Error fetching locations');
    } finally {
      setState(() => isLoadingSuggestions = false);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      filters['locationName'] = query;
      if (query.isEmpty) {
        filters['location'] = '';
        locationSuggestions.clear();
        isLoadingSuggestions = false;
      } else {
        _fetchLocationSuggestions(query);
      }
    });
  }

  void _clearLocation() {
    setState(() {
      _locationController.clear();
      filters['location'] = filters['locationName'] = '';
      locationSuggestions.clear();
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))
        ],
      ),
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.85,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters',
                    style: GoogleFonts.montserrat(
                        fontSize: 20, fontWeight: FontWeight.w700)),
                IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF666666)),
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            _buildSkillsSection(),
            _buildTextField(
                'Location', 'Enter location (city, country)', _onSearchChanged,
                controller: _locationController, clearCallback: _clearLocation),
            if (isLoadingSuggestions)
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: CircularProgressIndicator())
            else if (locationSuggestions.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE0E0E0))),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: locationSuggestions.length,
                  itemBuilder: (_, index) {
                    final suggestion = locationSuggestions[index];
                    return ListTile(
                      title: Text(suggestion['name'],
                          style: GoogleFonts.montserrat(fontSize: 14)),
                      subtitle: Text(suggestion['state_name'] ?? '',
                          style: GoogleFonts.montserrat(
                              fontSize: 12, color: Colors.grey)),
                      onTap: () {
                        setState(() {
                          filters['location'] = suggestion['id'];
                          filters['locationName'] = suggestion['name'];
                          _locationController.text = suggestion['name'];
                          locationSuggestions.clear();
                        });
                      },
                    );
                  },
                ),
              ),
            _buildCurrencySection(),
            _buildMultiSelect(
                'Project Type', ['Fixed', 'Hourly'], filters['projectType']),
            _buildMultiSelect(
                'Priority', ['Cold', 'Hot'], filters['requirementType']),
            _buildMultiSelect('Communication', ['Chat', 'Call', 'Email'],
                filters['connectType']),
            _buildMultiSelect('Profile Status', ['Verified', 'Unverified'],
                filters['adminProfile']),
            _buildSingleSelect(
                'Sort By',
                ['High to Low', 'Low to High'],
                filters['biddingCriteria'],
                (value) => setState(() => filters['biddingCriteria'] = value)),
            _buildSingleSelect(
                'Posted',
                ['Today', 'This Week', 'This Month', 'Any Time'],
                filters['freshness'],
                (value) => setState(() => filters['freshness'] = value)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildButton(
                      'Reset', Colors.white, const Color(0xFF1A1A1A), () {
                    setState(() {
                      filters = {
                        'tags': [],
                        'location': '',
                        'locationName': '',
                        'skills': <Map<String, dynamic>>{},
                        'currency': <String>{},
                        'projectType': <String>{},
                        'requirementType': <String>{},
                        'connectType': <String>{},
                        'adminProfile': <String>{},
                        'biddingCriteria': null,
                        'freshness': null,
                      };
                      _locationController.clear();
                      locationSuggestions.clear();
                      _skillsSearchController.clear();
                      skillSuggestions = allSkills;
                    });
                    widget.onClearFilters();
                  }, border: true),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildButton(
                      'Apply', const Color(0xFF1A1A1A), Colors.white, () {
                    final encodedFilters = _encodeFilters(filters);
                    print(
                        'Filters applied in FilterBottomSheet: $encodedFilters');
                    widget.onApplyFilters(encodedFilters);
                    Navigator.pop(context);
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSelection(Set<String> set, String value) {
    setState(() => set.contains(value) ? set.remove(value) : set.add(value));
  }

  Widget _buildSkillsSection() {
    final selectedSkills = filters['skills'] as Set<Map<String, dynamic>>;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Skills & Keywords',
              style: GoogleFonts.montserrat(
                  fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _showSkillsDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE0E0E0))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      selectedSkills.isEmpty
                          ? 'Select skills'
                          : '${selectedSkills.length} skill(s) selected',
                      style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: selectedSkills.isEmpty
                              ? const Color(0xFF999999)
                              : const Color(0xFF1A1A1A))),
                  const Icon(Icons.arrow_drop_down, color: Color(0xFF666666)),
                ],
              ),
            ),
          ),
          if (selectedSkills.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedSkills
                    .map((skill) => Chip(
                          label: Text(skill['skill'],
                              style: GoogleFonts.montserrat(
                                  fontSize: 12, color: Colors.white)),
                          backgroundColor: const Color(0xFF1A1A1A),
                          deleteIcon: const Icon(Icons.close,
                              size: 18, color: Colors.white),
                          onDeleted: () => setState(() =>
                              (filters['skills'] as Set<Map<String, dynamic>>)
                                  .removeWhere((s) => s['id'] == skill['id'])),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrencySection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Currency',
              style: GoogleFonts.montserrat(
                  fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          isLoadingCurrencies
              ? const Center(child: CircularProgressIndicator())
              : availableCurrencies.isEmpty
                  ? const Text('No currencies available')
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableCurrencies.map((currency) {
                        final isSelected = (filters['currency'] as Set<String>)
                            .contains(currency['id']);
                        return GestureDetector(
                          onTap: () => _toggleSelection(
                              filters['currency'], currency['id']),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF1A1A1A)
                                  : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF1A1A1A)
                                      : const Color(0xFFE0E0E0)),
                              boxShadow: [
                                if (isSelected)
                                  const BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2))
                              ],
                            ),
                            child: Text(
                              currency['lable'],
                              style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF1A1A1A)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, Function(String) onChanged,
      {TextEditingController? controller, VoidCallback? clearCallback}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.montserrat(
                  fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.montserrat(color: const Color(0xFF999999)),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF1A1A1A))),
              suffixIcon: controller?.text.isNotEmpty == true
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Color(0xFF666666)),
                      onPressed: clearCallback)
                  : null,
            ),
            style: GoogleFonts.montserrat(fontSize: 14),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelect(
      String label, List<String> items, Set<String> selectedValues) {
    return _buildSelectionGrid(label, items, selectedValues,
        (value) => _toggleSelection(selectedValues, value),
        multiSelect: true);
  }

  Widget _buildSingleSelect(String label, List<String> items,
      dynamic selectedValue, Function(String) onSelected) {
    return _buildSelectionGrid(label, items, selectedValue, onSelected);
  }

  Widget _buildSelectionGrid(String label, List<String> items,
      dynamic selectedValue, Function(String) onSelected,
      {bool multiSelect = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.montserrat(
                  fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              final isSelected = multiSelect
                  ? (selectedValue as Set<String>).contains(item)
                  : selectedValue == item;
              return GestureDetector(
                onTap: () => onSelected(item),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1A1A1A)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1A1A1A)
                            : const Color(0xFFE0E0E0)),
                    boxShadow: [
                      if (isSelected)
                        const BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2))
                    ],
                  ),
                  child: Text(
                    item,
                    style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF1A1A1A)),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
      String text, Color bgColor, Color textColor, VoidCallback onPressed,
      {bool border = false}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: border
                ? const BorderSide(color: Color(0xFF1A1A1A))
                : BorderSide.none),
      ),
      onPressed: onPressed,
      child: Text(text,
          style: GoogleFonts.montserrat(
              fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
    );
  }
}
