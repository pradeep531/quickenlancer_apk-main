import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFontStyle {
  static TextStyle poppinsStyle({
    required double fontSize,
    required Color color,
    FontWeight? fontWeight, // Optional, to be set by the caller
  }) {
    return GoogleFonts.poppins(
      height: 23.4 / 18, // Line height ratio (as per your original code)
      textBaseline: TextBaseline.alphabetic,
      letterSpacing: 0,
    ).copyWith(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight, // Pass through if provided
    );
  }
}
