// constants/app_text_styles.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headings
  static const TextStyle headline5 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle headline6 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  
  // Body text
  static const TextStyle subtitle1 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle subtitle2 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle body1 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
  );
  
  static const TextStyle body2 = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
  );
  
  static const TextStyle caption = TextStyle(
    color: AppColors.textTertiary,
    fontSize: 14,
  );
  
  // Button text
  static const TextStyle button = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}