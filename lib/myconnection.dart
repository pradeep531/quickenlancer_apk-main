import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickenlancer_apk/chat_page.dart';
import 'package:quickenlancer_apk/myconmodel.dart';

class InviteFriends extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_sharp, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Text(
              'My Connection',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        color: Color(0xFFFFFFFF),
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            // The new container with search and filter
            Container(
              height: 100,
              width: double.infinity,
              color: Color(0xFFFFFFFF),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(0.5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1.0),
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
                          fillColor: Color(0xFFFFFFFF),
                          suffixIcon: Icon(
                            CupertinoIcons.search,
                            size: 28.0,
                            color: Color(0xFFA5A5A5),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          isDense: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(1.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(1.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Connections list
            Myconnection(
              name: 'Vaibhav Danve',
              designation: 'web developer',
              project: 'Design software for',
              onChatPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      projectId: '',
                      chatSender: '',
                      chatReceiver: '',
                    ),
                  ),
                );
              },
            ),
            Myconnection(
              name: 'Vaibhav Danve',
              designation: 'web developer',
              project: 'Design software for',
              onChatPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      projectId: '',
                      chatSender: '',
                      chatReceiver: '',
                    ),
                  ),
                );
              },
            ),
            // Add more NotificationItem widgets as needed
          ],
        ),
      ),
    );
  }
}
