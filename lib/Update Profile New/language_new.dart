import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:quickenlancer_apk/Colors/colorfile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quickenlancer_apk/api/network/uri.dart';
import '../editprofilepage.dart';

class LanguagePageNew extends StatelessWidget {
  const LanguagePageNew({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Languages',
          style:
              GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[400], // Grey border color
            height: 1.0, // Thickness of the bottom border
          ),
        ),
      ),
      body: const LanguageForm(),
    );
  }
}

class LanguageForm extends StatefulWidget {
  const LanguageForm({Key? key}) : super(key: key);

  @override
  _LanguageFormState createState() => _LanguageFormState();
}

class _LanguageFormState extends State<LanguageForm> {
  final _languageNameController = TextEditingController();
  double _proficiency = 0.0;
  bool _reading = false,
      _writing = false,
      _speaking = false,
      _isLoading = false;
  final List<Map<String, dynamic>> _languages = [];
  List<Map<String, dynamic>> languages = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfileDetails();
  }

  @override
  void dispose() {
    _languageNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfileDetails() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final authToken = prefs.getString('auth_token');
      if (userId.isEmpty || authToken == null) throw Exception('Auth error');

      final response = await http.post(
        Uri.parse(URLS().get_profile_details),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'true') {
          setState(() {
            languages = List<Map<String, dynamic>>.from(
                jsonResponse['data']['languages'] ?? []);
            isLoading = false;
          });
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to fetch data');
        }
      } else {
        throw Exception('Failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
    }
  }

  String getKnownAbilities(dynamic known) {
    if (known == null || (known is List && known.isEmpty)) return 'None';
    List<int> knownList = known is String
        ? known
            .split(',')
            .where((e) => e.isNotEmpty)
            .map((e) => int.tryParse(e) ?? 0)
            .toList()
        : List<int>.from(known);
    List<String> abilities = [];
    if (knownList.contains(1)) abilities.add("Reading");
    if (knownList.contains(2)) abilities.add("Writing");
    if (knownList.contains(3)) abilities.add("Speaking");
    return abilities.join(", ");
  }

  Future<void> deleteLanguage(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    final authToken = prefs.getString('auth_token');
    final url = Uri.parse(URLS().user_delete_profile_items);
    final body = jsonEncode({
      'user_id': userId,
      'delete_id': id,
      'delete_item_type': '2',
    });

    setState(() => languages.removeWhere((lang) => lang['id'] == id));

    if (authToken != null) {
      try {
        await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
          body: body,
        );
      } catch (e) {
        print('Error during deletion: $e');
      }
    }
  }

  Future<void> _confirmDeleteLanguage(String id, String languageName) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text('Delete $languageName?',
            style: GoogleFonts.montserrat(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.montserrat()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete',
                style: GoogleFonts.montserrat(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) await deleteLanguage(id);
  }

  Future<void> _saveForm() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final authToken = prefs.getString('auth_token');
      if (userId.isEmpty || authToken == null) throw Exception('Auth error');
      if (_languages.isEmpty) throw Exception('No language added');

      final lang = _languages.last;
      final response = await http.post(
        Uri.parse(URLS().set_languages),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'proficient': lang['proficiency'].round(),
          'language': lang['name'],
          'known': lang['skills'],
          'language_id':
              lang.containsKey('language_id') ? lang['language_id'] : '',
        }),
      );

      if (response.statusCode == 200) {
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const Editprofilepage()),
        // );
        setState(() {
          _languages.clear();
          _languageNameController.clear();
          _proficiency = 0.0;
          _reading = _writing = _speaking = false;
        });
      } else {
        throw Exception('Failed to save');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e', style: GoogleFonts.montserrat()),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildProficiencyMeter(dynamic value) {
    double proficiency;
    if (value is String) {
      proficiency = double.tryParse(value) ?? 0.0;
    } else if (value is num) {
      proficiency = value.toDouble();
    } else {
      proficiency = 0.0;
    }

    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: proficiency / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Color.lerp(Colors.red, Colors.green, proficiency / 100)!,
            ),
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${proficiency.round()}%',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _languageNameController,
                decoration: InputDecoration(
                  hintText: 'Language',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text('Reading'),
                value: _reading,
                onChanged: (value) => setState(() => _reading = value!),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                title: const Text('Writing'),
                value: _writing,
                onChanged: (value) => setState(() => _writing = value!),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                title: const Text('Speaking'),
                value: _speaking,
                onChanged: (value) => setState(() => _speaking = value!),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),
              Text('Proficiency: ${_proficiency.round()}%'),
              Slider(
                value: _proficiency,
                min: 0,
                max: 100,
                divisions: 100,
                onChanged: (value) => setState(() => _proficiency = value),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  if (_languageNameController.text.isNotEmpty &&
                      (_reading || _writing || _speaking)) {
                    setState(() {
                      _languages.add({
                        'name': _languageNameController.text,
                        'proficiency': _proficiency,
                        'skills': [
                          _reading ? 1 : null,
                          _writing ? 2 : null,
                          _speaking ? 3 : null
                        ].where((e) => e != null).toList(),
                      });
                      _languageNameController.clear();
                      _proficiency = 0.0;
                      _reading = _writing = _speaking = false;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            const Text('Enter a language and select a skill'),
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colorfile.textColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: const Text(
                  'Add Language',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              if (_languages.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('New Languages',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._languages.asMap().entries.map((entry) {
                  final lang = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(lang['name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              _buildProficiencyMeter(lang['proficiency']),
                              Text(
                                  'Skills: ${getKnownAbilities(lang['skills'])}'),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () =>
                              setState(() => _languages.removeAt(entry.key)),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveForm,
                    icon: Icon(Icons.save, color: Colors.white),
                    label: Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colorfile.textColor,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Set border radius to 4
                      ),
                    ),
                  ),
                ),
              ],
              if (languages.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Existing Languages',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...languages.map((language) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(language['language'] ?? 'Unknown',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                _buildProficiencyMeter(language['proficient']),
                                Text(
                                    'Skills: ${getKnownAbilities(language['known'])}'),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            onPressed: () => _confirmDeleteLanguage(
                                language['id'].toString(),
                                language['language'] ?? 'Unknown'),
                          ),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
        if (_isLoading || isLoading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
