import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _isExpanded = false; // Track whether the container is expanded or not

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && !_isScrolled) {
        setState(() {
          _isScrolled = true;
        });
      } else if (_scrollController.offset <= 100 && _isScrolled) {
        setState(() {
          _isScrolled = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> messages = [
      {
        "text": "Hello!",
        "sender": "received",
        "time": DateTime.now().subtract(Duration(minutes: 2))
      },
      {
        "text": "How are you?",
        "sender": "sent",
        "time": DateTime.now().subtract(Duration(minutes: 1))
      },
      {
        "text": "I am good, thanks!",
        "sender": "received",
        "time": DateTime.now()
      },
      {
        "text": "Hello!",
        "sender": "received",
        "time": DateTime.now().subtract(Duration(minutes: 2))
      },
      {
        "text": "How are you?",
        "sender": "sent",
        "time": DateTime.now().subtract(Duration(minutes: 1))
      },
      {
        "text": "I am good, thanks!",
        "sender": "received",
        "time": DateTime.now()
      },
      {
        "text": "Hello!",
        "sender": "received",
        "time": DateTime.now().subtract(Duration(minutes: 2))
      },
      {
        "text": "How are you?",
        "sender": "sent",
        "time": DateTime.now().subtract(Duration(minutes: 1))
      },
      {
        "text": "I am good, thanks!",
        "sender": "received",
        "time": DateTime.now()
      },
      {
        "text": "Hello!",
        "sender": "received",
        "time": DateTime.now().subtract(Duration(minutes: 2))
      },
      {
        "text": "How are you?",
        "sender": "sent",
        "time": DateTime.now().subtract(Duration(minutes: 1))
      },
      {
        "text": "I am good, thanks!",
        "sender": "received",
        "time": DateTime.now()
      },
    ];

    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        title: Text(
          'My Connection',
          style: GoogleFonts.montserrat(
            color: Colorfile.textColor,
            fontWeight: FontWeight.w600,
            fontSize: 18.0,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: _isScrolled
                ? Container(
                    key: ValueKey(1),
                    height: screenHeight * 0.1, // 10% of screen height
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.fromARGB(255, 238, 206, 224),
                          Color.fromARGB(255, 199, 219, 240),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25.0,
                            backgroundImage: NetworkImage(
                              'https://images.pexels.com/photos/14653174/pexels-photo-14653174.jpeg',
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text:
                                    'Vaibhav required a freelancer for Design software for my factory shop ',
                                style: GoogleFonts.montserrat(
                                  color: Colorfile.textColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                                children: [
                                  TextSpan(
                                    text: _isExpanded ? '' : 'Readmore',
                                    style: TextStyle(
                                      color: Color(0xFF424752),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 9,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        setState(() {
                                          _isExpanded = !_isExpanded;
                                        });
                                      },
                                  ),
                                ],
                              ),
                              maxLines: _isExpanded ? null : 3,
                              overflow: _isExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      key: ValueKey(2),
                      height: screenHeight * 0.18, // 15% of screen height
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromARGB(255, 238, 206, 224),
                            Color.fromARGB(255, 199, 219, 240),
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 30.0,
                                backgroundImage: NetworkImage(
                                  'https://images.pexels.com/photos/14653174/pexels-photo-14653174.jpeg',
                                ),
                              ),
                              SizedBox(width: 16.0),
                              Expanded(
                                child: Text(
                                  'Vaibhav required a freelancer for Design software for my factory shop',
                                  style: GoogleFonts.montserrat(
                                    color: Colorfile.textColor,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Project Posted on: 11/04/2020 | Budget: INR 50000',
                            style: GoogleFonts.montserrat(
                              color: Colorfile.textColor,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSent = message['sender'] == 'sent';
                    final time = DateFormat('h:mm a').format(message['time']);
                    return Column(
                      crossAxisAlignment: isSent
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 10.0),
                          decoration: BoxDecoration(
                            color:
                                isSent ? Color(0xFFE3EDF8) : Color(0xFFFAFAFB),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12.0),
                              topRight: isSent
                                  ? Radius.circular(
                                      8) // No rounded corner for sent messages
                                  : Radius.circular(
                                      8.0), // Rounded for received messages
                              bottomLeft: isSent
                                  ? Radius.circular(
                                      8.0) // Rounded bottom left for sent messages
                                  : Radius.circular(
                                      0.0), // No rounded corner for received messages
                              bottomRight: isSent
                                  ? Radius.circular(
                                      0.0) // No rounded corner for sent messages
                                  : Radius.circular(
                                      8.0), // Rounded bottom right for received messages
                            ),
                            border: Border.all(
                              color: Colors.grey.withOpacity(
                                  0.3), // Grey border color with opacity
                              width: 1.0, // Border width
                            ),
                          ),
                          child: Text(
                            message['text']!,
                            style: GoogleFonts.montserrat(fontSize: 13.0),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Text(
                            time,
                            style: GoogleFonts.montserrat(
                              fontSize: 8.0,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors
                          .transparent, // Keep it transparent, just for the size
                    ),
                    child: IconButton(
                      icon: Icon(Icons.emoji_emotions_outlined,
                          color: Colors.black), // Emoji icon
                      onPressed: () {
                        // Handle emoji click
                      },
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type message here...',
                        border: InputBorder.none, // Remove default border
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12.0), // Padding for TextField
                      ),
                      style: GoogleFonts.montserrat(),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Container(
                    width: 50.0,
                    height: 50.0,
                    child: IconButton(
                      icon: Image.asset(
                        'assets/send.png', // Replace with the path to your PNG image
                        // color: Colorfile.textColor,
                      ),
                      onPressed: () {
                        // Send message functionality
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
