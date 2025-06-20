import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyBottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  MyBottomBar(
      {Key? key, required this.selectedIndex, required this.onItemTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen width and height using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Adjust height based on screen size for responsiveness
    double bottomBarHeight = screenHeight * 0.08; // 10% of screen height

    return Container(
      height: bottomBarHeight, // Dynamic height based on screen size
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: CupertinoTabBar(
        currentIndex:
            selectedIndex >= 0 ? selectedIndex : 0, // Fallback to 0 if -1
        onTap: onItemTapped,
        backgroundColor: Colors.transparent,
        activeColor: Colors.grey,
        inactiveColor: Colors.black45,
        border: Border.all(color: Colors.transparent),
        items: [
          BottomNavigationBarItem(
            icon: _buildIcon('assets/home.png', 0, screenWidth),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon('assets/my_project.png', 1, screenWidth),
            label: 'My Project',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon('assets/call.png', 2, screenWidth),
            label: 'Call',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon('assets/chat.png', 3, screenWidth),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon('assets/profile.png', 4, screenWidth),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(String assetPath, int index, double screenWidth) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: selectedIndex == index && selectedIndex >= 0
            ? LinearGradient(
                colors: [Color(0xFFB7D7F9), Color(0xFFE5ACCB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        shape: BoxShape.circle,
        boxShadow: selectedIndex == index && selectedIndex >= 0
            ? [
                // BoxShadow(
                //   color: Colors.blue.withOpacity(0.6),
                //   blurRadius: 10,
                //   spreadRadius: 2,
                // ),
              ]
            : null,
      ),
      child: Image.asset(
        assetPath,
        height: screenWidth *
            0.06, // Dynamically set icon size based on screen width
        width: screenWidth * 0.06,
        color: selectedIndex == index && selectedIndex >= 0
            ? null
            : Colors.black45,
      ),
    );
  }
}
