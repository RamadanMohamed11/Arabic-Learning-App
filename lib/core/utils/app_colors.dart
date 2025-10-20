import 'package:flutter/material.dart';

/// App Color Palette
/// A beautiful, cohesive color scheme for the Arabic Learning App
class AppColors {
  // Primary Colors from user palette
  static const Color slateBlue = Color(0xFF80A1BA);      // 80A1BA - Main primary color
  static const Color softTeal = Color(0xFF91C4C3);       // 91C4C3 - Secondary/Accent
  static const Color mintGreen = Color(0xFFB4DEBD);      // B4DEBD - Success/Highlight
  static const Color cream = Color(0xFFFFF7DD);          // FFF7DD - Background/Cards
  
  // Derived colors for better UI harmony
  static const Color darkSlateBlue = Color(0xFF667B8A);  // Darker variant
  static const Color lightSlateBlue = Color(0xFFB5C9D8); // Lighter variant
  static const Color darkTeal = Color(0xFF7AB0AF);       // Darker teal
  static const Color lightMint = Color(0xFFD4EED8);      // Lighter mint
  
  // Semantic colors
  static const Color primary = slateBlue;
  static const Color secondary = softTeal;
  static const Color accent = mintGreen;
  static const Color background = cream;
  static const Color surface = Colors.white;
  
  // Text colors
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF5A6C7D);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnAccent = Color(0xFF2C3E50);
  
  // Gradient combinations
  static const List<Color> primaryGradient = [slateBlue, darkSlateBlue];
  static const List<Color> secondaryGradient = [softTeal, darkTeal];
  static const List<Color> accentGradient = [mintGreen, softTeal];
  static const List<Color> warmGradient = [cream, mintGreen];
  
  // Exercise card gradients (using palette colors)
  static const List<Color> exercise1 = [softTeal, slateBlue];
  static const List<Color> exercise2 = [mintGreen, softTeal];
  static const List<Color> exercise3 = [slateBlue, darkSlateBlue];
  static const List<Color> exercise4 = [mintGreen, Color(0xFFA0D4B4)];
  static const List<Color> exercise5 = [softTeal, Color(0xFF7FB4B3)];
  static const List<Color> exercise6 = [slateBlue, softTeal];
  
  // Level gradients
  static const List<Color> level1 = [mintGreen, softTeal];
  static const List<Color> level2 = [softTeal, slateBlue];
  
  // UI Element colors
  static const Color cardBackground = surface;
  static const Color cardShadow = Color(0x1A000000);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color success = mintGreen;
  static const Color warning = Color(0xFFFDD787);
  static const Color error = Color(0xFFE89BA3);
  
  // Shadow colors with opacity
  static Color shadowLight = slateBlue.withOpacity(0.1);
  static Color shadowMedium = slateBlue.withOpacity(0.2);
  static Color shadowDark = slateBlue.withOpacity(0.3);
}
