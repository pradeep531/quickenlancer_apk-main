import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyBottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final int? isLoggedIn; // Use int? to match SharedPreferences usage

  const MyBottomBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.isLoggedIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions and text scale factor using MediaQuery
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double screenHeight = mediaQuery.size.height;
    final double textScaleFactor =
        mediaQuery.textScaleFactor.clamp(0.8, 1.2); // Prevent extreme scaling
    final double safeBottomPadding =
        mediaQuery.padding.bottom; // Handle safe area for notches

    // Responsive bottom bar height (8% of screen height, capped for large screens)
    final double bottomBarHeight =
        (screenHeight * 0.08).clamp(60.0, 80.0) + safeBottomPadding;

    // Icon size based on screen width (6% of screen width)
    final double iconSize = (screenWidth * 0.06).clamp(24.0, 32.0);

    // Determine navigation items based on login status
    final List<BottomNavigationBarItem> navItems = isLoggedIn == 1
        ? [
            _buildNavItem(
                'assets/home.png', 'Home', 0, iconSize, textScaleFactor),
            _buildNavItem('assets/my_project.png', 'My Project', 1, iconSize,
                textScaleFactor),
            _buildNavItem(
                'assets/call.png', 'Call', 2, iconSize, textScaleFactor),
            _buildNavItem(
                'assets/chat.png', 'Chat', 3, iconSize, textScaleFactor),
            _buildNavItem(
                'assets/profile.png', 'Profile', 4, iconSize, textScaleFactor),
          ]
        : [
            _buildNavItem(
                'assets/home.png', 'Home', 0, iconSize, textScaleFactor),
            _buildNavItem('assets/home.png', 'Hire Freelancer', 1, iconSize,
                textScaleFactor),
            _buildNavItem('assets/home.png', 'Hire Company', 2, iconSize,
                textScaleFactor),
            _buildNavItem('assets/home.png', 'Post Project', 3, iconSize,
                textScaleFactor),
          ];

    return Container(
      height: bottomBarHeight,
      decoration: const BoxDecoration(
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
      child: SafeArea(
        top: false,
        bottom: true,
        child: CupertinoTabBar(
          currentIndex: selectedIndex >= 0
              ? selectedIndex
              : 0, // Fallback to 0 if invalid
          onTap: onItemTapped,
          backgroundColor: Colors.transparent,
          activeColor: Colors.grey,
          inactiveColor: Colors.black45,
          border: Border.all(color: Colors.transparent),
          items: navItems,
          height: bottomBarHeight - safeBottomPadding, // Adjust for safe area
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    String assetPath,
    String label,
    int index,
    double iconSize,
    double textScaleFactor,
  ) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(iconSize * 0.2), // Responsive padding
        decoration: BoxDecoration(
          gradient: selectedIndex == index && selectedIndex >= 0
              ? const LinearGradient(
                  colors: [Color(0xFFB7D7F9), Color(0xFFE5ACCB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          shape: BoxShape.circle,
          boxShadow: selectedIndex == index && selectedIndex >= 0
              ? const [
                  // BoxShadow(
                  //   color: Colors.blueAccent,
                  //   blurRadius: 8,
                  //   spreadRadius: 1,
                  // ),
                ]
              : null,
        ),
        child: Image.asset(
          assetPath,
          height: iconSize,
          width: iconSize,
          color: selectedIndex == index && selectedIndex >= 0
              ? null
              : Colors.black45,
          colorBlendMode: selectedIndex == index && selectedIndex >= 0
              ? null
              : BlendMode.modulate,
        ),
      ),
      label: label,
    );
  }
}
