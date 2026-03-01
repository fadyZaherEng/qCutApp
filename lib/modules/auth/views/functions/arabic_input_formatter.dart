import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/network/api.dart';

class ArabicInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Regular expression for Arabic text (Arabic letters, Arabic-Indic digits, spaces, and common punctuation)
    final arabicRegex = RegExp(r'^[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF\s\d.,،؛!؟\-/]+$');

    // If the new text is fully valid, allow it
    if (arabicRegex.hasMatch(newValue.text)) {
      return newValue;
    }

    // Check if we are adding text
    if (newValue.text.length > oldValue.text.length) {
      // Show toast error
      ShowToast.showError(message: 'pleaseEnterCityNameInArabic'.tr);
      return oldValue; // Reject change
    }

    return oldValue;
  }
}
