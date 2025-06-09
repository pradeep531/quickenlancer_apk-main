import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Colors/colorfile.dart';

class CallsList extends StatelessWidget {
  const CallsList({super.key});

  // Sample data for multiple call entries
  final List<Map<String, dynamic>> callData = const [
    {
      'name': 'Vaibhav Danve',
      'lastCall': '01 Jan, 1970  |  05:30 AM',
      'avatar':
          'https://www.quickensol.com/quickenlancer-new/images/profile_pic/profile.png'
    },
    {
      'name': 'Priya Sharma',
      'lastCall': '02 Jan, 1970  |  09:15 AM',
      'avatar':
          'https://www.quickensol.com/quickenlancer-new/images/profile_pic/profile.png'
    },
    {
      'name': 'Rahul Patel',
      'lastCall': '03 Jan, 1970  |  02:45 PM',
      'avatar':
          'https://www.quickensol.com/quickenlancer-new/images/profile_pic/profile.png'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'All Data',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: Color(0xFFDDDDDD),
            thickness: 1,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: callData.length,
        itemBuilder: (context, index) {
          return Card(
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
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(callData[index]['avatar']),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          callData[index]['name'],
                          style: GoogleFonts.montserrat(
                            color: Colorfile.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last Call On: ${callData[index]['lastCall']}',
                          style: GoogleFonts.montserrat(
                            color: Colorfile.grey,
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
          );
        },
      ),
    );
  }
}
