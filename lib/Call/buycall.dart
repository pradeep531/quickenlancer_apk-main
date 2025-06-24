import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickenlancer_apk/BottomBar/bottom_bar.dart';
import 'package:quickenlancer_apk/Call/buycalltab.dart';
import 'package:quickenlancer_apk/Call/callhistorytab.dart';
import 'package:quickenlancer_apk/Call/callpage.dart';
import 'package:quickenlancer_apk/Chat/buychat_tab.dart';
import 'package:quickenlancer_apk/Chat/chatpage.dart';
import 'package:quickenlancer_apk/Chat/historeytab_chat.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import 'package:quickenlancer_apk/home_page.dart';
import 'package:quickenlancer_apk/editprofilepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GradientTabIndicator extends Decoration {
  final Gradient gradient;
  final double height;

  GradientTabIndicator({required this.gradient, this.height = 3.0});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _GradientBoxPainter(gradient: gradient, height: height);
  }
}

class _GradientBoxPainter extends BoxPainter {
  final Gradient gradient;
  final double height;

  _GradientBoxPainter({required this.gradient, required this.height});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect = Offset(offset.dx, configuration.size!.height - height) &
        Size(configuration.size!.width, height);
    final Paint paint = Paint()..shader = gradient.createShader(rect);

    canvas.drawRect(rect, paint);
  }
}

class Buycall extends StatefulWidget {
  const Buycall({super.key});

  @override
  _BuychatState createState() => _BuychatState();
}

class _BuychatState extends State<Buycall> {
  int _selectedIndex = 2;
  int? isLoggedIn;
  String profilePicPath = '';

  @override
  void initState() {
    super.initState();
    _initializeData(); // Call initializeData in initState
  }

  Future<void> _initializeData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn =
          prefs.getInt('is_logged_in'); // Assign value after async call
      profilePicPath =
          prefs.getString('profile_pic_path') ?? ''; // Store profile_pic_path
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Buycallpage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Buychatpage()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Editprofilepage()),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Buy Hassle Free Call',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 23.4 / 18,
              color: Colorfile.textColor,
            ),
          ),
          elevation: 0,
          bottom: TabBar(
            indicator: GradientTabIndicator(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF51A5D1),
                  Color(0xFF82399C),
                  Color(0xFFF04E80),
                ],
              ),
            ),
            indicatorWeight: 3.0,
            labelColor: Colorfile.textColor,
            unselectedLabelColor: Colors.grey,
            labelStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: '        Buy Call        '),
              Tab(text: '        History        '),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SingleChildScrollView(child: Buycalltab()),
            SingleChildScrollView(child: Callhistorytab()),
          ],
        ),
        bottomNavigationBar: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: MyBottomBar(
            key: ValueKey<int>(_selectedIndex),
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
            isLoggedIn: isLoggedIn,
          ),
        ),
      ),
    );
  }
}
