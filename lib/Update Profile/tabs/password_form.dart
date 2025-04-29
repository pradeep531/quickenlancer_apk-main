import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/network/uri.dart';
import '../../editprofilepage.dart';
import '../shared_widgets.dart';
import 'dart:convert';

class PasswordForm extends StatefulWidget {
  const PasswordForm({Key? key}) : super(key: key);

  @override
  _PasswordFormState createState() => _PasswordFormState();
}

class _PasswordFormState extends State<PasswordForm> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hasLowerAndUpperCase = false;
  bool _hasNumberAndSymbol = false;
  bool _hasMinLength = false;
  bool _isLoading = false;

  // Validation error messages
  String? _currentPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_validatePassword);
    _currentPasswordController.addListener(_validateCurrentPassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  void _validatePassword() {
    final password = _newPasswordController.text;

    setState(() {
      _hasLowerAndUpperCase = password.contains(RegExp(r'[a-z]')) &&
          password.contains(RegExp(r'[A-Z]'));
      _hasNumberAndSymbol = password.contains(RegExp(r'[0-9]')) &&
          password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      _hasMinLength = password.length >= 6;
      _newPasswordError = password.isEmpty ? 'New password is required' : null;
    });
  }

  void _validateCurrentPassword() {
    final currentPassword = _currentPasswordController.text;
    setState(() {
      _currentPasswordError =
          currentPassword.isEmpty ? 'Current password is required' : null;
    });
  }

  void _validateConfirmPassword() {
    final confirmPassword = _confirmPasswordController.text;
    setState(() {
      _confirmPasswordError =
          confirmPassword.isEmpty ? 'Confirm password is required' : null;
    });
  }

  Future<void> _saveForm() async {
    // Validate all fields before submission
    _validateCurrentPassword();
    _validatePassword();
    _validateConfirmPassword();

    if (_currentPasswordError != null ||
        _newPasswordError != null ||
        _confirmPasswordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (!_hasLowerAndUpperCase || !_hasNumberAndSymbol || !_hasMinLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please meet all password requirements')),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('New password and confirm password do not match')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final String? authToken = prefs.getString('auth_token');

      final url = Uri.parse(URLS().set_update_password);

      // Create JSON payload
      final Map<String, dynamic> payload = {
        'user_id': userId,
        'new_password': _newPasswordController.text,
        'current_password': _currentPasswordController.text,
      };

      // Print request details
      print('Request URL: $url');
      print('Request Body: ${jsonEncode(payload)}');

      // Send JSON request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(payload),
      );

      final jsonResponse = jsonDecode(response.body);

      // Print response details
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      setState(() {
        _isLoading = false;
      });

      // Validate server response structure
      if (!jsonResponse.containsKey('status') ||
          !jsonResponse.containsKey('message')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid server response')),
        );
        return;
      }

      if (response.statusCode == 200) {
        if (jsonResponse['status'] == 'true') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password updated successfully')),
          );
          // Clear form
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Editprofilepage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                jsonResponse['message'] ?? 'Failed to update password',
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              jsonResponse['message'] ?? 'Failed to update password',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildValidationItem(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check : Icons.circle_outlined,
            color: isValid ? Colors.teal : Colors.grey.shade400,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: isValid ? Colors.teal : Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String? errorText) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
        errorText: errorText, // Show error text if not null
        errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.teal, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 10,
        ),
      ),
      style: const TextStyle(fontSize: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(_currentPasswordController, 'Current Password',
                _currentPasswordError),
            const SizedBox(height: 12),
            _buildTextField(
                _newPasswordController, 'New Password', _newPasswordError),
            const SizedBox(height: 12),
            _buildTextField(_confirmPasswordController, 'Confirm Password',
                _confirmPasswordError),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey.shade50,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Password requirements:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildValidationItem('One lowercase & uppercase character',
                      _hasLowerAndUpperCase),
                  _buildValidationItem(
                      'One number & symbol', _hasNumberAndSymbol),
                  _buildValidationItem('6+ characters', _hasMinLength),
                ],
              ),
            ),
            const SizedBox(height: 20),
            StyledButton(
              text: 'Save',
              icon: Icons.save,
              onPressed: _saveForm,
            ),
          ],
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
            ),
          ),
      ],
    );
  }
}
