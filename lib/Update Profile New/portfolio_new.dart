import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:quickenlancer_apk/editprofilepage.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/network/uri.dart';
import '../Update Profile/shared_widgets.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

// Sample SharedWidgets.textField implementation (if not already defined)
class SharedWidgets {
  static Widget textField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
    String? hintText, // Added hintText parameter
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines ?? 1,
          validator: validator,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: hintText, // Added hintText to InputDecoration
            hintStyle: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.grey[600], // Consistent with app's color scheme
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Color(0xFFD9D9D9),
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Color(0xFFD9D9D9),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Color(0xFFD9D9D9),
                width: 1.0,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  // Placeholder for pickFile (adjust as per your implementation)
  static void pickFile({
    required Function(File) onFilePicked,
    required List<String> allowedExtensions,
  }) {
    // Implement file picker logic here
  }
}

// StyledButton class remains unchanged
class StyledButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final ButtonStyle? style;

  const StyledButton({
    Key? key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: style ??
          ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class PortfolioNew extends StatefulWidget {
  final String? portfolioId;
  const PortfolioNew({Key? key, this.portfolioId}) : super(key: key);

  @override
  _PortfolioFormState createState() => _PortfolioFormState();
}

class _PortfolioFormState extends State<PortfolioNew> {
  final _projectNameController = TextEditingController();
  final _projectUrlController = TextEditingController();
  final List<String> _selectedSkills = [];
  final _otherSkillsController = TextEditingController();
  final _projectDescriptionController = TextEditingController();
  File? _projectLogo;
  bool _isLoading = false;
  List<Map<String, dynamic>> _availableSkills = [];
  static const Color textColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _fetchSkills();
  }

  // _fetchSkills, _saveForm, _showSnackBar, and dispose methods remain unchanged
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
          _showSnackBar('No skills found');
        }
      } else {
        print('Failed to fetch skills: ${response.statusCode}');
        _showSnackBar('Failed to fetch skills');
      }
    } catch (e) {
      print('Error fetching skills: $e');
      _showSnackBar('Error fetching skills');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveForm() async {
    if (_projectNameController.text.isEmpty) {
      _showSnackBar('Please enter a project name');
      return;
    }
    if (_projectUrlController.text.isEmpty) {
      _showSnackBar('Please enter a project URL');
      return;
    }
    if (_selectedSkills.isEmpty) {
      _showSnackBar('Please select at least one project skill');
      return;
    }
    if (_projectDescriptionController.text.isEmpty) {
      _showSnackBar('Please enter a project description');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final String? authToken = prefs.getString('auth_token');

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
        _showSnackBar('Project saved successfully');
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
        _showSnackBar('Failed to save project: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saving portfolio: $e');
      _showSnackBar('Error saving project');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.grey,
      ),
    );
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
              'Portfolio',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Name
                SharedWidgets.textField(
                  _projectNameController,
                  'Project Name',
                  hintText: 'Select Project Name', // Added hint text
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a project name' : null,
                ),
                const SizedBox(height: 12),
                // Project URL
                SharedWidgets.textField(
                  _projectUrlController,
                  'Project URL',
                  hintText: 'Enter Project URL', // Added hint text
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter a project URL';
                    if (!Uri.parse(value).isAbsolute)
                      return 'Please enter a valid URL';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Multi-select skills dropdown with DropdownSearch
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Project Skills',
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownSearch<String>.multiSelection(
                        popupProps: PopupPropsMultiSelection.menu(
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              hintText: 'Search skills...',
                              hintStyle: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: textColor.withOpacity(0.6),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD9D9D9),
                                  width: 1.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD9D9D9),
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD9D9D9),
                                  width: 1.0,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                          fit: FlexFit.loose,
                          menuProps: MenuProps(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Enter Project Skill',
                            labelStyle: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: textColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: Color(0xFFD9D9D9),
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: Color(0xFFD9D9D9),
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: Color(0xFFD9D9D9),
                                width: 1.0,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            suffixIcon: const Icon(
                              CupertinoIcons.chevron_down,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                        items: _availableSkills
                            .map((skill) => skill['name'] as String)
                            .toList(),
                        selectedItems: _selectedSkills,
                        onChanged: (List<String> selected) {
                          setState(() {
                            _selectedSkills.clear();
                            _selectedSkills.addAll(selected);
                          });
                        },
                        validator: (List<String>? value) =>
                            value == null || value.isEmpty
                                ? 'Select at least one skill'
                                : null,
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
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: Colors.blueAccent,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    deleteIcon: const Icon(Icons.close,
                                        size: 18, color: Colors.white70),
                                    onDeleted: () {
                                      setState(() {
                                        _selectedSkills.remove(skill);
                                      });
                                    },
                                    elevation: 3,
                                    shadowColor:
                                        Colors.blueAccent.withOpacity(0.3),
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
                const SizedBox(height: 12),
                // Other Skills
                SharedWidgets.textField(
                  _otherSkillsController,
                  'Other Skills (Optional)',
                  hintText: 'Enter Your Skills', // Added hint text
                ),
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFD9D9D9),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Choose files to upload',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFA5A5A5),
                            ),
                          ),
                          TextButton(
                            onPressed: () => SharedWidgets.pickFile(
                              onFilePicked: (file) =>
                                  setState(() => _projectLogo = file),
                              allowedExtensions: ['png', 'jpeg', 'jpg'],
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                side: const BorderSide(
                                  color: Color(0xFFD9D9D9),
                                  width: 0.6,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Choose File',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF757575),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_projectLogo != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _projectLogo!.path.split('/').last,
                          style: GoogleFonts.montserrat(
                            color: Colors.grey[600],
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Image.file(
                          _projectLogo!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Text('Error loading image'),
                        ),
                      ],
                    ],
                  ),
                ),
                // Project Description
                const SizedBox(height: 12),
                // Upload Logo Container
                SharedWidgets.textField(
                  _projectDescriptionController,
                  'Project Description',
                  hintText:
                      'Describe your project in detail', // Added hint text
                  maxLines: 4,
                  validator: (value) => value!.isEmpty
                      ? 'Please enter a project description'
                      : null,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: StyledButton(
                    text: 'Save',
                    onPressed: _saveForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: textColor,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
