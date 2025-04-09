import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';

class FilterBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;
  final VoidCallback onClearFilters;

  const FilterBottomSheet({
    super.key,
    required this.onApplyFilters,
    required this.onClearFilters,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _selectedJobType;
  List<String> _selectedTags = [];
  TextEditingController _skillController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  String? _selectedCurrency;
  String? _selectedProjectType;
  String? _selectedRequirementType;
  String? _selectedConnectType;
  String? _selectedAdminProfile;
  String? _selectedBiddingCriteria;
  String? _selectedFreshness;

  final List<String> jobTypes = ['All', 'Full-time', 'Part-time', 'Contract'];
  final List<String> availableTags = [
    'Flutter',
    'Dart',
    'Mobile',
    'Web',
    'Backend',
    'Frontend'
  ];
  final List<String> currencies = ['INR', 'USD'];
  final List<String> projectTypes = ['Fixed', 'Hourly'];
  final List<String> requirementTypes = ['Cold', 'Hot'];
  final List<String> connectTypes = ['Chat', 'Call', 'Both'];
  final List<String> adminProfiles = ['Verified', 'Un-Verified'];
  final List<String> biddingCriteria = ['High to Low', 'Low to High'];
  final List<String> freshnessOptions = [
    'Today',
    'In this Week',
    'Previous Week',
    'One Month Ago',
    'Long Time'
  ];

  @override
  void dispose() {
    _skillController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colorfile.textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colorfile.textColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search by Skill
                  _buildSectionTitle('Search by Skill'),
                  TextField(
                    controller: _skillController,
                    decoration: InputDecoration(
                      hintText: 'Enter skills',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colorfile.textColor),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Currency
                  _buildSectionTitle('Currency'),
                  Wrap(
                    spacing: 8,
                    children: currencies.map((currency) {
                      return ChoiceChip(
                        label: Text(currency),
                        selected: _selectedCurrency == currency,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCurrency = selected ? currency : null;
                          });
                        },
                        selectedColor: Colorfile.textColor,
                        backgroundColor: Colors.grey[100],
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        labelStyle: TextStyle(
                          color: _selectedCurrency == currency
                              ? Colors.white
                              : Colorfile.textColor,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),

                  // Location
                  _buildSectionTitle('Enter your location'),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      hintText: 'Enter location',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colorfile.textColor),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Job Type
                  _buildSectionTitle('Job Type'),
                  Wrap(
                    spacing: 8,
                    children: jobTypes.map((type) {
                      return ChoiceChip(
                        label: Text(type),
                        selected: _selectedJobType == type,
                        onSelected: (selected) {
                          setState(() {
                            _selectedJobType = selected ? type : null;
                          });
                        },
                        selectedColor: Colorfile.textColor,
                        backgroundColor: Colors.grey[100],
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        labelStyle: TextStyle(
                          color: _selectedJobType == type
                              ? Colors.white
                              : Colorfile.textColor,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),

                  // Project Type
                  _buildSectionTitle('Project Type'),
                  Wrap(
                    spacing: 8,
                    children: projectTypes.map((type) {
                      return ChoiceChip(
                        label: Text(type),
                        selected: _selectedProjectType == type,
                        onSelected: (selected) {
                          setState(() {
                            _selectedProjectType = selected ? type : null;
                          });
                        },
                        selectedColor: Colorfile.textColor,
                        backgroundColor: Colors.grey[100],
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        labelStyle: TextStyle(
                          color: _selectedProjectType == type
                              ? Colors.white
                              : Colorfile.textColor,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),

                  // Requirement Type
                  _buildSectionTitle('Requirement Type'),
                  Wrap(
                    spacing: 8,
                    children: requirementTypes.map((type) {
                      return ChoiceChip(
                        label: Text(type),
                        selected: _selectedRequirementType == type,
                        onSelected: (selected) {
                          setState(() {
                            _selectedRequirementType = selected ? type : null;
                          });
                        },
                        selectedColor: Colorfile.textColor,
                        backgroundColor: Colors.grey[100],
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        labelStyle: TextStyle(
                          color: _selectedRequirementType == type
                              ? Colors.white
                              : Colorfile.textColor,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),

                  // Connect Type
                  _buildSectionTitle('Connect Type'),
                  Wrap(
                    spacing: 8,
                    children: connectTypes.map((type) {
                      return ChoiceChip(
                        label: Text(type),
                        selected: _selectedConnectType == type,
                        onSelected: (selected) {
                          setState(() {
                            _selectedConnectType = selected ? type : null;
                          });
                        },
                        selectedColor: Colorfile.textColor,
                        backgroundColor: Colors.grey[100],
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        labelStyle: TextStyle(
                          color: _selectedConnectType == type
                              ? Colors.white
                              : Colorfile.textColor,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),

                  // Project Admin Profile
                  _buildSectionTitle('Project Admin Profile'),
                  Wrap(
                    spacing: 8,
                    children: adminProfiles.map((profile) {
                      return ChoiceChip(
                        label: Text(profile),
                        selected: _selectedAdminProfile == profile,
                        onSelected: (selected) {
                          setState(() {
                            _selectedAdminProfile = selected ? profile : null;
                          });
                        },
                        selectedColor: Colorfile.textColor,
                        backgroundColor: Colors.grey[100],
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        labelStyle: TextStyle(
                          color: _selectedAdminProfile == profile
                              ? Colors.white
                              : Colorfile.textColor,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),

                  // Bidding Criteria
                  _buildSectionTitle('Bidding Criteria'),
                  Wrap(
                    spacing: 8,
                    children: biddingCriteria.map((criteria) {
                      return ChoiceChip(
                        label: Text(criteria),
                        selected: _selectedBiddingCriteria == criteria,
                        onSelected: (selected) {
                          setState(() {
                            _selectedBiddingCriteria =
                                selected ? criteria : null;
                          });
                        },
                        selectedColor: Colorfile.textColor,
                        backgroundColor: Colors.grey[100],
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        labelStyle: TextStyle(
                          color: _selectedBiddingCriteria == criteria
                              ? Colors.white
                              : Colorfile.textColor,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),

                  // Freshness
                  _buildSectionTitle('Freshness'),
                  Wrap(
                    spacing: 8,
                    children: freshnessOptions.map((option) {
                      return ChoiceChip(
                        label: Text(option),
                        selected: _selectedFreshness == option,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFreshness = selected ? option : null;
                          });
                        },
                        selectedColor: Colorfile.textColor,
                        backgroundColor: Colors.grey[100],
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        labelStyle: TextStyle(
                          color: _selectedFreshness == option
                              ? Colors.white
                              : Colorfile.textColor,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),

                  // Tags
                  _buildSectionTitle('Tags'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableTags.map((tag) {
                      return FilterChip(
                        label: Text(tag),
                        selected: _selectedTags.contains(tag),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTags.add(tag);
                            } else {
                              _selectedTags.remove(tag);
                            }
                          });
                        },
                        selectedColor: Colorfile.textColor,
                        backgroundColor: Colors.grey[100],
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        labelStyle: TextStyle(
                          color: _selectedTags.contains(tag)
                              ? Colors.white
                              : Colorfile.textColor,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onClearFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Clear Filters',
                      style: GoogleFonts.montserrat(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApplyFilters({
                        'skills': _skillController.text,
                        'currency': _selectedCurrency,
                        'location': _locationController.text,
                        'jobType': _selectedJobType,
                        'projectType': _selectedProjectType,
                        'requirementType': _selectedRequirementType,
                        'connectType': _selectedConnectType,
                        'adminProfile': _selectedAdminProfile,
                        'biddingCriteria': _selectedBiddingCriteria,
                        'freshness': _selectedFreshness,
                        'tags': _selectedTags,
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colorfile.textColor,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Apply Filters',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
