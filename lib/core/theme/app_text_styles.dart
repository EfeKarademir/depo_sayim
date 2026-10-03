import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle get _sans => GoogleFonts.dmSans();
  static TextStyle get _serif => GoogleFonts.cormorantGaramond();

  static TextStyle get countInput => GoogleFonts.jetBrainsMono(
        fontSize: 56,
        fontWeight: FontWeight.w900,
        color: AppColors.primary,
        height: 1.0,
      );

  static TextStyle get headline => _serif.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        height: 1.05,
        letterSpacing: -0.5,
      );

  static TextStyle get title => _sans.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );

  static TextStyle get subtitle => _sans.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.slate500,
        height: 1.45,
      );

  static TextStyle get labelSmall => _sans.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: AppColors.slate400,
      );

  static TextStyle get body => _sans.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.slate600,
        height: 1.5,
      );

  static TextStyle get bodyBold => _sans.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.slate800,
      );

  static TextStyle get monoBold => GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );
}
