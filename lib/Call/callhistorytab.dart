import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import 'package:quickenlancer_apk/Models/history_model.dart';
import 'package:skeleton_loader/skeleton_loader.dart';

class Callhistorytab extends StatefulWidget {
  const Callhistorytab({super.key});

  @override
  _CallHistoryTabState createState() => _CallHistoryTabState();
}

class _CallHistoryTabState extends State<Callhistorytab> {
  late Future<List<History>> history;

  @override
  void initState() {
    super.initState();
    history = _fetchHistoryData(); // Using a function to fetch history data
  }

  // Fetching history data function
  Future<List<History>> _fetchHistoryData() async {
    await Future.delayed(Duration(seconds: 2)); // Simulating network delay
    return [
      History.fromJson({
        'allocatedOn': '01-Jan-2025',
        'purchasedOn': '05-Jan-2025',
        'tokenNo': '0101010110112002212',
        'allocatedProject': 'Website Landing page Developer',
        'projectDescription':
            'Design and development of the website landing page.',
      }),
      History.fromJson({
        'allocatedOn': '02-Jan-2025',
        'purchasedOn': '06-Jan-2025',
        'tokenNo': '0202020220223003223',
        'allocatedProject': 'Mobile App Development',
        'projectDescription':
            'Development of mobile applications for Android and iOS.',
      }),
      History.fromJson({
        'allocatedOn': '03-Jan-2025',
        'purchasedOn': '07-Jan-2025',
        'tokenNo': '0303030330334004234',
        'allocatedProject': 'E-commerce Website',
        'projectDescription':
            'Design and development of an online shopping platform.',
      }),
      History.fromJson({
        'allocatedOn': '04-Jan-2025',
        'purchasedOn': '08-Jan-2025',
        'tokenNo': '0404040440445005245',
        'allocatedProject': 'SEO Optimization',
        'projectDescription':
            'Search Engine Optimization services for websites.',
      }),
      History.fromJson({
        'allocatedOn': '05-Jan-2025',
        'purchasedOn': '09-Jan-2025',
        'tokenNo': '0505050550556006256',
        'allocatedProject': 'Social Media Marketing',
        'projectDescription':
            'Social media marketing and strategy for brand growth.',
      }),
    ];
  }

  // Function to handle refresh
  Future<void> _refreshData() async {
    setState(() {
      history = _fetchHistoryData(); // Trigger a refresh by updating the future
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData, // Add swipe-to-refresh functionality
      child: FutureBuilder<List<History>>(
        future: history,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Skeleton loader during loading state
            return Center(
              child: SingleChildScrollView(
                child: SkeletonLoader(
                  builder: Column(
                    children: List.generate(
                      5, // Show skeleton for 5 items
                      (_) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          height: 250,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final historyDataList = snapshot.data!;
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  children: historyDataList.map((historyData) {
                    return Container(
                      margin: EdgeInsets.all(16.0),
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFB7D7F9),
                            Color(0xFFE5ACCB),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      width: double.infinity,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(0.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Allocated On',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF424752),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            historyData.allocatedOn,
                                            style: GoogleFonts.montserrat(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF424752),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 50,
                                      color: Color(0xFFB7D7F9),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Purchased On',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF424752),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            historyData.purchasedOn,
                                            style: GoogleFonts.montserrat(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF424752),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 1,
                                  width: double.infinity,
                                  color: Color(0xFFB7D7F9),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Token No. : ${historyData.tokenNo}',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colorfile.textColor,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Allocated Project: ${historyData.allocatedProject}',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colorfile.textColor,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        historyData.projectDescription,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF424752),
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
                    );
                  }).toList(),
                ),
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
