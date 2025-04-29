import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:quickenlancer_apk/editprofilepage.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/network/uri.dart';
import '../shared_widgets.dart';
import 'package:html/parser.dart' show parse;

class PortfolioFormEdit extends StatefulWidget {
  final String? portfolioId;
  final String? projectName;
  final String? projectUrl;
  final String? projectSkill;
  final String? otherSkills;
  final String? projectDescription;
  final File? projectLogo;
  final String? imageUrl; // New parameter for image URL

  const PortfolioFormEdit({
    Key? key,
    this.portfolioId,
    this.projectName,
    this.projectUrl,
    this.projectSkill,
    this.otherSkills,
    this.projectDescription,
    this.projectLogo,
    this.imageUrl,
  }) : super(key: key);

  @override
  _PortfolioFormState createState() => _PortfolioFormState();
}

class _PortfolioFormState extends State<PortfolioFormEdit> {
  final _projectNameController = TextEditingController();
  final _projectUrlController = TextEditingController();
  String? _projectSkill;
  final _otherSkillsController = TextEditingController();
  final _projectDescriptionController = TextEditingController();
  File? _projectLogo;
  bool _isLoading = false;

  // List to store fetched skills
  List<Map<String, dynamic>> _availableSkills = [];

  @override
  void initState() {
    super.initState();
    // Print constructor items for debugging
    print('PortfolioForm Constructor Items:');
    print('portfolioId: ${widget.portfolioId}');
    print('projectName: ${widget.projectName}');
    print('projectUrl: ${widget.projectUrl}');
    print('projectSkill: ${widget.projectSkill}');
    print('otherSkills: ${widget.otherSkills}');
    print('projectDescription: ${widget.projectDescription}');
    print('projectLogo: ${widget.projectLogo?.path ?? 'null'}');
    print('imageUrl: ${widget.imageUrl ?? 'null'}');

    // Autofill form fields with constructor data
    _projectNameController.text = widget.projectName ?? '';
    _projectUrlController.text = widget.projectUrl ?? '';
    _projectSkill = widget.projectSkill;
    _otherSkillsController.text = widget.otherSkills ?? '';

    // Handle projectDescription: Convert HTML to plain text if present
    if (widget.projectDescription != null &&
        widget.projectDescription!.isNotEmpty) {
      final plainText = _convertHtmlToPlainText(widget.projectDescription!);
      _projectDescriptionController.text = plainText;
    } else {
      _projectDescriptionController.text = '';
    }

    _projectLogo = widget.projectLogo;

    // Fetch skills to validate projectSkill
    _fetchSkills();
  }

  // Function to convert HTML to plain text
  String _convertHtmlToPlainText(String htmlString) {
    try {
      final document = parse(htmlString);
      final String plainText = document.body?.text.trim() ?? '';
      return plainText.replaceAll(RegExp(r'\s+'), ' ');
    } catch (e) {
      print('Error parsing HTML: $e');
      return htmlString.replaceAll(RegExp(r'<[^>]+>'), '').trim();
    }
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
    // Validate form fields
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
    if (_projectSkill == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a project skill')),
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

      // Find the selected skill's ID
      final selectedSkill = _availableSkills
          .firstWhere((skill) => skill['name'] == _projectSkill);
      final skillId = selectedSkill['id'];

      // Prepare form-data
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(URLS().set_portfolio),
      );
      request.headers['Authorization'] = 'Bearer $authToken';
      request.fields['project_name'] = _projectNameController.text;
      request.fields['user_id'] = userId;
      request.fields['project_url'] = _projectUrlController.text;
      request.fields['project_skills'] = jsonEncode([skillId]);
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

      // Print request body
      print('Portfolio Request: POST ${URLS().set_portfolio}');
      print('Portfolio Request Body: ${request.fields}');
      if (_projectLogo != null) {
        print('Portfolio Request File: ${_projectLogo!.path}');
      }

      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      // Print response
      print('Portfolio Response: ${response.statusCode} $responseBody');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project saved successfully')),
        );
        // Navigate to Editprofilepage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Editprofilepage()),
        );

        // Clear form
        setState(() {
          _projectNameController.clear();
          _projectUrlController.clear();
          _projectSkill = null;
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Portfolio',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project Name
                    SharedWidgets.textField(
                      _projectNameController,
                      'Project Name',
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a project name' : null,
                    ),
                    const SizedBox(height: 16),
                    // Project URL
                    SharedWidgets.textField(
                      _projectUrlController,
                      'Project URL',
                      keyboardType: TextInputType.url,
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter a project URL';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Project Skill Dropdown
                    SharedWidgets.dropdown<String>(
                      label: 'Project Skill',
                      value: _projectSkill,
                      items: _availableSkills
                          .map((skill) => skill['name'] as String)
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _projectSkill = value),
                      itemAsString: (String skill) => skill,
                      validator: (value) => value == null
                          ? 'Please select a project skill'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    // Other Skills
                    SharedWidgets.textField(
                      _otherSkillsController,
                      'Other Skills (Optional)',
                    ),
                    const SizedBox(height: 16),
                    // Project Description
                    SharedWidgets.textField(
                      _projectDescriptionController,
                      'Project Description',
                      maxLines: 4,
                      validator: (value) => value!.isEmpty
                          ? 'Please enter a project description'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    // Upload Logo Button
                    StyledButton(
                      text: 'Upload Logo',
                      icon: Icons.upload,
                      onPressed: () => SharedWidgets.pickFile(
                        onFilePicked: (file) =>
                            setState(() => _projectLogo = file),
                        allowedExtensions: ['png', 'jpeg', 'jpg'],
                      ),
                    ),
                    if (_projectLogo != null || widget.imageUrl != null) ...[
                      const SizedBox(height: 12),
                      // Display selected logo file name (if new file uploaded)
                      if (_projectLogo != null)
                        Text(
                          _projectLogo!.path.split('/').last,
                          style: GoogleFonts.montserrat(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 12),
                      // Display logo preview (new file or existing URL)
                      _projectLogo != null
                          ? Image.file(
                              _projectLogo!,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Text('Error loading image'),
                            )
                          : widget.imageUrl != null &&
                                  widget.imageUrl!.isNotEmpty
                              ? Image.network(
                                  widget.imageUrl!,
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                    'assets/test.jpg',
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const SizedBox.shrink(),
                    ],
                    const SizedBox(height: 24),
                    // Save Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
