import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/services/shared_pref/pref_keys.dart';
import 'package:q_cut/core/services/shared_pref/shared_pref.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';

class OtpVerificationController extends GetxController {
  // UI States
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool disposed = false.obs;

  // Text Editing Controllers
  final TextEditingController otpController = TextEditingController();

  // Timer state
  final RxInt timerSeconds = 60.obs;
  final RxBool isTimerRunning = false.obs;

  @override
  void onInit() {
    super.onInit();
    print("OtpVerificationController initialized");
    startTimer();
    otpController.text = ""; // "123456"; // Constant OTP
  }

  void startTimer() {
    timerSeconds.value = 60;
    isTimerRunning.value = true;
    _runTimer();
  }

  void _runTimer() async {
    while (timerSeconds.value > 0 && isTimerRunning.value) {
      await Future.delayed(const Duration(seconds: 1));
      if (!disposed.value) {
        timerSeconds.value--;
      } else {
        break; // Stop if controller is disposed
      }
    }
    isTimerRunning.value = false;
  }

  @override
  void onClose() {
    disposed.value = true;
    isTimerRunning.value = false;
    print("OtpVerificationController onClose() called");
    otpController.dispose();
    super.onClose();
  }

  // Method to resend OTP
  Future<void> resendOtp(String phoneNumber) async {
    if (timerSeconds.value > 0) return; // Prevent resend if timer is active

    isLoading.value = true;
    try {
      // TODO: Implement resend OTP API call
      // For now, just simulate and restart timer
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay
      ShowToast.showSuccessSnackBar(message: "OTP is 123456".tr);
      startTimer();
    } catch (e) {
      errorMessage.value = 'Error: $e';
      ShowToast.showError(message: errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Method to verify OTP
  Future<void> verifyOtp({
    required String otp,
    required String phoneNumber,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      // Since OTP is constant "123456" for this flow, we might not need to call API here
      // if the requirement is just to move to the next screen.
      // However, usually verify happens here.
      // For this specific request "make otp constatnt show for user from 1 to 6",
      // and "then when reset navigate to reset password screen".

      // check if OTP matches 123456
      if (otp != "123456") {
        ShowToast.showError(message: "Invalid OTP".tr);
        return;
      }

      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay
      // ShowToast.showSuccessSnackBar(message: "OTP verified successfully");
      // Navigation should be handled by the view based on success
    } catch (e) {
      errorMessage.value = 'Error: $e';
      ShowToast.showError(message: errorMessage.value);
      rethrow; // Rethrow to let view know it failed
    } finally {
      isLoading.value = false;
    }
  }

  // Method to update phone number
  Future<void> updatePhoneNumber(String newPhoneNumber) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final String formattedPhoneNumber = newPhoneNumber.startsWith('+')
          ? newPhoneNumber
          : (newPhoneNumber.startsWith('972')
              ? '+$newPhoneNumber'
              : "+972$newPhoneNumber");
      print("API Endpoint: ${Variables.VERIFY_CHANGE_PHONE}");

      print(
          "Request Body: {newPhoneNumber: $formattedPhoneNumber, otp: ${otpController.text}}");
      final response = await NetworkAPICall().addData({
        "newPhoneNumber": formattedPhoneNumber,
        "otp": otpController.text,
      }, Variables.VERIFY_CHANGE_PHONE);

      print("Update Phone Number Response Status: ${response.statusCode}");
      print("Update Phone Number Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Double check if body is actually a success message or JSON
        try {
          final responseBody = json.decode(response.body);
          if (responseBody is Map && responseBody.containsKey('message')) {
            // Update local storage
            await SharedPref()
                .setString(PrefKeys.phoneNumber, formattedPhoneNumber);

            ShowToast.showSuccessSnackBar(
                message: responseBody['message'] ??
                    'Phone number updated successfully'.tr);
            // Navigate back to profile or home
            Get.offAllNamed("/bottomNavigationBar");
          } else if (response.body.toString().contains("Endpoint not found")) {
            ShowToast.showError(message: "Error: Endpoint not found".tr);
          } else {
            // Fallback success if it's 200 but not standard JSON
            await SharedPref()
                .setString(PrefKeys.phoneNumber, formattedPhoneNumber);
            ShowToast.showSuccessSnackBar(
                message: 'Phone number updated successfully'.tr);
            Get.offAllNamed("/bottomNavigationBar");
          }
        } catch (e) {
          // If not JSON but status is successful
          if (response.body.toString().contains("Endpoint not found")) {
            ShowToast.showError(message: "Error: Endpoint not found".tr);
          } else {
            await SharedPref()
                .setString(PrefKeys.phoneNumber, formattedPhoneNumber);
            ShowToast.showSuccessSnackBar(
                message: 'Phone number updated successfully'.tr);
            Get.offAllNamed("/bottomNavigationBar");
          }
        }
      } else {
        // Handle non-200/201 status
        try {
          final responseBody = json.decode(response.body);
          ShowToast.showError(
              message:
                  responseBody['message'] ?? 'Failed to update phone number'.tr);
        } catch (e) {
          ShowToast.showError(
              message: response.body.isNotEmpty
                  ? response.body.toString()
                  : 'Failed to update phone number'.tr + " (Status: ${response.statusCode})");
        }
      }
    } catch (e) {
      print("Update Phone Number Error: $e");
      ShowToast.showError(message: 'Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
