import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Colors/colorfile.dart';

class AllProposals extends StatelessWidget {
  final String projectId;
  final List<dynamic> proposals;

  const AllProposals({
    super.key,
    required this.projectId,
    required this.proposals,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Softer background
      appBar: AppBar(
        title: Text(
          'All Proposals',
          style: GoogleFonts.montserrat(
            color: Colorfile.textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true, // Centered title
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colorfile.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0), // Thin border height
          child: Container(
            color: Colors.grey.shade300, // Light grey border
            height: 1.0, // Border thickness
          ),
        ),
      ),
      body: proposals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox_outlined,
                      size: 50, color: Colors.black45),
                  const SizedBox(height: 10),
                  Text(
                    'No Proposals Found',
                    style: GoogleFonts.montserrat(
                      color: Colors.black45,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12), // Reduced padding
              itemCount: proposals.length,
              itemBuilder: (context, index) {
                final proposal = proposals[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 6), // Tighter spacing
                  elevation: 0, // No shadow
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Colors.grey.shade200,
                        width: 0.5), // Subtle border
                    borderRadius: BorderRadius.circular(8), // Softer corners
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10), // Reduced padding
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // Center alignment
                      children: [
                        CircleAvatar(
                          radius: 20, // Smaller avatar
                          backgroundImage: proposal['profile_pic_url'] !=
                                      null &&
                                  proposal['profile_pic_url'].isNotEmpty
                              ? NetworkImage(proposal['profile_pic_url'])
                              : const NetworkImage(
                                  'https://www.quickensol.com/quickenlancer-new/images/profile_pic/profile.png'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${proposal['f_name'] ?? ''} ${proposal['l_name'] ?? ''}',
                                style: GoogleFonts.montserrat(
                                  color: Colors.black87,
                                  fontSize: 14, // Smaller font
                                  fontWeight: FontWeight.w500, // Lighter weight
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Sent On: ${proposal['sent_on_text'] ?? 'N/A'}',
                                style: GoogleFonts.montserrat(
                                  color: Colors.black45, // Softer color
                                  fontSize: 11, // Smaller font
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 6),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 32, // Smaller button
                                      child: TextButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Milestone action triggered',
                                                style: GoogleFonts.montserrat(),
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colorfile.textColor,
                                          backgroundColor: Colors.grey
                                              .shade100, // Light background
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                6), // Softer corners
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 0),
                                        ),
                                        child: Text(
                                          'Milestone',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 12, // Smaller font
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    if (proposal['is_hire_me_button'] == 1)
                                      SizedBox(
                                        height: 32, // Smaller button
                                        child: TextButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Hire Me action triggered',
                                                  style:
                                                      GoogleFonts.montserrat(),
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                Colorfile.textColor,
                                            backgroundColor: Colors.grey
                                                .shade100, // Light background
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 0),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.asset(
                                                'assets/attachment.png',
                                                height: 14,
                                                width: 14,
                                                color: Colorfile.textColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Attachment',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 12, // Smaller font
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
              },
            ),
    );
  }
}
