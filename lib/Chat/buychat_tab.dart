import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';

class BuyChatTab extends StatefulWidget {
  const BuyChatTab({super.key});

  @override
  _BuyChatTabState createState() => _BuyChatTabState();
}

class _BuyChatTabState extends State<BuyChatTab> {
  int itemCount = 0; // This will keep track of the count of items.

  void _increaseItem() {
    setState(() {
      itemCount++;
    });
  }

  void _decreaseItem() {
    if (itemCount > 0) {
      setState(() {
        itemCount--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(16.0),
          padding: EdgeInsets.all(1.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFB7D7F9),
                Color(0xFFE5ACCB),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          width: double.infinity,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/grp.png',
                        width: 100,
                        height: 100,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        margin: EdgeInsets.all(16.0),
                        padding: EdgeInsets.all(1.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFB7D7F9),
                              Color(0xFFE5ACCB),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: double.infinity,
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFFB7D7F9),
                                                Color(0xFFE5ACCB),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                            ),
                                          ),
                                          child: IconButton(
                                            icon: Icon(Icons.remove,
                                                color: Color(0xFF191E3E)),
                                            onPressed: _decreaseItem,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 8.0),
                                          child: Text(
                                            '$itemCount',
                                            style: GoogleFonts.montserrat(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFFB7D7F9),
                                                Color(0xFFE5ACCB),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                            ),
                                          ),
                                          child: IconButton(
                                            icon: Icon(Icons.add,
                                                color: Color(0xFF191E3E)),
                                            onPressed: _increaseItem,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 250,
                      height: 48,
                      margin: EdgeInsets.only(top: 16.0),
                      child: CupertinoButton(
                        onPressed: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) =>
                          //           const Buychat()), // Navigate to the new page
                          // );
                        },
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        color: Colorfile.textColor, // Background color
                        borderRadius: BorderRadius.circular(8),
                        child: Text(
                          'Update Profile To Buy Token',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(15), // Increased padding from all sides
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buy Hassle Free Chat',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.bold, // Heading
                  color: Colorfile.textColor,
                ),
              ),
              SizedBox(height: 5), // Space between title and subtitle
              Text(
                'With Hassle-Free Chat, you can purchase bulk chats that grant you pre-approved access to projects. This allows you to seamlessly connect with project partners without encountering any obstacles in the process.',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500, // Subtitle
                  color: Colorfile.textColor,
                  height: 1.5, // Adjust the line height here
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          height: 400,
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          decoration: BoxDecoration(
            color: Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              SizedBox(height: 30), // Space between rows
              // First row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(2, (index) {
                  // List of image paths and labels
                  List<String> imagePaths = [
                    'assets/Group 237731.png',
                    'assets/Group 237732.png',
                  ];
                  List<String> labels = [
                    'Pre-Approved Entry',
                    'Seamless Connection',
                  ];

                  return Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: (MediaQuery.of(context).size.width - 40) /
                        2, // Adjust width for two items per row
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          imagePaths[index], // Use the respective image
                          width: 75, // Image width
                          height: 75, // Image height
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 8),
                        Text(
                          labels[index], // Use the respective label
                          style: TextStyle(
                            fontFamily:
                                'Montserrat', // Set the font family to Montserrat
                            fontSize: 14, // Font size 14px
                            fontWeight: FontWeight.w500, // Font weight 500
                            height:
                                1.43, // line-height (14/20 = 0.7, so 1.43 for better control)
                            color: Colorfile.textColor, // Text color #191E3E
                            decoration: TextDecoration.none, // No underline
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              SizedBox(height: 40), // Space between rows
              // Second row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(2, (index) {
                  // List of image paths and labels
                  List<String> imagePaths = [
                    'assets/Group 237733.png',
                    'assets/Group 237734.png',
                  ];
                  List<String> labels = [
                    'Time Efficiency',
                    'Open Convenience',
                  ];

                  return Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: (MediaQuery.of(context).size.width - 40) /
                        2, // Adjust width for two items per row
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          imagePaths[index], // Use the respective image
                          width: 75, // Image width
                          height: 75, // Image height
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 8),
                        Text(
                          labels[index], // Use the respective label
                          style: TextStyle(
                            fontFamily:
                                'Montserrat', // Set the font family to Montserrat
                            fontSize: 14, // Font size 14px
                            fontWeight: FontWeight.w500, // Font weight 500
                            height:
                                1.43, // line-height (14/20 = 0.7, so 1.43 for better control)
                            color: Colorfile.textColor, // Text color #191E3E
                            decoration: TextDecoration.none, // No underline
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        )
      ],
    );
  }
}
