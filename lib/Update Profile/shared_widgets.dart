import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class SharedWidgets {
  static InputDecoration textFieldDecoration(String label,
      {String? Function(String?)? validator}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        color: Colors.grey[600],
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }

  static Widget NonEditTextField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
    bool enabled = true, // Add enabled parameter with default value true
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: textFieldDecoration(label),
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        validator: validator,
        enabled: enabled, // Pass enabled to TextFormField
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        ),
      ),
    );
  }

  static Widget textField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator, // Add validator parameter
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        // Change TextField to TextFormField
        controller: controller,
        decoration: textFieldDecoration(label),
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        validator: validator, // Pass validator to TextFormField
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        ),
      ),
    );
  }

  static Widget dropdown<T>({
    required String label,
    required T? value,
    required List<T> items, // Change to List<T> instead of DropdownMenuItem<T>
    required ValueChanged<T?> onChanged,
    String? Function(T?)? validator,
    String Function(T)?
        itemAsString, // Optional: for custom string representation
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownSearch<T>(
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: textFieldDecoration('Search'),
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
          menuProps: MenuProps(
            backgroundColor: Colors.white,
            elevation: 4,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: textFieldDecoration(label),
          baseStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        items: items,
        selectedItem: value,
        onChanged: onChanged,
        validator: validator,
        itemAsString: itemAsString, // Optional: for custom string display
      ),
    );
  }

  static Future<void> pickFile({
    required Function(File?) onFilePicked,
    required List<String> allowedExtensions,
  }) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );
    if (result != null && result.files.single.path != null) {
      onFilePicked(File(result.files.single.path!));
    }
  }
}

class StyledButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;

  const StyledButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
