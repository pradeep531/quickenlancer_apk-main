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
      backgroundColor: Colors.white, // Match CallsList background
      appBar: AppBar(
        title: Text(
          'Chat List',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colorfile.textColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        // centerTitle: true, // Centered title to match CallsList
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
                style: GoogleFonts.poppins(
                  color: Colors.black45,
                  fontSize: 14, // Match CallsList font size
                  fontWeight: FontWeight.w400,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12), // Match CallsList padding
              itemCount: chats!.length,
              itemBuilder: (context, index) {
                final chat = chats![index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 6), // Tighter spacing
                  elevation: 0, // No shadow for flat design
                  color: Colors.white,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFE2E2E2), // Match CallsList border
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.all(10), // Match CallsList padding
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // Center alignment
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom:
                                    35.0), // Match CallsList avatar alignment
                            child: CircleAvatar(
                              radius: 20, // Smaller avatar
                              backgroundImage: chat['profile_pic_url'] !=
                                          null &&
                                      chat['profile_pic_url'].isNotEmpty
                                  ? NetworkImage(chat['profile_pic_url'])
                                  : const NetworkImage(
                                      'https://www.quickensol.com/quickenlancer-new/images/profile_pic/profile.png'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${chat['f_name'] ?? ''} ${chat['l_name'] ?? ''}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black87,
                                    fontSize: 14, // Match CallsList font
                                    fontWeight: FontWeight
                                        .w600, // Match CallsList weight
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Last Chat: ${chat['sent_on_text'] ?? 'N/A'}',
                                  style: GoogleFonts.poppins(
                                    color: Colorfile
                                        .textColor, // Match CallsList color
                                    fontSize: 11, // Match CallsList font
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    SizedBox(
                                      height:
                                          32, // Match CallsList button height
                                      child: TextButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Chat with ${chat['f_name'] ?? ''} ${chat['l_name'] ?? ''}',
                                                style: GoogleFonts.poppins(),
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Color(
                                              0xFF191E3E), // Match CallsList button color
                                          backgroundColor: Color(0xFFFFFFFF),
                                          side: BorderSide(
                                            color: Color(
                                                0xFF191E3E), // Match CallsList border
                                            width: 1.0,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                6), // Match CallsList corners
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 0),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Icon(Icons.chat,
                                                size: 14,
                                                color: Color(
                                                    0xFF191E3E)), // Match CallsList icon
                                            const SizedBox(width: 4),
                                            Text(
                                              'Chat',
                                              style: GoogleFonts.poppins(
                                                fontSize:
                                                    12, // Match CallsList font
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF191E3E),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // const SizedBox(width: 12),
                                    if (chat['is_hire_me_button'] == 1)
                                      SizedBox(
                                        height:
                                            32, // Match CallsList button height
                                        child: TextButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Hire Me action triggered',
                                                  style: GoogleFonts.poppins(),
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors
                                                .black, // Match CallsList text color
                                            backgroundColor: Colors
                                                .transparent, // Transparent for gradient
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 0),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  6), // Match CallsList corners
                                            ),
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(
                                                      0xFFB7D7F9), // Match CallsList gradient
                                                  Color(0xFFE6ACCB),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                transform: GradientRotation(127.3 *
                                                    3.1415927 /
                                                    180), // Match CallsList rotation
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Hire Me',
                                                  style: GoogleFonts.poppins(
                                                    fontSize:
                                                        12, // Match CallsList font
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors
                                                        .black, // Match CallsList text color
                                                  ),
                                                ),
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
                  ),
                );
              },
            ),
    );
  }
}
