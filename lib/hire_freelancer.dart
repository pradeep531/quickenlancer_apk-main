import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:quickenlancer_apk/api/network/uri.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Colors/colorfile.dart';
import 'filter_bottom_sheet.dart';
import 'hire_freelancer_filter.dart';
import 'dart:async'; // Added for TimeoutException

class HireFreelancer extends StatefulWidget {
  const HireFreelancer({super.key});

  @override
  _HireFreelancerState createState() => _HireFreelancerState();
}

class _HireFreelancerState extends State<HireFreelancer> {
  List<dynamic> freelancers = [];
  List<dynamic> _currentFilters = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false,
      isLoadingMore = false,
      hasMore = true,
      showScrollToTop = false;
  String _searchKeyword = '';
  String? errorMessage;
  int offset = 0;
  final int limit = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchFreelancers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoading &&
        !isLoadingMore &&
        hasMore) {
      setState(() => offset += limit);
      _fetchFreelancers(isPaginating: true);
    }
    setState(() => showScrollToTop = _scrollController.position.pixels > 100);
  }

  Future<void> _fetchFreelancers({bool isPaginating = false}) async {
    setState(() {
      isPaginating ? isLoadingMore = true : isLoading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final url = Uri.parse(URLS().get_search_freelancer);
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${prefs.getString('auth_token')}',
      };
      final body = jsonEncode({
        "user_id": prefs.getString('user_id') ?? '',
        "search_keyword": _searchKeyword,
        "limit": limit,
        "offset": offset,
        "filters": _currentFilters,
      });

      print('Request URL: $url');
      print('Request Headers: $headers');
      print('Request Body: $body');

      final response = await http
          .post(
        url,
        headers: headers,
        body: body,
      )
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Request timed out');
      });

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.body.isEmpty) {
        setState(() {
          errorMessage = 'Empty response from server';
          isLoading = isLoadingMore = false;
          hasMore = false;
        });
        return;
      }

      final data = jsonDecode(response.body);
      setState(() {
        if (response.statusCode == 200 && data['status'] == 'true') {
          final newFreelancers = data['data'] ?? [];
          isPaginating
              ? freelancers.addAll(newFreelancers)
              : freelancers = newFreelancers;
          hasMore = newFreelancers.length == limit;
        } else {
          errorMessage = data['message'] ?? 'Failed to load freelancers';
          hasMore = false;
        }
        isLoading = isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = isLoadingMore = false;
        hasMore = false;
      });
      print('Error: $e');
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Hire Freelancers',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colorfile.textColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    Expanded(child: _buildSearchField(size)),
                    const SizedBox(width: 8),
                    _buildFilterButton(),
                  ],
                ),
              ),
              Expanded(
                child: isLoading && !isLoadingMore
                    ? _buildSkeletonLoader()
                    : errorMessage != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    errorMessage!,
                                    style: _textStyle(
                                      size: 16,
                                      color: Colors.red,
                                      weight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () => _fetchFreelancers(),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : freelancers.isEmpty
                            ? Center(
                                child: Text(
                                  'No freelancers found.',
                                  style: _textStyle(
                                      size: 18,
                                      color: Colors.grey,
                                      weight: FontWeight.w500),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: () async {
                                  setState(() => offset = 0);
                                  await _fetchFreelancers();
                                },
                                child: SingleChildScrollView(
                                  controller: _scrollController,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: freelancers.length,
                                          itemBuilder: (context, index) =>
                                              _FreelancerCard(
                                                  freelancer:
                                                      freelancers[index]),
                                        ),
                                      ),
                                      if (isLoadingMore)
                                        const CircularProgressIndicator(),
                                    ],
                                  ),
                                ),
                              ),
              ),
            ],
          ),
          if (showScrollToTop)
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _scrollToTop,
                  child:
                      const Icon(Icons.arrow_upward, color: Color(0xFF191E3E)),
                ),
              ),
            ),
        ],
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
          suffixIcon: _searchController.text.isNotEmpty
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.clear, color: Color(0xFFA5A5A5)),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchKeyword = '';
                        });
                        _fetchFreelancers();
                      },
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.search,
                          color: Color(0xFF3A3A3A)),
                      onPressed: () {
                        setState(() {
                          _searchKeyword = _searchController.text.trim();
                        });
                        _fetchFreelancers();
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
            _searchController.clear();
          });
          _fetchFreelancers();
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

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => HireFreelancerFilter(
        onApplyFilters: (List<dynamic> filters) {
          print('Filters applied in _showFilterSheet: $filters');
          setState(() {
            _currentFilters = filters;
          });
          _fetchFreelancers();
        },
        onClearFilters: () {
          print('Filters cleared in _showFilterSheet');
          setState(() {
            _currentFilters = [];
          });
          _fetchFreelancers();
        },
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _skeletonBox(width: 55, height: 55, circular: true),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _skeletonBox(width: 120, height: 20),
                        const SizedBox(height: 4),
                        _skeletonBox(width: 80, height: 14),
                        const SizedBox(height: 4),
                        _skeletonBox(width: 100, height: 14),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _skeletonBox(width: double.infinity, height: 14),
              const SizedBox(height: 8),
              _skeletonBox(width: 200, height: 14),
              const SizedBox(height: 16),
              Wrap(
                  spacing: 8,
                  children: List.generate(
                      3,
                      (_) => _skeletonBox(
                          width: 50,
                          height: 12,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6)))),
              const SizedBox(height: 16),
              Row(children: [
                _skeletonBox(width: 100, height: 16),
                const SizedBox(width: 16),
                _skeletonBox(width: 80, height: 16)
              ]),
              const SizedBox(height: 12),
              _skeletonBox(width: double.infinity, height: 44),
            ],
          ),
        ),
      ),
    );
  }

  Widget _skeletonBox(
      {required double width,
      required double height,
      bool circular = false,
      EdgeInsets? padding}) {
    return Container(
      width: width,
      height: height,
      margin: padding,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular ? null : BorderRadius.circular(4),
      ),
    );
  }

  TextStyle _textStyle(
      {double size = 14, Color? color, FontWeight weight = FontWeight.normal}) {
    return GoogleFonts.montserrat(
        fontSize: size, color: color ?? Colors.black, fontWeight: weight);
  }
}

class _FreelancerCard extends StatelessWidget {
  final dynamic freelancer;

  const _FreelancerCard({required this.freelancer});

  @override
  Widget build(BuildContext context) {
    final skills = (freelancer['skill_name'] as List<dynamic>?)
            ?.map((skill) => skill['skill'] as String)
            .toList() ??
        [];

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5ACCB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            Text(
              freelancer['exp_description'] ?? 'No description',
              style: _textStyle(size: 14, color: Colors.grey[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            skills.isNotEmpty
                ? Wrap(
                    spacing: 8,
                    children: skills
                        .map((skill) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFE8F1FC),
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                skill,
                                style: _textStyle(
                                    size: 12, weight: FontWeight.w500),
                              ),
                            ))
                        .toList(),
                  )
                : Text(
                    'No skills listed',
                    style: _textStyle(size: 14, color: Colors.grey[600]),
                  ),
            const SizedBox(height: 16),
            Text(
              'Average Amount: ${freelancer['average_rate_per_hour'] ?? 'Not specified'} ${freelancer['currency_label']}/hr',
              style: _textStyle(
                  size: 12,
                  color: const Color(0xFF353B43),
                  weight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF191E3E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: const BorderSide(color: Color(0xFF191E3E))),
                  elevation: 0,
                ),
                child: Text(
                  'Want to hire?',
                  style: _textStyle(
                      size: 16,
                      weight: FontWeight.bold,
                      color: const Color(0xFF191E3E)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isOnline = freelancer['is_online'] == 1;

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E2E2))),
      ),
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                ),
                child: ClipOval(
                  child: freelancer['profile_pic'] != null
                      ? Image.network(
                          freelancer['profile_pic'],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person,
                            size: 55,
                            color: Colors.grey,
                          ),
                        )
                      : const Icon(Icons.person, size: 55, color: Colors.grey),
                ),
              ),
              if (isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${freelancer['f_name']} ${freelancer['l_name']}',
                  style: _textStyle(size: 12, weight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${freelancer['city_name']}, ${freelancer['country_name']} | ${freelancer['experience']} Year Exp.',
                  style: _textStyle(size: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${freelancer['state_name']}',
                  style: _textStyle(size: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _textStyle(
      {double size = 14, Color? color, FontWeight weight = FontWeight.normal}) {
    return GoogleFonts.montserrat(
        fontSize: size, color: color ?? Colors.black, fontWeight: weight);
  }
}
