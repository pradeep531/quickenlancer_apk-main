import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import 'package:quickenlancer_apk/editprofilepage.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import '../../api/network/uri.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

class SharedWidgets {
  static Widget textField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
    String? hintText,
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
            hintText: hintText,
            hintStyle: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: const BorderSide(
                color: Color(0xFFD9D9D9),
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: const BorderSide(
                color: Color(0xFFD9D9D9),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
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

  static Future<void> pickFile({
    required Function(File) onFilePicked,
    required List<String> allowedExtensions,
    BuildContext? context,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        onFilePicked(file);
      } else {
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No file selected',
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
      }
    } catch (e) {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error picking file: $e',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

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
  bool _isBold = false, _isUnderline = false;
  final _formKey = GlobalKey<FormState>();
  final _projectNameController = TextEditingController();
  final _projectUrlController = TextEditingController();
  final List<String> _selectedSkills = [];
  final _otherSkillsController = TextEditingController();
  final _projectDescriptionController = TextEditingController();
  File? _projectLogo;
  bool _isLoading = false;
  List<Map<String, dynamic>> _availableSkills = [];
  static const Color textColor = Colors.black;
// Copyright 2013 The Flutter Authors. All rights reserved.
  String? _descriptionXssError;
  String? _otherSkillsXssError;
  @override
  void initState() {
    super.initState();
    _fetchSkills();
  }

  TextStyle _getTextStyle() => TextStyle(
        fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
        decoration:
            _isUnderline ? TextDecoration.underline : TextDecoration.none,
      );
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
      log('Skills Request: GET ${URLS().get_skills_api}');
      log('Skills Response: ${response.statusCode} ${response.body}');

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
          log('No skills found in response');
          _showSnackBar('No skills found');
        }
      } else {
        log('Failed to fetch skills: ${response.statusCode}');
        _showSnackBar('Failed to fetch skills');
      }
    } catch (e) {
      log('Error fetching skills: $e');
      _showSnackBar('Error fetching skills');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
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

        log('Portfolio Request: POST ${URLS().set_portfolio}');
        log('Portfolio Request Body: ${request.fields}');
        if (_projectLogo != null) {
          log('Portfolio Request File: ${_projectLogo!.path}');
        }

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        log('Portfolio Response: ${response.statusCode} $responseBody');

        if (response.statusCode == 200) {
          _showSnackBar('Project saved successfully');
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const Editprofilepage()),
          // );
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
        log('Error saving portfolio: $e');
        _showSnackBar('Error saving project');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleBold() => setState(() => _isBold = !_isBold);
  void _toggleUnderline() => setState(() => _isUnderline = !_isUnderline);
  void _clearText() => _projectDescriptionController.clear();
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

  bool _containsScriptTag(String input) {
    // Case-insensitive regex to detect <script> tags, including attributes and malformed tags
    final RegExp scriptTag = RegExp(
      r'<\s*script\b[^>]*>(.*?)<\s*/\s*script\s*>|<\s*script\b[^>]*>',
      caseSensitive: false,
      multiLine: true,
    );
    return scriptTag.hasMatch(input);
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
            // centerTitle: true,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SharedWidgets.textField(
                    _projectNameController,
                    'Project Name *',
                    hintText: 'Enter Project Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a project name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SharedWidgets.textField(
                    _projectUrlController,
                    'Project URL',
                    hintText: 'Enter Project URL (e.g., https://example.com)',
                    keyboardType: TextInputType.url,
                    // validator: (value) {
                    //   if (value!.isEmpty) return 'Please enter a project URL';
                    //   if (!Uri.parse(value).isAbsolute)
                    //     return 'Please enter a valid URL';
                    //   return null;
                    // },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Project Skill *',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownSearch<String>.multiSelection(
                    popupProps: PopupPropsMultiSelection.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          hintText: 'Search skills...',
                          hintStyle: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w400,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2.0,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          prefixIcon: Icon(
                            CupertinoIcons.search,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                        ),
                      ),
                      menuProps: MenuProps(
                        borderRadius: BorderRadius.circular(12.0),
                        elevation: 8,
                        backgroundColor: Colors.white,
                      ),
                      itemBuilder: (context, item, isSelected) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.blue.shade50 : Colors.white,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          item,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? Colors.blue.shade700
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Select Project Skills *',
                        labelStyle: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        suffixIcon: const Icon(
                          CupertinoIcons.chevron_down,
                          color: Colors.black87,
                          size: 20,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.0,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2.0,
                          ),
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
                    validator: (List<String>? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select at least one skill';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SharedWidgets.textField(
                    _otherSkillsController,
                    'Other Skills (Optional)',
                    hintText: 'Enter additional skills (comma-separated)',
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Upload Logo',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                'Upload Project Logo',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => SharedWidgets.pickFile(
                                onFilePicked: (file) =>
                                    setState(() => _projectLogo = file),
                                allowedExtensions: ['png', 'jpeg', 'jpg'],
                                context: context,
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                backgroundColor: Colors.blue.shade50,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  side: BorderSide(
                                    color: Colors.blue.shade200,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Choose File',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_projectLogo != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4.0),
                                child: Image.file(
                                  _projectLogo!,
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _projectLogo!.path.split('/').last,
                                  style: GoogleFonts.montserrat(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Project Description',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFF1F1F1),
                            border: Border(
                                bottom: BorderSide(
                                    color: Color(0xFFD9D9D9), width: 2.0)),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                  icon: Icon(Icons.format_bold,
                                      color:
                                          _isBold ? Colors.blue : Colors.black),
                                  onPressed: _toggleBold),
                              IconButton(
                                  icon: Icon(Icons.format_underline,
                                      color: _isUnderline
                                          ? Colors.blue
                                          : Colors.black),
                                  onPressed: _toggleUnderline),
                              IconButton(
                                icon: FaIcon(
                                  FontAwesomeIcons.eraser,
                                  color: Colors.black,
                                  size: 20.0,
                                ),
                                onPressed: _clearText,
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(12.0),
                          child: TextField(
                            controller: _projectDescriptionController,
                            maxLines: 5,
                            keyboardType: TextInputType.multiline,
                            style: _getTextStyle(),
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Describe your project...',
                                errorText: _descriptionXssError,
                                errorStyle: GoogleFonts.montserrat(
                                    fontSize: 12, color: Colors.red)),
                            onChanged: (value) {
                              setState(() {
                                _descriptionXssError = _containsScriptTag(value)
                                    ? 'Script tags are not allowed'
                                    : null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 24),
                  // Text(
                  //   'Project Description',
                  //   style: GoogleFonts.montserrat(
                  //     fontSize: 14,
                  //     fontWeight: FontWeight.w500,
                  //     color: Colors.black87,
                  //   ),
                  // ),
                  // // const SizedBox(height: 16),
                  // SharedWidgets.textField(
                  //   _projectDescriptionController,
                  //   '',
                  //   hintText: 'Describe your project in detail',
                  //   maxLines: 5,
                  //   // validator: (value) => value!.isEmpty
                  //   //     ? 'Please enter a project description'
                  //   //     : null,
                  // ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: StyledButton(
                      text: 'Save',
                      onPressed: _saveForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colorfile.textColor,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
