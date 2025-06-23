import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:quickenlancer_apk/api/network/uri.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../editprofilepage.dart';
import '../shared_widgets.dart';

class LanguageForm extends StatefulWidget {
  const LanguageForm({Key? key}) : super(key: key);

  @override
  _LanguageFormState createState() => _LanguageFormState();
}

class _LanguageFormState extends State<LanguageForm> {
  final _languageNameController = TextEditingController();
  double _proficiency = 0.0;
  bool _reading = false;
  bool _writing = false;
  bool _speaking = false;
  bool _isLoading = false;
  final List<Map<String, dynamic>> _languages = [];
  List<Map<String, dynamic>> languages = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    _languageNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchProfileDetails();
  }

  // Fetch profile details from API
  Future<void> _fetchProfileDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final String? authToken = prefs.getString('auth_token');

      if (userId.isEmpty || authToken == null) {
        throw Exception('User ID or auth token is missing');
      }

      final url = Uri.parse(URLS().get_profile_details);
      final body = jsonEncode({'user_id': userId});
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'true') {
          setState(() {
            languages = List<Map<String, dynamic>>.from(
                jsonResponse['data']['languages'] ?? []);
            isLoading = false;
          });
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to fetch data');
        }
      } else {
        throw Exception(
            'Failed to fetch profile details: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching profile details: ${e.toString()}';
      });
      print(errorMessage);
    }
  }

  // Function to map known values to readable strings
  String getKnownAbilities(dynamic known) {
    if (known == null || (known is List && known.isEmpty)) return 'None';

    List<int> knownList = [];

    // If known is a String, split it by commas and convert it to a List<int>
    if (known is String) {
      knownList = known
          .split(',')
          .where((e) => e.isNotEmpty)
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
    }
    // If known is already a List<int>
    else if (known is List<int>) {
      knownList = List<int>.from(known);
    }

    List<String> abilities = [];
    if (knownList.contains(1)) abilities.add("Read");
    if (knownList.contains(2)) abilities.add("Write");
    if (knownList.contains(3)) abilities.add("Speak");

    return abilities.join(", ");
  }

  // Function to handle delete action
  Future<void> deleteLanguage(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    final String? authToken = prefs.getString('auth_token');
    final url = Uri.parse(URLS().user_delete_profile_items);
    final body = jsonEncode({
      'user_id': userId,
      'delete_id': id,
      'delete_item_type': '2',
    });

    setState(() {
      languages.removeWhere((lang) => lang['id'] == id);
    });

    // Check if authToken exists
    if (authToken != null) {
      // Make an API call to delete the language using Bearer token
      final headers = {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      };

      try {
        final response = await http.post(
          url,
          headers: headers,
          body: body,
        );

        if (response.statusCode == 200) {
          print('Language deleted successfully');
        } else {
          print('Failed to delete language: ${response.statusCode}');
        }
      } catch (e) {
        print('Error during deletion: $e');
      }
    } else {
      print('No auth token found');
    }
  }

  // Function to show confirmation dialog before deletion
  Future<void> _confirmDeleteLanguage(String id, String languageName) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Language',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$languageName"?',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await deleteLanguage(id);
    }
  }

  Widget _buildProficiencyMeter(String label, double value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${value.round()}%',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Future<void> _saveForm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final authToken = prefs.getString('auth_token');

      if (userId.isEmpty || authToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User ID or auth token missing',
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

      if (_languages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No language added',
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

      // Take the last language added
      final lang = _languages.last;

      // Prepare JSON body
      final body = {
        'user_id': userId,
        'proficient': lang['proficiency'].round(),
        'language': lang['name'],
        'known': lang['skills'],
        'language_id':
            lang.containsKey('language_id') ? lang['language_id'] : '',
      };

      // Print the request body for debugging
      print('Request Headers: {"Authorization": "Bearer $authToken"}');
      print('Request Body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(URLS().set_languages),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      // Print the response for debugging
      print('Response Status Code: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Language saved successfully')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Editprofilepage(),
          ),
        );
        setState(() {
          _languages.clear();
          _languageNameController.clear();
          _proficiency = 0.0;
          _reading = false;
          _writing = false;
          _speaking = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save language: ${response.body}',
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form to add new language
              SharedWidgets.textField(_languageNameController, 'Language Name'),
              Text(
                'Skills',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              CheckboxListTile(
                title: Text(
                  'Reading',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                value: _reading,
                onChanged: (value) => setState(() => _reading = value!),
                activeColor: Color(0xFF2563EB),
                dense: true,
              ),
              CheckboxListTile(
                title: Text(
                  'Writing',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                value: _writing,
                onChanged: (value) => setState(() => _writing = value!),
                activeColor: Color(0xFF2563EB),
                dense: true,
              ),
              CheckboxListTile(
                title: Text(
                  'Speaking',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                value: _speaking,
                onChanged: (value) => setState(() => _speaking = value!),
                activeColor: Color(0xFF2563EB),
                dense: true,
              ),
              Row(
                children: [
                  Text(
                    'Proficiency',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_proficiency.round()}%',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              Slider(
                value: _proficiency,
                min: 0,
                max: 100,
                divisions: 100,
                label: '${_proficiency.round()}%',
                activeColor: const Color(0xFF2563EB),
                inactiveColor: Colors.grey[300],
                onChanged: (value) => setState(() => _proficiency = value),
              ),
              StyledButton(
                text: 'Add Language',
                icon: Icons.add,
                onPressed: () {
                  if (_languageNameController.text.isNotEmpty &&
                      (_reading || _writing || _speaking)) {
                    final skills = <int>[];
                    if (_reading) skills.add(1);
                    if (_writing) skills.add(2);
                    if (_speaking) skills.add(3);
                    setState(() {
                      _languages.add({
                        'name': _languageNameController.text,
                        'proficiency': _proficiency,
                        'skills': skills,
                      });
                      _languageNameController.clear();
                      _proficiency = 0.0;
                      _reading = false;
                      _writing = false;
                      _speaking = false;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please enter a language name and select at least one skill',
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
                },
              ),
              // Display locally added languages
              if (_languages.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[100]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Languages',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._languages.asMap().entries.map((entry) {
                        final index = entry.key;
                        final lang = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {},
                              hoverColor: Colors.grey[50],
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${lang['name']}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.redAccent,
                                            size: 18,
                                          ),
                                          onPressed: () => setState(
                                              () => _languages.removeAt(index)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    _buildProficiencyMeter(
                                        'Proficiency', lang['proficiency']),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 8,
                                      children: (lang['skills'] as List<int>)
                                          .map((skill) {
                                        final skillName = skill == 1
                                            ? 'Reading'
                                            : skill == 2
                                                ? 'Writing'
                                                : 'Speaking';
                                        return Chip(
                                          label: Text(
                                            skillName,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: Color(0xFF2563EB),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                StyledButton(
                  text: 'Save',
                  icon: Icons.save,
                  onPressed: _saveForm,
                ),
              ],
              // Display existing languages with delete functionality
              if (languages.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Existing Languages',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final language = languages[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12.0),
                      padding: EdgeInsets.all(14.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Language Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  language['language'] ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.translate,
                                        size: 16, color: Colors.grey.shade600),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Abilities: ${getKnownAbilities(language['known'])}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54),
                                        // overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.speed,
                                        size: 16, color: Colors.grey.shade600),
                                    SizedBox(width: 6),
                                    Text(
                                      'Proficiency: ${language['proficient'] ?? 0}%',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Delete button
                          IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: Colors.redAccent),
                            onPressed: () => _confirmDeleteLanguage(
                              language['id'].toString(),
                              language['language'] ?? 'Unknown',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
              ),
            ),
          ),
      ],
    );
  }
}
