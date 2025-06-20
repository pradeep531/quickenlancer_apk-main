import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:another_stepper/another_stepper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Projects/all_projects.dart';
import '../Projects/schedule_availability.dart';
import '../api/network/uri.dart'; // Adjust import path as needed
import 'package:quickenlancer_apk/Colors/colorfile.dart'; // Adjust import path as needed

class PostProject extends StatefulWidget {
  @override
  _PostProjectState createState() => _PostProjectState();
}

class _PostProjectState extends State<PostProject> {
  bool _isContainerVisible = false;
  int _currentStep = 0;
  bool _isSubmitting = false;
  List<Map<String, dynamic>> allSkills = [], skillSuggestions = [];
  List<Map<String, dynamic>> availableCurrencies = [];
  final TextEditingController _skillsSearchController = TextEditingController();
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _otherSkillsController = TextEditingController();
  final TextEditingController _projectCostController = TextEditingController();
  List<int> selectedSkillIds = [];
  List<String> _otherSkills = [];
  bool isLoadingSkills = false;
  bool isLoadingCurrencies = false;
  bool _isBold = false, _isUnderline = false;
  List<PlatformFile> _files = [];
  Map<String, dynamic>? selectedCurrency;

  // Validation error flags
  String? _projectNameError;
  String? _skillsError;
  String? _otherSkillsError;
  String? _projectCostError;
  String? _currencyError;
  String? _requirementTypeError;
  String? _lookingForError;
  String? _connectTypeError;
  String? _paymentTypeError;
  String? _skillsSearchXssError;
  String? _projectNameXssError;
  String? _descriptionXssError;
  String? _otherSkillsXssError;

  int selectedRequiredType = -1,
      selectedLookingFor = -1,
      selectedConnectType = -1,
      selectedPaymentType = -1;

  final List<Map<String, dynamic>> options = [
    {
      'type': 'requirementType',
      'label': 'Requirement Type *',
      'items': [
        {'label': 'Cold', 'icon': Icons.ac_unit, 'iconColor': Colors.blue},
        {
          'label': 'Hot',
          'icon': Icons.local_fire_department,
          'iconColor': Colors.orange
        },
      ]
    },
    {
      'type': 'lookingFor',
      'label': 'Select Looking For *',
      'items': [
        {'label': 'Company', 'iconColor': Colors.blue},
        {'label': 'Freelancer', 'iconColor': Colors.orange},
        {'label': 'Both'},
      ]
    },
    {
      'type': 'connectType',
      'label': 'Select Connect Type *',
      'items': [
        {'label': 'Chat'},
        {'label': 'Call'},
        {
          'label': 'Both',
          'icon': Icons.local_fire_department,
          'iconColor': Colors.orange
        },
      ]
    },
    {
      'type': 'paymentMode',
      'label': 'How do you want to pay? *',
      'items': [
        {'label': 'Fixed Rate', 'iconColor': Colors.orange},
        {'label': 'Hourly Rate'},
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchSkills();
    _fetchCurrencies();
    _otherSkillsController.addListener(_updateOtherSkills);
  }

  @override
  void dispose() {
    _otherSkillsController.removeListener(_updateOtherSkills);
    _otherSkillsController.dispose();
    _skillsSearchController.dispose();
    _projectNameController.dispose();
    _descriptionController.dispose();
    _projectCostController.dispose();
    super.dispose();
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

  void _updateOtherSkills() {
    setState(() {
      final input = _otherSkillsController.text;
      _otherSkills = input
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      _otherSkillsXssError =
          _containsScriptTag(input) ? 'Script tags are not allowed' : null;
    });
  }

  Future<void> _fetchSkills() async {
    setState(() => isLoadingSkills = true);
    try {
      final response = await http.get(Uri.parse(URLS().get_skills_api),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200 &&
          jsonDecode(response.body)['status'] == 'true') {
        setState(() {
          allSkills = skillSuggestions =
              (jsonDecode(response.body)['data'] as List)
                  .cast<Map<String, dynamic>>();
        });
      } else {
        _showSnackBar('Failed to load skills');
      }
    } catch (_) {
      _showSnackBar('Error fetching skills');
    } finally {
      setState(() => isLoadingSkills = false);
    }
  }

  Future<void> _fetchCurrencies() async {
    setState(() => isLoadingCurrencies = true);
    try {
      final response = await http.get(Uri.parse(URLS().get_currency_api),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200 &&
          jsonDecode(response.body)['status'] == 'true') {
        setState(() => availableCurrencies =
            (jsonDecode(response.body)['data'] as List)
                .cast<Map<String, dynamic>>());
      } else {
        _showSnackBar('Failed to load currencies');
      }
    } catch (_) {
      _showSnackBar('Error fetching currencies');
    } finally {
      setState(() => isLoadingCurrencies = false);
    }
  }

  bool _validateStep(int step) {
    bool isValid = true;
    setState(() {
      _projectNameError = null;
      _skillsError = null;
      _projectCostError = null;
      _currencyError = null;
      _requirementTypeError = null;
      _lookingForError = null;
      _connectTypeError = null;
      _paymentTypeError = null;
      _projectNameXssError = null;
      _descriptionXssError = null;
      _otherSkillsXssError = null;

      if (_containsScriptTag(_projectNameController.text)) {
        _projectNameXssError = 'Script tags are not allowed';
        isValid = false;
      }
      if (_containsScriptTag(_descriptionController.text)) {
        _descriptionXssError = 'Script tags are not allowed';
        isValid = false;
      }
      if (_containsScriptTag(_otherSkillsController.text)) {
        _otherSkillsXssError = 'Script tags are not allowed';
        isValid = false;
      }

      if (step == 0) {
        if (_projectNameController.text.isEmpty) {
          _projectNameError = 'Project name is required';
          isValid = false;
        }
      } else if (step == 1) {
        if (selectedSkillIds.isEmpty) {
          _skillsError = 'At least one skill is required';
          isValid = false;
        }
      } else if (step == 2) {
        if (_projectCostController.text.isEmpty) {
          _projectCostError = 'Project budget is required';
          isValid = false;
        }
        if (selectedCurrency == null) {
          _currencyError = 'Currency is required';
          isValid = false;
        }
        if (selectedRequiredType == -1) {
          _requirementTypeError = 'Requirement type is required';
          isValid = false;
        }
        if (selectedLookingFor == -1) {
          _lookingForError = 'Looking for is required';
          isValid = false;
        }
        if (selectedConnectType == -1) {
          _connectTypeError = 'Connect type is required';
          isValid = false;
        }
        if (selectedPaymentType == -1) {
          _paymentTypeError = 'Payment mode is required';
          isValid = false;
        }
      } else if (step == 3) {
        if (_projectNameController.text.isEmpty) {
          _projectNameError = 'Project name is required';
          isValid = false;
        }
        if (selectedSkillIds.isEmpty) {
          _skillsError = 'At least one skill is required';
          isValid = false;
        }
        if (_projectCostController.text.isEmpty) {
          _projectCostError = 'Project budget is required';
          isValid = false;
        }
        if (selectedCurrency == null) {
          _currencyError = 'Currency is required';
          isValid = false;
        }
        if (selectedRequiredType == -1) {
          _requirementTypeError = 'Requirement type is required';
          isValid = false;
        }
        if (selectedLookingFor == -1) {
          _lookingForError = 'Looking for is required';
          isValid = false;
        }
        if (selectedConnectType == -1) {
          _connectTypeError = 'Connect type is required';
          isValid = false;
        }
        if (selectedPaymentType == -1) {
          _paymentTypeError = 'Payment mode is required';
          isValid = false;
        }
      }
    });
    return isValid;
  }

  Future<void> _submitProject() async {
    if (!_validateStep(3)) {
      _showSnackBar(
          'Please fill all required fields and remove any script tags');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('auth_token');
      final String userId = prefs.getString('user_id') ?? '';

      if (authToken == null || authToken.isEmpty) {
        _showSnackBar('Auth token not found. Please log in again.');
        setState(() => _isSubmitting = false);
        return;
      }

      final otherSkillsFormatted = '[${_otherSkills.join(',')}]';
      final Map<String, dynamic> projectBody = {
        "user_id": userId,
        "newSkill": selectedSkillIds,
        "other_skills": otherSkillsFormatted,
        "project_name": _projectNameController.text,
        "description": _descriptionController.text,
        "currency": selectedCurrency?['id'].toString() ?? '2',
        "requirement_type": selectedRequiredType == 0 ? "0" : "1",
        "looking_for": (selectedLookingFor + 1).toString(),
        "project_type": selectedPaymentType == 0 ? "0" : "1",
        "project_cost": _projectCostController.text,
        "connect_type": (selectedConnectType + 1).toString(),
      };

      print('Project Request Body: ${jsonEncode(projectBody)}');
      log(authToken);
      final projectResponse = await http.post(
        Uri.parse(URLS().post_project),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(projectBody),
      );

      log('Project Response Body: ${projectResponse.body}');

      if (projectResponse.statusCode == 200) {
        final projectData = jsonDecode(projectResponse.body);
        if (projectData['status'] == 'true') {
          final String projectId = projectData['data']['project_id'].toString();

          if (_files.isNotEmpty) {
            final documentRequest = http.MultipartRequest(
              'POST',
              Uri.parse(URLS().post_project_documents),
            );
            documentRequest.headers['Authorization'] = 'Bearer $authToken';
            documentRequest.fields['user_id'] = userId;
            documentRequest.fields['project_id'] = projectId;

            for (var file in _files) {
              if (file.bytes != null) {
                documentRequest.files.add(
                  http.MultipartFile.fromBytes(
                    'project_documents[]',
                    file.bytes!,
                    filename: file.name,
                  ),
                );
              } else if (file.path != null) {
                documentRequest.files.add(
                  await http.MultipartFile.fromPath(
                    'project_documents[]',
                    file.path!,
                    filename: file.name,
                  ),
                );
              }
            }

            print('Document Request Fields: ${documentRequest.fields}');
            print(
                'Document Request Files: ${documentRequest.files.map((f) => f.filename).toList()}');

            final documentResponse = await documentRequest.send();
            final documentResponseBody =
                await http.Response.fromStream(documentResponse);

            log('Document Response Body: ${documentResponseBody.body}');

            if (documentResponse.statusCode == 200) {
              final documentData = jsonDecode(documentResponseBody.body);
              if (documentData['status'] == 'true') {
                _showSnackBar('Project and documents posted successfully!');
              } else {
                _showSnackBar(
                    'Project posted, but failed to upload documents: ${documentData['message']}');
              }
            } else {
              _showSnackBar(
                  'Project posted, but document upload failed: ${documentResponse.statusCode}');
            }
          } else {
            _showSnackBar('Project posted successfully!');
          }

          setState(() => _isSubmitting = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ScheduleAvailabilityPage(projectId: projectId),
            ),
          );
        } else {
          _showSnackBar('Failed to post project: ${projectData['message']}');
          setState(() => _isSubmitting = false);
        }
      } else {
        _showSnackBar(
            'Error: ${projectResponse.statusCode} - ${projectResponse.reasonPhrase}');
        setState(() => _isSubmitting = false);
      }
    } catch (e) {
      _showSnackBar('Error posting project: $e');
      setState(() => _isSubmitting = false);
    }
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );
    if (result != null) {
      setState(() {
        _files.addAll(result.files);
      });
    }
  }

  void _removeFile(PlatformFile file) {
    setState(() {
      _files.remove(file);
    });
  }

  void _removeOtherSkill(String skill) {
    setState(() {
      _otherSkills.remove(skill);
      _otherSkillsController.text = _otherSkills.join(', ');
      if (_otherSkills.isNotEmpty) _otherSkillsError = null;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _toggleBold() => setState(() => _isBold = !_isBold);
  void _toggleUnderline() => setState(() => _isUnderline = !_isUnderline);
  void _clearText() => _descriptionController.clear();

  void _showSkillsDialog() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setDialogState) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                TextField(
                  controller: _skillsSearchController,
                  decoration: InputDecoration(
                    hintText: 'Search skills...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    suffixIcon: _skillsSearchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              setDialogState(() {
                                _skillsSearchController.clear();
                                _onSkillsSearchChanged('');
                              });
                            },
                          )
                        : null,
                    errorText: _skillsSearchXssError,
                    errorStyle:
                        GoogleFonts.montserrat(fontSize: 12, color: Colors.red),
                  ),
                  onChanged: (value) {
                    setDialogState(() {
                      _onSkillsSearchChanged(value);
                      _skillsSearchXssError = _containsScriptTag(value)
                          ? 'Script tags are not allowed'
                          : null;
                    });
                  },
                ),
                SizedBox(height: 16),
                Expanded(
                  child: isLoadingSkills
                      ? Center(child: CircularProgressIndicator())
                      : skillSuggestions.isEmpty
                          ? Center(child: Text('No skills found'))
                          : ListView.builder(
                              itemCount: skillSuggestions.length,
                              itemBuilder: (_, index) {
                                final skill = skillSuggestions[index];
                                final isSelected = selectedSkillIds.contains(
                                    int.parse(skill['id'].toString()));
                                return CheckboxListTile(
                                  title: Text(skill['skill'],
                                      style:
                                          GoogleFonts.montserrat(fontSize: 14)),
                                  value: isSelected,
                                  onChanged: (_) {
                                    setDialogState(() => _toggleSkill(skill));
                                    setState(() {});
                                  },
                                );
                              },
                            ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1A1A1A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text('Done',
                      style: GoogleFonts.montserrat(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _toggleSkill(Map<String, dynamic> skill) {
    setState(() {
      final skillId = int.parse(skill['id'].toString());
      if (selectedSkillIds.contains(skillId)) {
        selectedSkillIds.remove(skillId);
      } else {
        selectedSkillIds.add(skillId);
      }
      _skillsError = null;
    });
  }

  void _onSkillsSearchChanged(String query) {
    setState(() => skillSuggestions = query.isEmpty
        ? allSkills
        : allSkills
            .where((skill) => skill['skill']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList());
  }

  Widget _buildSkillsSection() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose skills *',
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colorfile.textColor)),
          SizedBox(height: 8),
          GestureDetector(
            onTap: _showSkillsDialog,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color:
                        _skillsError != null ? Colors.red : Color(0xFFE0E0E0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedSkillIds.isEmpty
                        ? 'Hire freelancer by skills'
                        : '${selectedSkillIds.length} skill(s) selected',
                    style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: selectedSkillIds.isEmpty
                            ? Color(0xFF999999)
                            : Color(0xFF1A1A1A)),
                  ),
                  Icon(Icons.arrow_drop_down, color: Color(0xFF666666)),
                ],
              ),
            ),
          ),
          if (_skillsError != null)
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                _skillsError!,
                style: GoogleFonts.montserrat(fontSize: 12, color: Colors.red),
              ),
            ),
          if (selectedSkillIds.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedSkillIds.map((skillId) {
                  final skill = allSkills.firstWhere(
                      (s) => int.parse(s['id'].toString()) == skillId,
                      orElse: () => {'skill': 'Unknown', 'id': skillId});
                  return Chip(
                    label: Text(skill['skill'],
                        style: GoogleFonts.montserrat(
                            fontSize: 12, color: Colors.white)),
                    backgroundColor: Color(0xFF1A1A1A),
                    deleteIcon:
                        Icon(Icons.close, size: 18, color: Colors.white),
                    onDeleted: () =>
                        setState(() => selectedSkillIds.remove(skillId)),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOtherSkillsSection() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Other skills',
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colorfile.textColor)),
          SizedBox(height: 8),
          TextField(
            controller: _otherSkillsController,
            decoration: InputDecoration(
              hintText: 'Enter other skills, e.g., Python, Java, UX Design',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: _otherSkillsXssError != null
                        ? Colors.red
                        : Colors.grey.shade300),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              errorText: _otherSkillsXssError,
              errorStyle:
                  GoogleFonts.montserrat(fontSize: 12, color: Colors.red),
            ),
            onChanged: (value) {
              setState(() {
                _otherSkillsXssError = _containsScriptTag(value)
                    ? 'Script tags are not allowed'
                    : null;
              });
            },
          ),
          if (_otherSkills.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _otherSkills.map((skill) {
                  return Chip(
                    label: Text(skill,
                        style: GoogleFonts.montserrat(
                            fontSize: 12, color: Colors.white)),
                    backgroundColor: Color(0xFF1A1A1A),
                    deleteIcon:
                        Icon(Icons.close, size: 18, color: Colors.white),
                    onDeleted: () => _removeOtherSkill(skill),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFileSection() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upload project documents (if any)',
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colorfile.textColor)),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _files.isEmpty ? 'Choose files to upload' : 'Files selected',
                  style: GoogleFonts.montserrat(fontSize: 14),
                ),
                TextButton(
                  onPressed: _pickFile,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                    side: BorderSide(color: Colors.grey, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    'Choose Files',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Color(0xFF757575),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_files.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _files.map((file) {
                  return Chip(
                    label: Text(file.name,
                        style: GoogleFonts.montserrat(
                            fontSize: 12, color: Colors.white)),
                    backgroundColor: Color(0xFF1A1A1A),
                    deleteIcon:
                        Icon(Icons.close, size: 18, color: Colors.white),
                    onDeleted: () => _removeFile(file),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  TextStyle _getTextStyle() => TextStyle(
        fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
        decoration:
            _isUnderline ? TextDecoration.underline : TextDecoration.none,
      );

  Widget _buildCurrencySelector() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Currency *',
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colorfile.textColor)),
          SizedBox(height: 8),
          isLoadingCurrencies
              ? Center(child: CircularProgressIndicator())
              : Wrap(
                  spacing: 12.0,
                  runSpacing: 8.0,
                  children: availableCurrencies.asMap().entries.map((entry) {
                    final index = entry.key;
                    final currency = entry.value;
                    final isSelected = selectedCurrency == currency;
                    return GestureDetector(
                      onTap: () => setState(() {
                        selectedCurrency = isSelected ? null : currency;
                        _currencyError = null;
                      }),
                      child: Container(
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: isSelected ? Colors.green : Color(0xFFFFFFFF),
                          border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : _currencyError != null
                                      ? Colors.red
                                      : Color(0xFFD9D9D9),
                              width: 1),
                        ),
                        child: Center(
                          child: Text(
                            '${currency['currency']} (${currency['lable']})',
                            style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color:
                                    isSelected ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
          if (_currencyError != null)
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                _currencyError!,
                style: GoogleFonts.montserrat(fontSize: 12, color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionSelector(Map<String, dynamic> option) {
    final type = option['type'];
    final items = option['items'] as List<Map<String, dynamic>>;
    final selectedIndex = type == 'requirementType'
        ? selectedRequiredType
        : type == 'lookingFor'
            ? selectedLookingFor
            : type == 'connectType'
                ? selectedConnectType
                : selectedPaymentType;
    final error = type == 'requirementType'
        ? _requirementTypeError
        : type == 'lookingFor'
            ? _lookingForError
            : type == 'connectType'
                ? _connectTypeError
                : _paymentTypeError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(option['label'],
            style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black)),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: GestureDetector(
                onTap: () => setState(() {
                  if (type == 'requirementType') {
                    selectedRequiredType =
                        selectedRequiredType == index ? -1 : index;
                    _requirementTypeError = null;
                  } else if (type == 'lookingFor') {
                    selectedLookingFor =
                        selectedLookingFor == index ? -1 : index;
                    _lookingForError = null;
                  } else if (type == 'connectType') {
                    selectedConnectType =
                        selectedConnectType == index ? -1 : index;
                    _connectTypeError = null;
                  } else {
                    selectedPaymentType =
                        selectedPaymentType == index ? -1 : index;
                    _paymentTypeError = null;
                  }
                }),
                child: Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: selectedIndex == index
                        ? Colors.green
                        : Color(0xFFFFFFFF),
                    border: Border.all(
                        color: selectedIndex == index
                            ? Colors.white
                            : error != null
                                ? Colors.red
                                : Color(0xFFD9D9D9),
                        width: 1),
                  ),
                  child: item['icon'] != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(item['icon'],
                                color: selectedIndex == index
                                    ? Colors.white
                                    : item['iconColor'],
                                size: 16),
                            SizedBox(width: 8),
                            Text(item['label'],
                                style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: selectedIndex == index
                                        ? Colors.white
                                        : Colors.black)),
                          ],
                        )
                      : Center(
                          child: Text(item['label'],
                              style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: selectedIndex == index
                                      ? Colors.white
                                      : Colors.black))),
                ),
              ),
            );
          }).toList(),
        ),
        if (error != null)
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              error,
              style: GoogleFonts.montserrat(fontSize: 12, color: Colors.red),
            ),
          ),
        SizedBox(height: 15),
      ],
    );
  }

  Widget _buildReviewSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 1.0), // Added grey border
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review and Post',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Table(
            border: TableBorder(
              horizontalInside:
                  BorderSide(color: Colors.grey.shade200, width: 0.5),
              verticalInside:
                  BorderSide(color: Colors.grey.shade200, width: 0.5),
              borderRadius: BorderRadius.circular(6.0),
            ),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(3),
            },
            children: [
              _buildRow(
                'Project Name: ',
                _projectNameController.text.isEmpty
                    ? 'Not set'
                    : _projectNameController.text,
                isFirst: true,
              ),
              _buildRow(
                'Description: ',
                _descriptionController.text.isEmpty
                    ? 'Not set'
                    : _descriptionController.text,
              ),
              _buildRow(
                'Skills: ',
                selectedSkillIds.isEmpty
                    ? 'None'
                    : selectedSkillIds
                        .map((id) => allSkills.firstWhere((s) =>
                            int.parse(s['id'].toString()) == id)['skill'])
                        .join(', '),
              ),
              _buildRow(
                'Other Skills: ',
                _otherSkills.isEmpty ? 'None' : _otherSkills.join(', '),
              ),
              _buildRow(
                'Requirement Type: ',
                selectedRequiredType == -1
                    ? 'Not set'
                    : options[0]['items'][selectedRequiredType]['label'],
              ),
              _buildRow(
                'Looking For: ',
                selectedLookingFor == -1
                    ? 'Not set'
                    : options[1]['items'][selectedLookingFor]['label'],
              ),
              _buildRow(
                'Payment Mode: ',
                selectedPaymentType == -1
                    ? 'Not set'
                    : options[3]['items'][selectedPaymentType]['label'],
              ),
              _buildRow(
                'Connect Type: ',
                selectedConnectType == -1
                    ? 'Not set'
                    : options[2]['items'][selectedConnectType]['label'],
              ),
              _buildRow(
                'Currency: ',
                selectedCurrency == null
                    ? 'Not set'
                    : '${selectedCurrency!['currency']} (${selectedCurrency!['lable']})',
              ),
              _buildRow(
                'Project Cost: ',
                _projectCostController.text.isEmpty
                    ? 'Not set'
                    : _projectCostController.text,
              ),
              _buildRow(
                'Uploaded Files: ',
                _files.isEmpty ? 'None' : _files.map((f) => f.name).join(', '),
              ),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildRow(String label, String value, {bool isFirst = false}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isFirst ? Colors.grey.shade50 : Colors.white,
        borderRadius: isFirst
            ? const BorderRadius.vertical(top: Radius.circular(6.0))
            : null,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
              height: 1.4,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stepContents = [
      Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SETUP YOUR BASIC PROJECT DETAILS',
                style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colorfile.textColor)),
            SizedBox(height: 8),
            Text(
                'Enter the title/name of your project along with the basic details you want freelancers to know before bidding on your project.',
                style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colorfile.textColor)),
            SizedBox(height: 8),
            Text('Enter Your Project Name *',
                style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colorfile.textColor)),
            SizedBox(height: 8),
            TextField(
              controller: _projectNameController,
              decoration: InputDecoration(
                hintText: 'Enter your project name',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: _projectNameError != null ||
                                _projectNameXssError != null
                            ? Colors.red
                            : Colors.grey.shade300)),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                errorText: _projectNameError ?? _projectNameXssError,
                errorStyle:
                    GoogleFonts.montserrat(fontSize: 12, color: Colors.red),
              ),
              onChanged: (value) {
                setState(() {
                  if (value.isNotEmpty) _projectNameError = null;
                  _projectNameXssError = _containsScriptTag(value)
                      ? 'Script tags are not allowed'
                      : null;
                });
              },
            ),
            SizedBox(height: 16),
            Text('Project Description',
                style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colorfile.textColor)),
            SizedBox(height: 8),
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
                          bottom:
                              BorderSide(color: Color(0xFFD9D9D9), width: 2.0)),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                            icon: Icon(Icons.format_bold,
                                color: _isBold ? Colors.blue : Colors.black),
                            onPressed: _toggleBold),
                        IconButton(
                            icon: Icon(Icons.format_underline,
                                color:
                                    _isUnderline ? Colors.blue : Colors.black),
                            onPressed: _toggleUnderline),
                        IconButton(
                            icon: Icon(Icons.clear, color: Colors.black),
                            onPressed: _clearText),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _descriptionController,
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
          ],
        ),
      ),
      Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SETUP YOUR SKILLS AND DOCUMENTS',
                style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colorfile.textColor)),
            SizedBox(height: 8),
            Text(
                'Select the skills required for your project and upload any relevant documents.',
                style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colorfile.textColor)),
            SizedBox(height: 8),
            _buildSkillsSection(),
            SizedBox(height: 8),
            Text('Example:',
                style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colorfile.textColor)),
            SizedBox(height: 8),
            Text(
                'For website creation, select "Web Design" or "Web Development," or otherwise choose a specific technology.',
                style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colorfile.textColor)),
            SizedBox(height: 8),
            _buildOtherSkillsSection(),
            SizedBox(height: 8),
            _buildFileSection(),
          ],
        ),
      ),
      Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SETUP YOUR BUDGET AND PREFERENCES',
                style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black)),
            SizedBox(height: 8),
            Text(
                'Set up the budget for your project and choose your preferences.',
                style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.black)),
            SizedBox(height: 8),
            _buildCurrencySelector(),
            ...options.map(_buildOptionSelector),
            Text('Enter your project budget *',
                style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colorfile.textColor)),
            SizedBox(height: 8),
            TextField(
              controller: _projectCostController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter your project budget',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: _projectCostError != null
                            ? Colors.red
                            : Colors.grey.shade300)),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                errorText: _projectCostError,
                errorStyle:
                    GoogleFonts.montserrat(fontSize: 12, color: Colors.red),
              ),
              onChanged: (value) {
                setState(() {
                  if (value.isNotEmpty) _projectCostError = null;
                });
              },
            ),
          ],
        ),
      ),
      _buildReviewSection(),
    ];

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colorfile.body,
        appBar: AppBar(
          backgroundColor: Colorfile.body,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colorfile.textColor),
              onPressed: () => Navigator.pop(context)),
          title: Text('Post Project',
              style: GoogleFonts.montserrat(
                  color: Colorfile.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
        ),
        body: Stack(
          children: [
            CupertinoScrollbar(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => setState(
                          () => _isContainerVisible = !_isContainerVisible),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFB7D7F9), Color(0xFFE5ACCB)],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Why Quickenlancer Is The Best To',
                                      style: GoogleFonts.montserrat(
                                        color: Colorfile.textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 25,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colorfile.textColor,
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Transform.rotate(
                                        angle:
                                            _isContainerVisible ? 1.57 : 4.72,
                                        child: Icon(
                                          Icons.chevron_left_outlined,
                                          color: Colorfile.textColor,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Quickenlancer offers a swift and effortless project posting method, allowing users to submit their projects.',
                                style: GoogleFonts.montserrat(
                                  color: Colorfile.textColor,
                                  fontSize: 13,
                                ),
                              ),
                              Visibility(
                                visible: _isContainerVisible,
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: Color(0xFFE0E0E0),
                                        width: 1,
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFFB7D7F9),
                                              Color(0xFFE5ACCB),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: ClipOval(
                                          child: Padding(
                                            padding: EdgeInsets.all(6.0),
                                            child: Icon(
                                              Icons.verified_user,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        'Verified Freelancer',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colorfile.textColor,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Engage with thoroughly vetted and trusted freelancers.',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: _isContainerVisible,
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(left: 20.0, right: 20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: Color(0xFFE0E0E0),
                                        width: 1,
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFFB7D7F9),
                                              Color(0xFFE5ACCB),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: ClipOval(
                                          child: Padding(
                                            padding: EdgeInsets.all(6.0),
                                            child: Icon(
                                              Icons.verified_rounded,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        'Verified Company',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colorfile.textColor,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Engage with thoroughly vetted and trusted freelancers.',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: _isContainerVisible,
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: Color(0xFFE0E0E0),
                                        width: 1,
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFFB7D7F9),
                                              Color(0xFFE5ACCB),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: ClipOval(
                                          child: Padding(
                                            padding: EdgeInsets.all(6.0),
                                            child: Icon(
                                              Icons.person,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        'Direct Call Approach',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colorfile.textColor,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Communicate directly with freelancers and companies via calls.',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: _isContainerVisible,
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(left: 20.0, right: 20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: Color(0xFFE0E0E0),
                                        width: 1,
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFFB7D7F9),
                                              Color(0xFFE5ACCB),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: ClipOval(
                                          child: Padding(
                                            padding: EdgeInsets.all(6.0),
                                            child: Icon(
                                              Icons.person,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        'No Commission for Posting Projects',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colorfile.textColor,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Post your projects for free without any hidden fees.',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    AnotherStepper(
                      stepperList: List.generate(
                        4,
                        (index) => StepperData(
                          iconWidget: Icon(Icons.circle,
                              size: 20, color: Color(0xFF8B3A99)),
                          title: StepperText(
                              "Step ${index + 1}"), // Use StepperText instead of Text
                        ),
                      ),
                      stepperDirection: Axis.horizontal,
                      activeBarColor: Color(0xFF8B3A99),
                      inActiveBarColor: Color(0xFFD9D9D9),
                      iconWidth: 18,
                      iconHeight: 20,
                      barThickness: 2,
                      activeIndex: _currentStep,
                    ),
                    SizedBox(height: 20),
                    stepContents[_currentStep],
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_currentStep > 0)
                            Container(
                              height: 42,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFB7D7F9),
                                        Color(0xFFE5ACCB)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight),
                                  borderRadius: BorderRadius.circular(6)),
                              child: ElevatedButton(
                                onPressed: () => setState(() => _currentStep--),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4))),
                                child: Row(children: [
                                  Icon(Icons.arrow_back,
                                      color: Colorfile.textColor),
                                  SizedBox(width: 8),
                                  Text('Previous',
                                      style:
                                          TextStyle(color: Colorfile.textColor))
                                ]),
                              ),
                            ),
                          ElevatedButton(
                            onPressed: () {
                              if (_currentStep < stepContents.length - 1) {
                                if (_validateStep(_currentStep)) {
                                  setState(() => _currentStep++);
                                } else {
                                  _showSnackBar(
                                      'Please fill all required fields and remove any script tags');
                                }
                              } else {
                                _submitProject();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF191E3E),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                            ),
                            child: Text(_currentStep == stepContents.length - 1
                                ? 'Submit'
                                : 'Next'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            if (_isSubmitting)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
