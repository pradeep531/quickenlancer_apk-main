import 'dart:developer';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import 'api/network/uri.dart';
import 'home_page.dart';

class ChatPage extends StatefulWidget {
  final String chatSender;
  final String projectId;
  final String chatReceiver;
  const ChatPage({
    required this.chatReceiver,
    required this.chatSender,
    required this.projectId,
    Key? key,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  bool _isScrolled = false;
  bool _isExpanded = false;
  bool _isLoadingMore = false;
  bool _hasMoreMessages = true;
  int _limit = 10;
  int _offset = 0;
  List<Map<String, dynamic>> messages = [];
  String projectName = '';
  String projectCreatedOn = '';
  String projectAmount = '';
  String currencyLabel = '';
  String receiverName = '';
  String profilePic = '';

  @override
  void initState() {
    super.initState();
    _fetchChatData();

    _scrollController.addListener(() {
      setState(() {
        _isScrolled = _scrollController.offset > 100;
      });

      // Trigger fetch when scrolling near the top
      if (_scrollController.offset <= 50 &&
          !_isLoadingMore &&
          _hasMoreMessages &&
          _scrollController.position.pixels <=
              _scrollController.position.minScrollExtent + 50) {
        _offset += _limit;
        _fetchChatData();
      }
    });
  }

  Future<void> _fetchChatData({bool isRefresh = false}) async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Reset offset and messages if refreshing
    if (isRefresh) {
      _offset = 0;
      messages.clear();
      _hasMoreMessages = true;
    }

    final prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('auth_token');
    final userId = prefs.getString('user_id') ?? '';
    final String apiUrl = URLS().user_chats;
    final Map<String, dynamic> requestBody = {
      "user_id": userId,
      "offset": _offset,
      "limit": _limit,
      "project_id": widget.projectId,
    };

    log('Auth Token: $authToken');
    log('Request Body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        log('Fetch Chat Response: ${response.body}');
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'true') {
          final data = responseData['data'];
          final List<dynamic> fetchedMessages = data['messages'];

          setState(() {
            if (_offset == 0) {
              // Initial fetch or refresh: replace messages
              messages = fetchedMessages.map((msg) {
                return {
                  'text': msg['message'],
                  'sender': msg['text_align'] == 'right' ? 'sent' : 'received',
                  'time':
                      DateTime.tryParse(msg['created_on']) ?? DateTime.now(),
                };
              }).toList();
              // Populate project details only on initial fetch or refresh
              projectName = data['project_name'] ?? 'Untitled Project';
              projectCreatedOn = data['project_created_on'] ?? '';
              projectAmount = data['project_amount'] ?? '';
              currencyLabel = data['currency_label'] ?? 'INR';
              receiverName =
                  '${data['receiver_details']['f_name'] ?? ''} ${data['receiver_details']['l_name'] ?? ''}'
                      .trim();
              profilePic = data['profile_pic'] ??
                  'https://www.quickensol.com/quickenlancer-new/images/acco.png';
            } else {
              // Pagination: prepend new messages
              final newMessages = fetchedMessages.map((msg) {
                return {
                  'text': msg['message'],
                  'sender': msg['text_align'] == 'right' ? 'sent' : 'received',
                  'time':
                      DateTime.tryParse(msg['created_on']) ?? DateTime.now(),
                };
              }).toList();
              messages.insertAll(0, newMessages);
              _hasMoreMessages = fetchedMessages.length == _limit;
            }
            _isLoadingMore = false;
          });

          if (_offset == 0) {
            // Scroll to bottom only on initial fetch or refresh
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            });
          }
        } else {
          setState(() {
            _isLoadingMore = false;
            _hasMoreMessages = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load chat data')),
          );
        }
      } else {
        log('Fetch Chat Error: ${response.statusCode}');
        setState(() {
          _isLoadingMore = false;
          _hasMoreMessages = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load chat data')),
        );
      }
    } catch (e) {
      log('Fetch Chat Error: $e');
      setState(() {
        _isLoadingMore = false;
        _hasMoreMessages = false;
      });
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Error loading chat data')),
      // );
    }
  }

  Future<void> _sendMessage(String typedMessage) async {
    final prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('auth_token');

    final String apiUrl = URLS().user_send_message;
    final Map<String, dynamic> requestBody = {
      "user_id": prefs.getString('user_id'),
      "chat_sender": widget.chatSender,
      "message": typedMessage,
      "chat_receiver": widget.chatReceiver,
      "project_id": widget.projectId,
    };

    try {
      log('Send Message Request Body: ${jsonEncode(requestBody)}');
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(requestBody),
      );

      log('Send Message Response Body: ${response.body}');
      if (response.statusCode == 200) {
        setState(() {
          messages.add({
            "text": typedMessage,
            "sender": "sent",
            "time": DateTime.now(),
          });
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      } else {
        log('Send Message Error: ${response.statusCode} - ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message')),
        );
      }
    } catch (e) {
      log('Send Message Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error sending message')),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyHomePage()),
    );
    return false;
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colorfile.textColor),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyHomePage()),
              );
            },
          ),
          title: Text(
            receiverName.isNotEmpty ? receiverName : 'My Connection',
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
              duration: const Duration(milliseconds: 300),
              child: _isScrolled
                  ? Container(
                      key: const ValueKey(1),
                      height: screenHeight * 0.1,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
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
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 25.0,
                              backgroundImage: profilePic.isNotEmpty
                                  ? NetworkImage(profilePic)
                                  : null,
                              onBackgroundImageError: profilePic.isNotEmpty
                                  ? (exception, stackTrace) {
                                      log('Profile pic load error: $exception');
                                    }
                                  : null,
                              child: profilePic.isEmpty
                                  ? const Icon(Icons.person,
                                      size: 30.0, color: Colors.grey)
                                  : null,
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  text: '$receiverName - $projectName',
                                  style: GoogleFonts.montserrat(
                                    color: Colorfile.textColor,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  // children: [
                                  //   TextSpan(
                                  //     text: _isExpanded
                                  //         ? ' Read less'
                                  //         : ' Read more',
                                  //     style: const TextStyle(
                                  //       color: Color(0xFF424752),
                                  //       fontWeight: FontWeight.w500,
                                  //       fontSize: 9,
                                  //       decoration: TextDecoration.underline,
                                  //     ),
                                  //     recognizer: TapGestureRecognizer()
                                  //       ..onTap = () {
                                  //         setState(() {
                                  //           _isExpanded = !_isExpanded;
                                  //         });
                                  //       },
                                  //   ),
                                  // ],
                                ),
                                maxLines: _isExpanded ? null : 2,
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
                        key: const ValueKey(2),
                        height: screenHeight * 0.18,
                        padding: const EdgeInsets.all(12.0),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
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
                                  backgroundImage: profilePic.isNotEmpty
                                      ? NetworkImage(profilePic)
                                      : null,
                                  onBackgroundImageError: profilePic.isNotEmpty
                                      ? (exception, stackTrace) {
                                          log('Profile pic load error: $exception');
                                        }
                                      : null,
                                  child: profilePic.isEmpty
                                      ? const Icon(Icons.person,
                                          size: 40.0, color: Colors.grey)
                                      : null,
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: Text(
                                    '$receiverName - $projectName',
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
                            const SizedBox(height: 8.0),
                            Text(
                              'Posted on: ${_formatDate(projectCreatedOn)} | Budget: $currencyLabel $projectAmount',
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
                child: messages.isEmpty && !_isLoadingMore
                    ? Center(
                        child: Text(
                          'No messages are there',
                          style: GoogleFonts.montserrat(
                            fontSize: 16.0,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _fetchChatData(isRefresh: true),
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: _scrollController,
                          itemCount: messages.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (_isLoadingMore && index == 0) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }
                            final messageIndex =
                                _isLoadingMore ? index - 1 : index;
                            final message = messages[messageIndex];
                            final isSent = message['sender'] == 'sent';
                            final time =
                                DateFormat('h:mm a').format(message['time']);
                            return Column(
                              crossAxisAlignment: isSent
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 10.0),
                                  decoration: BoxDecoration(
                                    color: isSent
                                        ? const Color(0xFFE3EDF8)
                                        : const Color(0xFFFAFAFB),
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(12.0),
                                      topRight: isSent
                                          ? const Radius.circular(0.0)
                                          : const Radius.circular(12.0),
                                      bottomLeft: isSent
                                          ? const Radius.circular(12.0)
                                          : const Radius.circular(0.0),
                                      bottomRight: isSent
                                          ? const Radius.circular(0.0)
                                          : const Radius.circular(12.0),
                                    ),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.3),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Text(
                                    message['text']!,
                                    style:
                                        GoogleFonts.montserrat(fontSize: 13.0),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
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
                          },
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.emoji_emotions_outlined,
                            color: Colors.black),
                        onPressed: () {
                          // Implement emoji picker
                        },
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'Type message here...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                        ),
                        style: GoogleFonts.montserrat(),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      width: 50.0,
                      height: 50.0,
                      child: IconButton(
                        icon: Image.asset('assets/send.png'),
                        onPressed: () {
                          if (_textController.text.trim().isNotEmpty) {
                            _sendMessage(_textController.text.trim());
                            _textController.clear();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
