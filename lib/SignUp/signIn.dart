import 'dart:developer';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:linkedin_login/linkedin_login.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import 'package:quickenlancer_apk/SignUp/forgotPassword.dart';
import 'package:quickenlancer_apk/SignUp/signup.dart';
import 'package:quickenlancer_apk/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../api/network/uri.dart';
import 'onboardingstep.dart';
import 'package:file_picker/file_picker.dart';

class SignInPage extends StatefulWidget {
  final Map<String, dynamic>? projectData; // Add projectData parameter
  final List<PlatformFile>? files; // Add files parameter

  SignInPage({this.projectData, this.files});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;
  bool _obscurePassword = true;

  bool _validateInputs() {
    setState(() {
      _emailError = null;
      _passwordError = null;

      if (_emailController.text.isEmpty) {
        _emailError = 'Email cannot be empty';
      } else if (!_emailRegExp.hasMatch(_emailController.text)) {
        _emailError = 'Please enter a valid email address';
      }

      if (_passwordController.text.isEmpty) {
        _passwordError = 'Password cannot be empty';
      }
    });

    return _emailError == null && _passwordError == null;
  }

  Future<bool> _handleGoogleSignIn() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      print('Attempting Google Sign-In...');

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print('Google Sign-In cancelled by user');
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('Google Sign-In Response:');
      print('User ID: ${googleUser.id}');
      print('Display Name: ${googleUser.displayName}');
      print('Email: ${googleUser.email}');
      print('Access Token: ${googleAuth.accessToken}');
      print('ID Token: ${googleAuth.idToken}');
      log('Full Google User Object: ${googleUser.toString()}');

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        print('Firebase Sign-In Successful:');
        print('Firebase UID: ${firebaseUser.uid}');
        print('Firebase Display Name: ${firebaseUser.displayName}');
        print('Firebase Email: ${firebaseUser.email}');
        print('Firebase Photo URL: ${firebaseUser.photoURL}');

        await _storeSocialLoginData(firebaseUser);
        await initiateSearchProjectData(firebaseUser.uid);

        return true;
      } else {
        print('Firebase Sign-In failed');
        _showErrorSnackBar('Google login failed');
        return false;
      }
    } catch (e, stackTrace) {
      print('Google Sign-In Error: $e');
      print('Stack Trace: $stackTrace');
      _showErrorSnackBar('An error occurred during Google login');
      return false;
    }
  }

  Future<bool> _handleFacebookSignIn() async {
    try {
      print('Attempting Facebook Sign-In...');

      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final AccessToken? accessToken = result.accessToken;
        print('Facebook Sign-In Successful:');

        final userData = await FacebookAuth.instance.getUserData();
        print('User Data: $userData');
        print('Name: ${userData['name']}');
        print('Email: ${userData['email']}');

        final OAuthCredential credential =
            FacebookAuthProvider.credential(accessToken!.tokenString);

        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        final User? firebaseUser = userCredential.user;

        if (firebaseUser != null) {
          print('Firebase Sign-In Successful:');
          print('Firebase UID: ${firebaseUser.uid}');
          print('Firebase Display Name: ${firebaseUser.displayName}');
          print('Firebase Email: ${firebaseUser.email}');
          print('Firebase Photo URL: ${firebaseUser.photoURL}');

          await _storeSocialLoginData(firebaseUser);
          await initiateSearchProjectData(firebaseUser.uid);

          return true;
        } else {
          print('Firebase Sign-In failed');
          _showErrorSnackBar('Facebook login failed');
          return false;
        }
      } else if (result.status == LoginStatus.cancelled) {
        print('Facebook Sign-In cancelled by user');
        _showErrorSnackBar('Facebook login cancelled', color: Colors.orange);
        return false;
      } else {
        print('Facebook Sign-In failed: ${result.message}');
        _showErrorSnackBar('Facebook login failed: ${result.message}');
        return false;
      }
    } catch (e, stackTrace) {
      print('Facebook Sign-In Error: $e');
      print('Stack Trace: $stackTrace');
      _showErrorSnackBar('An error occurred during Facebook login');
      return false;
    }
  }

  Future<bool> _handleLinkedInSignIn() async {
    try {
      print('Attempting LinkedIn Sign-In...');

      final String state = Uuid().v4();

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => LinkedInUserWidget(
            clientId: '77hlq88j8tc8tv',
            clientSecret: 'MObMX51CyrYHRcqn',
            redirectUrl:
                'https://www.quickensol.com/quickenlancer-new/linkedin-success',
            onGetUserProfile: (UserSucceededAction user) async {
              print('LinkedIn Sign-In Successful:');
              print('User ID: ${user.user.name}');
              print('Name: ${user.user.givenName} ${user.user.familyName}');
              print('Access Token: ${user.user.token}');

              final email = user.user.email ?? 'linkedin_user@example.com';
              print('LinkedIn Email: $email');

              Navigator.pop(context, true); // Return true on success
            },
            onError: (UserFailedAction error) {
              print('LinkedIn Sign-In Error: $error');
              _showErrorSnackBar('LinkedIn login failed');
              Navigator.pop(context, false);
            },
            scope: [OpenIdScope(), EmailScope(), ProfileScope()],
          ),
        ),
      );

      return result ?? false;
    } catch (e, stackTrace) {
      print('LinkedIn Sign-In Error: $e');
      print('Stack Trace: $stackTrace');
      _showErrorSnackBar('An error occurred during LinkedIn login');
      return false;
    }
  }

  Future<bool> signIn() async {
    if (!_validateInputs()) {
      return false;
    }

    setState(() {
      _isLoading = true;
    });

    final String url = URLS().login_apiUrl;
    final requestBody = jsonEncode({
      "email": _emailController.text,
      "password": _passwordController.text,
    });

    log('Request body: $requestBody');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      print('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == "true") {
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setInt('is_logged_in', 1);

        final data = responseData['data'];
        await prefs.setString('user_id', data['id'] ?? '');
        await prefs.setString('first_name', data['f_name'] ?? '');
        await prefs.setString('last_name', data['l_name'] ?? '');
        await prefs.setString('email', data['email'] ?? '');
        await prefs.setString('country', data['country'] ?? '');
        await prefs.setString('auth_token', data['auth_token'] ?? '');
        await prefs.setString(
            'profile_pic_path', data['profile_pic_path'] ?? '');

        print('Shared Preferences set:');
        print('is_logged_in: ${prefs.getInt('is_logged_in')}');
        print('user_id: ${prefs.getString('user_id')}');
        print('first_name: ${prefs.getString('first_name')}');
        print('last_name: ${prefs.getString('last_name')}');
        print('email: ${prefs.getString('email')}');
        print('auth_token: ${prefs.getString('auth_token')}');
        print('profile_pic_path: ${prefs.getString('profile_pic_path')}');

        await initiateSearchProjectData(data['id'] ?? '0');
        return true;
      } else {
        _showErrorSnackBar(responseData['message'] ?? 'Login failed');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      _showErrorSnackBar('An error occurred. Please try again');
      return false;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _storeSocialLoginData(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('is_logged_in', 1);
    await prefs.setString('user_id', user.uid);
    final nameParts = user.displayName?.split(' ') ?? [];
    await prefs.setString(
        'first_name', nameParts.isNotEmpty ? nameParts[0] : '');
    await prefs.setString('last_name',
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '');
    await prefs.setString('email', user.email ?? '');
    await prefs.setString('profile_pic_path', user.photoURL ?? '');

    print('Social Login Shared Preferences set:');
    print('is_logged_in: ${prefs.getInt('is_logged_in')}');
    print('user_id: ${prefs.getString('user_id')}');
    print('first_name: ${prefs.getString('first_name')}');
    print('last_name: ${prefs.getString('last_name')}');
    print('email: ${prefs.getString('email')}');
    print('profile_pic_path: ${prefs.getString('profile_pic_path')}');
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            contentPadding: EdgeInsets.all(20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 50,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Success',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Login successful!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            elevation: 8,
          ),
        );
      },
    );
    // Future.delayed(Duration(seconds: 2)).then((_) {
    //   Navigator.pop(context); // Close dialog
    // });
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => const MyHomePage(),
    //   ),
    // );
    // Future.delayed(Duration(seconds: 2)).then((_) {
    //   Navigator.pop(context); // Close dialog
    // });
  }

  void _showErrorSnackBar(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> initiateSearchProjectData(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('auth_token');

      final String searchUrl = URLS().initiate_search_project_data_api;
      final searchRequestBody = jsonEncode({
        "userId": userId,
      });

      log('Search API Request body: $searchRequestBody');

      final searchResponse = await http.post(
        Uri.parse(searchUrl),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: searchRequestBody,
      );

      print(
          'Search Response API Response status: ${searchResponse.statusCode}');
      print('Search Response API Response body: ${searchResponse.body}');
    } catch (e) {
      print('Search Error API Error: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Sign In',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colorfile.textColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Sign In To Your Account',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colorfile.textColor,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Email ID',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colorfile.textColor,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: '',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.7),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (_emailError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            _emailError!,
                            style: GoogleFonts.poppins(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Password',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colorfile.textColor,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: '',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.7),
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      if (_passwordError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            _passwordError!,
                            style: GoogleFonts.poppins(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  children: [
                    Transform.scale(
                      scale: 0.8,
                      child: Checkbox(
                        value: false,
                        onChanged: (value) {},
                      ),
                    ),
                    Text(
                      'Remember Me',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colorfile.textColor,
                      ),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Forgotpassword(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerRight,
                      ),
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 16.5 / 14,
                          letterSpacing: 0.5,
                          color: Colorfile.textColor,
                        ).copyWith(
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.solid,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            bool success = await signIn();
                            if (success) {
                              _showSuccessDialog();
                              Navigator.pop(context, {
                                'success': true,
                                'projectData': widget.projectData,
                                'files': widget.files,
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyHomePage(),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colorfile.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Sign In',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.10),
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Or',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colorfile.lightgrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        bool success = await _handleGoogleSignIn();
                        if (success) {
                          _showSuccessDialog();
                          Future.delayed(Duration(seconds: 2)).then((_) {
                            Navigator.pop(context, {
                              'success': true,
                              'projectData': widget.projectData,
                              'files': widget.files,
                            });
                          });
                        }
                      },
                      child: ClipOval(
                        child: Image(
                          image: AssetImage('assets/google.png'),
                          width: screenWidth * 0.08,
                          height: screenWidth * 0.08,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    GestureDetector(
                      onTap: () async {
                        bool success = await _handleFacebookSignIn();
                        if (success) {
                          _showSuccessDialog();
                          Future.delayed(Duration(seconds: 2)).then((_) {
                            Navigator.pop(context, {
                              'success': true,
                              'projectData': widget.projectData,
                              'files': widget.files,
                            });
                          });
                        }
                      },
                      child: ClipOval(
                        child: Image(
                          image: AssetImage('assets/facebook.png'),
                          width: screenWidth * 0.08,
                          height: screenWidth * 0.08,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    GestureDetector(
                      onTap: () async {
                        bool success = await _handleLinkedInSignIn();
                        if (success) {
                          _showSuccessDialog();
                          Future.delayed(Duration(seconds: 2)).then((_) {
                            Navigator.pop(context, {
                              'success': true,
                              'projectData': widget.projectData,
                              'files': widget.files,
                            });
                          });
                        }
                      },
                      child: ClipOval(
                        child: Image(
                          image: AssetImage('assets/linkedin.png'),
                          width: screenWidth * 0.08,
                          height: screenWidth * 0.08,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.08),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colorfile.darkgrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OnboardingSignup(),
                          ),
                        );
                      },
                      child: Text(
                        'SignUp',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colorfile.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
