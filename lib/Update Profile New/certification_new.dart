import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import '../../api/network/uri.dart';
import '../../editprofilepage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class CertificationNew extends StatefulWidget {
  const CertificationNew({Key? key}) : super(key: key);

  @override
  _CertificationNewState createState() => _CertificationNewState();
}

class _CertificationNewState extends State<CertificationNew> {
  final _certificationNameController = TextEditingController();
  final List<File> _certificateFiles = [];
  final List<Map<String, dynamic>> _certifications = [];
  bool _isLoading = false;
  String _certificationBasePath = '';

  @override
  void initState() {
    super.initState();
    _fetchProfileDetails();
  }

  @override
  void dispose() {
    _certificationNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfileDetails() async {
    setState(() => _isLoading = true);

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

      log('Full API Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'true' ||
            jsonResponse['status'] == true) {
          final data = jsonResponse['data'];
          if (data == null) {
            throw Exception('Data field is null in API response');
          }
          final certifications = data['certificates'] as List<dynamic>? ?? [];
          final basePath = data['image_path'] != null
              ? data['image_path']['certification_path'] as String? ?? ''
              : '';
          setState(() {
            _certificationBasePath =
                'https://quicken.blr1.digitaloceanspaces.com/$basePath';
            _certifications.clear();
            _certifications.addAll(certifications.map((cert) {
              final fileNames = cert['fileName'] != null
                  ? (cert['fileName'] as String)
                      .replaceAll(RegExp(r'(cert_\d+_\d+\.\w+)'), '')
                      .split(',')
                      .where((name) => name.trim().isNotEmpty)
                      .toList()
                  : [];
              return {
                'id': cert['id'].toString(),
                'name': cert['name'] as String? ?? 'Unnamed',
                'files': fileNames
                    .map((name) => '$_certificationBasePath$name')
                    .toList(),
              };
            }));
          });
        } else {
          throw Exception(
              'API returned false status: ${jsonResponse['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception(
            'Failed to fetch profile details: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching certifications: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['png', 'jpeg', 'jpg', 'pdf'],
      );
      if (result != null) {
        setState(() {
          _certificateFiles.addAll(result.paths.map((path) {
            debugPrint('Picked file: $path');
            return File(path!);
          }));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking files: $e')),
      );
    }
  }

  void _addCertification() {
    if (_certificationNameController.text.isNotEmpty) {
      setState(() {
        _certifications.add({
          'name': _certificationNameController.text,
          'files': List<File>.from(_certificateFiles),
        });
        _certificationNameController.clear();
        _certificateFiles.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a certification name')),
      );
    }
  }

  Future<String> _fileToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      debugPrint('Error converting file to base64: ${file.path}, Error: $e');
      return '';
    }
  }

  Future<void> deleteCertification(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    final String? authToken = prefs.getString('auth_token');
    final url = Uri.parse(URLS().user_delete_profile_items);

    final body = jsonEncode({
      'user_id': userId,
      'delete_id': id,
      'delete_item_type': '1',
    });

    setState(() {
      _certifications.removeWhere((cert) => cert['id'] == id);
    });

    if (authToken != null) {
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
          await _fetchProfileDetails();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to delete certification: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during deletion: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No auth token found')),
      );
    }
  }

  Future<void> _confirmDeleteCertification(String id, String certName) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Delete Certification',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colorfile.textColor,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$certName"?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colorfile.textColor.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colorfile.textColor.withOpacity(0.5),
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
      await deleteCertification(id);
    }
  }

  Future<void> _viewCertificationFiles(List<dynamic> files) async {
    for (var file in files) {
      if (file is String) {
        final Uri fileUri = Uri.parse(file);
        try {
          if (await canLaunchUrl(fileUri)) {
            await launchUrl(
              fileUri,
              mode: LaunchMode.externalApplication,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cannot open file: $file')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error opening file: $e')),
          );
        }
      }
    }
  }

  Future<void> _saveForm() async {
    if (_certifications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No certifications to save')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final authToken = prefs.getString('auth_token') ?? '';

      if (userId.isEmpty || authToken.isEmpty) {
        throw Exception('User ID or auth token is missing');
      }

      List<Map<String, dynamic>> certificationsPayload = [];
      for (var cert in _certifications) {
        if (cert['files'].isEmpty ||
            cert['files'].every((file) => file is String)) {
          debugPrint(
              'Skipping certification "${cert['name']}" with no new files');
          continue;
        }

        List<String> base64Files = [];
        for (var file in cert['files']) {
          if (file is File) {
            try {
              if (await file.exists()) {
                final base64String = await _fileToBase64(file);
                if (base64String.isNotEmpty) {
                  base64Files.add(base64String);
                } else {
                  debugPrint('Failed to convert file to base64: ${file.path}');
                }
              } else {
                debugPrint('File does not exist: ${file.path}');
              }
            } catch (e) {
              debugPrint('Error processing file ${file.path}: $e');
            }
          }
        }

        if (base64Files.isNotEmpty) {
          certificationsPayload.add({
            'certification_name': cert['name'],
            'files': base64Files,
          });
        }
      }

      if (certificationsPayload.isEmpty) {
        throw Exception(
            'No valid files to upload. Please check file accessibility.');
      }

      final payload = {
        'user_id': userId,
        'certifications': certificationsPayload,
      };

      debugPrint('Request Body: ${jsonEncode(payload)}');

      final response = await http.post(
        Uri.parse(URLS().set_certificates),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Certifications saved successfully')),
        );
        setState(() {
          _certifications.clear();
          _certificateFiles.clear();
          _certificationNameController.clear();
        });
        await _fetchProfileDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to save certifications: ${response.statusCode} - ${response.body}')),
        );
      }
    } catch (e) {
      debugPrint('Error saving certifications: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Certifications',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colorfile.textColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colorfile.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(
            color: Colors.grey.withOpacity(0.3),
            height: 1,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Certification Name*',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colorfile.textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _certificationNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter certification name',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colorfile.textColor.withOpacity(0.3),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colorfile.textColor.withOpacity(0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colorfile.textColor.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colorfile.textColor,
                          width: 1.5,
                        ),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colorfile.textColor,
                    ),
                  ),
                  SizedBox(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      GestureDetector(
                        onTap: _pickFiles,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.2),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Choose File',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colorfile.textColor,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _pickFiles,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade50,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 1.0,
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.upload,
                                      color: Color(0xFF757575),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Choose File',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF757575),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _addCertification,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colorfile.textColor.withOpacity(0.2),
                                width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add,
                                  color: Colorfile.textColor, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Add Certification',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colorfile.textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_certificateFiles.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Column(
                      children: _certificateFiles.asMap().entries.map((entry) {
                        final index = entry.key;
                        final file = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Icon(
                                file.path.endsWith('.pdf')
                                    ? Icons.picture_as_pdf
                                    : Icons.image,
                                color: Colorfile.textColor.withOpacity(0.5),
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  file.path.split('/').last,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colorfile.textColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close,
                                    color: Colorfile.textColor.withOpacity(0.5),
                                    size: 20),
                                onPressed: () => setState(() {
                                  _certificateFiles.removeAt(index);
                                }),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colorfile.textColor,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Save',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (_certifications.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Text(
                      'Certificate',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colorfile.textColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width,
                      ),
                      child: DataTable(
                        border: TableBorder.all(
                          color: const Color(0xFFD9D9D9),
                          width: 0.5,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(6)),
                        ),
                        columnSpacing: 16,
                        headingRowColor:
                            MaterialStateProperty.all(const Color(0xFFF5F7FA)),
                        columns: [
                          DataColumn(
                            label: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Text(
                                'Certificate',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colorfile.textColor,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Text(
                                'View',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colorfile.textColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Text(
                                'Action',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colorfile.textColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                        rows: _certifications.asMap().entries.map((entry) {
                          final cert = entry.value;
                          return DataRow(cells: [
                            DataCell(
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text(
                                  cert['name'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colorfile.textColor,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.remove_red_eye_outlined,
                                    color: Colorfile.textColor,
                                    size: 18,
                                  ),
                                  onPressed: () =>
                                      _viewCertificationFiles(cert['files']),
                                ),
                              ),
                            ),
                            DataCell(
                              cert['id'] != null
                                  ? Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: IconButton(
                                        icon: Image.asset(
                                          'assets/delete_icon.png',
                                          width: 14,
                                          height: 14,
                                          color: Colorfile.textColor,
                                        ),
                                        onPressed: () =>
                                            _confirmDeleteCertification(
                                          cert['id'],
                                          cert['name'],
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colorfile.textColor.withOpacity(0.1),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colorfile.textColor),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
