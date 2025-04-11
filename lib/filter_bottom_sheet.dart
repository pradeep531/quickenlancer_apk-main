import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

class FilterBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;
  final VoidCallback onClearFilters;

  const FilterBottomSheet({
    required this.onApplyFilters,
    required this.onClearFilters,
    super.key,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  Map<String, dynamic> filters = {
    'jobType': <String>{},
    'tags': [],
    'location': '',
    'skills': '',
    'currency': <String>{},
    'projectType': <String>{},
    'requirementType': <String>{},
    'connectType': <String>{},
    'adminProfile': <String>{},
    'biddingCriteria': null,
    'freshness': null,
  };

  // Helper method to convert Sets to Lists for JSON encoding
  Map<String, dynamic> _prepareFiltersForEncoding(
      Map<String, dynamic> filters) {
    final encodableFilters = Map<String, dynamic>.from(filters);
    encodableFilters.updateAll((key, value) {
      if (value is Set) {
        return value.toList(); // Convert Set to List
      }
      return value;
    });
    return encodableFilters;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(24, 32, 24, 24),
      height: MediaQuery.of(context).size.height * 0.85,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: GoogleFonts.montserrat(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.3,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 24),
            _buildMultiSelectionGrid(
              'Job Type',
              ['Full-time', 'Part-time', 'Contract', 'Freelance'],
              filters['jobType'],
              (value) => _toggleSelection(filters['jobType'], value),
            ),
            _buildTextFieldSection(
              'Skills & Keywords',
              'Enter skills (e.g., Flutter, Python)',
              (value) => filters['skills'] = value,
            ),
            _buildTextFieldSection(
              'Location',
              'Enter location (city, country)',
              (value) => filters['location'] = value,
              advancedSearch: true,
            ),
            _buildMultiSelectionGrid(
              'Currency',
              ['INR', 'USD', 'EUR', 'GBP'],
              filters['currency'],
              (value) => _toggleSelection(filters['currency'], value),
            ),
            _buildMultiSelectionGrid(
              'Project Type',
              ['Fixed', 'Hourly', 'Milestone'],
              filters['projectType'],
              (value) => _toggleSelection(filters['projectType'], value),
            ),
            _buildMultiSelectionGrid(
              'Priority',
              ['Cold', 'Warm', 'Hot'],
              filters['requirementType'],
              (value) => _toggleSelection(filters['requirementType'], value),
            ),
            _buildMultiSelectionGrid(
              'Communication',
              ['Chat', 'Call', 'Email'],
              filters['connectType'],
              (value) => _toggleSelection(filters['connectType'], value),
            ),
            _buildMultiSelectionGrid(
              'Profile Status',
              ['Verified', 'Unverified'],
              filters['adminProfile'],
              (value) => _toggleSelection(filters['adminProfile'], value),
            ),
            _buildSelectionGrid(
              'Sort By',
              ['High to Low', 'Low to High'],
              filters['biddingCriteria'],
              (value) => filters['biddingCriteria'] = value,
            ),
            _buildSelectionGrid(
              'Posted',
              ['Today', 'This Week', 'This Month', 'Any Time'],
              filters['freshness'],
              (value) => filters['freshness'] = value,
            ),
            SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _buildButton(
                    'Reset',
                    Colors.transparent,
                    Colors.blueAccent,
                    () {
                      setState(() {
                        filters = {
                          'jobType': <String>{},
                          'tags': [],
                          'location': '',
                          'skills': '',
                          'currency': <String>{},
                          'projectType': <String>{},
                          'requirementType': <String>{},
                          'connectType': <String>{},
                          'adminProfile': <String>{},
                          'biddingCriteria': null,
                          'freshness': null,
                        };
                      });
                      widget.onClearFilters();
                    },
                    border: true,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildButton(
                    'Apply Filters',
                    Colors.blue,
                    Colors.white,
                    () {
                      final encodableFilters =
                          _prepareFiltersForEncoding(filters);
                      widget.onApplyFilters(filters);
                      print('Applied filters: ${jsonEncode(encodableFilters)}');
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSelection(Set<String> currentSet, String value) {
    setState(() {
      if (currentSet.contains(value)) {
        currentSet.remove(value);
      } else {
        currentSet.add(value);
      }
    });
  }

  Widget _buildTextFieldSection(
    String label,
    String hint,
    Function(String) onChanged, {
    bool advancedSearch = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.montserrat(color: Colors.grey[500]),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
              suffixIcon: Icon(Icons.search, color: Colors.grey[400]),
            ),
            style: GoogleFonts.montserrat(fontSize: 15),
            onChanged: onChanged,
          ),
          if (advancedSearch) ...[
            SizedBox(height: 8),
            GestureDetector(
              onTap: () {},
              child: Text(
                'Advanced Search Options',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMultiSelectionGrid(String label, List<String> items,
      Set<String> selectedValues, Function(String) onSelected) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: items.map((item) {
              bool isSelected = selectedValues.contains(item);
              return GestureDetector(
                onTap: () => onSelected(item),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [Colors.blue, Colors.blue.shade700],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [Colors.white, Colors.grey[50]!],
                          ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[200]!,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(isSelected ? 0.2 : 0.05),
                        blurRadius: 8,
                        offset: Offset(0, isSelected ? 4 : 2),
                      ),
                    ],
                  ),
                  child: Text(
                    item,
                    style: GoogleFonts.montserrat(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionGrid(String label, List<String> items,
      dynamic selectedValue, Function(String) onSelected) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: items.map((item) {
              bool isSelected = selectedValue == item;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    onSelected(item);
                  });
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [Colors.blue, Colors.blue.shade700],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [Colors.white, Colors.grey[50]!],
                          ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[200]!,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(isSelected ? 0.2 : 0.05),
                        blurRadius: 8,
                        offset: Offset(0, isSelected ? 4 : 2),
                      ),
                    ],
                  ),
                  child: Text(
                    item,
                    style: GoogleFonts.montserrat(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    String text,
    Color bgColor,
    Color textColor,
    VoidCallback onPressed, {
    bool border = false,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: border
              ? BorderSide(color: Colors.blueAccent, width: 1)
              : BorderSide.none,
        ),
        elevation: border ? 0 : 8,
        shadowColor: Colors.black26,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
