import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({Key? key}) : super(key: key);

  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  int _currentTab = 0;
  bool _isSidebarExpanded = false;

  // Controllers and state
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _countryController = TextEditingController();
  String? _state;
  final _cityController = TextEditingController();
  final _designationController = TextEditingController();
  final _mobileController = TextEditingController();
  String? _currency;
  final _addressController = TextEditingController();
  File? _profileImage;

  String? _selectedSkill;
  double _skillRating = 1.0;
  final List<Map<String, dynamic>> _skills = [];
  final List<String> _availableSkills = ['Android', 'IOS', 'HTML', 'Core Java'];

  final _projectNameController = TextEditingController();
  final _projectUrlController = TextEditingController();
  String? _projectSkill;
  final _otherSkillsController = TextEditingController();
  final _projectDescriptionController = TextEditingController();
  File? _projectLogo;

  final _languageNameController = TextEditingController();
  double _readingProficiency = 0.0;
  double _writingProficiency = 0.0;
  double _speakingProficiency = 0.0;
  final List<Map<String, dynamic>> _languages = [];

  File? _certificateFile;
  final _certificationNameController = TextEditingController();
  final List<String> _certifications = [];

  final _experienceController = TextEditingController();
  final _experienceDescriptionController = TextEditingController();

  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _designationController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _projectNameController.dispose();
    _projectUrlController.dispose();
    _otherSkillsController.dispose();
    _projectDescriptionController.dispose();
    _languageNameController.dispose();
    _certificationNameController.dispose();
    _experienceController.dispose();
    _experienceDescriptionController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickFile({
    required Function(File?) onFilePicked,
    required List<String> allowedExtensions,
  }) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        onFilePicked(File(result.files.single.path!));
      });
    }
  }

  InputDecoration _textFieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.montserrat(
        color: Colors.grey[600],
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: _textFieldDecoration(label),
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        style: GoogleFonts.montserrat(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: _textFieldDecoration(label),
        items: items,
        onChanged: onChanged,
        style: GoogleFonts.montserrat(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        ),
        dropdownColor: Colors.white,
        icon: const Icon(Icons.arrow_drop_down,
            color: Color(0xFF2563EB), size: 20),
      ),
    );
  }

  Widget _styledButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getTabs() {
    return [
      {
        'title': 'Profile',
        'icon': Icons.person,
        'content': Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _textField(_firstNameController, 'First Name'),
            _textField(_lastNameController, 'Last Name'),
            _textField(_emailController, 'Email',
                keyboardType: TextInputType.emailAddress),
            _textField(_countryController, 'Country'),
            _dropdown<String>(
              label: 'State',
              value: _state,
              items: ['Maharashtra', 'Karnataka', 'Delhi']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => _state = value),
            ),
            _textField(_cityController, 'City'),
            _textField(_designationController, 'Designation'),
            _textField(_mobileController, 'Mobile Number',
                keyboardType: TextInputType.number),
            _dropdown<String>(
              label: 'Currency',
              value: _currency,
              items: ['USD', 'EUR', 'INR']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => _currency = value),
            ),
            _textField(_addressController, 'Address', maxLines: 3),
            _styledButton(
              text: 'Upload Picture',
              icon: Icons.upload,
              onPressed: () => _pickFile(
                onFilePicked: (file) => _profileImage = file,
                allowedExtensions: ['png', 'jpeg', 'jpg'],
              ),
            ),
            if (_profileImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _profileImage!.path.split('/').last,
                  style: GoogleFonts.montserrat(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      },
      {
        'title': 'Skills',
        'icon': Icons.build,
        'content': Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dropdown<String>(
              label: 'Select Skill',
              value: _selectedSkill,
              items: _availableSkills
                  .map((skill) =>
                      DropdownMenuItem(value: skill, child: Text(skill)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedSkill = value),
            ),
            if (_selectedSkill != null) ...[
              Text(
                'Rate your skill (1-5)',
                style: GoogleFonts.montserrat(
                    fontSize: 15, fontWeight: FontWeight.w500),
              ),
              Slider(
                value: _skillRating,
                min: 1,
                max: 5,
                divisions: 4,
                label: _skillRating.round().toString(),
                activeColor: const Color(0xFF2563EB),
                inactiveColor: Colors.grey[300],
                onChanged: (value) => setState(() => _skillRating = value),
              ),
              _styledButton(
                text: 'Add Skill',
                icon: Icons.add,
                onPressed: () {
                  if (_selectedSkill != null &&
                      !_skills.any((s) => s['name'] == _selectedSkill)) {
                    setState(() {
                      _skills.add({
                        'name': _selectedSkill!,
                        'rating': _skillRating.round()
                      });
                      _selectedSkill = null;
                      _skillRating = 1.0;
                    });
                  }
                },
              ),
            ],
            ..._skills.map((skill) => ListTile(
                  title: Text(
                    '${skill['name']} (Rating: ${skill['rating']}/5)',
                    style: GoogleFonts.montserrat(
                        fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete,
                        color: Colors.redAccent, size: 20),
                    onPressed: () => setState(() => _skills.remove(skill)),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                )),
          ],
        ),
      },
      {
        'title': 'Portfolio',
        'icon': Icons.work,
        'content': Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _textField(_projectNameController, 'Project Name'),
            _textField(_projectUrlController, 'Project URL',
                keyboardType: TextInputType.url),
            _dropdown<String>(
              label: 'Project Skill',
              value: _projectSkill,
              items: _skills
                  .map((skill) => DropdownMenuItem<String>(
                        value: skill['name'] as String,
                        child: Text(skill['name'] as String),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _projectSkill = value),
            ),
            _textField(_otherSkillsController, 'Other Skills (Optional)'),
            _textField(_projectDescriptionController, 'Project Description',
                maxLines: 4),
            _styledButton(
              text: 'Upload Logo',
              icon: Icons.upload,
              onPressed: () => _pickFile(
                onFilePicked: (file) => _projectLogo = file,
                allowedExtensions: ['png', 'jpeg', 'jpg'],
              ),
            ),
            if (_projectLogo != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _projectLogo!.path.split('/').last,
                  style: GoogleFonts.montserrat(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      },
      {
        'title': 'Language',
        'icon': Icons.language,
        'content': Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _textField(_languageNameController, 'Language Name'),
            Text(
              'Reading Proficiency',
              style: GoogleFonts.montserrat(
                  fontSize: 15, fontWeight: FontWeight.w500),
            ),
            Slider(
              value: _readingProficiency,
              min: 0,
              max: 100,
              divisions: 100,
              label: '${_readingProficiency.round()}%',
              activeColor: const Color(0xFF2563EB),
              inactiveColor: Colors.grey[300],
              onChanged: (value) => setState(() => _readingProficiency = value),
            ),
            Text(
              'Writing Proficiency',
              style: GoogleFonts.montserrat(
                  fontSize: 15, fontWeight: FontWeight.w500),
            ),
            Slider(
              value: _writingProficiency,
              min: 0,
              max: 100,
              divisions: 100,
              label: '${_writingProficiency.round()}%',
              activeColor: const Color(0xFF2563EB),
              inactiveColor: Colors.grey[300],
              onChanged: (value) => setState(() => _writingProficiency = value),
            ),
            Text(
              'Speaking Proficiency',
              style: GoogleFonts.montserrat(
                  fontSize: 15, fontWeight: FontWeight.w500),
            ),
            Slider(
              value: _speakingProficiency,
              min: 0,
              max: 100,
              divisions: 100,
              label: '${_speakingProficiency.round()}%',
              activeColor: Color(0xFF2563EB),
              inactiveColor: Colors.grey[300],
              onChanged: (value) =>
                  setState(() => _speakingProficiency = value),
            ),
            const SizedBox(height: 12),
            _styledButton(
              text: 'Add Language',
              icon: Icons.add,
              onPressed: () {
                if (_languageNameController.text.isNotEmpty) {
                  setState(() {
                    _languages.add({
                      'name': _languageNameController.text,
                      'reading': _readingProficiency,
                      'writing': _writingProficiency,
                      'speaking': _speakingProficiency,
                    });
                    _languageNameController.clear();
                    _readingProficiency = 0.0;
                    _writingProficiency = 0.0;
                    _speakingProficiency = 0.0;
                  });
                }
              },
            ),
            ..._languages.map((lang) => ListTile(
                  title: Text(
                    '${lang['name']} (Read: ${lang['reading'].round()}%, Write: ${lang['writing'].round()}%, Speak: ${lang['speaking'].round()}%)',
                    style: GoogleFonts.montserrat(
                        fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                )),
          ],
        ),
      },
      {
        'title': 'Certification',
        'icon': Icons.verified,
        'content': Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _styledButton(
              text: 'Upload Certificate',
              icon: Icons.upload,
              onPressed: () => _pickFile(
                onFilePicked: (file) => _certificateFile = file,
                allowedExtensions: ['png', 'jpeg', 'jpg', 'pdf'],
              ),
            ),
            SizedBox(height: 12),
            if (_certificateFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                child: Row(
                  children: [
                    Icon(Icons.description, color: Colors.grey[600], size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _certificateFile!.path.split('/').last,
                        style: GoogleFonts.montserrat(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            _textField(_certificationNameController, 'Certification Name'),
            _styledButton(
              text: 'Add Certification',
              icon: Icons.add,
              onPressed: () {
                if (_certificationNameController.text.isNotEmpty) {
                  setState(() {
                    _certifications.add(_certificationNameController.text);
                    _certificationNameController.clear();
                    _certificateFile = null;
                  });
                }
              },
            ),
            if (_certifications.isNotEmpty) ...[
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
                      'Certifications',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._certifications.asMap().entries.map((entry) {
                      final index = entry.key;
                      final cert = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {},
                            hoverColor: Colors.grey[50],
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.verified,
                                    color: const Color(0xFF2563EB),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      cert,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent, size: 18),
                                    onPressed: () => setState(
                                        () => _certifications.removeAt(index)),
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
            ],
          ],
        ),
      },
      {
        'title': 'Experience',
        'icon': Icons.history,
        'content': Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _textField(_experienceController, 'Experience (Years)',
                keyboardType: TextInputType.number),
            _textField(
                _experienceDescriptionController, 'Experience Description',
                maxLines: 4),
          ],
        ),
      },
      {
        'title': 'Password',
        'icon': Icons.lock,
        'content': Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _textField(_newPasswordController, 'New Password',
                keyboardType: TextInputType.visiblePassword),
            _textField(_confirmPasswordController, 'Confirm Password',
                keyboardType: TextInputType.visiblePassword),
          ],
        ),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _getTabs();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Update Profile',
          style: GoogleFonts.montserrat(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isSidebarExpanded ? Icons.arrow_left : Icons.arrow_right,
              color: Colors.grey[700],
              size: 24,
            ),
            onPressed: () =>
                setState(() => _isSidebarExpanded = !_isSidebarExpanded),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate available width for content area
          final sidebarWidth = _isSidebarExpanded ? 140.0 : 60.0;
          const horizontalPadding = 48.0; // Total padding (24 on each side)
          final availableWidth =
              constraints.maxWidth - sidebarWidth - horizontalPadding;
          // Ensure maxWidth and minWidth are doubles and non-negative
          final maxContentWidth =
              (availableWidth > 300 ? availableWidth : 300).toDouble();
          final minContentWidth =
              (availableWidth > 200 ? 200 : availableWidth).toDouble();

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Sidebar with Collapsible Tabs
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: sidebarWidth,
                color: Colors.white,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: tabs.length,
                        itemBuilder: (context, index) {
                          return Material(
                            color: _currentTab == index
                                ? Colors.grey[100]
                                : Colors.transparent,
                            child: InkWell(
                              onTap: () => setState(() => _currentTab = index),
                              hoverColor: Colors.grey[100],
                              child: ListTile(
                                leading: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Icon(
                                    tabs[index]['icon'],
                                    color: _currentTab == index
                                        ? const Color(0xFF2563EB)
                                        : Colors.grey[600],
                                    size: 22,
                                  ),
                                ),
                                title: _isSidebarExpanded
                                    ? Text(
                                        tabs[index]['title'],
                                        style: GoogleFonts.montserrat(
                                          color: _currentTab == index
                                              ? const Color(0xFF2563EB)
                                              : Colors.grey[800],
                                          fontWeight: _currentTab == index
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      )
                                    : null,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: _isSidebarExpanded ? 12 : 10,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Right Content Area
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: maxContentWidth,
                        minWidth: minContentWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            tabs[_currentTab]['title'],
                            style: GoogleFonts.montserrat(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[100]!),
                            ),
                            child: tabs[_currentTab]['content'],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (_currentTab > 0)
                                TextButton(
                                  onPressed: () =>
                                      setState(() => _currentTab -= 1),
                                  child: Text(
                                    'Back',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 12),
                              _styledButton(
                                text: _currentTab == tabs.length - 1
                                    ? 'Save'
                                    : 'Next',
                                icon: _currentTab == tabs.length - 1
                                    ? Icons.save
                                    : Icons.arrow_forward,
                                onPressed: () {
                                  if (_currentTab < tabs.length - 1) {
                                    setState(() => _currentTab += 1);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Profile updated successfully',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor:
                                            const Color(0xFF2563EB),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
