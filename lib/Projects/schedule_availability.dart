import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../api/network/uri.dart';
import 'all_projects.dart';
import 'posted.dart';

class ScheduleAvailabilityPage extends StatefulWidget {
  final String projectId;

  const ScheduleAvailabilityPage({super.key, required this.projectId});

  @override
  _ScheduleAvailabilityPageState createState() =>
      _ScheduleAvailabilityPageState();
}

class _ScheduleAvailabilityPageState extends State<ScheduleAvailabilityPage> {
  final Map<String, Map<String, Object?>> availability = {
    'Monday': {'enabled': 0, 'from': null, 'to': null},
    'Tuesday': {'enabled': 0, 'from': null, 'to': null},
    'Wednesday': {'enabled': 0, 'from': null, 'to': null},
    'Thursday': {'enabled': 0, 'from': null, 'to': null},
    'Friday': {'enabled': 0, 'from': null, 'to': null},
    'Saturday': {'enabled': 0, 'from': null, 'to': null},
    'Sunday': {'enabled': 0, 'from': null, 'to': null},
  };

  bool isLoading = false;

  // Helper method to compare two TimeOfDay objects
  bool _isTimeAfter(TimeOfDay time1, TimeOfDay time2) {
    final minutes1 = time1.hour * 60 + time1.minute;
    final minutes2 = time2.hour * 60 + time2.minute;
    return minutes1 > minutes2;
  }

  // Handle back navigation with confirmation dialog
  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Confirm',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Are you sure you want to go back? Any unsaved changes will be lost.',
              style: GoogleFonts.poppins(
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AllProjects()),
                  );
                },
                child: Text(
                  'Yes',
                  style: GoogleFonts.poppins(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<void> _selectTime(
      BuildContext context, String day, bool isFrom) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: isFrom
          ? (availability[day]!['from'] as TimeOfDay?) ?? TimeOfDay.now()
          : (availability[day]!['to'] as TimeOfDay?) ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: Colors.blue.shade700,
              dialHandColor: Colors.blue.shade600,
              entryModeIconColor: Colors.blue.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue.shade700,
                textStyle: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      if (!isFrom && availability[day]!['from'] != null) {
        // Validate "to" time is after "from" time
        final TimeOfDay fromTime = availability[day]!['from'] as TimeOfDay;
        if (!_isTimeAfter(selectedTime, fromTime)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'End time must be after start time',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      setState(() {
        if (isFrom) {
          availability[day]!['from'] = selectedTime;
        } else {
          availability[day]!['to'] = selectedTime;
        }
      });
    }
  }

  Future<void> _saveAvailability() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String userId = prefs.getString('user_id') ?? '';
      final String? authToken = prefs.getString('auth_token');

      final Map<String, dynamic> requestBody = {
        'user_id': userId,
        'project_id': widget.projectId,
        'other_skills': '', // Replace with actual skills if needed
        'is_monday': availability['Monday']!['enabled'].toString(),
        'from_monday': availability['Monday']!['from'] != null
            ? (availability['Monday']!['from'] as TimeOfDay).hour
            : 9,
        'to_monday': availability['Monday']!['to'] != null
            ? (availability['Monday']!['to'] as TimeOfDay).hour
            : 9,
        'is_tuesday': availability['Tuesday']!['enabled'].toString(),
        'from_tuesday': availability['Tuesday']!['from'] != null
            ? (availability['Tuesday']!['from'] as TimeOfDay).hour
            : 9,
        'to_tuesday': availability['Tuesday']!['to'] != null
            ? (availability['Tuesday']!['to'] as TimeOfDay).hour
            : 9,
        'is_wednesday': availability['Wednesday']!['enabled'].toString(),
        'from_wednesday': availability['Wednesday']!['from'] != null
            ? (availability['Wednesday']!['from'] as TimeOfDay).hour
            : 9,
        'to_wednesday': availability['Wednesday']!['to'] != null
            ? (availability['Wednesday']!['to'] as TimeOfDay).hour
            : 9,
        'is_thursday': availability['Thursday']!['enabled'].toString(),
        'from_thursday': availability['Thursday']!['from'] != null
            ? (availability['Thursday']!['from'] as TimeOfDay).hour
            : 9,
        'to_thursday': availability['Thursday']!['to'] != null
            ? (availability['Thursday']!['to'] as TimeOfDay).hour
            : 9,
        'is_friday': availability['Friday']!['enabled'].toString(),
        'from_friday': availability['Friday']!['from'] != null
            ? (availability['Friday']!['from'] as TimeOfDay).hour
            : 9,
        'to_friday': availability['Friday']!['to'] != null
            ? (availability['Friday']!['to'] as TimeOfDay).hour
            : 9,
        'is_saturday': availability['Saturday']!['enabled'].toString(),
        'from_saturday': availability['Saturday']!['from'] != null
            ? (availability['Saturday']!['from'] as TimeOfDay).hour
            : 9,
        'to_saturday': availability['Saturday']!['to'] != null
            ? (availability['Saturday']!['to'] as TimeOfDay).hour
            : 9,
        'is_sunday': availability['Sunday']!['enabled'].toString(),
        'from_sunday': availability['Sunday']!['from'] != null
            ? (availability['Sunday']!['from'] as TimeOfDay).hour
            : 9,
        'to_sunday': availability['Sunday']!['to'] != null
            ? (availability['Sunday']!['to'] as TimeOfDay).hour
            : 9,
      };

      // Print request details for debugging
      debugPrint('Request URL: ${URLS().set_project_time_availability}');
      debugPrint('Request Body: ${jsonEncode(requestBody)}');
      debugPrint('Auth Token: ${authToken ?? 'No token'}');

      // Prepare headers with Bearer token if available
      final headers = {
        'Content-Type': 'application/json',
        if (authToken != null && authToken.isNotEmpty)
          'Authorization': 'Bearer $authToken',
      };

      final response = await http.post(
        Uri.parse(URLS().set_project_time_availability),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      // Print response details
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Availability saved successfully!',
                style: GoogleFonts.poppins()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AllProjects()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to save: ${response.statusCode} - ${response.body}',
                style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Set Your Availability',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.blue,
              size: 20,
            ),
            onPressed: () async {
              await _onWillPop();
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          children: availability.keys.map((day) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  availability[day]!['enabled'] =
                                      availability[day]!['enabled'] == 1
                                          ? 0
                                          : 1;
                                  if (availability[day]!['enabled'] == 0) {
                                    availability[day]!['from'] = null;
                                    availability[day]!['to'] = null;
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                transform: Matrix4.identity()
                                  ..scale(availability[day]!['enabled'] == 1
                                      ? 1.0
                                      : 0.98),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: availability[day]!['enabled'] == 1
                                        ? Colors.blue.shade200
                                        : Colors.transparent,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: availability[day]!['enabled'] == 1
                                          ? Colors.blue.shade100
                                              .withOpacity(0.3)
                                          : Colors.black.withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          day,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Transform.scale(
                                          scale: 0.85,
                                          child: Switch(
                                            value:
                                                availability[day]!['enabled'] ==
                                                    1,
                                            activeColor: Colors.blue.shade600,
                                            activeTrackColor:
                                                Colors.blue.shade100,
                                            inactiveThumbColor:
                                                Colors.grey.shade400,
                                            inactiveTrackColor:
                                                Colors.grey.shade200,
                                            onChanged: (value) {
                                              setState(() {
                                                availability[day]!['enabled'] =
                                                    value ? 1 : 0;
                                                if (!value) {
                                                  availability[day]!['from'] =
                                                      null;
                                                  availability[day]!['to'] =
                                                      null;
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (availability[day]!['enabled'] == 1) ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey.shade700,
                                              ),
                                              children: [
                                                const TextSpan(text: 'From: '),
                                                TextSpan(
                                                  text: availability[day]![
                                                              'from'] ==
                                                          null
                                                      ? '--:--'
                                                      : (availability[day]![
                                                                  'from']
                                                              as TimeOfDay)
                                                          .format(context),
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.blue.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                _selectTime(context, day, true),
                                            style: ElevatedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 8),
                                              backgroundColor:
                                                  Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              surfaceTintColor:
                                                  Colors.transparent,
                                              foregroundColor:
                                                  Colors.blue.shade700,
                                              splashFactory:
                                                  InkRipple.splashFactory,
                                              elevation: 0,
                                            ).copyWith(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.transparent),
                                              overlayColor:
                                                  MaterialStateProperty.all(
                                                      Colors.blue.shade100),
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.blue.shade50,
                                                    Colors.blue.shade100,
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 8),
                                              child: Text(
                                                'Select',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.blue.shade700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey.shade700,
                                              ),
                                              children: [
                                                const TextSpan(text: 'To: '),
                                                TextSpan(
                                                  text: availability[day]![
                                                              'to'] ==
                                                          null
                                                      ? '--:--'
                                                      : (availability[day]![
                                                                  'to']
                                                              as TimeOfDay)
                                                          .format(context),
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.blue.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => _selectTime(
                                                context, day, false),
                                            style: ElevatedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 8),
                                              backgroundColor:
                                                  Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              surfaceTintColor:
                                                  Colors.transparent,
                                              foregroundColor:
                                                  Colors.blue.shade700,
                                              splashFactory:
                                                  InkRipple.splashFactory,
                                              elevation: 0,
                                            ).copyWith(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.transparent),
                                              overlayColor:
                                                  MaterialStateProperty.all(
                                                      Colors.blue.shade100),
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.blue.shade50,
                                                    Colors.blue.shade100,
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 8),
                                              child: Text(
                                                'Select',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.blue.shade700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _saveAvailability,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            shadowColor: Colors.black.withOpacity(0.15),
                          ).copyWith(
                            overlayColor:
                                MaterialStateProperty.all(Colors.blue.shade200),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.save,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Save Availability',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
