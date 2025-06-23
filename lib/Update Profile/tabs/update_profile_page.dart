import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickenlancer_apk/Update%20Profile/tabs/language_form.dart';
import 'package:quickenlancer_apk/Update%20Profile/tabs/skills_form.dart';
import 'certification_form.dart';
import 'experience_form.dart';
import 'password_form.dart';
import 'portfolio_form.dart';
import 'profile_form.dart';
import '../shared_widgets.dart';

class UpdateProfilePage extends StatefulWidget {
  final int initialTab; // Add initialTab parameter
  const UpdateProfilePage({Key? key, required this.initialTab})
      : super(key: key);

  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  late int _currentTab; // Use late initialization
  bool _isSidebarExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab; // Initialize _currentTab with initialTab
  }

  List<Map<String, dynamic>> _getTabs() {
    return [
      {
        'title': 'Profile',
        'icon': Icons.person,
        'content': ProfileForm(),
      },
      {
        'title': 'Skills',
        'icon': Icons.build,
        'content': SkillsForm(),
      },
      {
        'title': 'Portfolio',
        'icon': Icons.work,
        'content': PortfolioForm(),
      },
      {
        'title': 'Language',
        'icon': Icons.language,
        'content': LanguageForm(),
      },
      {
        'title': 'Certification',
        'icon': Icons.verified,
        'content': CertificationForm(),
      },
      {
        'title': 'Experience',
        'icon': Icons.history,
        'content': ExperienceForm(),
      },
      {
        'title': 'Password',
        'icon': Icons.lock,
        'content': PasswordForm(),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _getTabs();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Update Profile',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isSidebarExpanded ? Icons.arrow_left : Icons.arrow_right,
              color: Colors.grey[700],
              size: 24,
            ),
            onPressed: () =>
                setState(() => _isSidebarExpanded = !_isSidebarExpanded),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final sidebarWidth = _isSidebarExpanded ? 140.0 : 60.0;
          const horizontalPadding = 48.0;
          final availableWidth =
              constraints.maxWidth - sidebarWidth - horizontalPadding;
          final maxContentWidth =
              (availableWidth > 300 ? availableWidth : 300).toDouble();
          final minContentWidth =
              (availableWidth > 200 ? 200 : availableWidth).toDouble();

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: sidebarWidth,
                color: Colors.white,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: tabs.length,
                        itemBuilder: (context, index) {
                          return Material(
                            color: _currentTab == index
                                ? Colors.grey[100]
                                : Colors.transparent,
                            child: InkWell(
                              onTap: () => setState(() => _currentTab = index),
                              hoverColor: Colors.grey[100],
                              child: ListTile(
                                leading: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Icon(
                                    tabs[index]['icon'],
                                    color: _currentTab == index
                                        ? const Color(0xFF2563EB)
                                        : Colors.grey[600],
                                    size: 22,
                                  ),
                                ),
                                title: _isSidebarExpanded
                                    ? Text(
                                        tabs[index]['title'],
                                        style: GoogleFonts.poppins(
                                          color: _currentTab == index
                                              ? const Color(0xFF2563EB)
                                              : Colors.grey[800],
                                          fontWeight: _currentTab == index
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      )
                                    : null,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: _isSidebarExpanded ? 12 : 10,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: maxContentWidth,
                        minWidth: minContentWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            tabs[_currentTab]['title'],
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[100]!),
                            ),
                            child: tabs[_currentTab]['content'],
                          ),
                          const SizedBox(height: 24),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.end,
                          //   children: [
                          //     if (_currentTab > 0)
                          //       TextButton(
                          //         onPressed: () =>
                          //             setState(() => _currentTab -= 1),
                          //         child: Text(
                          //           'Back',
                          //           style: GoogleFonts.poppins(
                          //             color: Colors.grey[600],
                          //             fontSize: 14,
                          //             fontWeight: FontWeight.w500,
                          //           ),
                          //         ),
                          //       ),
                          //     const SizedBox(width: 12),
                          //     StyledButton(
                          //       text: _currentTab == tabs.length - 1
                          //           ? 'Save'
                          //           : 'Next',
                          //       icon: _currentTab == tabs.length - 1
                          //           ? Icons.save
                          //           : Icons.arrow_forward,
                          //       onPressed: () {
                          //         if (_currentTab < tabs.length - 1) {
                          //           setState(() => _currentTab += 1);
                          //         } else {
                          //           ScaffoldMessenger.of(context).showSnackBar(
                          //             SnackBar(
                          //               content: Text(
                          //                 'Profile updated successfully',
                          //                 style: GoogleFonts.poppins(
                          //                   fontSize: 14,
                          //                   fontWeight: FontWeight.w500,
                          //                   color: Colors.white,
                          //                 ),
                          //               ),
                          //               backgroundColor:
                          //                   const Color(0xFF2563EB),
                          //             ),
                          //           );
                          //         }
                          //       },
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
