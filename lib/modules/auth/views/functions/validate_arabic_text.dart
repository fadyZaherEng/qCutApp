import 'package:get/get.dart';

/// Validates that the input contains only Arabic characters, spaces, and common punctuation
String? validateArabicText(String? value) {
  if (value == null || value.isEmpty) {
    return null; // Let required validation handle empty values
  }

  // Regular expression for Arabic text
  // Matches: Arabic letters, Arabic-Indic digits, spaces, and common punctuation
  final arabicRegex = RegExp(r'^[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF\s\d.,،؛!؟\-/]+$');

  if (!arabicRegex.hasMatch(value)) {
    return 'pleaseEnterCityNameInArabic'.tr;
  }

  return null;
}

/// Checks if a string contains Arabic characters
bool hasArabicCharacters(String text) {
  final arabicRegex = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]');
  return arabicRegex.hasMatch(text);
}
