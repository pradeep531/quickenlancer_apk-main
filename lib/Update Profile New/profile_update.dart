import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../../api/network/uri.dart'; // Adjust path as per your project structure
import '../../editprofilepage.dart'; // Adjust path as per your project structure

// Data Models
class Country {
  final String id;
  final String name;
  final String code; // Country code (e.g., +1, +91)

  const Country({required this.id, required this.name, this.code = ''});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['phone_code']?.toString() ?? '',
    );
  }
}

class Region {
  final String id;
  final String name;

  Region({required this.id, required this.name});

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id']?.toString() ?? '',
      name: json['state_name']?.toString() ?? '',
    );
  }
}

class City {
  final String id;
  final String name;

  City({required this.id, required this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id']?.toString() ?? '',
      name: json['city_name']?.toString() ?? '',
    );
  }
}

class Currency {
  final String id;
  final String name;

  Currency({required this.id, required this.name});

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json['id']?.toString() ?? '',
      name: json['lable']?.toString() ?? '',
    );
  }
}

// Custom TextField Widget
Widget CustomTextField(
  TextEditingController controller,
  String label, {
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  String? Function(String?)? validator,
  InputDecoration? decoration, // Added decoration parameter
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Material(
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: decoration ??
            InputDecoration(
              labelText: label,
              labelStyle: GoogleFonts.montserrat(
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
              border: const OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            ),
        validator: validator,
      ),
    ),
  );
}

// Custom Non-Editable TextField Widget
Widget NonEditTextField(
  TextEditingController controller,
  String label, {
  TextInputType keyboardType = TextInputType.text,
  bool enabled = false,
  String? Function(String?)? validator,
  InputDecoration? decoration, // Added decoration parameter
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Material(
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        decoration: decoration ??
            InputDecoration(
              labelText: label,
              labelStyle: GoogleFonts.montserrat(
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
              border: const OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              filled: true,
              fillColor: Colors.grey[200],
            ),
        validator: validator,
      ),
    ),
  );
}

class ProfilePageNew extends StatefulWidget {
  const ProfilePageNew({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePageNew> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colorfile.textColor,
          ),
        ),
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colorfile.textColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Color(0xFFD9D9D9),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ProfileForm(),
        ),
      ),
    );
  }
}

class ProfileForm extends StatefulWidget {
  const ProfileForm({Key? key}) : super(key: key);

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _designationController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  Country? _selectedCountry;
  Region? _selectedState;
  City? _selectedCity;
  Currency? _selectedCurrency;
  String? _selectedGender;
  File? _profileImage;
  String? _profileImageUrl;
  Country? _selectedCountryCode;
  bool _isLoading = false;
  List<Country> _countries = [];
  List<Region> _states = [];
  List<City> _cities = [];
  List<Currency> _currencies = [];
  final List<String> _genders = ['Male', 'Female', 'Others'];

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

  @override
  void initState() {
    super.initState();
    _fetchApiResponses();
    fetchProfileDetails();
  }

  Future<void> fetchProfileDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final String? authToken = prefs.getString('auth_token');

      final url = Uri.parse(URLS().get_profile_details);
      final body = jsonEncode({'user_id': userId});

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Profile details: $responseData');

        if (responseData['status'] == 'true') {
          final basicDetails = responseData['data']['basic_details'];

          setState(() {
            _firstNameController.text = basicDetails['f_name'] ?? '';
            _lastNameController.text = basicDetails['l_name'] ?? '';
            _designationController.text =
                basicDetails['profile_description'] ?? '';
            _addressController.text = basicDetails['address'] ?? '';
            _mobileController.text =
                basicDetails['mobile_no']?.toString() ?? '';
            _emailController.text = basicDetails['email'] ?? '';
            _profileImageUrl = basicDetails['profile_pic_path'] ?? '';

            String genderValue = basicDetails['gender']?.toString() ?? '';
            if (genderValue == '0') {
              _selectedGender = 'Male';
            } else if (genderValue == '1') {
              _selectedGender = 'Female';
            } else {
              _selectedGender = 'Others';
            }

            String countryCode = basicDetails['country_code'] ?? '';
            if (countryCode.isNotEmpty) {
              _selectedCountryCode = _staticCountryCodes.firstWhere(
                (country) => country.code == countryCode,
                orElse: () => Country(id: '', name: '', code: ''),
              );
              if (_selectedCountryCode!.id.isEmpty) {
                _selectedCountryCode = null;
              }
            }
          });

          String countryName = basicDetails['country_name'] ?? '';
          if (countryName.isNotEmpty && _countries.isNotEmpty) {
            Country? matchedCountry = _countries.firstWhere(
              (country) => country.name == countryName,
              orElse: () => Country(id: '', name: ''),
            );
            if (matchedCountry.id.isNotEmpty) {
              setState(() {
                _selectedCountry = matchedCountry;
              });
              await _fetchStates();

              String stateId = basicDetails['state']?.toString() ?? '';
              if (stateId.isNotEmpty && _states.isNotEmpty) {
                Region? matchedState = _states.firstWhere(
                  (state) => state.id == stateId,
                  orElse: () => Region(id: '', name: ''),
                );
                if (matchedState.id.isNotEmpty) {
                  setState(() {
                    _selectedState = matchedState;
                  });
                  await _fetchCities();

                  String cityName = basicDetails['city_name'] ?? '';
                  if (cityName.isNotEmpty && _cities.isNotEmpty) {
                    City? matchedCity = _cities.firstWhere(
                      (city) => city.name == cityName,
                      orElse: () => City(id: '', name: ''),
                    );
                    if (matchedCity.id.isNotEmpty) {
                      setState(() {
                        _selectedCity = matchedCity;
                      });
                    }
                  }
                }
              }
            }
          }

          String currencyName = basicDetails['currency'] ?? '';
          if (currencyName.isNotEmpty && _currencies.isNotEmpty) {
            Currency? matchedCurrency = _currencies.firstWhere(
              (currency) => currency.name == currencyName,
              orElse: () => Currency(id: '', name: ''),
            );
            if (matchedCurrency.id.isNotEmpty) {
              setState(() {
                _selectedCurrency = matchedCurrency;
              });
            }
          }
        }
      } else {
        print('Failed to fetch profile: ${response.statusCode}');
        _showSnackBar(context, 'Failed to fetch profile details');
      }
    } catch (e) {
      print('Error fetching profile: $e');
      _showSnackBar(context, 'Error fetching profile: $e');
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _designationController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchApiResponses() async {
    await _fetchCountries();
    await _fetchCurrencies();
  }

  Future<void> _fetchCountries() async {
    try {
      final requestBody = {'country_id': ''};
      print('Country Request URL: ${URLS().countries}');
      print('Country Request Body: ${jsonEncode(requestBody)}');

      final countryResponse = await http.post(
        Uri.parse(URLS().countries),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Country Response Status Code: ${countryResponse.statusCode}');
      print('Country Response Body: ${countryResponse.body}');

      if (countryResponse.statusCode == 200) {
        final json = jsonDecode(countryResponse.body);
        if (json['status'] == 'true') {
          setState(() {
            _countries = (json['data'] as List)
                .map((item) => Country.fromJson(item))
                .where((country) =>
                    country.id.isNotEmpty && country.name.isNotEmpty)
                .toList();
          });
        } else {
          _showSnackBar(
              context, 'Failed to load countries: ${json['message']}');
        }
      } else {
        _showSnackBar(context, 'Failed to load countries');
      }
    } catch (e) {
      _showSnackBar(context, 'Error fetching countries: $e');
      print('Country Exception: $e');
    }
  }

  Future<void> _fetchStates() async {
    if (_selectedCountry == null) return;

    try {
      final requestBody = {'country_id': _selectedCountry!.id, 'state_id': ''};
      print('State Request URL: ${URLS().states}');
      print('State Request Body: ${jsonEncode(requestBody)}');

      final stateResponse = await http.post(
        Uri.parse(URLS().states),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('State Response Status Code: ${stateResponse.statusCode}');
      print('State Response Body: ${stateResponse.body}');

      if (stateResponse.statusCode == 200) {
        final json = jsonDecode(stateResponse.body);
        if (json['status'] == 'true') {
          setState(() {
            _states = (json['data'] as List)
                .map((item) => Region.fromJson(item))
                .where(
                    (region) => region.id.isNotEmpty && region.name.isNotEmpty)
                .toList();
            _selectedCity = null;
            _cities = [];
          });
        } else {
          _showSnackBar(context, 'Failed to load states: ${json['message']}');
        }
      } else {
        _showSnackBar(context, 'Failed to load states');
      }
    } catch (e) {
      _showSnackBar(context, 'Error fetching states: $e');
      print('State Exception: $e');
    }
  }

  Future<void> _fetchCities() async {
    if (_selectedCountry == null || _selectedState == null) return;

    try {
      final requestBody = {
        'country_id': _selectedCountry!.id,
        'state_id': _selectedState!.id,
        'city_id': ''
      };
      print('City Request URL: ${URLS().cities}');
      print('City Request Body: ${jsonEncode(requestBody)}');

      final cityResponse = await http.post(
        Uri.parse(URLS().cities),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('City Response Status Code: ${cityResponse.statusCode}');
      print('City Response Body: ${cityResponse.body}');

      if (cityResponse.statusCode == 200) {
        final json = jsonDecode(cityResponse.body);
        if (json['status'] == 'true') {
          setState(() {
            _cities = (json['data'] as List)
                .map((item) => City.fromJson(item))
                .where((city) => city.id.isNotEmpty && city.name.isNotEmpty)
                .toList();
          });
        } else {
          _showSnackBar(context, 'Failed to load cities: ${json['message']}');
        }
      } else {
        _showSnackBar(context, 'Failed to load cities');
      }
    } catch (e) {
      _showSnackBar(context, 'Error fetching cities: $e');
      print('City Exception: $e');
    }
  }

  Future<void> _fetchCurrencies() async {
    try {
      print('Currency Request URL: ${URLS().get_currency_api}');

      final currencyResponse = await http.get(
        Uri.parse(URLS().get_currency_api),
        headers: {'Content-Type': 'application/json'},
      );

      print('Currency Response Status Code: ${currencyResponse.statusCode}');
      print('Currency Response Body: ${currencyResponse.body}');

      if (currencyResponse.statusCode == 200) {
        final json = jsonDecode(currencyResponse.body);
        if (json['status'] == 'true') {
          setState(() {
            _currencies = (json['data'] as List)
                .map((item) => Currency.fromJson(item))
                .where((currency) =>
                    currency.id.isNotEmpty && currency.name.isNotEmpty)
                .toList();
          });
        } else {
          _showSnackBar(
              context, 'Failed to load currencies: ${json['message']}');
        }
      } else {
        _showSnackBar(context, 'Failed to load currencies');
      }
    } catch (e) {
      _showSnackBar(context, 'Error fetching currencies: $e');
      print('Currency Exception: $e');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    if (scaffoldMessenger != null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      print('No ScaffoldMessenger found for showing SnackBar: $message');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Notice'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a mobile number';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Please enter a valid 10-digit mobile number';
    }
    return null;
  }

  String? _validateCountryCode(Country? value) {
    if (value == null) {
      return 'Please select a country code';
    }
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final prefs = await SharedPreferences.getInstance();
        final String? authToken = prefs.getString('auth_token');
        final String? userId = prefs.getString('user_id');

        if (authToken == null) {
          _showSnackBar(context, 'Authentication token not found');
          setState(() {
            _isLoading = false;
          });
          return;
        }

        if (userId == null) {
          _showSnackBar(context, 'User ID not found');
          setState(() {
            _isLoading = false;
          });
          return;
        }

        print('Auth Token: $authToken');

        var request = http.MultipartRequest(
          'POST',
          Uri.parse(URLS().set_profil_basic_details),
        );

        request.headers['Authorization'] = 'Bearer $authToken';

        request.fields['user_id'] = userId;
        request.fields['f_name'] = _firstNameController.text;
        request.fields['l_name'] = _lastNameController.text;
        request.fields['designation'] = _designationController.text;
        request.fields['country_code'] = _selectedCountryCode?.code ?? '';
        request.fields['mobile_no'] = _mobileController.text;
        request.fields['gender'] = _selectedGender == 'Male'
            ? '0'
            : _selectedGender == 'Female'
                ? '1'
                : '';
        request.fields['address'] = _addressController.text;
        request.fields['pincode'] = '';
        request.fields['country'] = _selectedCountry?.id ?? '';
        request.fields['state'] = _selectedState?.id ?? '';
        request.fields['city'] = _selectedCity?.id ?? '';
        request.fields['currency'] = _selectedCurrency?.id ?? '';

        if (_profileImage != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'profile_pic',
              _profileImage!.path,
            ),
          );
        }

        print('Profile Save Request URL: ${URLS().set_profil_basic_details}');
        print('Profile Save Request Headers: ${request.headers}');
        print('Profile Save Request Fields: ${request.fields}');
        print(
            'Profile Save Request Files: ${request.files.map((file) => file.filename).toList()}');

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        print('Profile Save Response Status Code: ${response.statusCode}');
        print('Profile Save Response Body: $responseBody');

        final jsonResponse = jsonDecode(responseBody);

        if (response.statusCode == 200 && jsonResponse['status'] == 'true') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Editprofilepage()),
            (route) => route.isFirst,
          );
          _showSnackBar(context, 'Profile saved successfully');
        } else if (response.statusCode == 401) {
          _showSnackBar(context,
              'Unauthorized: Invalid or expired token. Please log in again.');
        } else {
          _showSnackBar(context,
              'Failed to save profile: ${jsonResponse['message'] ?? 'Unknown error'}');
        }
      } catch (e) {
        print('Profile Save Exception: $e');
        _showSnackBar(context, 'Error saving profile: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _deleteProfileImage() {
    setState(() {
      _profileImage = null;
      _profileImageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : _profileImageUrl != null &&
                                  _profileImageUrl!.isNotEmpty
                              ? NetworkImage(_profileImageUrl!)
                              : null,
                      child: _profileImage == null &&
                              (_profileImageUrl == null ||
                                  _profileImageUrl!.isEmpty)
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey[600],
                            )
                          : null,
                    ),
                    if (_profileImage != null || _profileImageUrl != null)
                      Positioned(
                        child: GestureDetector(
                          onTap: _deleteProfileImage,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // First Name Field
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'First Name*',
                style: GoogleFonts.montserrat(
                  color: Colorfile.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            CustomTextField(
              _firstNameController,
              'First Name',
              decoration: InputDecoration(
                hintText: 'Enter first name',
                hintStyle: GoogleFonts.montserrat(
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w400,
                ),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16.0),
              ),
              validator: (value) => _validateRequired(value, 'first name'),
            ),
            // Last Name Field
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Last Name*',
                style: GoogleFonts.montserrat(
                  color: Colorfile.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            CustomTextField(
              _lastNameController,
              'Last Name',
              decoration: InputDecoration(
                hintText: 'Enter last name',
                hintStyle: GoogleFonts.montserrat(
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w400,
                ),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16.0),
              ),
              validator: (value) => _validateRequired(value, 'last name'),
            ),
            // Email Field
            Visibility(
              visible: _emailController.text.isNotEmpty,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Email*',
                      style: GoogleFonts.montserrat(
                        color: Colorfile.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  NonEditTextField(
                    _emailController,
                    'Email',
                    keyboardType: TextInputType.emailAddress,
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: 'Enter email',
                      hintStyle: GoogleFonts.montserrat(
                        color: Colorfile.textColor,
                        fontWeight: FontWeight.w400,
                      ),
                      border: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFD9D9D9), width: 1),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFD9D9D9), width: 1),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFD9D9D9), width: 1),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                    ),
                    validator: _validateEmail,
                  ),
                ],
              ),
            ),
            // Gender Dropdown
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Gender*',
                style: GoogleFonts.montserrat(
                  color: Colorfile.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Material(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: 'Select gender',
                    hintStyle: GoogleFonts.montserrat(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w400,
                    ),
                    border: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFD9D9D9), width: 1),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFD9D9D9), width: 1),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFD9D9D9), width: 1),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                  ),
                  value: _selectedGender,
                  items: _genders
                      .map((gender) => DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a gender' : null,
                ),
              ),
            ),
            // Country Dropdown
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Country*',
                style: GoogleFonts.montserrat(
                  color: Colorfile.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Material(
                child: DropdownButtonFormField<Country>(
                  decoration: InputDecoration(
                    hintText: 'Select country',
                    hintStyle: GoogleFonts.montserrat(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w400,
                    ),
                    border: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFD9D9D9), width: 1),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFD9D9D9), width: 1),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFD9D9D9), width: 1),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                  ),
                  value: _selectedCountry,
                  items: _countries
                      .map((country) => DropdownMenuItem<Country>(
                            value: country,
                            child: Text(country.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCountry = value;
                      _selectedState = null;
                      _selectedCity = null;
                      _states = [];
                      _cities = [];
                    });
                    _fetchStates();
                  },
                  validator: (value) =>
                      value == null ? 'Please select a country' : null,
                ),
              ),
            ),
            // State Dropdown
            if (_selectedCountry != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'State*',
                      style: GoogleFonts.montserrat(
                        color: Colorfile.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Material(
                      child: DropdownButtonFormField<Region>(
                        decoration: InputDecoration(
                          hintText: 'Select state',
                          hintStyle: GoogleFonts.montserrat(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w400,
                          ),
                          border: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFFD9D9D9), width: 1),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFFD9D9D9), width: 1),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFFD9D9D9), width: 1),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                        ),
                        value: _selectedState,
                        items: _states
                            .map((state) => DropdownMenuItem<Region>(
                                  value: state,
                                  child: Text(state.name),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (_states.isNotEmpty) {
                            setState(() {
                              _selectedState = value;
                              _selectedCity = null;
                              _cities = [];
                            });
                            _fetchCities();
                          }
                        },
                        validator: (value) =>
                            value == null ? 'Please select a state' : null,
                      ),
                    ),
                  ),
                ],
              ),
            // City Dropdown
            if (_selectedState != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'City*',
                      style: GoogleFonts.montserrat(
                        color: Colorfile.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Material(
                      child: DropdownButtonFormField<City>(
                        decoration: InputDecoration(
                          hintText: 'Select city',
                          hintStyle: GoogleFonts.montserrat(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w400,
                          ),
                          border: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFFD9D9D9), width: 1),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFFD9D9D9), width: 1),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFFD9D9D9), width: 1),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                        ),
                        value: _selectedCity,
                        items: _cities
                            .map((city) => DropdownMenuItem<City>(
                                  value: city,
                                  child: Text(city.name),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (_cities.isNotEmpty) {
                            setState(() {
                              _selectedCity = value;
                            });
                          }
                        },
                        validator: (value) =>
                            value == null ? 'Please select a city' : null,
                      ),
                    ),
                  ),
                ],
              ),
            // Currency Dropdown
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Currency*',
                style: GoogleFonts.montserrat(
                  color: Colorfile.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Material(
                child: DropdownButtonFormField<Currency>(
                  decoration: InputDecoration(
                    hintText: 'Select currency',
                    hintStyle: GoogleFonts.montserrat(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w400,
                    ),
                    border: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFD9D9D9), width: 1),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFD9D9D9), width: 1),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFD9D9D9), width: 1),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                  ),
                  value: _selectedCurrency,
                  items: _currencies
                      .map((currency) => DropdownMenuItem<Currency>(
                            value: currency,
                            child: Text(currency.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (_currencies.isNotEmpty) {
                      setState(() {
                        _selectedCurrency = value;
                      });
                    }
                  },
                  validator: (value) => value == null && _currencies.isNotEmpty
                      ? 'Please select a currency'
                      : null,
                ),
              ),
            ),
            // Designation Field
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Designation*',
                style: GoogleFonts.montserrat(
                  color: Colorfile.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            CustomTextField(
              _designationController,
              'Designation',
              decoration: InputDecoration(
                hintText: 'Enter designation',
                hintStyle: GoogleFonts.montserrat(
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w400,
                ),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16.0),
              ),
              validator: (value) => _validateRequired(value, 'designation'),
            ),
            // Mobile Number Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Mobile number* ',
                          style: GoogleFonts.montserrat(
                            color: Colorfile.textColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 16.0, // Adjust as needed
                          ),
                        ),
                        TextSpan(
                          text: '(For updates, share your WhatsApp no.)',
                          style: GoogleFonts.montserrat(
                            color: Colorfile.textColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.0, // Smaller size for this part
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: Material(
                    child: DropdownButtonFormField<Country>(
                      decoration: InputDecoration(
                        hintText: 'Select code',
                        hintStyle: GoogleFonts.montserrat(
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w400,
                        ),
                        border: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFFD9D9D9), width: 1),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFFD9D9D9), width: 1),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFFD9D9D9), width: 1),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                      ),
                      value: _selectedCountryCode,
                      items: _staticCountryCodes
                          .map((country) => DropdownMenuItem<Country>(
                                value: country,
                                child: Text(country.code),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCountryCode = value;
                        });
                      },
                      validator: _validateCountryCode,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  _mobileController,
                  'Mobile Number',
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter mobile number',
                    hintStyle: GoogleFonts.montserrat(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w400,
                    ),
                    border: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFD9D9D9), width: 1),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFD9D9D9), width: 1),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFD9D9D9), width: 1),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                  ),
                  validator: _validateMobile,
                ),
              ],
            ),
            // Address Field
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Address*',
                style: GoogleFonts.montserrat(
                  color: Colorfile.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            CustomTextField(
              _addressController,
              'Address',
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter address',
                hintStyle: GoogleFonts.montserrat(
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w400,
                ),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16.0),
              ),
              validator: (value) => _validateRequired(value, 'address'),
            ),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.upload),
              label: Text(
                _profileImage == null ? 'Upload Picture' : 'Change Picture',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colorfile.textColor, // Set the button color
                foregroundColor: Colors.white, // Set the icon and text color
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4), // Set rounded corners
                ),
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
            const SizedBox(height: 20),
            _isLoading
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor),
                      ),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: _saveForm,
                    label: Text(
                      'Save',
                      style:
                          GoogleFonts.montserrat(fontWeight: FontWeight.w500),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colorfile.textColor, // Set the button color
                      foregroundColor:
                          Colors.white, // Set the icon and text color
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(4), // Set rounded corners
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
