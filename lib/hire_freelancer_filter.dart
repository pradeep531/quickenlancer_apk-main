import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api/network/uri.dart'; // Adjust based on your project

class HireFreelancerFilter extends StatefulWidget {
  final Function(List<dynamic>) onApplyFilters;
  final VoidCallback onClearFilters;

  const HireFreelancerFilter({
    required this.onApplyFilters,
    required this.onClearFilters,
    super.key,
  });

  @override
  State<HireFreelancerFilter> createState() =>
      _HireFreelancerFilterBottomSheetState();
}

class _HireFreelancerFilterBottomSheetState
    extends State<HireFreelancerFilter> {
  Map<String, dynamic> filters = {
    'tags': [],
    'location': '',
    'locationName': '',
    'skills': <Map<String, dynamic>>{},
    'currency': <String>{},
    'language': <String>{},
    'projectType': <String>{},
    'requirementType': <String>{},
    'connectType': <String>{},
    'adminProfile': <String>{},
    'biddingCriteria': null,
    'freshness': null,
  };

  List<Map<String, dynamic>> locationSuggestions = [];
  List<Map<String, dynamic>> allSkills = [], skillSuggestions = [];
  List<Map<String, dynamic>> availableCurrencies = [];
  // Static list of languages
  final List<Map<String, dynamic>> availableLanguages = [
    {'id': 'en', 'name': 'English'},
    {'id': 'hi', 'name': 'Hindi'},
    {'id': 'ja', 'name': 'Japanese'},
    {'id': 'fr', 'name': 'French'},
  ];
  bool isLoadingSuggestions = false,
      isLoadingSkills = false,
      isLoadingCurrencies = false;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _skillsSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _locationController.text = filters['locationName'];
    _fetchSkills();
    _fetchCurrencies();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _skillsSearchController.dispose();
    super.dispose();
  }

  List<dynamic> _encodeFilters(Map<String, dynamic> filters) {
    final List<dynamic> encoded = [];

    // Skills: Add as a list of searchbar@@{id}
    if (filters['skills'].isNotEmpty) {
      final skillsList = (filters['skills'] as Set<Map<String, dynamic>>)
          .map((skill) => 'searchbar@@${skill['id']}')
          .toList();
      if (skillsList.isNotEmpty) encoded.add(skillsList);
    }

    // Location: Add as location@@{id}
    if (filters['location'].toString().isNotEmpty) {
      encoded.add('location@@${filters['location']}');
    }

    // Currency: Add each as currency@@{id}
    if (filters['currency'].isNotEmpty) {
      (filters['currency'] as Set<String>)
          .forEach((id) => encoded.add('currency@@$id'));
    }

    // Language: Add each as language@@{id}
    if (filters['language'].isNotEmpty) {
      (filters['language'] as Set<String>)
          .forEach((id) => encoded.add('language@@$id'));
    }

    // Project Type: Add each as type@@0 (Fixed), type@@1 (Hourly)
    if (filters['projectType'].isNotEmpty) {
      (filters['projectType'] as Set<String>).forEach((type) {
        encoded.add(type == 'Fixed' ? 'type@@0' : 'type@@1');
      });
    }

    // Requirement Type: Add each as req_type@@0 (Cold), req_type@@1 (Hot)
    if (filters['requirementType'].isNotEmpty) {
      (filters['requirementType'] as Set<String>).forEach((req) {
        encoded.add(req == 'Cold' ? 'req_type@@0' : 'req_type@@1');
      });
    }

    // Connect Type: Add each as conn_type@@1 (Chat), conn_type@@2 (Call), conn_type@@3 (Email)
    if (filters['connectType'].isNotEmpty) {
      (filters['connectType'] as Set<String>).forEach((conn) {
        encoded.add(conn == 'Chat'
            ? 'conn_type@@1'
            : conn == 'Call'
                ? 'conn_type@@2'
                : 'conn_type@@3');
      });
    }

    // Admin Profile: Add each as profile_type@@1 (Verified), profile_type@@0 (Unverified)
    if (filters['adminProfile'].isNotEmpty) {
      (filters['adminProfile'] as Set<String>).forEach((profile) {
        encoded
            .add(profile == 'Verified' ? 'profile_type@@1' : 'profile_type@@0');
      });
    }

    // Bidding Criteria: Add as bidding@@high_to_low, bidding@@low_to_high
    if (filters['biddingCriteria'] != null) {
      encoded.add(filters['biddingCriteria'] == 'High to Low'
          ? 'bidding@@high_to_low'
          : 'bidding@@low_to_high');
    }

    // Freshness: Add as freshness@@today, freshness@@this_week, etc.
    if (filters['freshness'] != null) {
      final freshnessMap = {
        'Today': 'freshness@@today',
        'This Week': 'freshness@@this_week',
        'This Month': 'freshness@@one_month',
        'Any Time': 'freshness@@long_time',
      };
      encoded.add(freshnessMap[filters['freshness']]!);
    }

    return encoded;
  }

  Future<void> _fetchSkills() async {
    setState(() => isLoadingSkills = true);
    try {
      final response = await http.get(Uri.parse(URLS().get_skills_api),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200 &&
          jsonDecode(response.body)['status'] == 'true') {
        setState(() {
          allSkills = skillSuggestions =
              (jsonDecode(response.body)['data'] as List)
                  .cast<Map<String, dynamic>>();
        });
      } else {
        _showSnackBar('Failed to load skills');
      }
    } catch (_) {
      _showSnackBar('Error fetching skills');
    } finally {
      setState(() => isLoadingSkills = false);
    }
  }

  Future<void> _fetchCurrencies() async {
    setState(() => isLoadingCurrencies = true);
    try {
      final response = await http.get(Uri.parse(URLS().get_currency_api),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200 &&
          jsonDecode(response.body)['status'] == 'true') {
        setState(() => availableCurrencies =
            (jsonDecode(response.body)['data'] as List)
                .cast<Map<String, dynamic>>());
      } else {
        _showSnackBar('Failed to load currencies');
      }
    } catch (_) {
      _showSnackBar('Error fetching currencies');
    } finally {
      setState(() => isLoadingCurrencies = false);
    }
  }

  void _onSkillsSearchChanged(String query) {
    setState(() => skillSuggestions = query.isEmpty
        ? allSkills
        : allSkills
            .where((skill) => skill['skill']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList());
  }

  void _toggleSkill(Map<String, dynamic> skill) {
    setState(() {
      final skills = filters['skills'] as Set<Map<String, dynamic>>;
      skills.any((s) => s['id'] == skill['id'])
          ? skills.removeWhere((s) => s['id'] == skill['id'])
          : skills.add(skill);
    });
  }

  void _showSkillsDialog() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setDialogState) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                TextField(
                  controller: _skillsSearchController,
                  decoration: InputDecoration(
                    hintText: 'Search skills...',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    suffixIcon: _skillsSearchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setDialogState(() {
                                _skillsSearchController.clear();
                                _onSkillsSearchChanged('');
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) =>
                      setDialogState(() => _onSkillsSearchChanged(value)),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: isLoadingSkills
                      ? const Center(child: CircularProgressIndicator())
                      : skillSuggestions.isEmpty
                          ? const Center(child: Text('No skills found'))
                          : ListView.builder(
                              itemCount: skillSuggestions.length,
                              itemBuilder: (_, index) {
                                final skill = skillSuggestions[index];
                                final isSelected = (filters['skills']
                                        as Set<Map<String, dynamic>>)
                                    .any((s) => s['id'] == skill['id']);
                                return CheckboxListTile(
                                  title: Text(skill['skill'],
                                      style: GoogleFonts.poppins(fontSize: 14)),
                                  value: isSelected,
                                  onChanged: (_) {
                                    setDialogState(() => _toggleSkill(skill));
                                    setState(() {});
                                  },
                                );
                              },
                            ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text('Done',
                      style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> _fetchLocationSuggestions(String keyword) async {
    setState(() => isLoadingSuggestions = true);
    try {
      final response = await http.post(
        Uri.parse(URLS().get_location_api),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'keyword': keyword}),
      );
      if (response.statusCode == 200 &&
          jsonDecode(response.body)['status'] == 'true') {
        setState(() => locationSuggestions =
            (jsonDecode(response.body)['data'] as List)
                .cast<Map<String, dynamic>>());
      } else {
        setState(() => locationSuggestions.clear());
        _showSnackBar('Failed to load suggestions');
      }
    } catch (_) {
      setState(() => locationSuggestions.clear());
      _showSnackBar('Error fetching locations');
    } finally {
      setState(() => isLoadingSuggestions = false);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      filters['locationName'] = query;
      if (query.isEmpty) {
        filters['location'] = '';
        locationSuggestions.clear();
        isLoadingSuggestions = false;
      } else {
        _fetchLocationSuggestions(query);
      }
    });
  }

  void _clearLocation() {
    setState(() {
      _locationController.clear();
      filters['location'] = filters['locationName'] = '';
      locationSuggestions.clear();
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))
        ],
      ),
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.85,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF6B7280),
                  borderRadius: BorderRadius.circular(10),
                ),
                width: 32,
                height: 4,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters',
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.w700)),
                IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF666666)),
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            _buildSkillsSection(),

            _buildTextField(
                'Advanced Search', 'Enter Your Location', _onSearchChanged,
                controller: _locationController, clearCallback: _clearLocation),
            if (isLoadingSuggestions)
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: CircularProgressIndicator())
            else if (locationSuggestions.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE0E0E0))),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: locationSuggestions.length,
                  itemBuilder: (_, index) {
                    final suggestion = locationSuggestions[index];
                    return ListTile(
                      title: Text(suggestion['name'],
                          style: GoogleFonts.poppins(fontSize: 14)),
                      subtitle: Text(suggestion['state_name'] ?? '',
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.grey)),
                      onTap: () {
                        setState(() {
                          filters['location'] = suggestion['id'];
                          filters['locationName'] = suggestion['name'];
                          _locationController.text = suggestion['name'];
                          locationSuggestions.clear();
                        });
                      },
                    );
                  },
                ),
              ),
            _buildCurrencySection(),
            _buildLanguageSection(),
            _buildMultiSelect(
                'Project Type', ['Fixed', 'Hourly'], filters['projectType']),
            // _buildMultiSelect(
            //     'Priority', ['Cold', 'Hot'], filters['requirementType']),
            // _buildMultiSelect('Communication', ['Chat', 'Call', 'Email'],
            //     filters['connectType']),
            _buildMultiSelect('Project Admin Profile',
                ['Verified', 'Unverified'], filters['adminProfile']),
            _buildSingleSelect(
                'Sort By',
                ['High to Low', 'Low to High'],
                filters['biddingCriteria'],
                (value) => setState(() => filters['biddingCriteria'] = value)),
            _buildSingleSelect(
                'Freshness',
                ['Today', 'This Week', 'This Month', 'Any Time'],
                filters['freshness'],
                (value) => setState(() => filters['freshness'] = value)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildButton(
                      'Reset', Colors.white, const Color(0xFF1A1A1A), () {
                    setState(() {
                      filters = {
                        'tags': [],
                        'location': '',
                        'locationName': '',
                        'skills': <Map<String, dynamic>>{},
                        'currency': <String>{},
                        'language': <String>{},
                        'projectType': <String>{},
                        'requirementType': <String>{},
                        'connectType': <String>{},
                        'adminProfile': <String>{},
                        'biddingCriteria': null,
                        'freshness': null,
                      };
                      _locationController.clear();
                      locationSuggestions.clear();
                      _skillsSearchController.clear();
                      skillSuggestions = allSkills;
                    });
                    widget.onClearFilters();
                  }, border: true),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildButton(
                      'Apply', const Color(0xFF1A1A1A), Colors.white, () {
                    final encodedFilters = _encodeFilters(filters);
                    print(encodedFilters);
                    widget.onApplyFilters(encodedFilters);
                    Navigator.pop(context);
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSelection(Set<String> set, String value) {
    setState(() => set.contains(value) ? set.remove(value) : set.add(value));
  }

  Widget _buildSkillsSection() {
    final selectedSkills = filters['skills'] as Set<Map<String, dynamic>>;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Skills & Keywords',
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _showSkillsDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE0E0E0))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      selectedSkills.isEmpty
                          ? 'Search'
                          : '${selectedSkills.length} skill(s) selected',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: selectedSkills.isEmpty
                              ? const Color(0xFF191E3E)
                              : const Color(0xFF1A1A1A))),
                  const Icon(Icons.arrow_drop_down, color: Color(0xFF666666)),
                ],
              ),
            ),
          ),
          if (selectedSkills.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedSkills
                    .map((skill) => Chip(
                          label: Text(skill['skill'],
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.white)),
                          backgroundColor: const Color(0xFF1A1A1A),
                          deleteIcon: const Icon(Icons.close,
                              size: 18, color: Colors.white),
                          onDeleted: () => setState(() =>
                              (filters['skills'] as Set<Map<String, dynamic>>)
                                  .removeWhere((s) => s['id'] == skill['id'])),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrencySection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Currency',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5),
          Container(
            height: 1,
            color: const Color(0xFFE0E0E0),
          ),
          const SizedBox(height: 4),
          isLoadingCurrencies
              ? const Center(child: CircularProgressIndicator())
              : availableCurrencies.isEmpty
                  ? const Text('No currencies available')
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: availableCurrencies.length,
                      itemBuilder: (context, index) {
                        final currency = availableCurrencies[index];
                        final isSelected = (filters['currency'] as Set<String>)
                            .contains(currency['id']);
                        return CheckboxListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          dense: true,
                          visualDensity: VisualDensity(vertical: -2),
                          title: Text(
                            currency['lable'],
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          value: isSelected,
                          activeColor: const Color(0xFF1A1A1A),
                          checkColor: Colors.white,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (bool? value) {
                            if (value != null) {
                              setState(() {
                                _toggleSelection(
                                    filters['currency'], currency['id']);
                              });
                            }
                          },
                        );
                      },
                    ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Language',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5),
          Container(
            height: 1,
            color: const Color(0xFFE0E0E0),
          ),
          const SizedBox(height: 4),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: availableLanguages.length,
            itemBuilder: (context, index) {
              final language = availableLanguages[index];
              final isSelected =
                  (filters['language'] as Set<String>).contains(language['id']);
              return CheckboxListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                dense: true,
                visualDensity: VisualDensity(vertical: -2),
                title: Text(
                  language['name'],
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                value: isSelected,
                activeColor: const Color(0xFF1A1A1A),
                checkColor: Colors.white,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (bool? value) {
                  if (value != null) {
                    setState(() {
                      _toggleSelection(filters['language'], language['id']);
                    });
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, Function(String) onChanged,
      {TextEditingController? controller, VoidCallback? clearCallback}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5),
          Container(
            height: 1,
            color: const Color(0xFFE0E0E0),
          ),
          SizedBox(height: 5),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: const Color(0xFF191E3E),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              suffixIcon: controller?.text.isNotEmpty == true
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Color(0xFF666666)),
                      onPressed: clearCallback,
                    )
                  : null,
            ),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF1A1A1A),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelect(
      String label, List<String> items, Set<String> selectedValues) {
    return _buildSelectionGrid(label, items, selectedValues,
        (value) => _toggleSelection(selectedValues, value),
        multiSelect: true);
  }

  Widget _buildSingleSelect(String label, List<String> items,
      dynamic selectedValue, Function(String) onSelected) {
    return _buildSelectionGrid(label, items, selectedValue, onSelected);
  }

  Widget _buildSelectionGrid(String label, List<String> items,
      dynamic selectedValue, Function(String) onSelected,
      {bool multiSelect = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5),
          Container(
            height: 1,
            color: const Color(0xFFE0E0E0),
          ),
          const SizedBox(height: 4),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = multiSelect
                  ? (selectedValue as Set<String>).contains(item)
                  : selectedValue == item;
              return CheckboxListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                dense: true,
                visualDensity: VisualDensity(vertical: -2),
                title: Text(
                  item,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                value: isSelected,
                activeColor: const Color(0xFF1A1A1A),
                checkColor: Colors.white,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (bool? value) {
                  if (value == true) {
                    if (multiSelect) {
                      onSelected(item);
                    } else {
                      setState(() {
                        selectedValue = item;
                        onSelected(item);
                      });
                    }
                  } else if (multiSelect) {
                    onSelected(item);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
      String text, Color bgColor, Color textColor, VoidCallback onPressed,
      {bool border = false}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: border
                ? const BorderSide(color: Color(0xFF1A1A1A))
                : BorderSide.none),
      ),
      onPressed: onPressed,
      child: Text(text,
          style: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
    );
  }
}
