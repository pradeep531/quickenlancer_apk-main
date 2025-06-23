import 'package:dropdown_search/dropdown_search.dart';
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
  InputDecoration? decoration,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0), // Reduced padding
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: decoration ??
          InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.poppins(
              color: Colors.grey[500],
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colorfile.textColor, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
            filled: true,
            fillColor: Colors.white,
          ),
      validator: validator,
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
  InputDecoration? decoration,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: decoration ??
          InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.poppins(
              color: Colors.grey[500],
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colorfile.textColor, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
            filled: true,
            fillColor: Colors.grey[100],
          ),
      validator: validator,
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colorfile.textColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colorfile.textColor,
            size: 22,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            color: Color(0xFFE0E0E0),
            height: 0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
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
          content: Text(
            message,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.grey[800],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Notice',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            message,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: GoogleFonts.poppins(color: Colorfile.textColor),
              ),
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
          // Navigator.pushAndRemoveUntil(
          //   context,
          //   MaterialPageRoute(builder: (context) => const Editprofilepage()),
          //   (route) => route.isFirst,
          // );
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
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey[200],
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
                              size: 45,
                              color: Colors.grey[500],
                            )
                          : null,
                    ),
                    if (_profileImage != null || _profileImageUrl != null)
                      Positioned(
                        child: GestureDetector(
                          onTap: _deleteProfileImage,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Text(
              'First Name*',
              style: GoogleFonts.poppins(
                color: Colorfile.textColor, // Example: blue color
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  hintText: 'Enter first name',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colorfile.textColor, width: 1.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 8.0,
                  ),
                ),
                validator: (value) => _validateRequired(value, 'first name'),
              ),
            ),
            Text(
              'Last Name*',
              style: GoogleFonts.poppins(
                color: Colorfile.textColor, // Example: blue color
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  hintText: 'Enter last name',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colorfile.textColor, width: 1.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 8.0,
                  ),
                ),
                validator: (value) => _validateRequired(value, 'last name'),
              ),
            ),
            Text(
              'Gender*',
              style: GoogleFonts.poppins(
                color: Colorfile.textColor, // Example: blue color
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Material(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: 'Select gender',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFD9D9D9), width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFD9D9D9), width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colorfile.textColor, width: 1.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 8.0),
                  ),
                  value: _selectedGender,
                  items: _genders
                      .map((gender) => DropdownMenuItem<String>(
                            value: gender,
                            child: Text(
                              gender,
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
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
            Visibility(
              visible: _emailController.text.isNotEmpty,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email*',
                    style: GoogleFonts.poppins(
                      color: Colorfile.textColor, // Example: blue color
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(vertical: 6.0),
                  //   child: TextFormField(
                  //     controller: _emailController,
                  //     readOnly: true, // Makes it view-only
                  //     decoration: InputDecoration(
                  //       hintText: 'Email',
                  //       hintStyle: GoogleFonts.poppins(
                  //         color: Colors.grey[400],
                  //         fontWeight: FontWeight.w400,
                  //         fontSize: 14,
                  //       ),
                  //       border: OutlineInputBorder(
                  //         borderSide:
                  //             BorderSide(color: Color(0xFFD9D9D9), width: 1),
                  //         borderRadius: BorderRadius.circular(4),
                  //       ),
                  //       enabledBorder: OutlineInputBorder(
                  //         borderSide:
                  //             BorderSide(color: Color(0xFFD9D9D9), width: 1),
                  //         borderRadius: BorderRadius.circular(4),
                  //       ),
                  //       focusedBorder: OutlineInputBorder(
                  //         borderSide: BorderSide(
                  //             color: Colorfile.textColor, width: 1.5),
                  //         borderRadius: BorderRadius.circular(4),
                  //       ),
                  //       filled: true,
                  //       fillColor: Colors.grey[100],
                  //       contentPadding: const EdgeInsets.symmetric(
                  //           vertical: 10.0, horizontal: 8.0),
                  //     ),
                  //     validator: _validateEmail,
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Color(0xFFD9D9D9), // Hex color #D9D9D9
                          width: 1, // 1px border
                        ),
                      ),
                      child: Text(
                        _emailController.text,
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Country*',
              style: GoogleFonts.poppins(
                color: Colorfile.textColor, // Example: blue color
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: DropdownSearch<Country>(
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: 'Search country',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFD9D9D9), width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFD9D9D9), width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colorfile.textColor, width: 1.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 8.0),
                    ),
                  ),
                  menuProps: MenuProps(
                    backgroundColor: Colors.white,
                  ),
                ),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    hintText: 'Select country',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFD9D9D9), width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFD9D9D9), width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colorfile.textColor, width: 1.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 8.0),
                  ),
                ),
                items: _countries,
                itemAsString: (Country country) => country.name,
                selectedItem: _selectedCountry,
                onChanged: (Country? value) {
                  setState(() {
                    _selectedCountry = value;
                    _selectedState = null;
                    _selectedCity = null;
                    _states = [];
                    _cities = [];
                  });
                  _fetchStates();
                },
                validator: (Country? value) =>
                    value == null ? 'Please select a country' : null,
              ),
            ),
            if (_selectedCountry != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'State*',
                    style: GoogleFonts.poppins(
                      color: Colorfile.textColor, // Example: blue color
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: DropdownSearch<Region>(
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            hintText: 'Search state',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFFD9D9D9), width: 1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFFD9D9D9), width: 1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colorfile.textColor, width: 1.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 8.0),
                          ),
                        ),
                        menuProps: MenuProps(
                          backgroundColor: Colors.white,
                        ),
                      ),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          hintText: 'Select state',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFFD9D9D9), width: 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFFD9D9D9), width: 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colorfile.textColor, width: 1.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 8.0),
                        ),
                      ),
                      items: _states,
                      itemAsString: (Region state) => state.name,
                      selectedItem: _selectedState,
                      onChanged: (Region? value) {
                        if (_states.isNotEmpty) {
                          setState(() {
                            _selectedState = value;
                            _selectedCity = null;
                            _cities = [];
                          });
                          _fetchCities();
                        }
                      },
                      validator: (Region? value) =>
                          value == null ? 'Please select a state' : null,
                    ),
                  ),
                ],
              ),
            if (_selectedState != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'City*',
                    style: GoogleFonts.poppins(
                      color: Colorfile.textColor, // Example: blue color
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: DropdownSearch<City>(
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            hintText: 'Search city',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFFD9D9D9), width: 1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFFD9D9D9), width: 1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colorfile.textColor, width: 1.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 8.0),
                          ),
                        ),
                        menuProps: MenuProps(
                          backgroundColor: Colors.white,
                        ),
                      ),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          hintText: 'Select city',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFFD9D9D9), width: 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFFD9D9D9), width: 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colorfile.textColor, width: 1.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 8.0),
                        ),
                      ),
                      items: _cities,
                      itemAsString: (City city) => city.name,
                      selectedItem: _selectedCity,
                      onChanged: (City? value) {
                        if (_cities.isNotEmpty) {
                          setState(() {
                            _selectedCity = value;
                          });
                        }
                      },
                      validator: (City? value) =>
                          value == null ? 'Please select a city' : null,
                    ),
                  ),
                ],
              ),
            Text(
              'Currency*',
              style: GoogleFonts.poppins(
                color: Colorfile.textColor, // Example: blue color
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Material(
                child: DropdownButtonFormField<Currency>(
                  decoration: InputDecoration(
                    hintText: 'Select currency',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFD9D9D9), width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFD9D9D9), width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colorfile.textColor, width: 1.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 8.0),
                  ),
                  value: _selectedCurrency,
                  items: _currencies
                      .map((currency) => DropdownMenuItem<Currency>(
                            value: currency,
                            child: Text(
                              currency.name,
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
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
            Text(
              'Description*',
              style: GoogleFonts.poppins(
                color: Colorfile.textColor, // Example: blue color
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: TextFormField(
                controller: _designationController,
                decoration: InputDecoration(
                  hintText: 'Enter description',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colorfile.textColor, width: 1.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 8.0,
                  ),
                ),
                validator: (value) => _validateRequired(value, 'designation'),
              ),
            ),
            Text(
              'Address*',
              style: GoogleFonts.poppins(
                color: Colorfile.textColor, // Example: blue color
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter address',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colorfile.textColor, width: 1.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 8.0,
                  ),
                ),
                validator: (value) => _validateRequired(value, 'address'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Mobile number* ',
                      style: GoogleFonts.poppins(
                        color: Colorfile.textColor, // Example: blue color
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Material(
                    child: DropdownButtonFormField<Country>(
                      decoration: InputDecoration(
                        hintText: 'Code',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFFD9D9D9), width: 1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFFD9D9D9), width: 1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colorfile.textColor, width: 1.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 8.0),
                      ),
                      value: _selectedCountryCode,
                      items: _staticCountryCodes
                          .map((country) => DropdownMenuItem<Country>(
                                value: country,
                                child: Text(
                                  country.code,
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
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
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: CustomTextField(
                    _mobileController,
                    'Mobile Number',
                    keyboardType: TextInputType.number,
                    validator: _validateMobile,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white, // Optional: for better contrast
                border: Border.all(
                  color: Color(0xFFD9D9D9), // Hex color #D9D9D9
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(4.0), // Radius 4
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upload Profile Picture',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(
                          color: Colors.blue.shade200,
                          width: 1.0,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _profileImage == null
                          ? 'Upload Picture'
                          : 'Change Picture',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_profileImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _profileImage!.path.split('/').last,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 16),
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colorfile.textColor),
                    ),
                  )
                : ElevatedButton(
                    onPressed: _saveForm,
                    child: Text(
                      'Save',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colorfile.textColor,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
