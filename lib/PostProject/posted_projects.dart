import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';

class PostedProjects extends StatefulWidget {
  const PostedProjects({super.key});

  @override
  State<PostedProjects> createState() => _PostedProjectsPageState();
}

class _PostedProjectsPageState extends State<PostedProjects> {
  Future<void> _onRefresh() async => await Future.delayed(Duration(seconds: 2));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8F1FC),
      appBar: AppBar(
        backgroundColor: Colorfile.body,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colorfile.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Posted Project',
            style: GoogleFonts.montserrat(
                color: Colorfile.textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListContainer(),
      ),
    );
  }
}

class ListContainer extends StatefulWidget {
  @override
  _ListContainerState createState() => _ListContainerState();
}

class _ListContainerState extends State<ListContainer> {
  bool isDescriptionExpanded = false;
  final String dummyJsonPosted = '''
  [
    {"title": "Zero Commission Hiring Platform", "location": "India | Looking for Freelancer and Company | Cold 2", "description": "It is a long established fact that a reader will be distracted by the readable content of a page when looking fact that a reader.", "tags": ["Mobile App", "E-commerce", "Payment Integration"], "hiredOn": "7/09/2023", "hiredStatus": "Confirmed", "attachments": ["Attachment 1", "Attachment 2"]},
    {"title": "Zero Commission Hiring Platform", "location": "USA | Looking for Freelancer | Hot 3", "description": "It is a long established fact that a reader will be distracted by the readable content of a page when looking fact that a reader.", "tags": ["Mobile App", "E-commerce", "Payment Integration"], "hiredOn": "", "hiredStatus": "", "attachments": [""]},
        {"title": "Zero Commission Hiring Platform", "location": "USA | Looking for Freelancer | Hot 3", "description": "It is a long established fact that a reader will be distracted by the readable content of a page when looking fact that a reader.", "tags": ["Mobile App", "E-commerce", "Payment Integration"], "hiredOn": "", "hiredStatus": "", "attachments": [""]},
            {"title": "Zero Commission Hiring Platform", "location": "India | Looking for Freelancer and Company | Cold 2", "description": "It is a long established fact that a reader will be distracted by the readable content of a page when looking fact that a reader.", "tags": ["Mobile App", "E-commerce", "Payment Integration"], "hiredOn": "7/09/2023", "hiredStatus": "Confirmed", "attachments": ["Attachment 1", "Attachment 2"]},
                {"title": "Zero Commission Hiring Platform", "location": "India | Looking for Freelancer and Company | Cold 2", "description": "It is a long established fact that a reader will be distracted by the readable content of a page when looking fact that a reader.", "tags": ["Mobile App", "E-commerce", "Payment Integration"], "hiredOn": "7/09/2023", "hiredStatus": "Confirmed", "attachments": ["Attachment 1", "Attachment 2"]}
  ]
  ''';

  List<Map<String, dynamic>> parseJobs(String jsonString) =>
      (jsonDecode(jsonString) as List<dynamic>).cast<Map<String, dynamic>>();

  @override
  Widget build(BuildContext context) {
    final jobs = parseJobs(dummyJsonPosted);

    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Container(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [Color(0xFFB7D7F9), Color(0xFFE5ACCB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            margin: EdgeInsets.all(1),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job['title'],
                    style: GoogleFonts.montserrat(
                        color: Colorfile.textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 5),
                Text(
                    isDescriptionExpanded
                        ? 'Description: ${job['description']}'
                        : 'Description: ${job['description'].substring(0, 100)}...',
                    style: GoogleFonts.montserrat(
                        color: Colorfile.textColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
                GestureDetector(
                  onTap: () => setState(
                      () => isDescriptionExpanded = !isDescriptionExpanded),
                  child: Text(isDescriptionExpanded ? 'Show Less' : 'Read More',
                      style: TextStyle(color: Colors.blue, fontSize: 10)),
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: (job['tags'] as List<dynamic>)
                      .map((tag) => Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            decoration: BoxDecoration(
                                color: Color(0xFFE8F1FC),
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(tag,
                                style: GoogleFonts.montserrat(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colorfile.textColor)),
                          ))
                      .toList(),
                ),
                SizedBox(height: 10),
                if (job['hiredOn'].isEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xFFFAFAFAFA),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                              side: BorderSide(color: Color(0xFFD9D9D9)),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Transform.rotate(
                                angle: 0.6,
                                child: Icon(Icons.attach_file,
                                    color: Colorfile.textColor),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Attachment',
                                style: GoogleFonts.montserrat(
                                  color: Colorfile.textColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10), // Space between buttons
                      Expanded(
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xFFCAEA95),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Text(
                            'Waiting for Approval',
                            style: GoogleFonts.montserrat(
                              color: Color(0xFF5C8A3C),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // Ensures spacing between avatar & text + icons
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    AssetImage('assets/profile_pic.png'),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Vaibhav Danve',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colorfile.textColor,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Image.asset('assets/india.png',
                                          height: 20, width: 20),
                                      SizedBox(width: 4),
                                      Text(
                                        'Gondia, India',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Image.asset(
                                'assets/Group 2237886.png',
                                height: 30,
                                width: 30,
                              ),
                              SizedBox(width: 8),
                              Image.asset(
                                'assets/Group 2237887.png',
                                height: 30,
                                width: 30,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Divider(),
                      Table(
                        children: [
                          TableRow(
                            children: [
                              Text('Hired on',
                                  style: GoogleFonts.montserrat(
                                      fontSize:
                                          12.0, // Changed to 12px equivalent
                                      color: Colors.black54)),
                              Text(':', textAlign: TextAlign.center),
                              Text(job['hiredOn'],
                                  textAlign: TextAlign
                                      .right, // Aligning data to the right
                                  style: GoogleFonts.montserrat(
                                      fontSize:
                                          12.0, // Changed to 12px equivalent
                                      color: Colors.black54))
                            ],
                          ),
                          TableRow(
                            children: [
                              Text('Hired Status',
                                  style: GoogleFonts.montserrat(
                                      fontSize:
                                          12.0, // Changed to 12px equivalent
                                      color: Colors.black54)),
                              Text(':', textAlign: TextAlign.center),
                              Text(job['hiredStatus'],
                                  textAlign: TextAlign
                                      .right, // Aligning data to the right
                                  style: GoogleFonts.montserrat(
                                      fontSize:
                                          12.0, // Changed to 12px equivalent
                                      color: Colors.black54))
                            ],
                          ),
                          if ((job['attachments'] as List).isNotEmpty)
                            TableRow(
                              children: [
                                Text('Project Attachments',
                                    style: GoogleFonts.montserrat(
                                        fontSize:
                                            12.0, // Changed to 12px equivalent
                                        color: Colors.black54)),
                                Text(':', textAlign: TextAlign.center),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .end, // Align icon to the right
                                  children: [
                                    Transform.rotate(
                                        angle: 0.6,
                                        child: Icon(Icons.attach_file,
                                            color: Colorfile.textColor,
                                            size: 15)),
                                  ],
                                )
                              ],
                            )
                        ],
                      )
                    ],
                  )
              ],
            ),
          ),
        );
      },
    );
  }
}
