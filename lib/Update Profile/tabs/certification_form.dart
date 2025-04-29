import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../api/network/uri.dart';
import '../../editprofilepage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import '../shared_widgets.dart';

class CertificationForm extends StatefulWidget {
  const CertificationForm({Key? key}) : super(key: key);

  @override
  _CertificationFormState createState() => _CertificationFormState();
}

class _CertificationFormState extends State<CertificationForm> {
  final _certificationNameController = TextEditingController();
  final List<File> _certificateFiles = [];
  final List<Map<String, dynamic>> _certifications = [];
  bool _isLoading = false;
  String _certificationBasePath = '';

  @override
  void initState() {
    super.initState();
    _fetchProfileDetails(); // Fetch certifications on widget initialization
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

      print('Request URL: $url');
      print('Request Headers: $headers');
      print('Request Body: $body');

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}');

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
                'id': cert['id'].toString(), // Store ID for deletion
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
      print('Error fetching profile details: $e');
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
          _certificateFiles.addAll(result.paths.map((path) => File(path!)));
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
      print('Error encoding file to Base64: $e');
      return '';
    }
  }

  // Function to handle delete action
  Future<void> deleteCertification(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    final String? authToken = prefs.getString('auth_token');
    final url = Uri.parse(URLS().user_delete_profile_items);

    final body = jsonEncode({
      'user_id': userId,
      'delete_id': id,
      'delete_item_type': '1', // Assuming 3 is for certifications
    });

    // Log the request body
    print('Request Body: $body');

    setState(() {
      _certifications.removeWhere((cert) => cert['id'] == id);
    });

    // Check if authToken exists
    if (authToken != null) {
      // Make an API call to delete the certification using Bearer token
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

        // Log the response status and body
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');

        log('Delete Certification Response Status: ${response.statusCode}');
        log('Delete Certification Response Body: ${response.body}');

        if (response.statusCode == 200) {
          print('Certification deleted successfully');
          await _fetchProfileDetails(); // Refresh certifications after deletion
        } else {
          print('Failed to delete certification: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to delete certification: ${response.statusCode}')),
          );
        }
      } catch (e) {
        print('Error during deletion: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during deletion: $e')),
        );
      }
    } else {
      print('No auth token found');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No auth token found')),
      );
    }
  }

  // Function to show confirmation dialog before deletion
  Future<void> _confirmDeleteCertification(String id, String certName) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Certification',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$certName"?',
          style: GoogleFonts.montserrat(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: GoogleFonts.montserrat(
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

      // Prepare JSON payload
      List<Map<String, dynamic>> certificationsPayload = [];
      for (var cert in _certifications) {
        List<String> base64Files = [];
        for (var file in cert['files']) {
          if (file is File && await file.exists()) {
            final base64String = await _fileToBase64(file);
            if (base64String.isNotEmpty) {
              base64Files.add(base64String);
            } else {
              print('Failed to encode file: ${file.path}');
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
        throw Exception('No valid files to upload');
      }

      final payload = {
        'user_id': userId,
        'certifications': certificationsPayload,
      };

      // Log payload for debugging
      log('Request Payload: ${jsonEncode(payload)}');

      // Send POST request
      final response = await http.post(
        Uri.parse(URLS().set_certificates),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      print('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Certifications saved successfully')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Editprofilepage()),
        );
        setState(() {
          _certifications.clear();
          _certificateFiles.clear();
          _certificationNameController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to save certifications: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Certifications',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[600],
                ),
              ),
              SizedBox(height: 12),

              // Certification Name Input
              TextField(
                controller: _certificationNameController,
                decoration: InputDecoration(
                  labelText: 'Certification Name',
                  labelStyle:
                      GoogleFonts.montserrat(color: Colors.blueGrey[600]),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue[200]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue[200]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue[600]!),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                style:
                    GoogleFonts.montserrat(fontSize: 14, color: Colors.black87),
              ),
              SizedBox(height: 12),

              // File Upload Section
              OutlinedButton.icon(
                onPressed: _pickFiles,
                icon: Icon(Icons.upload_file, color: Colors.blue[600]),
                label: Text(
                  'Upload Files',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  side: BorderSide(color: Colors.blue[600]!),
                ),
              ),
              if (_certificateFiles.isNotEmpty) ...[
                SizedBox(height: 8),
                Column(
                  children: _certificateFiles.asMap().entries.map((entry) {
                    final index = entry.key;
                    final file = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            file.path.endsWith('.pdf')
                                ? Icons.picture_as_pdf
                                : Icons.image,
                            color: Colors.blue[600],
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              file.path.split('/').last,
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete,
                                color: Colors.red[400], size: 20),
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
              SizedBox(height: 12),

              // Add Certification Button
              OutlinedButton.icon(
                onPressed: _addCertification,
                icon: Icon(Icons.add, color: Colors.blue[600]),
                label: Text(
                  'Add',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  side: BorderSide(color: Colors.blue[600]!),
                ),
              ),
              SizedBox(height: 12),

              // Save Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveForm,
                icon: Icon(Icons.save, color: Colors.white),
                label: Text(
                  'Save',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  backgroundColor: Color(0xFF2563EB),
                  minimumSize: Size(double.infinity, 40),
                ),
              ),
              if (_certifications.isNotEmpty) ...[
                SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Added Certifications',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    ..._certifications.asMap().entries.map((entry) {
                      final index = entry.key;
                      final cert = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.verified,
                              color: Colors.blue[600],
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cert['name'],
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (cert['files'].isNotEmpty)
                                    Text(
                                      '${cert['files'].length} file(s)',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  if (cert['files'].isNotEmpty)
                                    Column(
                                      children:
                                          (cert['files'] as List).map((file) {
                                        final fileName = file is File
                                            ? file.path.split('/').last
                                            : (file as String).split('/').last;
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Row(
                                            children: [
                                              Icon(
                                                fileName.endsWith('.pdf')
                                                    ? Icons.picture_as_pdf
                                                    : Icons.image,
                                                color: Colors.blue[600],
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  fileName,
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 12,
                                                    color: Colors.black87,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete,
                                  color: Colors.red[400], size: 20),
                              onPressed: () => _confirmDeleteCertification(
                                cert['id'] ?? '',
                                cert['name'],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
              ),
            ),
          ),
      ],
    );
  }
}
