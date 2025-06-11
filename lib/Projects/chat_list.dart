import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Colors/colorfile.dart';

class ChatList extends StatelessWidget {
  final String projectId;
  final String chatSender;
  final String chatReceiver;
  final List<dynamic>? chats; // Optional chats list

  const ChatList({
    super.key,
    required this.projectId,
    required this.chatSender,
    required this.chatReceiver,
    this.chats,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // Softer background for minimal look
      appBar: AppBar(
        title: Text(
          'Chat List',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colorfile.textColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true, // Centered title for cleaner look
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0), // Thin border height
          child: Container(
            color: Colors.grey.shade300, // Light grey border
            height: 1.0, // Border thickness
          ),
        ),
      ),
      body: chats == null || chats!.isEmpty
          ? Center(
              child: Text(
                'No chats available',
                style: GoogleFonts.montserrat(
                  color: Colors.black45,
                  fontSize: 14, // Smaller font for subtlety
                  fontWeight: FontWeight.w400,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12), // Reduced padding
              itemCount: chats!.length,
              itemBuilder: (context, index) {
                final chat = chats![index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 6), // Tighter spacing
                  elevation: 0, // No shadow for flat design
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
                          backgroundImage: chat['profile_pic_url'] != null &&
                                  chat['profile_pic_url'].isNotEmpty
                              ? NetworkImage(chat['profile_pic_url'])
                              : const NetworkImage(
                                  'https://www.quickensol.com/quickenlancer-new/images/profile_pic/profile.png'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${chat['f_name'] ?? ''} ${chat['l_name'] ?? ''}',
                                style: GoogleFonts.montserrat(
                                  color: Colors.black87,
                                  fontSize: 14, // Smaller, cleaner font
                                  fontWeight: FontWeight.w500, // Lighter weight
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Last Chat: ${chat['sent_on_text'] ?? 'N/A'}',
                                style: GoogleFonts.montserrat(
                                  color: Colors.black45, // Softer color
                                  fontSize: 11, // Smaller font
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  SizedBox(
                                    height: 32, // Smaller button
                                    child: TextButton(
                                      onPressed: () {
                                        // Navigate to a detailed chat view or perform an action
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Chat with ${chat['f_name'] ?? ''} ${chat['l_name'] ?? ''}',
                                              style: GoogleFonts.montserrat(),
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colorfile.textColor,
                                        backgroundColor: Colors
                                            .grey.shade100, // Light background
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              6), // Softer corners
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 0),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.chat,
                                              size: 14,
                                              color: Colorfile.textColor),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Chat',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 12, // Smaller font
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  if (chat['is_hire_me_button'] == 1)
                                    SizedBox(
                                      height: 32, // Smaller button
                                      child: TextButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Hire Me action triggered',
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
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 0),
                                        ),
                                        child: Text(
                                          'Hire Me',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 12, // Smaller font
                                            fontWeight: FontWeight.w500,
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
