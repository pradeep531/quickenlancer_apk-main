import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../api/network/uri.dart';
import 'all_projects.dart';
import 'post_project_final.dart';
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
  bool applyToAllDays = false;

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
        if (applyToAllDays) {
          for (var dayKey in availability.keys) {
            if (isFrom) {
              availability[dayKey]!['from'] = selectedTime;
            } else {
              availability[dayKey]!['to'] = selectedTime;
            }
            availability[dayKey]!['enabled'] = 1; // Automatically toggle on
          }
        } else {
          if (isFrom) {
            availability[day]!['from'] = selectedTime;
          } else {
            availability[day]!['to'] = selectedTime;
          }
          availability[day]!['enabled'] = 1; // Automatically toggle on
        }
      });
    }
  }

  void _applyToAllDaysToggle(bool value) {
    setState(() {
      applyToAllDays = value;
      if (value) {
        for (var day in availability.keys) {
          availability[day]!['enabled'] = 1;
        }
      } else {
        for (var day in availability.keys) {
          availability[day]!['enabled'] = 0;
          availability[day]!['from'] = null;
          availability[day]!['to'] = null;
        }
      }
    });
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
        'other_skills': '',
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
          MaterialPageRoute(builder: (context) => const PostProjectFinal()),
        );
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const AllProjects()),
        // );
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
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFFFFF),
          elevation: 0,
          title: Text(
            'Schedule Time',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Placeholder for asset image
                    // Image.asset(
                    //   'assets/schedule.png', // Replace with your actual image path
                    //   height: 150, // Adjust height as needed
                    //   width: double.infinity,
                    //   fit: BoxFit.contain,
                    // ),
                    // const SizedBox(height: 16),
                    Text(
                      'Your Time Availability For This Project *',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colorfile.textColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Apply to All Days',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              Transform.scale(
                                scale: 0.7, // Reduce toggle size
                                child: Switch(
                                  value: applyToAllDays,
                                  onChanged: _applyToAllDaysToggle,
                                  activeColor: Colors.green,
                                  activeTrackColor:
                                      Colors.green.withOpacity(0.3),
                                  inactiveThumbColor: Colors.grey.shade400,
                                  inactiveTrackColor: Colors.grey.shade200,
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            color: Color(0xFFE5E7EB),
                            thickness: 0.5,
                            height: 16,
                          ),
                          ...availability.keys.map((day) {
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          day,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colorfile.textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Transform.scale(
                                      scale: 0.7, // Reduce toggle size
                                      child: Switch(
                                        value:
                                            availability[day]!['enabled'] == 1,
                                        onChanged: (value) {
                                          setState(() {
                                            availability[day]!['enabled'] =
                                                value ? 1 : 0;
                                            if (!value) {
                                              availability[day]!['from'] = null;
                                              availability[day]!['to'] = null;
                                            } else if (applyToAllDays) {
                                              availability[day]!['from'] =
                                                  availability['Monday']![
                                                      'from'];
                                              availability[day]!['to'] =
                                                  availability['Monday']!['to'];
                                            }
                                          });
                                        },
                                        activeColor: Colors.green,
                                        activeTrackColor:
                                            Colors.green.withOpacity(0.3),
                                        inactiveThumbColor:
                                            Colors.grey.shade400,
                                        inactiveTrackColor:
                                            Colors.grey.shade200,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  color: Color(0xFFE5E7EB),
                                  thickness: 0.5,
                                  height: 16,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () =>
                                          _selectTime(context, day, true),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFFFFF),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              availability[day]!['from'] == null
                                                  ? 'Select Time'
                                                  : (availability[day]!['from']
                                                          as TimeOfDay)
                                                      .format(context),
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: availability[day]![
                                                            'from'] ==
                                                        null
                                                    ? Colorfile.textColor
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.grey,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'To',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          _selectTime(context, day, false),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFFFFF),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              availability[day]!['to'] == null
                                                  ? 'Select Time'
                                                  : (availability[day]!['to']
                                                          as TimeOfDay)
                                                      .format(context),
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color:
                                                    availability[day]!['to'] ==
                                                            null
                                                        ? Colorfile.textColor
                                                        : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.grey,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveAvailability,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colorfile.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    'SUBMIT',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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
