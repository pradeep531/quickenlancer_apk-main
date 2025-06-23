import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:quickenlancer_apk/editprofilepage.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/network/uri.dart';
import '../shared_widgets.dart';

class PortfolioForm extends StatefulWidget {
  final String? portfolioId;
  const PortfolioForm({Key? key, this.portfolioId}) : super(key: key);

  @override
  _PortfolioFormState createState() => _PortfolioFormState();
}

class _PortfolioFormState extends State<PortfolioForm> {
  final _projectNameController = TextEditingController();
  final _projectUrlController = TextEditingController();
  final List<String> _selectedSkills = [];
  final _otherSkillsController = TextEditingController();
  final _projectDescriptionController = TextEditingController();
  File? _projectLogo;
  bool _isLoading = false;
  List<Map<String, dynamic>> _availableSkills = [];

  @override
  void initState() {
    super.initState();
    _fetchSkills();
  }

  Future<void> _fetchSkills() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('auth_token');
      final response = await http.get(
        Uri.parse(URLS().get_skills_api),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );
      print('Skills Request: GET ${URLS().get_skills_api}');
      print('Skills Response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'true' && jsonResponse['data'] != null) {
          setState(() {
            _availableSkills = (jsonResponse['data'] as List)
                .map((skill) => {
                      'name': skill['skill'].toString(),
                      'id': skill['id'].toString(),
                    })
                .toList();
          });
        } else {
          print('No skills found in response');
        }
      } else {
        print('Failed to fetch skills: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching skills: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveForm() async {
    if (_projectNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a project name')),
      );
      return;
    }
    if (_projectUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a project URL')),
      );
      return;
    }
    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select at least one project skill')),
      );
      return;
    }
    if (_projectDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a project description')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final String? authToken = prefs.getString('auth_token');

      // Get IDs for selected skills
      final skillIds = _selectedSkills
          .map((skillName) => _availableSkills
              .firstWhere((skill) => skill['name'] == skillName)['id'])
          .toList();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(URLS().set_portfolio),
      );
      request.headers['Authorization'] = 'Bearer $authToken';
      request.fields['project_name'] = _projectNameController.text;
      request.fields['user_id'] = userId;
      request.fields['project_url'] = _projectUrlController.text;
      request.fields['project_skills'] = jsonEncode(skillIds);
      request.fields['other_skills'] = _otherSkillsController.text;
      request.fields['project_desc'] = _projectDescriptionController.text;
      if (widget.portfolioId != null) {
        request.fields['portfolio_id'] = widget.portfolioId!;
      }
      if (_projectLogo != null) {
        request.files.add(
          await http.MultipartFile.fromPath('logo', _projectLogo!.path),
        );
      }

      print('Portfolio Request: POST ${URLS().set_portfolio}');
      print('Portfolio Request Body: ${request.fields}');
      if (_projectLogo != null) {
        print('Portfolio Request File: ${_projectLogo!.path}');
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Portfolio Response: ${response.statusCode} $responseBody');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project saved successfully')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Editprofilepage()),
        );

        setState(() {
          _projectNameController.clear();
          _projectUrlController.clear();
          _selectedSkills.clear();
          _otherSkillsController.clear();
          _projectDescriptionController.clear();
          _projectLogo = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to save project: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error saving portfolio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving project')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleSkillSelection(String skill) {
    setState(() {
      if (_selectedSkills.contains(skill)) {
        _selectedSkills.remove(skill);
      } else {
        _selectedSkills.add(skill);
      }
    });
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _projectUrlController.dispose();
    _otherSkillsController.dispose();
    _projectDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SharedWidgets.textField(
              _projectNameController,
              'Project Name',
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a project name' : null,
            ),
            SharedWidgets.textField(
              _projectUrlController,
              'Project URL',
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value!.isEmpty) return 'Please enter a project URL';
                if (!Uri.parse(value).isAbsolute)
                  return 'Please enter a valid URL';
                return null;
              },
            ),
            // Multi-select skills dropdown
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Project Skills',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey[900],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey[100]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.grey[300]!, width: 1.5),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Text(
                          'Select skills',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.blueAccent),
                        items: _availableSkills
                            .map((skill) => skill['name'] as String)
                            .toList()
                            .map((skill) => DropdownMenuItem<String>(
                                  value: skill,
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: _selectedSkills.contains(skill),
                                        onChanged: (value) =>
                                            _toggleSkillSelection(skill),
                                        activeColor: Colors.blueAccent,
                                        checkColor: Colors.white,
                                      ),
                                      Expanded(
                                        child: Text(
                                          skill,
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            color: Colors.blueGrey[800],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _toggleSkillSelection(value);
                          }
                        },
                      ),
                    ),
                  ),
                  if (_selectedSkills.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _selectedSkills
                          .map((skill) => Chip(
                                label: Text(
                                  skill,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: Colors.blueAccent,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                deleteIcon: const Icon(Icons.close,
                                    size: 18, color: Colors.white70),
                                onDeleted: () => _toggleSkillSelection(skill),
                                elevation: 3,
                                shadowColor: Colors.blueAccent.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            SharedWidgets.textField(
              _otherSkillsController,
              'Other Skills (Optional, comma-separated)',
            ),
            SharedWidgets.textField(
              _projectDescriptionController,
              'Project Description',
              maxLines: 4,
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a project description' : null,
            ),
            StyledButton(
              text: 'Upload Logo',
              icon: Icons.upload,
              onPressed: () => SharedWidgets.pickFile(
                onFilePicked: (file) => setState(() => _projectLogo = file),
                allowedExtensions: ['png', 'jpeg', 'jpg'],
              ),
            ),
            if (_projectLogo != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _projectLogo!.path.split('/').last,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Image.file(
                  _projectLogo!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Text('Error loading image'),
                ),
              ),
            ],
            const SizedBox(height: 16),
            StyledButton(
              text: 'Save',
              icon: Icons.save,
              onPressed: _saveForm,
            ),
          ],
        ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
