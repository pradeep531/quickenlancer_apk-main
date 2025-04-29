import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/network/uri.dart';
import '../../editprofilepage.dart';
import '../shared_widgets.dart';

class ExperienceForm extends StatefulWidget {
  const ExperienceForm({Key? key}) : super(key: key);

  @override
  _ExperienceFormState createState() => _ExperienceFormState();
}

class _ExperienceFormState extends State<ExperienceForm> {
  final _experienceController = TextEditingController();
  final _experienceDescriptionController = TextEditingController();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchProfileDetails();
  }

  @override
  void dispose() {
    _experienceController.dispose();
    _experienceDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfileDetails() async {
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

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'true' && jsonResponse['data'] != null) {
          final basicDetails = jsonResponse['data']['basic_details'];
          setState(() {
            // Autofill experience if available
            if (basicDetails['experience'] != null) {
              _experienceController.text =
                  basicDetails['experience'].toString();
            }
            // Autofill experience description if available
            if (basicDetails['exp_description'] != null) {
              _experienceDescriptionController.text =
                  basicDetails['exp_description'].toString();
            }
          });
        } else {
          print('Invalid response: status is not true or data is missing');
        }
      } else {
        print('Failed to fetch profile details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching profile details: $e');
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    final authToken = prefs.getString('auth_token') ?? '';

    final url = Uri.parse(URLS().set_experience);
    final request = http.MultipartRequest('POST', url);

    // Add form fields to multipart request
    request.fields['experience'] = _experienceController.text;
    request.fields['user_id'] = userId;
    request.fields['exp_description'] = _experienceDescriptionController.text;

    // Add authorization header
    request.headers['Authorization'] = 'Bearer $authToken';

    print('Request URL: $url');
    print('Request Fields: ${request.fields}');
    print('Authorization Token: Bearer $authToken');

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Editprofilepage(),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Experience saved successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to save experience: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while saving')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SharedWidgets.textField(
                _experienceController,
                'Experience (Years)',
                keyboardType:
                    TextInputType.text, // Changed to text to handle "25 Years"
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter years of experience';
                  }
                  // Optionally validate format (e.g., "X Years")
                  if (!RegExp(r'^\d+\s*Years?$').hasMatch(value)) {
                    return 'Please enter a valid format (e.g., "25 Years")';
                  }
                  return null;
                },
              ),
              SharedWidgets.textField(
                _experienceDescriptionController,
                'Experience Description',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an experience description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              StyledButton(
                text: 'Save',
                icon: Icons.save,
                onPressed: _saveForm,
              ),
            ],
          ),
        ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
