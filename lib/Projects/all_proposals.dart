import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Colors/colorfile.dart';

class AllProposals extends StatelessWidget {
  const AllProposals({super.key});

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
          'All Proposals',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Dynamic list of proposals from callData
            ...callData.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
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
                        backgroundImage: NetworkImage(data['avatar']),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'],
                              style: GoogleFonts.montserrat(
                                color: Colorfile.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Last Call On: ${data['lastCall']}',
                              style: GoogleFonts.montserrat(
                                color: Colorfile.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 36,
                                    child: TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                        foregroundColor: Color(0xFF000000),
                                        side: const BorderSide(
                                            color: Color(0xFF000000), width: 1),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 0),
                                      ),
                                      child: Text(
                                        'Milestone',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    height: 36,
                                    child: TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                        foregroundColor: Color(0xFF000000),
                                        side: const BorderSide(
                                            color: Color(0xFF000000), width: 1),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 0),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Image.asset(
                                            'assets/attachment.png',
                                            height: 18,
                                            width: 18,
                                            color: Color(0xFF000000),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Attachment',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
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
            }).toList(),
            // Static card with Milestone and Attachment buttons
            Card(
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
                    const CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(
                          'https://www.quickensol.com/quickenlancer-new/images/profile_pic/profile.png'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vaibhav Danve',
                            style: GoogleFonts.montserrat(
                              color: Colorfile.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Last Call On: 01 Jan, 1970  |  05:30 AM',
                            style: GoogleFonts.montserrat(
                              color: Colorfile.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 36,
                                  child: TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      foregroundColor: Color(0xFF000000),
                                      side: const BorderSide(
                                          color: Color(0xFF000000), width: 1),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 0),
                                    ),
                                    child: Text(
                                      'Milestone',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                  height: 36,
                                  child: TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      foregroundColor: Color(0xFF000000),
                                      side: const BorderSide(
                                          color: Color(0xFF000000), width: 1),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 0),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/attachment.png',
                                          height: 18,
                                          width: 18,
                                          color: Color(0xFF000000),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Attachment',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
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
            ),
            // Buttons section
          ],
        ),
      ),
    );
  }
}
