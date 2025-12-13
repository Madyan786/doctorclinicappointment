import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  // Font Family
  static String get fontFamily => GoogleFonts.outfit().fontFamily!;

  // Headings
  static TextStyle get heading1 => GoogleFonts.outfit(
        fontSize: 30.sp,
        fontWeight: FontWeight.w700,
        height: 60 / 40,
      );

  static TextStyle get heading2 => GoogleFonts.outfit(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get heading3 => GoogleFonts.outfit(
        fontSize: 28.sp,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  // Body Text
  static TextStyle get bodyLarge => GoogleFonts.outfit(
        fontSize: 18.sp,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.outfit(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.outfit(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  // Button Text
  static TextStyle get buttonLarge => GoogleFonts.outfit(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get buttonMedium => GoogleFonts.outfit(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get buttonSmall => GoogleFonts.outfit(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      );

  // Caption & Labels
  static TextStyle get caption => GoogleFonts.outfit(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get label => GoogleFonts.outfit(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
      );

  // Custom with color
  static TextStyle get heading1White => heading1.copyWith(color: Colors.white);
  static TextStyle get heading2White => heading2.copyWith(color: Colors.white);
  static TextStyle get bodyWhite => bodyMedium.copyWith(color: Colors.white);
}
