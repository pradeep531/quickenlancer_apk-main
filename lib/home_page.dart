import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickenlancer_apk/BottomBar/bottom_bar.dart';
import 'package:quickenlancer_apk/Call/callpage.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import 'package:quickenlancer_apk/Models/jobdatamodel.dart';
import 'package:quickenlancer_apk/Models/jobjson.dart';
import 'package:quickenlancer_apk/Chat/chatpage.dart';
import 'package:quickenlancer_apk/editprofilepage.dart';
import 'package:quickenlancer_apk/side_bar_drawer.dart';
import 'package:quickenlancer_apk/filter_bottom_sheet.dart';
import 'profilepage.dart';

void main() {
  runApp(MaterialApp(home: MyHomePage()));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  Map<String, dynamic> _currentFilters = {};

  Future<void> _onRefresh() async {
    await Future.delayed(Duration(seconds: 2));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Chatpage()),
      );
    }
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Callpage()),
      );
    }

    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    }
  }

  void showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(
        onApplyFilters: (filters) {
          // Handle the filters here (e.g., update your job list)
          print('Received filters: $filters');
        },
        onClearFilters: () {
          // Clear filters logic here
          print('Filters cleared');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double padding = screenWidth * 0.05;

    return Scaffold(
      backgroundColor: Color(0xFFE8F1FC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFFFFFFF),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/profile_pic.png'),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vaibhav Danve',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colorfile.textColor,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Image.asset(
                      'assets/india.png',
                      height: screenHeight * 0.02,
                      width: screenHeight * 0.02,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Gondia , India',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.black54,
                        fontFamily: GoogleFonts.montserrat().fontFamily,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.more_vert),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: Column(
            key: ValueKey<int>(_selectedIndex),
            children: [
              Container(
                height: 100,
                width: double.infinity,
                color: Colors.white,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: padding, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(0.5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              width: 1.0,
                              color: Colors.transparent,
                            ),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFB7D7F9),
                                Color(0xFFE5ACCB),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: TextField(
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Colors.white,
                              suffixIcon: Icon(
                                CupertinoIcons.search,
                                size: 28.0,
                                color: Color(0xFFA5A5A5),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              isDense: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFB7D7F9),
                              Color(0xFFE5ACCB),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(1.5),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: IconButton(
                              icon: SizedBox(
                                height: 24.0,
                                width: 24.0,
                                child: Image.asset('assets/filter 1.png'),
                              ),
                              onPressed: () => showFilterSheet(context),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListContainer(filters: _currentFilters),
              ),
            ],
          ),
        ),
      ),
      endDrawer: SideBarDrawer(),
      bottomNavigationBar: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: MyBottomBar(
          key: ValueKey<int>(_selectedIndex),
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}

class ListContainer extends StatefulWidget {
  final Map<String, dynamic> filters;

  const ListContainer({super.key, this.filters = const {}});

  @override
  _ListContainerState createState() => _ListContainerState();
}

class _ListContainerState extends State<ListContainer> {
  bool isDescriptionExpanded = false;

  List<Job> _filterJobs(List<Job> jobs) {
    if (widget.filters.isEmpty) return jobs;

    return jobs.where((job) {
      bool matches = true;

      if (widget.filters.containsKey('priceRange')) {
        double price =
            double.parse(job.price.replaceAll('\$', '').split('-')[0]);
        matches = matches &&
            price >= widget.filters['priceRange']['start'] &&
            price <= widget.filters['priceRange']['end'];
      }

      if (widget.filters.containsKey('jobType') &&
          widget.filters['jobType'] != 'All') {
        matches = matches && job.jobType == widget.filters['jobType'];
      }

      if (widget.filters.containsKey('tags') &&
          (widget.filters['tags'] as List).isNotEmpty) {
        matches = matches &&
            job.tags
                .any((tag) => (widget.filters['tags'] as List).contains(tag));
      }

      return matches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double textScaleFactor = MediaQuery.of(context).textScaleFactor;

    List<Job> jobs = _filterJobs(parseJobs(dummyJson));

    return ListView.builder(
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        Job job = jobs[index];

        return Container(
          width: screenWidth * 0.8,
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [
                Color(0xFFB7D7F9),
                Color(0xFFE5ACCB),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            margin: EdgeInsets.all(1.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Opacity(
                  opacity: 0.9,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(8.0),
                    title: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.title,
                                style: GoogleFonts.montserrat(
                                  color: Colorfile.textColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/india.png',
                                    width: screenWidth * 0.04,
                                    height: screenWidth * 0.04,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    job.location,
                                    style: GoogleFonts.montserrat(
                                      color: Colorfile.textColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Description: ${isDescriptionExpanded ? job.description : job.description.length > 100 ? job.description.substring(0, 100) + '...' : job.description}',
                                style: GoogleFonts.montserrat(
                                  color: Colorfile.textColor,
                                  fontSize:
                                      screenWidth * 0.032 * textScaleFactor,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: isDescriptionExpanded ? null : 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isDescriptionExpanded =
                                        !isDescriptionExpanded;
                                  });
                                },
                                child: Text(
                                  isDescriptionExpanded
                                      ? 'Read Less'
                                      : 'Read More',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize:
                                        screenWidth * 0.035 * textScaleFactor,
                                    fontWeight: FontWeight.w500,
                                  ),
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
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: job.tags.map((tag) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Color(0xFFE8F1FC),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colorfile.textColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        job.price,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colorfile.textColor,
                        ),
                      ),
                      Text(
                        job.jobType,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colorfile.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.only(top: 12, bottom: 12),
                  decoration: BoxDecoration(
                    color: Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CupertinoButton(
                        onPressed: () {},
                        padding: EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 10.0),
                        color: Colorfile.textColor,
                        borderRadius: BorderRadius.circular(4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white, BlendMode.srcIn),
                              child: Image.asset(
                                'assets/chat.png',
                                width: 20,
                                height: 20,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Chat',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 1.33,
                                color: Colors.white,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CupertinoButton(
                        onPressed: () {},
                        padding: EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 10.0),
                        color: Colorfile.textColor,
                        borderRadius: BorderRadius.circular(4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white, BlendMode.srcIn),
                              child: Image.asset(
                                'assets/call.png',
                                width: 20,
                                height: 20,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Call',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 1.33,
                                color: Colors.white,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CupertinoButton(
                        onPressed: () {},
                        padding: EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 10.0),
                        color: Colorfile.textColor,
                        borderRadius: BorderRadius.circular(4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Proposal',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 1.33,
                                color: Colors.white,
                                decoration: TextDecoration.none,
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
        );
      },
    );
  }

  List<Job> parseJobs(String jsonString) {
    final parsed = jsonDecode(jsonString) as List<dynamic>;
    return parsed.map((json) => Job.fromJson(json)).toList();
  }
}
