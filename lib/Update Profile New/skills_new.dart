import 'dart:developer';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/network/uri.dart';
import '../../editprofilepage.dart';
import 'dart:convert';

class SkillsNew extends StatefulWidget {
  const SkillsNew({Key? key}) : super(key: key);

  @override
  _SkillsNewState createState() => _SkillsNewState();
}

class _SkillsNewState extends State<SkillsNew> {
  Map<String, String>? _selectedSkill;
  final _skillRateController = TextEditingController();
  final List<Map<String, dynamic>> _skills = [];
  List<Map<String, String>> _availableSkills = [];
  bool _hasNewSkill = false; // Track if a new skill is added from dropdown

  @override
  void initState() {
    super.initState();
    _fetchSkills();
    _fetchProfileDetails();
  }

  Future<void> _fetchSkills() async {
    try {
      final response = await http.get(Uri.parse(URLS().get_skills_api));
      print('Fetch Skills API Response:');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('Parsed JSON Response: $jsonResponse');

        if (jsonResponse['status'] == 'true' && jsonResponse['data'] != null) {
          setState(() {
            _availableSkills = (jsonResponse['data'] as List)
                .map((skill) => {
                      'name': skill['skill'].toString(),
                      'skill_id': skill['id'].toString(),
                    })
                .toList();
          });
          print('Available Skills: $_availableSkills');
        } else {
          _showSnackBar('No skills found');
          print('No skills found in response: $jsonResponse');
        }
      } else {
        _showSnackBar('Failed to fetch skills');
        print('Failed to fetch skills: Status ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Error fetching skills');
      print('Error fetching skills: $e');
    }
  }

  Future<void> _fetchProfileDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final String? authToken = prefs.getString('auth_token');

      final url = Uri.parse(URLS().get_profile_details);
      final body = jsonEncode({'user_id': userId});

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        log('Response body: ${response.body}');

        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'true' && responseData['data'] != null) {
          final skillsData = responseData['data']['skills'] as List;
          log('Skills Data from API: $skillsData'); // Debug: Log API skills data
          setState(() {
            _skills.clear();
            _hasNewSkill = false; // Ensure API-fetched skills don't enable Save
            for (var skill in skillsData) {
              if (skill['skill_id'] != null &&
                  skill['skill_id'] != 0 &&
                  skill['skill'] != null &&
                  skill['pkey'] != null) {
                _skills.add({
                  'name': skill['skill'].toString(),
                  'pkey': skill['pkey'].toString(),
                  'skill_id': skill['skill_id'].toString(),
                  'rate': double.tryParse(skill['rate'].toString()) ?? 0.0,
                  'isNew': false, // Mark API-fetched skills as not new
                });
              } else {
                print('Skipping invalid skill: $skill');
              }
            }
          });
          if (_skills.isEmpty) {
            _showSnackBar('No valid skills found in profile');
          }
        } else {
          _showSnackBar('No profile data');
        }
      } else {
        _showSnackBar('Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching profile: $e');
      _showSnackBar('Error fetching profile');
    }
  }

  Future<void> _deleteSkill(String skillPkey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final String? authToken = prefs.getString('auth_token');

      if (skillPkey.isEmpty) {
        _showSnackBar('Cannot delete skill: Invalid skill key');
        return;
      }

      final url = Uri.parse(URLS().user_delete_profile_items);
      final body = jsonEncode({
        'user_id': userId,
        'delete_id': skillPkey,
        'delete_item_type': '3',
      });

      print('Delete Skill Request:');
      print('URL: $url');
      print('Headers: {'
          '\'Content-Type\': \'application/json\', '
          '${authToken != null ? '\'Authorization\': \'Bearer $authToken\'' : ''}}');
      log('Body: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: body,
      );

      print('Delete Skill Response:');
      print('Status Code: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'true') {
          _showSnackBar('Skill deleted successfully');
        } else {
          throw Exception('Failed to delete skill: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to delete skill: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting skill with pkey $skillPkey: $e');
      _showSnackBar('Error deleting skill: $e');
      rethrow;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blueGrey,
        behavior: SnackBarBehavior.floating, // makes it float
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.black12),
        ),
        elevation: 8, // adds shadow, available in newer Flutter versions
      ),
    );
  }

  Future<void> _saveForm() async {
    // Filter only newly added skills
    final newSkills = _skills.where((skill) => skill['isNew'] == true).toList();
    if (newSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please add at least one new skill before saving',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final String? authToken = prefs.getString('auth_token');

      final Map<String, dynamic> requestBody = {
        'user_id': userId,
        'skill_details': newSkills
            .map((skill) => {
                  'skill_id': skill['skill_id'],
                  'rate': skill['rate'].toString(),
                })
            .toList(),
      };

      print('Request Body (New Skills Only): $requestBody');

      final response = await http.post(
        Uri.parse(URLS().set_skills),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(requestBody),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'true') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'New skills saved successfully',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SkillsNew()),
          );

          setState(() {
            // Remove only the saved new skills
            _skills.removeWhere((skill) => skill['isNew'] == true);
            _selectedSkill = null;
            _skillRateController.clear();
            _hasNewSkill = false; // Reset after saving
          });
        } else {
          throw Exception('Failed to save skills: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to save skills: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving skills: $e',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Skills list in build: $_skills'); // Debug: Log the skills list
    print(
        'Skills isEmpty: ${_skills.isEmpty}'); // Debug: Check if skills is empty
    print('Has new skill: $_hasNewSkill'); // Debug: Check new skill flag

    const Color textColor = Colors.black; // Define textColor (adjust as needed)
    const String currency = ''; // Define currency (adjust as needed)

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFD9D9D9),
                width: 1.0,
              ),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Skills',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Select Skill",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            DropdownSearch<Map<String, String>>(
              popupProps: const PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: 'Search skills...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(
                        color: Color(0xFFD9D9D9),
                        width: 1.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(
                        color: Color(0xFFD9D9D9),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(
                        color: Color(0xFFD9D9D9),
                        width: 1.0,
                      ),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                fit: FlexFit.loose,
                menuProps: MenuProps(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: 'Select Skill',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(
                      color: Color(0xFFD9D9D9),
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(
                      color: Color(0xFFD9D9D9),
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(
                      color: Color(0xFFD9D9D9),
                      width: 1.0,
                    ),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  suffixIcon: Icon(
                    CupertinoIcons.chevron_down,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
              items: _availableSkills,
              itemAsString: (Map<String, String>? skill) =>
                  skill?['name'] ?? '',
              selectedItem: _selectedSkill,
              onChanged: (Map<String, String>? value) {
                setState(() {
                  _selectedSkill = value;
                });
              },
              validator: (Map<String, String>? value) =>
                  value == null ? 'Select a skill' : null,
            ),
            if (_selectedSkill != null) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _skillRateController,
                decoration: InputDecoration(
                  labelText: 'Cost (USD)',
                  hintText: 'Enter cost in USD',
                  filled: true,
                  fillColor: Colors.white, // Plain white background
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  labelStyle: TextStyle(color: Colors.grey),
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color(0xFFD9D9D9),
                        width: 1.5), // You can customize this color
                    borderRadius: BorderRadius.circular(4),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    final rate =
                        double.tryParse(_skillRateController.text) ?? 0.0;
                    if (_selectedSkill != null &&
                        !_skills.any((s) =>
                            s['skill_id'] == _selectedSkill!['skill_id'])) {
                      setState(() {
                        _skills.add({
                          'name': _selectedSkill!['name']!,
                          'skill_id': _selectedSkill!['skill_id']!,
                          'rate': rate,
                          'pkey': '',
                          'isNew': true,
                        });
                        _hasNewSkill = true;
                        _selectedSkill = null;
                        _skillRateController.clear();
                      });
                    } else {
                      _showSnackBar(
                        _selectedSkill == null
                            ? 'Select a skill'
                            : 'Skill already added',
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colorfile.textColor,
                    foregroundColor: Colors.white,
                    elevation: 6,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Add'),
                ),
              )
            ],
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(
                    color: const Color(0xFFD9D9D9),
                    width: 1,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(3),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(1),
                  },
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(color: Color(0xFFF5F7FA)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            'Skill',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: textColor,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            'Cost',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: textColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            'Action',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: textColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    ..._skills.map((skill) => TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  if (skill['name'] == 'Hibernate')
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.blue,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  Text(
                                    skill['name'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colorfile.textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                '$currency ${skill['rate'].toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colorfile.textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            IconButton(
                              icon: Image.asset(
                                'assets/delete_icon.png',
                                width: 14,
                                height: 14,
                                color: Colorfile.textColor,
                              ),
                              onPressed: () async {
                                final bool? confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: Text(
                                      'Confirm Deletion',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colorfile.textColor,
                                      ),
                                    ),
                                    content: Text(
                                      'Are you sure you want to delete ${skill['name']}?',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    actionsPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    actions: [
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.grey[700],
                                        ),
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colorfile.textColor,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  try {
                                    if (skill['pkey'].isNotEmpty) {
                                      await _deleteSkill(skill['pkey']);
                                    }
                                    setState(() {
                                      _skills.remove(skill);
                                      _hasNewSkill = _skills
                                          .any((s) => s['isNew'] == true);
                                    });
                                  } catch (e) {
                                    // Error handled in _deleteSkill
                                  }
                                }
                              },
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _hasNewSkill ? _saveForm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _hasNewSkill ? Colorfile.textColor : Colors.grey[400],
                  disabledBackgroundColor: Colors.grey[400],
                  disabledForegroundColor: Colors.grey[600],
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                child: Text(
                  'Save',
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
    );
  }
}
