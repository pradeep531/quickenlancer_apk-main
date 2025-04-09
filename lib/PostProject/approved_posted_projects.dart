// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:quickenlancer_apk/Colors/colorfile.dart';
// import 'package:quickenlancer_apk/Models/postedprojectmodel.dart';
// import 'package:quickenlancer_apk/Models/postedprojectmodels.dart';

// class ApprovedPostedProjects extends StatefulWidget {
//   const ApprovedPostedProjects({super.key});

//   @override
//   State<ApprovedPostedProjects> createState() =>
//       _ApprovedPostedProjectsPageState();
// }

// class _ApprovedPostedProjectsPageState extends State<ApprovedPostedProjects> {
//   int _selectedIndex = 0;

//   Future<void> _onRefresh() async {
//     await Future.delayed(Duration(seconds: 2));
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       backgroundColor: Color(0xFFE8F1FC),
//       appBar: AppBar(
//         backgroundColor: Colorfile.body,
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back,
//             color: Colorfile.textColor,
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: Text(
//           'Posted Project',
//           style: GoogleFonts.montserrat(
//             color: Colorfile.textColor,
//             fontSize: screenWidth * 0.05,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _onRefresh,
//         child: AnimatedSwitcher(
//           duration: Duration(milliseconds: 300),
//           child: Column(
//             key: ValueKey<int>(_selectedIndex),
//             children: [
//               Expanded(
//                 child: ListContainer(),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ListContainer extends StatefulWidget {
//   @override
//   _ListContainerState createState() => _ListContainerState();
// }

// class _ListContainerState extends State<ListContainer> {
//   bool isDescriptionExpanded = false; // Move this outside the build method

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     double textScaleFactor = MediaQuery.of(context).textScaleFactor;

//     List<Postedprojectmodels> jobs = parseJobs(dummyJsonPosted);

//     return ListView.builder(
//       itemCount: jobs.length,
//       itemBuilder: (context, index) {
//         Postedprojectmodels job = jobs[index];

//         return Container(
//           width: screenWidth * 0.8,
//           margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             gradient: LinearGradient(
//               colors: [
//                 Color(0xFFB7D7F9),
//                 Color(0xFFE5ACCB),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: Container(
//             margin: EdgeInsets.all(1.0),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Opacity(
//                   opacity: 0.9,
//                   child: ListTile(
//                     contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
//                     title: Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 job.title,
//                                 style: GoogleFonts.montserrat(
//                                   color: Colorfile.textColor,
//                                   fontSize:
//                                       screenWidth * 0.05 * textScaleFactor,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               SizedBox(height: 5),
//                               Text(
//                                 isDescriptionExpanded
//                                     ? 'Description: ${job.description}'
//                                     : 'Description: ${job.description.substring(0, 100)}...',
//                                 style: GoogleFonts.montserrat(
//                                   color: Colorfile.textColor,
//                                   fontSize:
//                                       screenWidth * 0.032 * textScaleFactor,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                                 maxLines: isDescriptionExpanded ? null : 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     isDescriptionExpanded =
//                                         !isDescriptionExpanded;
//                                   });
//                                 },
//                                 child: Text(
//                                   isDescriptionExpanded
//                                       ? 'Show Less'
//                                       : 'Read More',
//                                   style: TextStyle(
//                                     color: Colors.blue,
//                                     fontSize:
//                                         screenWidth * 0.03 * textScaleFactor,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.all(4.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Wrap(
//                         spacing: 8.0,
//                         runSpacing: 4.0,
//                         children: job.tags.map((tag) {
//                           return Container(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 8.0, vertical: 4.0),
//                             decoration: BoxDecoration(
//                               color: Color(0xFFE8F1FC),
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Text(
//                               tag,
//                               style: GoogleFonts.montserrat(
//                                 fontSize: screenWidth * 0.04 * textScaleFactor,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colorfile.textColor,
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                       SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           CircleAvatar(
//                             radius: 20,
//                             backgroundImage:
//                                 AssetImage('assets/profile_pic.png'),
//                           ),
//                           SizedBox(width: 10),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         'Vaibhav Danve',
//                                         style: TextStyle(
//                                           fontSize: screenWidth *
//                                               0.04, // 4% of screen width
//                                           fontWeight: FontWeight.bold,
//                                           color: Colorfile.textColor,
//                                           fontFamily: GoogleFonts.montserrat()
//                                               .fontFamily,
//                                         ),
//                                       ),
//                                       SizedBox(width: 80),
//                                       Icon(
//                                         Icons.edit, // First icon
//                                         size: screenHeight *
//                                             0.025, // Adjust size if needed
//                                         color: Colors.black54,
//                                       ),
//                                       SizedBox(
//                                           width:
//                                               8), // Spacing between the icons
//                                       Icon(
//                                         Icons.share, // Second icon
//                                         size: screenHeight *
//                                             0.025, // Adjust size if needed
//                                         color: Colors.black54,
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 4),
//                               Row(
//                                 children: [
//                                   Image.asset(
//                                     'assets/india.png', // Replace with the path to your Indian flag image
//                                     height: screenHeight *
//                                         0.02, // 2% of screen height
//                                     width: screenHeight *
//                                         0.02, // 2% of screen height
//                                   ),
//                                   SizedBox(width: 4),
//                                   Text(
//                                     'Gondia, India',
//                                     style: TextStyle(
//                                       fontSize: screenWidth *
//                                           0.035, // 3.5% of screen width
//                                       color: Colors.black54,
//                                       fontFamily:
//                                           GoogleFonts.montserrat().fontFamily,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           )
//                         ],
//                       ),
//                       Divider(),
//                       Table(
//                         children: [
//                           TableRow(
//                             children: [
//                               Text(
//                                 'Hired on',
//                                 style: TextStyle(
//                                   fontSize: screenWidth * 0.035,
//                                   color: Colors.black54,
//                                   fontFamily:
//                                       GoogleFonts.montserrat().fontFamily,
//                                 ),
//                               ),
//                               Text(
//                                 ':',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontSize: screenWidth * 0.035,
//                                   color: Colors.black54,
//                                   fontFamily:
//                                       GoogleFonts.montserrat().fontFamily,
//                                 ),
//                               ),
//                               Text(
//                                 '7/09/2023',
//                                 style: TextStyle(
//                                   fontSize: screenWidth * 0.035,
//                                   color: Colors.black54,
//                                   fontFamily:
//                                       GoogleFonts.montserrat().fontFamily,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           TableRow(
//                             children: [
//                               Text(
//                                 'Hired Status',
//                                 style: TextStyle(
//                                   fontSize: screenWidth * 0.035,
//                                   color: Colors.black54,
//                                   fontFamily:
//                                       GoogleFonts.montserrat().fontFamily,
//                                 ),
//                               ),
//                               Text(
//                                 ':',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontSize: screenWidth * 0.035,
//                                   color: Colors.black54,
//                                   fontFamily:
//                                       GoogleFonts.montserrat().fontFamily,
//                                 ),
//                               ),
//                               Text(
//                                 'Confirmed',
//                                 style: TextStyle(
//                                   fontSize: screenWidth * 0.035,
//                                   color: Colors.black54,
//                                   fontFamily:
//                                       GoogleFonts.montserrat().fontFamily,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           TableRow(
//                             children: [
//                               Text(
//                                 'Project Attachments',
//                                 style: TextStyle(
//                                   fontSize: screenWidth * 0.035,
//                                   color: Colors.black54,
//                                   fontFamily:
//                                       GoogleFonts.montserrat().fontFamily,
//                                 ),
//                               ),
//                               Text(
//                                 ':',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontSize: screenWidth * 0.035,
//                                   color: Colors.black54,
//                                   fontFamily:
//                                       GoogleFonts.montserrat().fontFamily,
//                                 ),
//                               ),
//                               Transform.rotate(
//                                 angle: 0.6,
//                                 child: Icon(
//                                   Icons.attach_file,
//                                   size: 18,
//                                   color: Colorfile.textColor,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   List<Postedprojectmodels> parseJobs(String jsonString) {
//     final parsed = jsonDecode(jsonString) as List<dynamic>;
//     return parsed.map((json) => Postedprojectmodels.fromJson(json)).toList();
//   }
// }
