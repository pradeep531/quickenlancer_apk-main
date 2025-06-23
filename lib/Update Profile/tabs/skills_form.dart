import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/network/uri.dart';
import '../../editprofilepage.dart';
import '../shared_widgets.dart';
import 'dart:convert';

class SkillsForm extends StatefulWidget {
  const SkillsForm({Key? key}) : super(key: key);

  @override
  _SkillsFormState createState() => _SkillsFormState();
}

class _SkillsFormState extends State<SkillsForm> {
  Map<String, String>? _selectedSkill;
  final _skillRateController = TextEditingController();
  final List<Map<String, dynamic>> _skills = [];
  List<Map<String, String>> _availableSkills = [];

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
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'true' && responseData['data'] != null) {
          final skillsData = responseData['data']['skills'] as List;
          setState(() {
            _skills.clear();
            for (var skill in skillsData) {
              if (skill['skill_id'] != null &&
                  skill['skill_id'] != 0 &&
                  skill['skill'] != null &&
                  skill['pkey'] != null) {
                _skills.add({
                  'name': skill['skill'].toString(),
                  'pkey': skill['pkey'].toString(),
                  'skill_id': skill['skill_id'].toString(), // Store skill_id
                  'rate': double.tryParse(skill['rate'].toString()) ?? 0.0,
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
      SnackBar(content: Text(message), backgroundColor: Colors.grey),
    );
  }

  Future<void> _saveForm() async {
    if (_skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please add at least one skill before saving',
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

    // Show loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Get user ID and auth token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final String? authToken = prefs.getString('auth_token');

      // Prepare request body as raw JSON
      final Map<String, dynamic> requestBody = {
        'user_id': userId,
        'skill_details': _skills
            .map((skill) => {
                  'skill_id': skill['skill_id'],
                  'rate': skill['rate'].toString(),
                })
            .toList(),
      };

      print('Request Body: $requestBody');

      // Send POST request with raw JSON
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

      // Close the loader
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'true') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Skills saved successfully',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to Editprofilepage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Editprofilepage()),
          );

          // Clear form
          setState(() {
            _skills.clear();
            _selectedSkill = null;
            _skillRateController.clear();
          });
        } else {
          throw Exception('Failed to save skills: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to save skills: ${response.statusCode}');
      }
    } catch (e) {
      // Close the loader
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
  void dispose() {
    _skillRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SharedWidgets.dropdown<Map<String, String>>(
          label: 'Skill',
          value: _selectedSkill,
          items: _availableSkills,
          onChanged: (value) => setState(() => _selectedSkill = value),
          itemAsString: (skill) => skill['name']!,
          validator: (value) => value == null ? 'Select a skill' : null,
        ),
        if (_selectedSkill != null) ...[
          TextField(
            controller: _skillRateController,
            decoration: const InputDecoration(labelText: 'Rate'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          ElevatedButton(
            onPressed: () {
              final rate = double.tryParse(_skillRateController.text) ?? 0.0;
              if (_selectedSkill != null &&
                  !_skills.any(
                      (s) => s['skill_id'] == _selectedSkill!['skill_id'])) {
                setState(() {
                  _skills.add({
                    'name': _selectedSkill!['name']!,
                    'skill_id': _selectedSkill!['skill_id']!,
                    'rate': rate,
                    'pkey': '', // Initialize pkey as empty for new skills
                  });
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
            child: const Text('Add'),
          ),
        ],
        ..._skills.map((skill) {
          return ListTile(
            title: Text(skill['name']),
            subtitle: Text('Rate: ${skill['rate']}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Deletion'),
                    content: Text(
                        'Are you sure you want to delete ${skill['name']}?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  try {
                    // Only call _deleteSkill if pkey exists (for profile skills)
                    if (skill['pkey'].isNotEmpty) {
                      await _deleteSkill(skill['pkey']);
                    }
                    setState(() {
                      _skills.remove(skill);
                    });
                  } catch (e) {
                    // Error already handled in _deleteSkill
                  }
                }
              },
            ),
            dense: true,
          );
        }),
        StyledButton(
          text: 'Save',
          icon: Icons.save,
          onPressed: _saveForm,
        ),
      ],
    );
  }
}
