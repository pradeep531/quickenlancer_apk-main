import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

// Define a global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationItemData> _allNotifications = [];
  bool _isLoading = true;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadDummyNotifications();
  }

  void _loadDummyNotifications() {
    _allNotifications = [
      NotificationItemData(
        message: "Lorem Ipsum",
        timeAgo: "2 min ago",
        subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
        imagePath: 'assets/notification.png',
        appRedirectionUrl: "https://example.com",
        recordId: "ID_1",
      ),
      NotificationItemData(
        message: "Dolor Sit",
        timeAgo: "5 min ago",
        subtitle: "Sed do eiusmod tempor incididunt ut labore et dolore",
        imagePath: 'assets/notification.png',
        appRedirectionUrl: "https://example.com",
        recordId: "ID_2",
      ),
      NotificationItemData(
        message: "Consectetur",
        timeAgo: "10 min ago",
        subtitle: "Ut enim ad minim veniam, quis nostrud exercitation",
        imagePath: 'assets/notification.png',
        appRedirectionUrl: "https://example.com",
        recordId: "ID_3",
      ),
      NotificationItemData(
        message: "Adipiscing Elit",
        timeAgo: "15 min ago",
        subtitle: "Duis aute irure dolor in reprehenderit in voluptate",
        imagePath: 'assets/notification.png',
        appRedirectionUrl: "https://example.com",
        recordId: "ID_4",
      ),
      NotificationItemData(
        message: "Eiusmod Tempor",
        timeAgo: "20 min ago",
        subtitle: "Excepteur sint occaecat cupidatat non proident",
        imagePath: 'assets/notification.png',
        appRedirectionUrl: "https://example.com",
        recordId: "ID_5",
      ),
      NotificationItemData(
        message: "Incididunt Ut",
        timeAgo: "25 min ago",
        subtitle: "Sunt in culpa qui officia deserunt mollit anim",
        imagePath: 'assets/notification.png',
        appRedirectionUrl: "https://example.com",
        recordId: "ID_6",
      ),
      NotificationItemData(
        message: "Labore Et",
        timeAgo: "30 min ago",
        subtitle: "Nemo enim ipsam voluptatem quia voluptas sit",
        imagePath: 'assets/notification.png',
        appRedirectionUrl: "https://example.com",
        recordId: "ID_7",
      ),
      NotificationItemData(
        message: "Dolore Magna",
        timeAgo: "35 min ago",
        subtitle: "Neque porro quisquam est qui dolorem ipsum",
        imagePath: 'assets/notification.png',
        appRedirectionUrl: "https://example.com",
        recordId: "ID_8",
      ),
      NotificationItemData(
        message: "Aliquam Quaerat",
        timeAgo: "40 min ago",
        subtitle: "Quis autem vel eum iure reprehenderit qui in ea",
        imagePath: 'assets/notification.png',
        appRedirectionUrl: "https://example.com",
        recordId: "ID_9",
      ),
      NotificationItemData(
        message: "Voluptatem",
        timeAgo: "45 min ago",
        subtitle: "At vero eos et accusamus et iusto odio dignissimos",
        imagePath: 'assets/notification.png',
        appRedirectionUrl: "https://example.com",
        recordId: "ID_10",
      ),
    ];

    _isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      _isLoading = true;
      _allNotifications = [];
    });
    await Future.delayed(const Duration(seconds: 1));
    _loadDummyNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_sharp, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              Text(
                'Notifications',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: Color(0xFFD9D9D9),
              height: 1.0,
            ),
          ),
        ),
        body: _isLoading
            ? _buildShimmer()
            : _allNotifications.isEmpty
                ? const Center(
                    child: Text(
                      'No notifications available',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refreshNotifications,
                    child: Scrollbar(
                      controller: _scrollController,
                      thickness: 10.0,
                      radius: const Radius.circular(8.0),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _allNotifications.length,
                        itemBuilder: (context, index) {
                          final notification = _allNotifications[index];
                          return NotificationItem(
                            message: notification.message,
                            timeAgo: notification.timeAgo,
                            subtitle: notification.subtitle,
                            imagePath: notification.imagePath,
                            appRedirectionUrl: notification.appRedirectionUrl,
                            recordId: notification.recordId,
                          );
                        },
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListTile(
            leading: CircleAvatar(backgroundColor: Colors.grey[300]),
            title: Container(color: Colors.grey[300], height: 16.0),
            subtitle: Container(color: Colors.grey[300], height: 14.0),
            contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
          ),
        );
      },
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String message;
  final String timeAgo;
  final String subtitle;
  final String imagePath;
  final String appRedirectionUrl;
  final String recordId;

  const NotificationItem({
    Key? key,
    required this.message,
    required this.timeAgo,
    required this.subtitle,
    required this.imagePath,
    required this.appRedirectionUrl,
    required this.recordId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        // Add navigation logic here using appRedirectionUrl if needed
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFD9D9D9),
              width: 0.8,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE3EDF8),
                  ),
                  child: Image.asset(
                    imagePath,
                    width: 30,
                    height: 30,
                    color: const Color(0xFF191E3E),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              message,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            timeAgo,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationItemData {
  final String message;
  final String timeAgo;
  final String subtitle;
  final String imagePath;
  final String appRedirectionUrl;
  final String recordId;

  NotificationItemData({
    required this.message,
    required this.timeAgo,
    required this.subtitle,
    required this.imagePath,
    required this.appRedirectionUrl,
    required this.recordId,
  });
}
