import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({Key? key}) : super(key: key);

  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  int _currentStep = 0;

  // Controllers and state
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _countryController = TextEditingController();
  String? _state;
  final _cityController = TextEditingController();
  final _designationController = TextEditingController();
  final _mobileController = TextEditingController();
  File? _profileImage;

  String? _selectedSkill;
  final List<String> _skills = [];
  final List<String> _availableSkills = ['Android', 'IOS', 'HTML', 'Core Java'];

  final _projectNameController = TextEditingController();
  final _projectUrlController = TextEditingController();
  String? _projectSkill;
  File? _projectLogo;

  final _languageNameController = TextEditingController();
  double _proficiency = 0.0;
  final List<Map<String, dynamic>> _languages = [];

  File? _certificateFile;
  final _certificationNameController = TextEditingController();
  final List<String> _certifications = [];

  final _experienceController = TextEditingController();

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
    _projectNameController.dispose();
    _projectUrlController.dispose();
    _languageNameController.dispose();
    _certificationNameController.dispose();
    _experienceController.dispose();
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
      labelStyle: TextStyle(color: Colors.grey[600]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF64B5F6)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF1976D2)),
          filled: true,
          fillColor: Color(0xFFF5F5F5), // Light grey background
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1976D2), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
          ),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        style: const TextStyle(fontSize: 16),
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
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        dropdownColor: Colors.white,
      ),
    );
  }

  Widget _button({
    required String text,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // White background
        foregroundColor: const Color(0xFF1976D2), // Blue text
        side:
            const BorderSide(color: Color(0xFF1976D2), width: 2), // Blue border
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: const TextStyle(fontSize: 16),
      ),
      child: Text(text),
    );
  }

  List<Step> _getSteps() {
    return [
      Step(
        title: const Text('Profile'),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
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
              _button(
                text: 'Upload Picture',
                onPressed: () => _pickFile(
                  onFilePicked: (file) => _profileImage = file,
                  allowedExtensions: ['png', 'jpeg', 'jpg'],
                ),
              ),
              if (_profileImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _profileImage!.path.split('/').last,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Skills'),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              _dropdown<String>(
                label: 'Select Skill',
                value: _selectedSkill,
                items: _availableSkills
                    .map((skill) =>
                        DropdownMenuItem(value: skill, child: Text(skill)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSkill = value;
                    if (value != null && !_skills.contains(value)) {
                      _skills.add(value);
                      _selectedSkill = null;
                    }
                  });
                },
              ),
              ..._skills.map((skill) => ListTile(
                    title: Text(skill, style: const TextStyle(fontSize: 16)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setState(() => _skills.remove(skill)),
                    ),
                  )),
            ],
          ),
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Portfolio'),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              _textField(_projectNameController, 'Project Name'),
              _textField(_projectUrlController, 'Project URL',
                  keyboardType: TextInputType.url),
              _dropdown<String>(
                label: 'Project Skill',
                value: _projectSkill,
                items: _skills
                    .map((skill) =>
                        DropdownMenuItem(value: skill, child: Text(skill)))
                    .toList(),
                onChanged: (value) => setState(() => _projectSkill = value),
              ),
              _button(
                text: 'Upload Logo',
                onPressed: () => _pickFile(
                  onFilePicked: (file) => _projectLogo = file,
                  allowedExtensions: ['png', 'jpeg', 'jpg'],
                ),
              ),
              if (_projectLogo != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _projectLogo!.path.split('/').last,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Language'),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              _textField(_languageNameController, 'Language Name'),
              const Text('Proficiency', style: TextStyle(fontSize: 16)),
              Slider(
                value: _proficiency,
                min: 0,
                max: 100,
                divisions: 100,
                label: '${_proficiency.round()}%',
                activeColor: const Color(0xFF64B5F6),
                onChanged: (value) => setState(() => _proficiency = value),
              ),
              _button(
                text: 'Add Language',
                onPressed: () {
                  if (_languageNameController.text.isNotEmpty) {
                    setState(() {
                      _languages.add({
                        'name': _languageNameController.text,
                        'proficiency': _proficiency,
                      });
                      _languageNameController.clear();
                      _proficiency = 0.0;
                    });
                  }
                },
              ),
              ..._languages.map((lang) => ListTile(
                    title: Text(
                      '${lang['name']} (${lang['proficiency'].round()}%)',
                      style: const TextStyle(fontSize: 16),
                    ),
                  )),
            ],
          ),
        ),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Certification'),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              _button(
                text: 'Upload Certificate',
                onPressed: () => _pickFile(
                  onFilePicked: (file) => _certificateFile = file,
                  allowedExtensions: ['png', 'jpeg', 'jpg', 'pdf'],
                ),
              ),
              SizedBox(height: 10),
              if (_certificateFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _certificateFile!.path.split('/').last,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
              _textField(_certificationNameController, 'Certification Name'),
              _button(
                text: 'Add Certification',
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
              ..._certifications.map((cert) => ListTile(
                    title: Text(cert, style: const TextStyle(fontSize: 16)),
                  )),
            ],
          ),
        ),
        isActive: _currentStep >= 4,
        state: _currentStep > 4 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Experience'),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              _textField(_experienceController, 'Experience (Years)',
                  keyboardType: TextInputType.number),
            ],
          ),
        ),
        isActive: _currentStep >= 5,
        state: _currentStep > 5 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Change Password'),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              _textField(_newPasswordController, 'New Password',
                  keyboardType: TextInputType.visiblePassword),
              _textField(_confirmPasswordController, 'Confirm Password',
                  keyboardType: TextInputType.visiblePassword),
            ],
          ),
        ),
        isActive: _currentStep >= 6,
        state: _currentStep > 6 ? StepState.complete : StepState.indexed,
      ),
    ];
  }

  void _onStepContinue() {
    if (_currentStep < _getSteps().length - 1) {
      setState(() => _currentStep += 1);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  void _onStepTapped(int step) {
    setState(() => _currentStep = step);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAFAFAFA),
      appBar: AppBar(
        title: const Text('Update Profile'),
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        onStepTapped: _onStepTapped,
        steps: _getSteps(),
        controlsBuilder: (context, details) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              _button(
                text:
                    _currentStep == _getSteps().length - 1 ? 'Finish' : 'Next',
                onPressed: details.onStepContinue ?? () {},
              ),
              const SizedBox(width: 8),
              if (_currentStep > 0)
                TextButton(
                  onPressed: details.onStepCancel ?? () {},
                  child: Text(
                    'Back',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
