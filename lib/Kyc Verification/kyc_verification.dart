import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:another_stepper/another_stepper.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:quickenlancer_apk/Colors/colorfile.dart'; // Adjust import path
import '../../api/network/uri.dart'; // Adjust import path
import '../Update Profile/shared_widgets.dart';
import 'package:http_parser/http_parser.dart';
// import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart'; // PhonePe SDK
import 'package:crypto/crypto.dart'; // For checksum generation

// Data Models
class Country {
  final String id, name, code;
  const Country({required this.id, required this.name, this.code = ''});
  factory Country.fromJson(Map<String, dynamic> json) => Country(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        code: json['phone_code']?.toString() ?? '',
      );
}

class Region {
  final String id, name;
  Region({required this.id, required this.name});
  factory Region.fromJson(Map<String, dynamic> json) => Region(
        id: json['id']?.toString() ?? '',
        name: json['state_name']?.toString() ?? '',
      );
}

class City {
  final String id, name;
  City({required this.id, required this.name});
  factory City.fromJson(Map<String, dynamic> json) => City(
        id: json['id']?.toString() ?? '',
        name: json['city_name']?.toString() ?? '',
      );
}

class KYCVerificationPage extends StatefulWidget {
  const KYCVerificationPage({super.key});
  @override
  _KYCVerificationPageState createState() => _KYCVerificationPageState();
}

class _KYCVerificationPageState extends State<KYCVerificationPage> {
  int _currentStep = 0;
  bool _isContainerVisible = false,
      _isSubmitting = false,
      _isRecording = false,
      _isApiLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _controllers = {
    'firstName': TextEditingController(),
    'lastName': TextEditingController(),
    'email': TextEditingController(),
    'mobile': TextEditingController(),
    'address': TextEditingController(),
    'idProofName': TextEditingController(),
    'idProofNumber': TextEditingController(),
  };
  String? _selectedGender, _idProofFileError, _cameraError;
  Country? _selectedCountry, _selectedCountryCode;
  Region? _selectedState;
  City? _selectedCity;
  File? _idProofFile;
  CameraController? _cameraController;
  VideoPlayerController? _videoPlayerController;
  XFile? _recordedVideo;
  Timer? _timer;
  int _recordingSeconds = 0;
  final _genderOptions = ['Male', 'Female', 'Others'];
  List<Country> _countries = [];
  static const List<Country> _staticCountryCodes = [
    Country(id: '1', name: 'United States', code: '+1'),
    Country(id: '2', name: 'India', code: '+91'),
    Country(id: '3', name: 'United Kingdom', code: '+44'),
    Country(id: '4', name: 'Canada', code: '+1'),
    Country(id: '5', name: 'Australia', code: '+61'),
    Country(id: '6', name: 'Germany', code: '+49'),
    Country(id: '7', name: 'France', code: '+33'),
    Country(id: '8', name: 'Brazil', code: '+55'),
    Country(id: '9', name: 'South Africa', code: '+27'),
    Country(id: '10', name: 'Japan', code: '+81'),
  ];
  List<Region> _states = [];
  List<City> _cities = [];
  String _country = '';
  String _paidVia = '';

  @override
  void initState() {
    super.initState();
    _initializePreferences();

    _initializeCamera();
    _fetchCountries();
    _fetchProfileDetails();
  }

  Future<void> _initializePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _country = prefs.getString('country') ?? '';
    _paidVia = _country == "101" ? "2" : "1";
    print('Country: $_country, PaidVia: $_paidVia');
  }

  Future<void> _fetchProfileDetails() async {
    setState(() => _isApiLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final authToken = prefs.getString('auth_token');
      final requestBody = {'user_id': userId};
      print('Profile Details Request Body: $requestBody');

      final response = await http.post(
        Uri.parse(URLS().get_profile_details),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(requestBody),
      );

      print('Profile Details Response Status: ${response.statusCode}');
      print('Profile Details Response Body: ${response.body}');

      if (response.statusCode == 200 &&
          jsonDecode(response.body)['status'] == 'true') {
        final data = jsonDecode(response.body)['data']['basic_details'];
        setState(() {
          _controllers['firstName']!.text = data['f_name'] ?? '';
          _controllers['lastName']!.text = data['l_name'] ?? '';
          _controllers['email']!.text = data['email'] ?? '';
          _controllers['mobile']!.text = data['mobile_no']?.toString() ?? '';
          _selectedGender = data['gender'] == '0'
              ? 'Male'
              : data['gender'] == '1'
                  ? 'Female'
                  : 'Others';
          _selectedCountryCode = _staticCountryCodes.firstWhere(
            (c) => c.code == data['country_code'],
            orElse: () => Country(id: '', name: '', code: ''),
          );
          if (_selectedCountryCode!.id.isEmpty) _selectedCountryCode = null;
        });

        if (data['country_name']?.isNotEmpty ?? false) {
          _selectedCountry = _countries.firstWhere(
            (c) => c.name == data['country_name'],
            orElse: () => Country(id: '', name: ''),
          );
          if (_selectedCountry!.id.isNotEmpty) {
            await _fetchStates();
            if (data['state']?.isNotEmpty ?? false) {
              _selectedState = _states.firstWhere(
                (s) => s.id == data['state'],
                orElse: () => Region(id: '', name: ''),
              );
              if (_selectedState!.id.isNotEmpty) {
                await _fetchCities();
                _selectedCity = _cities.firstWhere(
                  (c) => c.name == data['city_name'],
                  orElse: () => City(id: '', name: ''),
                );
              }
            }
          }
        }
      } else {
        _showSnackBar('Failed to fetch profile');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => _isApiLoading = false);
    }
  }

  Future<void> _updateBasicDetails() async {
    setState(() => _isApiLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final authToken = prefs.getString('auth_token');
      final requestBody = {
        'user_id': userId,
        'f_name': _controllers['firstName']!.text,
        'l_name': _controllers['lastName']!.text,
        'gender': _selectedGender == 'Male'
            ? '0'
            : _selectedGender == 'Female'
                ? '1'
                : '2',
        'mobile_no': _controllers['mobile']!.text,
        'country_code': _selectedCountryCode?.code ?? '',
        'country': _selectedCountry?.id ?? '',
        'state': _selectedState?.id ?? '',
        'city': _selectedCity?.id ?? '',
        'address': _controllers['address']!.text,
      };
      print('Update Basic Details Request Body: $requestBody');

      final response = await http.post(
        Uri.parse(URLS().update_basic_details),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(requestBody),
      );

      print('Update Basic Details Response Status: ${response.statusCode}');
      print('Update Basic Details Response Body: ${response.body}');

      final data = jsonDecode(response.body);
      _showSnackBar(response.statusCode == 200 && data['status'] == 'true'
          ? 'Profile updated'
          : 'Failed to update: ${data['message'] ?? response.statusCode}');
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => _isApiLoading = false);
    }
  }

  Future<void> _submitKYCDocuments() async {
    setState(() => _isApiLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final authToken = prefs.getString('auth_token');

      var request =
          http.MultipartRequest('POST', Uri.parse(URLS().submit_kyc_documents));
      request.headers['Authorization'] = 'Bearer $authToken';
      request.fields['id_proof_name'] = _controllers['idProofName']!.text;
      request.fields['id_proof_number'] = _controllers['idProofNumber']!.text;
      request.fields['user_id'] = userId;

      if (_idProofFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'documents',
          _idProofFile!.path,
          contentType: MediaType('image', _idProofFile!.path.split('.').last),
        ));
      }

      print('KYC Documents Request URL: ${request.url}');
      print('KYC Documents Request Headers: ${request.headers}');
      print('KYC Documents Request Fields: ${request.fields}');
      print(
          'KYC Documents Request Files: ${request.files.map((f) => f.filename).toList()}');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('KYC Documents Response Status Code: ${response.statusCode}');
      print('KYC Documents Response Body: $responseBody');

      final data = jsonDecode(responseBody);

      if (response.statusCode == 200 && data['status'] == 'true') {
        _showSnackBar('Documents submitted successfully');
      } else {
        _showSnackBar(
            'Failed to submit documents: ${data['message'] ?? response.statusCode}');
      }
    } catch (e) {
      print('KYC Documents Exception: $e');
      _showSnackBar('Error submitting documents: $e');
    } finally {
      setState(() => _isApiLoading = false);
    }
  }

  Future<void> _submitKYCVideo() async {
    setState(() => _isApiLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final authToken = prefs.getString('auth_token');

      var request =
          http.MultipartRequest('POST', Uri.parse(URLS().submit_kyc_video));
      request.headers['Authorization'] = 'Bearer $authToken';
      request.fields['user_id'] = userId;

      if (_recordedVideo != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'kyc_video',
          _recordedVideo!.path,
          contentType: MediaType('video', _recordedVideo!.path.split('.').last),
        ));
      }

      print('KYC Video Request URL: ${request.url}');
      print('KYC Video Request Headers: ${request.headers}');
      print('KYC Video Request Fields: ${request.fields}');
      print(
          'KYC Video Request Files: ${request.files.map((f) => f.filename).toList()}');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('KYC Video Response Status Code: ${response.statusCode}');
      print('KYC Video Response Body: $responseBody');

      final data = jsonDecode(responseBody);

      if (response.statusCode == 200 && data['status'] == 'true') {
        _showSnackBar('Video submitted successfully');
      } else {
        _showSnackBar(
            'Failed to submit video: ${data['message'] ?? response.statusCode}');
      }
    } catch (e) {
      print('KYC Video Exception: $e');
      _showSnackBar('Error submitting video: $e');
    } finally {
      setState(() => _isApiLoading = false);
    }
  }

  Future<void> _initializeCamera() async {
    setState(() => _isApiLoading = true);
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => throw 'No front camera',
      );
      _cameraController =
          CameraController(frontCamera, ResolutionPreset.medium);
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      setState(() => _cameraError = 'Camera error: $e');
    } finally {
      setState(() => _isApiLoading = false);
    }
  }

  void _startRecording() async {
    if (_cameraController?.value.isInitialized ?? false) {
      try {
        await _cameraController!.startVideoRecording();
        setState(() {
          _isRecording = true;
          _recordingSeconds = 0;
        });
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() => _recordingSeconds++);
        });
      } catch (e) {
        _showSnackBar('Recording error: $e');
      }
    }
  }

  void _stopRecording() async {
    if (_cameraController?.value.isRecordingVideo ?? false) {
      try {
        _recordedVideo = await _cameraController!.stopVideoRecording();
        _timer?.cancel();
        _videoPlayerController =
            VideoPlayerController.file(File(_recordedVideo!.path));
        await _videoPlayerController!.initialize();
        setState(() => _isRecording = false);
        await _initializeCamera();
      } catch (e) {
        _showSnackBar('Stop recording error: $e');
      }
    }
  }

  void _reRecord() async {
    await _videoPlayerController?.dispose();
    setState(() {
      _videoPlayerController = null;
      _recordedVideo = null;
      _cameraError = null;
    });
    await _initializeCamera();
  }

  Future<void> _pickIdProofFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        if (await file.length() > 100 * 1024) {
          setState(() => _idProofFileError = 'File size exceeds 100KB');
          return;
        }
        setState(() {
          _idProofFile = file;
          _idProofFileError = null;
        });
      } else {
        setState(() => _idProofFileError = 'No file selected');
      }
    } catch (e) {
      setState(() => _idProofFileError = 'Error: $e');
    }
  }

  Future<void> _fetchCountries() async {
    setState(() => _isApiLoading = true);
    try {
      final requestBody = {'country_id': ''};
      print('Countries Request Body: $requestBody');

      final response = await http.post(
        Uri.parse(URLS().countries),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Countries Response Status: ${response.statusCode}');
      print('Countries Response Body: ${response.body}');

      final json = jsonDecode(response.body);
      if (response.statusCode == 200 && json['status'] == 'true') {
        setState(() {
          _countries = (json['data'] as List)
              .map((item) => Country.fromJson(item))
              .where((c) => c.id.isNotEmpty && c.name.isNotEmpty)
              .toList();
        });
      } else {
        _showSnackBar('Failed to load countries');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => _isApiLoading = false);
    }
  }

  Future<void> _fetchStates() async {
    if (_selectedCountry == null) return;
    setState(() => _isApiLoading = true);
    try {
      final requestBody = {'country_id': _selectedCountry!.id, 'state_id': ''};
      print('States Request Body: $requestBody');

      final response = await http.post(
        Uri.parse(URLS().states),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('States Response Status: ${response.statusCode}');
      print('States Response Body: ${response.body}');

      final json = jsonDecode(response.body);
      if (response.statusCode == 200 && json['status'] == 'true') {
        setState(() {
          _states = (json['data'] as List)
              .map((item) => Region.fromJson(item))
              .where((s) => s.id.isNotEmpty && s.name.isNotEmpty)
              .toList();
          _selectedCity = null;
          _cities = [];
        });
      } else {
        _showSnackBar('Failed to load states');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => _isApiLoading = false);
    }
  }

  Future<void> _fetchCities() async {
    if (_selectedCountry == null || _selectedState == null) return;
    setState(() => _isApiLoading = true);
    try {
      final requestBody = {
        'country_id': _selectedCountry!.id,
        'state_id': _selectedState!.id,
        'city_id': ''
      };
      print('Cities Request Body: $requestBody');

      final response = await http.post(
        Uri.parse(URLS().cities),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Cities Response Status: ${response.statusCode}');
      print('Cities Response Body: ${response.body}');

      final json = jsonDecode(response.body);
      if (response.statusCode == 200 && json['status'] == 'true') {
        setState(() {
          _cities = (json['data'] as List)
              .map((item) => City.fromJson(item))
              .where((c) => c.id.isNotEmpty && c.name.isNotEmpty)
              .toList();
        });
      } else {
        _showSnackBar('Failed to load cities');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => _isApiLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose();
    _videoPlayerController?.dispose();
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  String? _sanitizeInput(String? input) {
    if (input == null || input.isEmpty) return null;
    final xssPattern = RegExp(
        r'(<script>|</script>|javascript:|onerror|onload|alert\(|<iframe|<img|<svg|<object)',
        caseSensitive: false);
    return xssPattern.hasMatch(input) ? 'Enter a valid input' : null;
  }

  String? _validateField(String? value, String field,
      {bool isEmail = false, bool isMobile = false}) {
    if (value == null || value.isEmpty) return 'Please enter $field';
    if (isEmail && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value))
      return 'Invalid email';
    if (isMobile && !RegExp(r'^\d{10}$').hasMatch(value))
      return 'Invalid 10-digit mobile';
    return _sanitizeInput(value);
  }

  bool _validateStep(int step) {
    setState(() {
      _idProofFileError = null;
      _cameraError = null;
    });
    bool isValid = true;
    if (step == 0 || step == 3) {
      if ((step == 0 || _formKey.currentState != null) &&
          (_formKey.currentState?.validate() == false ||
              _selectedGender == null ||
              _selectedCountry == null ||
              _selectedCountryCode == null ||
              (_states.isNotEmpty && _selectedState == null) ||
              (_cities.isNotEmpty && _selectedCity == null))) {
        isValid = false;
      }
    }
    if (step == 1 || step == 3) {
      if (_controllers['idProofName']!.text.isEmpty ||
          _controllers['idProofNumber']!.text.isEmpty ||
          _idProofFile == null) {
        setState(() => _idProofFileError = 'Complete ID Proof details');
        isValid = false;
      }
    }
    if (step == 2 || step == 3) {
      if (_recordedVideo == null) {
        setState(() => _cameraError = 'Video required');
        isValid = false;
      }
    }
    return isValid;
  }

  Future<void> _initiatePhonePePayment() async {
    try {
      setState(() => _isApiLoading = true);
      print('Initiating PhonePe payment for amount ₹1');
      _showSnackBar('PhonePe payment initiated');

      // Initialize PhonePe SDK
      String merchantId =
          'YOUR_MERCHANT_ID'; // Replace with your PhonePe Merchant ID
      String appId = ''; // Optional, can be empty
      String saltKey = 'YOUR_SALT_KEY'; // Replace with your PhonePe Salt Key
      String saltIndex =
          'YOUR_SALT_INDEX'; // Replace with your Salt Index (e.g., '1')
      bool enableLogging = true; // Set to false in production
      String environment = 'SANDBOX'; // Use 'PRODUCTION' for live environment

      // await PhonePePaymentSdk.init(
      //   environment,
      //   appId,
      //   merchantId,
      //   enableLogging,
      // );

      // Prepare payment request payload
      String amount = '100'; // Amount in paise (₹1 = 100 paise)
      String transactionId =
          'TX${DateTime.now().millisecondsSinceEpoch}'; // Unique transaction ID
      String callbackUrl =
          'https://your-callback-url.com'; // Replace with your callback URL
      String redirectUrl =
          'https://your-redirect-url.com'; // Replace with your redirect URL

      // Generate checksum
      String payload =
          '{"merchantId":"$merchantId","transactionId":"$transactionId","amount":$amount,"redirectUrl":"$redirectUrl","callbackUrl":"$callbackUrl"}';
      String checksum = _generateChecksum(payload, saltKey, saltIndex);

      // Start PhonePe payment
      // var response = await PhonePePaymentSdk.startTransaction(
      //   payload,
      //   checksum,
      //   // Optional package name for UPI apps
      // );

      // Handle response
      // if (response != null && response['status'] == 'SUCCESS') {
      //   _showSnackBar('PhonePe payment successful');
      // } else {
      //   _showSnackBar('PhonePe payment failed or cancelled');
      //   throw Exception('Payment failed or cancelled');
      // }

      await Future.delayed(const Duration(seconds: 2)); // Ensure visibility
    } catch (e) {
      _showSnackBar('PhonePe payment error: $e');
      throw e;
    } finally {
      setState(() => _isApiLoading = false);
    }
  }

  String _generateChecksum(String payload, String saltKey, String saltIndex) {
    String input = '$payload###$saltIndex';
    var bytes = utf8.encode(input + saltKey);
    var hash = sha256.convert(bytes).toString();
    return '$hash###$saltIndex';
  }

  Future<void> _initiateStripePayment() async {
    try {
      print('Initiating Stripe payment for amount ₹1');
      _showSnackBar('Stripe payment initiated');
      await Future.delayed(const Duration(seconds: 2)); // Ensure visibility
      return;
    } catch (e) {
      _showSnackBar('Stripe payment error: $e');
      throw e;
    }
  }

  Future<void> _submitKYCPayment(String userId, String authToken) async {
    try {
      final requestBody = {
        'user_id': userId,
        'transaction_id': 10,
        'gateway_ref_no': 0,
        'payment_status': '1',
      };
      print('KYC Payment Request Body: $requestBody');

      final response = await http.post(
        Uri.parse(URLS().submit_kyc_payment),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(requestBody),
      );

      print('KYC Payment Response Status: ${response.statusCode}');
      print('KYC Payment Response Body: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == 'true') {
        _showSnackBar('Payment details submitted successfully');
      } else {
        _showSnackBar(
            'Failed to submit payment details: ${data['message'] ?? response.statusCode}');
      }
    } catch (e) {
      print('KYC Payment Exception: $e');
      _showSnackBar('Error submitting payment details: $e');
    }
  }

  void _submitKYC() async {
    if (!_validateStep(3)) {
      _showSnackBar('Complete all fields');
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final authToken = prefs.getString('auth_token') ?? '';

      if (_paidVia == '2') {
        await _initiatePhonePePayment();
      } else {
        // await _initiateStripePayment();
        await _initiatePhonePePayment();
      }

      await _submitKYCPayment(userId, authToken);

      await Future.delayed(const Duration(seconds: 2));
      _showSnackBar('KYC Submitted Successfully!');
      await Future.delayed(const Duration(seconds: 2)); // Ensure visibility
    } catch (e) {
      _showSnackBar('Error during KYC submission: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
      );
    }
  }

  String _formatDuration(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

  Widget _buildFileSection() => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upload ID Proof *',
                style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colorfile.textColor)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border.all(
                    color: _idProofFileError != null
                        ? Colors.red
                        : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _idProofFileError ??
                          (_idProofFile == null
                              ? 'Choose file'
                              : _idProofFile!.path.split('/').last),
                      style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: _idProofFileError != null
                              ? Colors.red
                              : Colorfile.textColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StyledButton(
                      text: 'Choose File',
                      icon: Icons.upload,
                      onPressed: _pickIdProofFile),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('Image size < 100KB (JPG, JPEG, PNG)',
                style: GoogleFonts.montserrat(
                    fontSize: 12, color: Colors.blueGrey)),
            if (_idProofFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_idProofFile!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                            child: Text('Invalid image',
                                style: GoogleFonts.montserrat(
                                    fontSize: 12, color: Colors.red)))),
                  ),
                ),
              ),
          ],
        ),
      );

  Widget _buildVideoSection() => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Record Verification *',
                style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colorfile.textColor)),
            const SizedBox(height: 8),
            if (_cameraError != null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8)),
                child: Center(
                    child: Text(_cameraError!,
                        style: GoogleFonts.montserrat(
                            fontSize: 14, color: Colors.red),
                        textAlign: TextAlign.center)),
              )
            else if (_recordedVideo != null && _videoPlayerController != null)
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8)),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: VideoPlayer(_videoPlayerController!)),
                  ),
                  IconButton(
                    icon: Icon(
                        _videoPlayerController!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 48),
                    onPressed: () => setState(() =>
                        _videoPlayerController!.value.isPlaying
                            ? _videoPlayerController!.pause()
                            : _videoPlayerController!.play()),
                  ),
                ],
              )
            else if (_cameraController != null &&
                _cameraController!.value.isInitialized)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8)),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CameraPreview(_cameraController!)),
                  ),
                  if (_isRecording)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(_formatDuration(_recordingSeconds),
                            style: GoogleFonts.montserrat(
                                fontSize: 12, color: Colors.white)),
                      ),
                    ),
                ],
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8)),
                child: Center(
                    child: Text('Initializing camera...',
                        style: GoogleFonts.montserrat(
                            fontSize: 14, color: Colorfile.textColor))),
              ),
            const SizedBox(height: 12),
            Center(
              child: StyledButton(
                text: _recordedVideo != null
                    ? 'Re-Record'
                    : (_isRecording ? 'Stop' : 'Record'),
                icon: _recordedVideo != null
                    ? Icons.videocam
                    : (_isRecording ? Icons.stop : Icons.videocam),
                onPressed: (_cameraError != null ||
                            _cameraController == null ||
                            !_cameraController!.value.isInitialized) &&
                        _recordedVideo == null
                    ? null
                    : (_recordedVideo != null
                        ? _reRecord
                        : (_isRecording ? _stopRecording : _startRecording)),
                buttonColor: _isRecording ? Colors.red : null,
              ),
            ),
          ],
        ),
      );
  @override
  Widget build(BuildContext context) {
    final stepContents = [
      _buildStep(
        title: 'Personal Information',
        subtitle: 'Provide your personal details.',
        content: Form(
          key: _formKey,
          child: Column(
            children: [
              SharedWidgets.textField(_controllers['firstName']!, 'First Name',
                  validator: (v) => _validateField(v, 'first name')),
              SharedWidgets.textField(_controllers['lastName']!, 'Last Name',
                  validator: (v) => _validateField(v, 'last name')),
              TextField(
                controller: _controllers['email'],
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: GoogleFonts.montserrat(
                      fontSize: 14, color: Colorfile.textColor),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
                style: GoogleFonts.montserrat(
                    fontSize: 14, color: Colorfile.textColor),
              ),
              const SizedBox(height: 16),
              SharedWidgets.dropdown<String>(
                label: 'Gender',
                value: _selectedGender,
                items: _genderOptions,
                onChanged: (v) => setState(() => _selectedGender = v),
                itemAsString: (g) => g,
                validator: (v) => v == null ? 'Select gender' : null,
              ),
              SharedWidgets.dropdown<Country>(
                label: 'Country Code',
                value: _selectedCountryCode,
                items: _staticCountryCodes,
                onChanged: (v) => setState(() => _selectedCountryCode = v),
                itemAsString: (c) => '${c.name} (${c.code})',
                validator: (v) => v == null ? 'Select country code' : null,
              ),
              SharedWidgets.textField(
                _controllers['mobile']!,
                'Mobile Number',
                validator: (v) =>
                    _validateField(v, 'mobile number', isMobile: true),
                keyboardType: TextInputType.phone,
              ),
              SharedWidgets.dropdown<Country>(
                label: 'Country',
                value: _selectedCountry,
                items: _countries,
                onChanged: (v) {
                  setState(() {
                    _selectedCountry = v;
                    _selectedState = null;
                    _selectedCity = null;
                    _states = [];
                    _cities = [];
                  });
                  _fetchStates();
                },
                itemAsString: (c) => c.name,
                validator: (v) => v == null ? 'Select country' : null,
              ),
              if (_selectedCountry != null)
                SharedWidgets.dropdown<Region>(
                  label: 'State',
                  value: _selectedState,
                  items: _states,
                  onChanged: (v) {
                    setState(() {
                      _selectedState = v;
                      _selectedCity = null;
                      _cities = [];
                    });
                    _fetchCities();
                  },
                  itemAsString: (s) => s.name,
                  validator: (v) =>
                      v == null && _states.isNotEmpty ? 'Select state' : null,
                ),
              if (_selectedState != null)
                SharedWidgets.dropdown<City>(
                  label: 'City',
                  value: _selectedCity,
                  items: _cities,
                  onChanged: (v) => setState(() => _selectedCity = v),
                  itemAsString: (c) => c.name,
                  validator: (v) =>
                      v == null && _cities.isNotEmpty ? 'Select city' : null,
                ),
              SharedWidgets.textField(_controllers['address']!, 'Address',
                  maxLines: 3, validator: (v) => _validateField(v, 'address')),
            ],
          ),
        ),
      ),
      _buildStep(
        title: 'ID Proof Details',
        subtitle: 'Provide and upload ID proof.',
        content: Column(
          children: [
            SharedWidgets.textField(
                _controllers['idProofName']!, 'ID Proof Name',
                validator: (v) => _validateField(v, 'ID proof name')),
            SharedWidgets.textField(
                _controllers['idProofNumber']!, 'ID Proof Number',
                validator: (v) => _validateField(v, 'ID proof number'),
                keyboardType: TextInputType.number),
            _buildFileSection(),
          ],
        ),
      ),
      _buildStep(
        title: 'Verification Video',
        subtitle: 'Record a short video.',
        content: _buildVideoSection(),
      ),
      _buildStep(
        title: 'Confirm Payment',
        subtitle: 'Review details and pay.',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('₹1',
                style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colorfile.textColor)),
            const SizedBox(height: 12),
            Text('Confirm Payment',
                style: GoogleFonts.montserrat(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Complete KYC with a nominal payment.',
                style:
                    GoogleFonts.montserrat(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    ];

    void _handleBackPress(BuildContext context) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Confirm Exit'),
          content: Text('Are you sure you want to go back?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), // Close dialog
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog
                if (Navigator.canPop(context)) {
                  Navigator.pop(context); // Pop the current screen
                }
              },
              child: Text('Yes'),
            ),
          ],
        ),
      );
    }

    return ScaffoldMessenger(
      child: Scaffold(
        backgroundColor: Colorfile.body,
        appBar: AppBar(
          backgroundColor: Colorfile.body,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colorfile.textColor),
            onPressed: () =>
                _handleBackPress(context), // Only call _handleBackPress
          ),
          title: Text('KYC Verification',
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
                        height: 120,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [Color(0xFFB7D7F9), Color(0xFFE5ACCB)],
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Text('Why Quickenlancer KYC?',
                                          style: GoogleFonts.montserrat(
                                              color: Colorfile.textColor,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold))),
                                  Container(
                                    width: 25,
                                    height: 25,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colorfile.textColor,
                                            width: 1)),
                                    child: Center(
                                        child: Transform.rotate(
                                            angle: _isContainerVisible
                                                ? 1.57
                                                : 4.72,
                                            child: Icon(
                                                Icons.chevron_left_outlined,
                                                color: Colorfile.textColor,
                                                size: 20))),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Secure and verified user identities.',
                                  style: GoogleFonts.montserrat(
                                      color: Colorfile.textColor,
                                      fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _isContainerVisible ? 150 : 0,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Color(0xFFB7D7F9), Color(0xFFE5ACCB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight)),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: const Color(0xFFE0E0E0), width: 1)),
                            child: ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFB7D7F9),
                                          Color(0xFFE5ACCB)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight)),
                                child: ClipOval(
                                    child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Icon(Icons.verified_user,
                                            color: Colors.white))),
                              ),
                              title: Text('Secure Verification',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colorfile.textColor)),
                              subtitle: Text(
                                  'Ensure a trusted platform experience.',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnotherStepper(
                      stepperList: List.generate(
                          4,
                          (_) => StepperData(
                              iconWidget: Icon(Icons.circle,
                                  size: 20, color: Color(0xFF8B3A99)))),
                      stepperDirection: Axis.horizontal,
                      activeBarColor: Color(0xFF8B3A99),
                      inActiveBarColor: Color(0xFFD9D9D9),
                      iconWidth: 18,
                      iconHeight: 20,
                      barThickness: 2,
                      activeIndex: _currentStep,
                    ),
                    const SizedBox(height: 20),
                    _isApiLoading
                        ? Center(
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor)))
                        : stepContents[_currentStep],
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_currentStep > 0)
                            StyledButton(
                                text: 'Previous',
                                icon: Icons.arrow_back,
                                onPressed: () => setState(() => _currentStep--),
                                buttonColor: null),
                          StyledButton(
                            text: _currentStep == stepContents.length - 1
                                ? 'Submit'
                                : 'Next',
                            icon: _currentStep == stepContents.length - 1
                                ? Icons.check
                                : Icons.arrow_forward,
                            onPressed: () async {
                              if (_currentStep < stepContents.length - 1) {
                                if (_validateStep(_currentStep)) {
                                  if (_currentStep == 0) {
                                    _formKey.currentState?.save();
                                    await _updateBasicDetails();
                                    if (mounted) setState(() => _currentStep++);
                                  } else if (_currentStep == 1) {
                                    await _submitKYCDocuments();
                                    if (mounted) setState(() => _currentStep++);
                                  } else if (_currentStep == 2) {
                                    await _submitKYCVideo();
                                    if (mounted) setState(() => _currentStep++);
                                  } else {
                                    setState(() => _currentStep++);
                                  }
                                } else {
                                  _showSnackBar('Complete all fields');
                                }
                              } else {
                                _submitKYC();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            if (_isSubmitting || _isApiLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                    child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white))),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(
          {required String title,
          required String subtitle,
          required Widget content}) =>
      Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colorfile.textColor)),
            const SizedBox(height: 8),
            Text(subtitle,
                style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colorfile.textColor)),
            const SizedBox(height: 8),
            content,
          ],
        ),
      );
}

class StyledButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? buttonColor;

  const StyledButton(
      {Key? key,
      required this.text,
      required this.icon,
      required this.onPressed,
      this.buttonColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        height: 42,
        decoration: BoxDecoration(
          gradient: buttonColor == null
              ? LinearGradient(
                  colors: [Color(0xFFB7D7F9), Color(0xFFE5ACCB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)
              : null,
          color: buttonColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.black),
          label: Text(text,
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w500)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
      );
}
