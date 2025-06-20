import 'package:flutter/material.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import '../BottomBar/bottom_bar.dart';
import '../Call/callpage.dart';
import '../Chat/chatpage.dart';
import '../SignUp/signIn.dart';
import '../editprofilepage.dart';
import '../home_page.dart';
import 'all_projects.dart';

class PostProjectFinal extends StatefulWidget {
  const PostProjectFinal({Key? key}) : super(key: key);

  @override
  _PostProjectFinalState createState() => _PostProjectFinalState();
}

class _PostProjectFinalState extends State<PostProjectFinal> {
  int _selectedIndex = -1; // Set to -1 to indicate no selection
  int isLoggedIn = 0;

  void _onItemTapped(int index) {
    final routes = {
      0: const MyHomePage(),
      1: const AllProjects(),
      2: const Buycallpage(),
      3: const Buychatpage(),
      4: const Editprofilepage(),
    };

    if (routes.containsKey(index)) {
      setState(() => _selectedIndex = index);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => routes[index]!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colorfile.body,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Post Project',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colorfile.textColor,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.withOpacity(0.1),
              Colors.pink.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(35.0),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(
                  color: Color(0xFFE5ACCB), // Hex color #E5ACCB
                  width: 1.0, // 1px border width
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/tick.png',
                    width: 150,
                    height: 130,
                    fit: BoxFit.contain,
                  ),
                  const Text(
                    'Congratulations,\nYou Are Almost Done!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colorfile.textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Thanks for your requirement! Quickenlancer is reviewing and will notify you soon.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colorfile.textColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyHomePage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colorfile.textColor,
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'GO BACK HOME',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colorfile.textColor,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colorfile.textColor),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: MyBottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
