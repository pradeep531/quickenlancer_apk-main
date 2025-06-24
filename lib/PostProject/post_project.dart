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
import '../SignUp/signIn.dart';
import '../api/network/uri.dart'; // Adjust import path as needed
import 'package:quickenlancer_apk/Colors/colorfile.dart'; // Adjust import path as needed

class PostProject extends StatefulWidget {
  @override
  _PostProjectState createState() => _PostProjectState();
}

class _PostProjectState extends State<PostProject> {
  bool isExpanded = false;
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

  // Future<void> _submitProject() async {
  //   if (!_validateStep(3)) {
  //     _showSnackBar(
  //         'Please fill all required fields and remove any script tags');
  //     return;
  //   }

  //   setState(() => _isSubmitting = true);

  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final String? authToken = prefs.getString('auth_token');
  //     final String userId = prefs.getString('user_id') ?? '';

  //     if (authToken == null || authToken.isEmpty) {
  //       _showSnackBar('Auth token not found. Please log in again.');
  //       setState(() => _isSubmitting = false);
  //       return;
  //     }

  //     final otherSkillsFormatted = '[${_otherSkills.join(',')}]';
  //     final Map<String, dynamic> projectBody = {
  //       "user_id": userId,
  //       "newSkill": selectedSkillIds,
  //       "other_skills": otherSkillsFormatted,
  //       "project_name": _projectNameController.text,
  //       "description": _descriptionController.text,
  //       "currency": selectedCurrency?['id'].toString() ?? '2',
  //       "requirement_type": selectedRequiredType == 0 ? "0" : "1",
  //       "looking_for": (selectedLookingFor + 1).toString(),
  //       "project_type": selectedPaymentType == 0 ? "0" : "1",
  //       "project_cost": _projectCostController.text,
  //       "connect_type": (selectedConnectType + 1).toString(),
  //     };

  //     print('Project Request Body: ${jsonEncode(projectBody)}');
  //     log(authToken);
  //     final projectResponse = await http.post(
  //       Uri.parse(URLS().post_project),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $authToken',
  //       },
  //       body: jsonEncode(projectBody),
  //     );

  //     log('Project Response Body: ${projectResponse.body}');

  //     if (projectResponse.statusCode == 200) {
  //       final projectData = jsonDecode(projectResponse.body);
  //       if (projectData['status'] == 'true') {
  //         final String projectId = projectData['data']['project_id'].toString();

  //         if (_files.isNotEmpty) {
  //           final documentRequest = http.MultipartRequest(
  //             'POST',
  //             Uri.parse(URLS().post_project_documents),
  //           );
  //           documentRequest.headers['Authorization'] = 'Bearer $authToken';
  //           documentRequest.fields['user_id'] = userId;
  //           documentRequest.fields['project_id'] = projectId;

  //           for (var file in _files) {
  //             if (file.bytes != null) {
  //               documentRequest.files.add(
  //                 http.MultipartFile.fromBytes(
  //                   'project_documents[]',
  //                   file.bytes!,
  //                   filename: file.name,
  //                 ),
  //               );
  //             } else if (file.path != null) {
  //               documentRequest.files.add(
  //                 await http.MultipartFile.fromPath(
  //                   'project_documents[]',
  //                   file.path!,
  //                   filename: file.name,
  //                 ),
  //               );
  //             }
  //           }

  //           print('Document Request Fields: ${documentRequest.fields}');
  //           print(
  //               'Document Request Files: ${documentRequest.files.map((f) => f.filename).toList()}');

  //           final documentResponse = await documentRequest.send();
  //           final documentResponseBody =
  //               await http.Response.fromStream(documentResponse);

  //           log('Document Response Body: ${documentResponseBody.body}');

  //           if (documentResponse.statusCode == 200) {
  //             final documentData = jsonDecode(documentResponseBody.body);
  //             if (documentData['status'] == 'true') {
  //               _showSnackBar('Project and documents posted successfully!');
  //             } else {
  //               _showSnackBar(
  //                   'Project posted, but failed to upload documents: ${documentData['message']}');
  //             }
  //           } else {
  //             _showSnackBar(
  //                 'Project posted, but document upload failed: ${documentResponse.statusCode}');
  //           }
  //         } else {
  //           _showSnackBar('Project posted successfully!');
  //         }

  //         setState(() => _isSubmitting = false);
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) =>
  //                 ScheduleAvailabilityPage(projectId: projectId),
  //           ),
  //         );
  //       } else {
  //         _showSnackBar('Failed to post project: ${projectData['message']}');
  //         setState(() => _isSubmitting = false);
  //       }
  //     } else {
  //       _showSnackBar(
  //           'Error: ${projectResponse.statusCode} - ${projectResponse.reasonPhrase}');
  //       setState(() => _isSubmitting = false);
  //     }
  //   } catch (e) {
  //     _showSnackBar('Error posting project: $e');
  //     setState(() => _isSubmitting = false);
  //   }
  // }
  // Add this method in _PostProjectState
  Future<void> _submitProjectWithData(
      Map<String, dynamic> projectData, List<PlatformFile> files) async {
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

      final Map<String, dynamic> projectBody = {
        "user_id": userId,
        "newSkill": projectData['newSkill'],
        "other_skills": projectData['other_skills'],
        "project_name": projectData['project_name'],
        "description": projectData['description'],
        "currency": projectData['currency'],
        "requirement_type": projectData['requirement_type'],
        "looking_for": projectData['looking_for'],
        "project_type": projectData['project_type'],
        "project_cost": projectData['project_cost'],
        "connect_type": projectData['connect_type'],
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
        final projectDataResponse = jsonDecode(projectResponse.body);
        if (projectDataResponse['status'] == 'true') {
          final String projectId =
              projectDataResponse['data']['project_id'].toString();

          if (files.isNotEmpty) {
            final documentRequest = http.MultipartRequest(
              'POST',
              Uri.parse(URLS().post_project_documents),
            );
            documentRequest.headers['Authorization'] = 'Bearer $authToken';
            documentRequest.fields['user_id'] = userId;
            documentRequest.fields['project_id'] = projectId;

            for (var file in files) {
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
          _showSnackBar(
              'Failed to post project: ${projectDataResponse['message']}');
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

// Replace the existing _submitProject method with this
  Future<void> _submitProject() async {
    if (!_validateStep(3)) {
      _showSnackBar(
          'Please fill all required fields and remove any script tags');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final int? isLoggedIn = prefs.getInt('is_logged_in');

      // Prepare project data
      final otherSkillsFormatted = '[${_otherSkills.join(',')}]';
      final Map<String, dynamic> projectData = {
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

      // If not logged in, prompt sign-in
      if (isLoggedIn != 1) {
        setState(() => _isSubmitting = false);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor:
                  Colors.white, // Prevents unwanted tint on elevation
              elevation: 8.0, // Subtle shadow for depth
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0), // Softer corners
              ),
              title: const Text(
                'Sign In Required',
                style: TextStyle(
                  fontSize: 22.0, // Slightly larger for prominence
                  fontWeight: FontWeight.w700, // Bolder for hierarchy
                  color: Colors.black87,
                  letterSpacing: 0.5, // Improved readability
                ),
              ),
              content: const Text(
                'You need to sign in to post a project. Please sign in to proceed.',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black54,
                  height: 1.6, // Increased line spacing for clarity
                  fontWeight: FontWeight.w400, // Lighter for readability
                ),
              ),
              actionsPadding: EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 12.0), // Consistent spacing
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    foregroundColor: Colors.grey, // Ripple effect color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10.0), // Rounded corners
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey, // Subtle color for cancel
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push<Map<String, dynamic>>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignInPage(
                          projectData: projectData,
                          files: _files,
                        ),
                      ),
                    ).then((result) async {
                      if (result != null && result['success'] == true) {
                        await _submitProjectWithData(
                            result['projectData'], result['files']);
                      } else {
                        _showSnackBar('Sign-in was not successful');
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colorfile
                        .textColor, // Vibrant primary color (replacing Colorfile.textColor)
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10.0), // Matching rounded corners
                    ),
                    elevation: 2.0, // Subtle button elevation
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white, // High contrast
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
        return;
      }

      // If logged in, proceed with project submission
      await _submitProjectWithData(projectData, _files);
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
                        GoogleFonts.poppins(fontSize: 12, color: Colors.red),
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
                                      style: GoogleFonts.poppins(fontSize: 14)),
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
                      style: GoogleFonts.poppins(
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
              style: GoogleFonts.poppins(
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
                    style: GoogleFonts.poppins(
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
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
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
                        style: GoogleFonts.poppins(
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
              style: GoogleFonts.poppins(
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
              errorStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
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
                        style: GoogleFonts.poppins(
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
              style: GoogleFonts.poppins(
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
                  style: GoogleFonts.poppins(fontSize: 14),
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
                    style: GoogleFonts.poppins(
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
                        style: GoogleFonts.poppins(
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
              style: GoogleFonts.poppins(
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
                            style: GoogleFonts.poppins(
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
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
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
            style: GoogleFonts.poppins(
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
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: selectedIndex == index
                                        ? Colors.white
                                        : Colors.black)),
                          ],
                        )
                      : Center(
                          child: Text(item['label'],
                              style: GoogleFonts.poppins(
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
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
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
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
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
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project Name',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _projectNameController.text.isEmpty
                          ? 'Not set'
                          : _projectNameController.text,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final textStyle = GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                          height: 1.4,
                        );
                        final span = TextSpan(
                            text: _descriptionController.text,
                            style: textStyle);
                        final tp = TextPainter(
                          text: span,
                          maxLines: 2,
                          ellipsis: '...',
                          textDirection: TextDirection.ltr,
                        );
                        tp.layout(maxWidth: constraints.maxWidth);

                        if (!tp.didExceedMaxLines && !isExpanded) {
                          return Text(
                            _descriptionController.text,
                            style: textStyle,
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _descriptionController.text,
                              maxLines: isExpanded ? null : 2,
                              overflow: isExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                              style: textStyle,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isExpanded = !isExpanded;
                                });
                              },
                              child: Text(
                                isExpanded ? 'Read less' : 'Read more',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skills',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    selectedSkillIds.isEmpty
                        ? Text(
                            'None',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          )
                        : Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: selectedSkillIds.map((id) {
                              final skill = allSkills.firstWhere((s) =>
                                  int.parse(s['id'].toString()) == id)['skill'];
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F1FC),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Text(
                                  skill,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black54,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Other Skills',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _otherSkills.isEmpty
                        ? Text(
                            'None',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          )
                        : Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _otherSkills.map((skill) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F1FC),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Text(
                                  skill,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black54,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(1.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFB7D7F9),
                      Color(0xFFE5ACCB),
                    ],
                    transform: GradientRotation(140.96 * 3.14159 / 180),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(7.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Requirement Type: ',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colorfile.textColor,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      selectedRequiredType == -1
                                          ? 'Not set'
                                          : options[0]['items']
                                              [selectedRequiredType]['label'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colorfile.textColor,
                                        height: 1.2,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Connect Type: ',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colorfile.textColor,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      selectedConnectType == -1
                                          ? 'Not set'
                                          : options[2]['items']
                                              [selectedConnectType]['label'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colorfile.textColor,
                                        height: 1.2,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Looking For: ',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colorfile.textColor,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      selectedLookingFor == -1
                                          ? 'Not set'
                                          : options[1]['items']
                                              [selectedLookingFor]['label'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colorfile.textColor,
                                        height: 1.2,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Currency: ',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colorfile.textColor,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      selectedCurrency == null
                                          ? 'Not set'
                                          : '${selectedCurrency!['currency']} (${selectedCurrency!['lable']})',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colorfile.textColor,
                                        height: 1.2,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'How To Pay: ',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colorfile.textColor,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      selectedPaymentType == -1
                                          ? 'Not set'
                                          : options[3]['items']
                                              [selectedPaymentType]['label'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colorfile.textColor,
                                        height: 1.2,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Project Cost: ',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colorfile.textColor,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      _projectCostController.text.isEmpty
                                          ? 'Not set'
                                          : _projectCostController.text,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colorfile.textColor,
                                        height: 1.2,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uploaded Files',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF), // Background color
                        border: Border.all(
                          color: Color(0xFFD9D9D9), // Border color
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(
                            4), // Optional: Rounded corners
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.insert_drive_file,
                            color: Colors.blue,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _files.isEmpty
                                  ? 'None'
                                  : _files.map((f) => f.name).join(', '),
                              style: GoogleFonts.poppins(
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
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colorfile.textColor)),
            SizedBox(height: 8),
            Text(
                'Enter the title/name of your project along with the basic details you want freelancers to know before bidding on your project.',
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colorfile.textColor)),
            SizedBox(height: 8),
            Text('Enter Your Project Name *',
                style: GoogleFonts.poppins(
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
                    GoogleFonts.poppins(fontSize: 12, color: Colors.red),
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
                style: GoogleFonts.poppins(
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
                          errorStyle: GoogleFonts.poppins(
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
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colorfile.textColor)),
            SizedBox(height: 8),
            Text(
                'Select the skills required for your project and upload any relevant documents.',
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colorfile.textColor)),
            SizedBox(height: 8),
            _buildSkillsSection(),
            SizedBox(height: 8),
            Text('Example:',
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colorfile.textColor)),
            SizedBox(height: 8),
            Text(
                'For website creation, select "Web Design" or "Web Development," or otherwise choose a specific technology.',
                style: GoogleFonts.poppins(
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
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black)),
            SizedBox(height: 8),
            Text(
                'Set up the budget for your project and choose your preferences.',
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.black)),
            SizedBox(height: 8),
            _buildCurrencySelector(),
            ...options.map(_buildOptionSelector),
            Text('Enter your project budget *',
                style: GoogleFonts.poppins(
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
                    GoogleFonts.poppins(fontSize: 12, color: Colors.red),
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
              style: GoogleFonts.poppins(
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
                                      style: GoogleFonts.poppins(
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
                                style: GoogleFonts.poppins(
                                  color: Colorfile.textColor,
                                  fontSize: 13,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Visibility(
                                  visible: _isContainerVisible,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
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
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colorfile.textColor,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Engage with thoroughly vetted and trusted freelancers.',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: _isContainerVisible,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
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
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colorfile.textColor,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Engage with thoroughly vetted and trusted freelancers.',
                                        style: GoogleFonts.poppins(
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
                                  padding: EdgeInsets.all(8.0),
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
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colorfile.textColor,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Communicate directly with freelancers and companies via calls.',
                                        style: GoogleFonts.poppins(
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
                                  padding: EdgeInsets.all(8.0),
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
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colorfile.textColor,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Post your projects for free without any hidden fees.',
                                        style: GoogleFonts.poppins(
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
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: ElevatedButton(
                                onPressed: () => setState(() => _currentStep--),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.arrow_back,
                                        color: Colorfile.textColor),
                                    SizedBox(width: 8),
                                    Text('Previous',
                                        style: TextStyle(
                                            color: Colorfile.textColor)),
                                  ],
                                ),
                              ),
                            ),
                          Spacer(), // Pushes the Next button to the right
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
                                borderRadius: BorderRadius.circular(6),
                              ),
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
