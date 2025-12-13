import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:doctorclinic/core/core.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final double? height;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final TextDecoration? decoration;
  final double? letterSpacing;

  const CustomText(
    this.text, {
    super.key,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.height,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.decoration,
    this.letterSpacing,
  });

  // Heading 1 - Large titles
  factory CustomText.heading1(
    String text, {
    Color? color,
    TextAlign? textAlign,
  }) {
    return CustomText(
      text,
      fontSize: 30,
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.textPrimary,
      textAlign: textAlign,
    );
  }

  // Heading 2 - Section titles
  factory CustomText.heading2(
    String text, {
    Color? color,
    TextAlign? textAlign,
  }) {
    return CustomText(
      text,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.textPrimary,
      textAlign: textAlign,
    );
  }

  // Heading 3 - Sub section titles
  factory CustomText.heading3(
    String text, {
    Color? color,
    TextAlign? textAlign,
  }) {
    return CustomText(
      text,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.textPrimary,
      textAlign: textAlign,
    );
  }

  // Body Large
  factory CustomText.bodyLarge(
    String text, {
    Color? color,
    TextAlign? textAlign,
  }) {
    return CustomText(
      text,
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: color ?? AppColors.textPrimary,
      textAlign: textAlign,
    );
  }

  // Body Medium
  factory CustomText.bodyMedium(
    String text, {
    Color? color,
    TextAlign? textAlign,
  }) {
    return CustomText(
      text,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: color ?? AppColors.textPrimary,
      textAlign: textAlign,
    );
  }

  // Body Small
  factory CustomText.bodySmall(
    String text, {
    Color? color,
    TextAlign? textAlign,
  }) {
    return CustomText(
      text,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color ?? AppColors.textSecondary,
      textAlign: textAlign,
    );
  }

  // Caption
  factory CustomText.caption(
    String text, {
    Color? color,
    TextAlign? textAlign,
  }) {
    return CustomText(
      text,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color ?? AppColors.textSecondary,
      textAlign: textAlign,
    );
  }

  // Button text
  factory CustomText.button(
    String text, {
    Color? color,
  }) {
    return CustomText(
      text,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.white,
    );
  }

  // Link text
  factory CustomText.link(
    String text, {
    Color? color,
  }) {
    return CustomText(
      text,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.primary,
      decoration: TextDecoration.underline,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow ?? TextOverflow.ellipsis,
      maxLines: maxLines,
      softWrap: true,
      style: GoogleFonts.outfit(
        fontSize: (fontSize ?? 14).sp,
        fontWeight: fontWeight ?? FontWeight.w400,
        color: color ?? AppColors.textPrimary,
        height: height,
        decoration: decoration,
        letterSpacing: letterSpacing,
      ),
    );
  }
}
