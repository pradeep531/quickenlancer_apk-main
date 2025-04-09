import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import 'package:another_stepper/another_stepper.dart';
import 'package:quickenlancer_apk/PostProject/step4.dart';

class PostProject extends StatefulWidget {
  @override
  _PostProjectState createState() => _PostProjectState();
}

class _PostProjectState extends State<PostProject> {
  bool _isContainerVisible = false;
  int _currentStep = 0;
  final List<Map<String, dynamic>> requirementType = [
    {
      'label': 'Cold',
      'icon': Icons.ac_unit,
      'iconColor': Colors.blue, // Icon color for 'Cold'
    },
    {
      'label': 'Hot',
      'icon': Icons.local_fire_department,
      'iconColor': Colors.orange, // Icon color for 'Hot'
    },
  ];
  final List<Map<String, dynamic>> lookingFor = [
    {
      'label': 'Company',
      // 'icon': Icons.ac_unit,
      'iconColor': Colors.blue, // Icon color for 'Cold'
    },
    {
      'label': 'Freelancer',
      // 'icon': Icons.local_fire_department,
      'iconColor': Colors.orange, // Icon color for 'Hot'
    },
    {
      'label': 'Both',
      'icon': Icons.local_fire_department,
      // 'iconColor': Colors.orange, // Icon color for 'Hot'
    },
  ];
  final List<Map<String, dynamic>> paymentMode = [
    {
      'label': 'Fixed Rate',
      // 'icon': Icons.local_fire_department,
      'iconColor': Colors.orange, // Icon color for 'Hot'
    },
    {
      'label': 'Hourly Rate',
      // 'icon': Icons.local_fire_department,
      // 'iconColor': Colors.orange, // Icon color for 'Hot'
    },
  ];
  final List<Map<String, dynamic>> connecttype = [
    {
      'label': 'Chat',
      // 'icon': Icons.message,
      // 'iconColor': Colors.orange, // Icon color for 'Hot'
    },
    {
      'label': 'Call',
      // 'icon': Icons.phone,
      // 'iconColor': Colors.orange, // Icon color for 'Hot'
    },
    {
      'label': 'Both',
      'icon': Icons.local_fire_department,
      'iconColor': Colors.orange, // Icon color for 'Hot'
    },
  ];
  TextEditingController _controller = TextEditingController();
  bool _isBold = false;
  bool _isUnderline = false;
  String? _fileName;
  int selectedRequiredType = -1;
  int selectedLookingFor = -1;
  int selectedConnectType = -1;
  int selectedPaymentType = -1;
  void _pickFile() async {
    // Open file picker
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    // Check if a file was picked
    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
      });
    } else {
      // User canceled the picker
      setState(() {
        _fileName = null;
      });
    }
  }

  void _toggleBold() {
    setState(() {
      _isBold = !_isBold;
    });
  }

  void _toggleUnderline() {
    setState(() {
      _isUnderline = !_isUnderline;
    });
  }

  // Function to clear text
  void _clearText() {
    _controller.clear();
  }

  TextStyle _getTextStyle() {
    return TextStyle(
      fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
      decoration: _isUnderline ? TextDecoration.underline : TextDecoration.none,
    );
  }

  // Content for each step

  @override
  Widget build(BuildContext context) {
    List<Widget> stepContents = [
      Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SETUP YOUR BASIC PROJECT DETAILS',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colorfile.textColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Enter the title/name of your project along with the basic details you want freelancers to know before bidding on your project.',
              style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colorfile.textColor),
            ),
            SizedBox(height: 8),
            Text(
              'Enter Your Project Name',
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colorfile.textColor),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Enter your project name *',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(0.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        bottom: 12.0), // Optional margin for spacing
                    decoration: BoxDecoration(
                      color: Color(0xFFF1F1F1), // Set the background color here
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFD9D9D9), // Blue bottom border color
                          width: 2.0, // Border thickness
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.format_bold,
                            color: _isBold ? Colors.blue : Colors.black,
                          ),
                          onPressed: _toggleBold,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.format_underline,
                            color: _isUnderline ? Colors.blue : Colors.black,
                          ),
                          onPressed: _toggleUnderline,
                        ),
                        IconButton(
                          icon: Image.asset(
                            'assets/eraser.png', // Replace with the path to your asset image
                            width: 22, // Optional: Set the width of the image
                            height: 22, // Optional: Set the height of the image
                          ),
                          onPressed: _clearText,
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: _getTextStyle(), // Apply formatting here
                      decoration: InputDecoration(
                        // hintText: 'Write your project details here...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
      Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SETUP YOUR BASIC PROJECT DETAILS',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colorfile.textColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Enter the title/name of your project along with the basic details you want freelancers to know before bidding on your project.',
              style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colorfile.textColor),
            ),
            SizedBox(height: 8),
            Text(
              'Choose skills *',
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colorfile.textColor),
            ),
            SizedBox(height: 8),

            // Text Container
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hire freelancer by skills',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Icon(
                    CupertinoIcons.chevron_down, // Dropdown icon
                    color: Colors.grey.shade700, // Icon color
                  ),
                ],
              ),
            ),

            SizedBox(height: 8),
            Text(
              'Example:',
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colorfile.textColor),
            ),
            SizedBox(height: 8),

            Text(
              'For website creation, select "Web Design" or "Web Development," or otherwise choose a specific technology.',
              style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colorfile.textColor),
            ),

            SizedBox(height: 8),
            Text(
              'Other skills *',
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colorfile.textColor),
            ),
            SizedBox(height: 8),

            // Text Container
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Enter other skills, comma-separated',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),

            SizedBox(height: 8),
            Text(
              'Upload project documents (if any)',
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colorfile.textColor),
            ),
            SizedBox(height: 8),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text Container with Button inside it
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Text widget for file upload instruction
                      Text(
                        'Choose files to upload',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      // TextButton with grey border, no elevation, and radius 4
                      TextButton(
                        onPressed: _pickFile,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey,
                          backgroundColor: Colors.transparent, // No background
                          side: BorderSide(
                              color: Colors.grey, width: 1), // Grey border
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4), // Radius 4
                          ),
                        ),
                        child: Text(
                          'Choose File',
                          style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF757575)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
      Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SETUP YOUR BUDGET',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'At last, set up the budget for your project and choose the currency you want to pay in and post your project.',
              style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              'Requirement Type *',
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: requirementType.map((option) {
                int index = requirementType.indexOf(option);
                return Padding(
                  padding: const EdgeInsets.only(
                      right: 10.0), // Adds spacing between items
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        // Toggle selection for the current option
                        selectedRequiredType =
                            (selectedRequiredType == index) ? -1 : index;
                      });
                    },
                    child: Container(
                      width: 100,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: selectedRequiredType == index
                            ? Colors.green // Change color when selected
                            : Color(0xFFFFFFFF), // Default color
                        border: Border.all(
                            color: selectedRequiredType == index
                                ? Colors.white // Blue border when selected
                                : Color(0xFFD9D9D9),
                            width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            option['icon'],
                            color: selectedRequiredType == index
                                ? Colors.white
                                : option['iconColor'], // Set the icon color
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            option['label'],
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: selectedRequiredType == index
                                  ? Colors
                                      .white // Change text color when selected
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 15),
            Text(
              'Select Looking For *',
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: lookingFor.map((option) {
                int index = lookingFor.indexOf(option);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      // Toggle selection for the current option
                      selectedLookingFor =
                          (selectedLookingFor == index) ? -1 : index;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Container(
                      width: 100,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: selectedLookingFor == index
                            ? Colors.green
                            : Color(0xFFFFFFFF), // Default color
                        border: Border.all(
                            color: selectedLookingFor == index
                                ? Colors.white // Blue border when selected
                                : Color(0xFFD9D9D9),
                            width: 1),
                      ),
                      child: option['icon'] != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  option['icon'],
                                  color: selectedLookingFor == index
                                      ? Colors.white
                                      : option[
                                          'iconColor'], // Set the icon color
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  option['label'],
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: selectedLookingFor == index
                                        ? Colors
                                            .white // Change text color when selected
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            )
                          : Center(
                              child: Text(
                                option['label'],
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: selectedLookingFor == index
                                      ? Colors
                                          .white // Change text color when selected
                                      : Colors.black,
                                ),
                              ),
                            ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 15),
            Text(
              'Select Connect Type  *',
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: connecttype.map((option) {
                int index = connecttype.indexOf(option);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      // Toggle selection for the current option
                      selectedConnectType =
                          (selectedConnectType == index) ? -1 : index;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Container(
                      width: 100,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: selectedConnectType == index
                            ? Colors.green // Change color when selected
                            : Color(0xFFFFFFFF), // Default color
                        border: Border.all(
                            color: selectedConnectType == index
                                ? Colors.white // Blue border when selected
                                : Color(0xFFD9D9D9),
                            width: 1),
                      ),
                      child: option['icon'] != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  option['icon'],
                                  color: selectedConnectType == index
                                      ? Colors.white
                                      : option[
                                          'iconColor'], // Set the icon color
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  option['label'],
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: selectedConnectType == index
                                        ? Colors
                                            .white // Change text color when selected
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            )
                          : Center(
                              child: Text(
                                option['label'],
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: selectedConnectType == index
                                      ? Colors
                                          .white // Change text color when selected
                                      : Colors.black,
                                ),
                              ),
                            ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 15),
            Text(
              'How do you want to pay? *',
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .start, // Changed to start for better control of spacing
              children: paymentMode.map((option) {
                int index = paymentMode.indexOf(option);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      // Toggle selection for the current option
                      selectedPaymentType =
                          (selectedPaymentType == index) ? -1 : index;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Container(
                      width: 100,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: selectedPaymentType == index
                            ? Colors.green // Change color when selected
                            : Color(0xFFFFFFFF), // Default color
                        border: Border.all(
                            color: selectedPaymentType == index
                                ? Colors.white // Border color when selected
                                : Color(0xFFD9D9D9),
                            width: 1),
                      ),
                      child: option['icon'] != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  option['icon'],
                                  color: selectedPaymentType == index
                                      ? Colors.white
                                      : option[
                                          'iconColor'], // Set the icon color
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  option['label'],
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: selectedPaymentType == index
                                        ? Colors
                                            .white // Change text color when selected
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            )
                          : Center(
                              child: Text(
                                option['label'],
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: selectedPaymentType == index
                                      ? Colors
                                          .white // Change text color when selected
                                      : Colors.black,
                                ),
                              ),
                            ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 15),
            Text(
              'Enter your project budget  *',
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colorfile.textColor),
            ),
            SizedBox(height: 8),

            // Text Container
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Enter your project budget',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
      Container(
        padding: EdgeInsets.all(16.0),
        color: Colors.purple.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 4: Review and Post',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Review your details and post the project.'),
          ],
        ),
      ),
    ];
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colorfile.body,
        appBar: AppBar(
          backgroundColor: Colorfile.body,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colorfile.textColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Post Project',
            style: GoogleFonts.montserrat(
              color: Colorfile.textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: CupertinoScrollbar(
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isContainerVisible = !_isContainerVisible;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFB7D7F9),
                          Color(0xFFE5ACCB),
                        ],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Why Quickenlancer Is The Best To',
                                  style: GoogleFonts.montserrat(
                                    color: Colorfile.textColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colorfile.textColor,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Transform.rotate(
                                    angle: _isContainerVisible ? 1.57 : 4.72,
                                    child: Icon(
                                      Icons.chevron_left_outlined,
                                      color: Colorfile.textColor,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Quickenlancer offers a swift and effortless project posting method, allowing users to submit their projects.',
                            style: GoogleFonts.montserrat(
                              color: Colorfile.textColor,
                              fontSize: 10,
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFB7D7F9), Color(0xFFE5ACCB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  width: double.infinity,
                  height: _isContainerVisible ? 150 : 0,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Color(0xFFE0E0E0),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFB7D7F9),
                                  Color(0xFFE5ACCB),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: ClipOval(
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Image.asset(
                                  'assets/chat.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            'Verified Freelancer',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 20 / 13,
                              letterSpacing: 0.01,
                              color: Colorfile.textColor,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          subtitle: Text(
                            'Engage with thoroughly vetted and trusted freelancers.',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              height: 20 / 11,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                AnotherStepper(
                  stepperList: [
                    StepperData(
                      iconWidget: Icon(
                        Icons.circle,
                        size: 20,
                        color: Color(0xFF8B3A99),
                      ),
                    ),
                    StepperData(
                      iconWidget: Icon(
                        Icons.circle,
                        size: 20,
                        color: Color(0xFF8B3A99),
                      ),
                    ),
                    StepperData(
                      iconWidget: Icon(
                        Icons.circle,
                        size: 20,
                        color: Color(0xFF8B3A99),
                      ),
                    ),
                  ],
                  stepperDirection: Axis.horizontal,
                  activeBarColor: Color(0xFF8B3A99),
                  inActiveBarColor: Color(0xFFD9D9D9),
                  iconWidth: 18,
                  iconHeight: 20,
                  barThickness: 2,
                  activeIndex: _currentStep,
                ),
                SizedBox(height: 20),
                stepContents[_currentStep],
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // Align to the right
                    children: [
                      if (_currentStep > 0)
                        Container(
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFB7D7F9),
                                Color(0xFFE5ACCB),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _currentStep--;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_back,
                                    color: Colorfile.textColor),
                                SizedBox(width: 8),
                                Text('Previous',
                                    style:
                                        TextStyle(color: Colorfile.textColor)),
                              ],
                            ),
                          ),
                        ),
                      if (_currentStep < stepContents.length - 1)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (_currentStep == 2) {
                                // Navigate to the next page when step is 4
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          NewPage()), // Replace 'NextPage' with your actual page
                                );
                              } else {
                                // Increment the step for other cases
                                _currentStep++;
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF191E3E),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            textStyle: TextStyle(fontSize: 14),
                            fixedSize: Size(113, 42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text('Next'),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
