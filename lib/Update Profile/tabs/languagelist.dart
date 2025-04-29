import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/network/uri.dart';

class LanguageListScreen extends StatefulWidget {
  @override
  _LanguageListScreenState createState() => _LanguageListScreenState();
}

class _LanguageListScreenState extends State<LanguageListScreen> {
  List<Map<String, dynamic>> languages = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfileDetails();
  }

  // Fetch profile details from API
  Future<void> _fetchProfileDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

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
      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'true') {
          setState(() {
            // Now safely handling the response without throwing an exception
            languages = List<Map<String, dynamic>>.from(
                jsonResponse['data']['languages'] ?? []);
            isLoading = false;
          });
        } else {
          // If the status is not true, throw an exception with a message from the response
          throw Exception(jsonResponse['message'] ?? 'Failed to fetch data');
        }
      } else {
        // Handle non-200 response status
        throw Exception(
            'Failed to fetch profile details: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching profile details: ${e.toString()}';
      });
      print(errorMessage);
    }
  }

  // Function to map known values to readable strings
  String getKnownAbilities(dynamic known) {
    if (known == null || (known is List && known.isEmpty)) return 'None';

    List<int> knownList = [];

    // If known is a String, split it by commas and convert it to a List<int>
    if (known is String) {
      knownList = known
          .split(',')
          .where((e) => e.isNotEmpty)
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
    }
    // If known is already a List<int>
    else if (known is List<int>) {
      knownList = List<int>.from(known);
    }

    List<String> abilities = [];
    if (knownList.contains(1)) abilities.add("Read");
    if (knownList.contains(2)) abilities.add("Write");
    if (knownList.contains(3)) abilities.add("Speak");

    return abilities.join(", ");
  }

  // Function to handle delete action
  void deleteLanguage(int id) {
    setState(() {
      languages.removeWhere((lang) => lang['id'] == id);
    });
    // Optionally, make an API call to delete the language
    print('Deleted language with ID: $id');
    // Example API call for deletion (uncomment and modify as needed):
    /*
    final url = Uri.parse(URLS().delete_language);
    final headers = {'Authorization': 'Bearer $authToken'}; 
    http.post(url, headers: headers, body: jsonEncode({'language_id': id}));
    */
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Languages'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Languages'),
        ),
        body: Center(child: Text(errorMessage!)),
      );
    }

    if (languages.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Languages'),
        ),
        body: Center(child: Text('No languages found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Languages'),
      ),
      body: Container(
        child: ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: languages.length,
          itemBuilder: (context, index) {
            final language = languages[index];
            return Container(
              margin: EdgeInsets.only(bottom: 10.0),
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          language['language'] ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Abilities: ${getKnownAbilities(language['known'])}',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Proficiency: ${language['proficient'] ?? 0}%',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteLanguage(language['id']),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
