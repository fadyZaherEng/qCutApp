import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:q_cut/core/services/shared_pref/pref_keys.dart';
import 'package:q_cut/core/services/shared_pref/shared_pref.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'package:q_cut/modules/auth/models/auth_response_model.dart';
import 'package:q_cut/modules/auth/models/user_model.dart';
import 'package:q_cut/modules/auth/views/otp_verification_view.dart';
import 'package:q_cut/modules/auth/views/password_reset_success_view.dart';
import 'package:q_cut/modules/customer/features/home_features/home/models/barber_model.dart';

class AuthController extends GetxController {
  final NetworkAPICall _apiCall = NetworkAPICall();

  // Form Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  final TextEditingController passwordController =
      TextEditingController(text: "");
  final TextEditingController city = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController barberShopNameController =
      TextEditingController();
  final TextEditingController locationDescriptionController =
      TextEditingController();

  // Form Keys
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  // UI States
  final RxBool isLoading = false.obs;
  final RxBool isSignUpSuccess = false.obs;
  final RxBool isLoginSuccess = false.obs;
  final RxString errorMessage = ''.obs;

  // User Data
  Rx<SignUpResponse?> signupResponse = Rx<SignUpResponse?>(null);
  Rx<LoginResponse?> loginResponse = Rx<LoginResponse?>(null);

  // Store userId from signup response
  final RxString userId = ''.obs;
  double locationLatitude = 0.0;
  double locationLongitude = 0.0;

  @override
  void onClose() {
    // fullNameController.dispose();
    // phoneNumberController.dispose();
    // passwordController.dispose();
    // confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> signUp(BuildContext context) async {
    if (!signupFormKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userData = UserModel(
        fullName: fullNameController.text.trim(),
        phoneNumber: phoneNumberController.text.trim().startsWith("+")
            ? phoneNumberController.text.trim().replaceAll('\u200E', '')
            : "+972${phoneNumberController.text.trim().replaceAll('\u200E', '')}",
        password: passwordController.text,
        city: city.text.trim(),
      );

      final requestData = {
        'userType':
            SharedPref().getBool(PrefKeys.userRole)! ? "user" : 'barber',
        'userData': SharedPref().getBool(PrefKeys.userRole)!
            ? userData.toJson()
            : {
                ...userData.toJson(),
                'barberShop': barberShopNameController.text.trim(),
                'locationDescription':
                    locationDescriptionController.text.trim(),
                "location": {
                  "type": "Point",
                  "coordinates": [locationLongitude, locationLatitude]
                }
              }
      };

      final response =
          await _apiCall.postDataAsGuest(requestData, Variables.SIGNUP);
      print({
        ...userData.toJson(),
        'barberShop': barberShopNameController.text.trim(),
        'locationDescription': locationDescriptionController.text.trim(),
        "location": {
          "type": "Point",
          "coordinates": [locationLongitude, locationLatitude]
        }
      });

      final responseBody = json.decode(response.body);
      print("response ${json.decode(response.body)}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        signupResponse.value = SignUpResponse.fromJson(responseBody);
        isSignUpSuccess.value = true;

        userId.value = responseBody['_id'] ?? '';

        if (userId.value.isEmpty) {
          errorMessage.value = 'User ID not received from server';
          ShowToast.showError(message: errorMessage.value);
          return;
        }

        ShowToast.showSuccessSnackBar(
            message:
                'Account created successfully ِAnd OTP Verification is 123456'
                    .tr);

        Get.to(() => OtpVerificationView(userId: userId.value));
      } else {
        errorMessage.value = responseBody['message'] ?? 'Failed to sign up';
        ShowToast.showError(message: errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Network error: $e';
      Get.snackbar('Error', 'Failed to connect to server',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Get FCM token
  Future<String> getFCMToken() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $fcmToken");
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      fcmToken = newToken;
      // Handle token refresh if needed
      print('FCM Token refreshed: $newToken');
    });
    if (fcmToken == null) {
      print('Failed to get FCM token');
    } else {
      print('FCM Token: $fcmToken');
    }
    return fcmToken ?? '';
  }

  Future<void> forgetPassword(String phoneNumber) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final String formattedPhone =
          phoneNumber.startsWith("+") ? phoneNumber : "+972$phoneNumber";

      final response = await _apiCall.postDataAsGuest(
          {"phoneNumber": formattedPhone}, Variables.FORGET_PASSWORD);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ShowToast.showSuccessSnackBar(message: "OTP is 123456".tr);
        Get.toNamed(
          AppRouter.otpVerificationResetCasePath,
          arguments: {
            "isFromResetPassword": true,
            "phoneNumber": formattedPhone,
          },
        );
      } else {
        final responseBody = json.decode(response.body);
        errorMessage.value = responseBody['message'] ?? 'Failed to send OTP'.tr;
        ShowToast.showError(message: errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Network error: $e';
      ShowToast.showError(message: 'failedToConnectToServer'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveLoginData(
      dynamic responseBody, LoginResponse loginResponse, bool isChecked) async {
    await SharedPref().setString(PrefKeys.id, loginResponse.id);
    await SharedPref().setString(PrefKeys.barberId, loginResponse.id);
    await SharedPref()
        .setString(PrefKeys.accessToken, loginResponse.accessToken);
    await SharedPref().setString(PrefKeys.profilePic, loginResponse.profilePic);
    await SharedPref().setString(PrefKeys.coverPic, loginResponse.coverPic);
    await SharedPref()
        .setString(PrefKeys.phoneNumber, loginResponse.phoneNumber);
    await SharedPref().setString(PrefKeys.fullName, loginResponse.fullName);
    await SharedPref().setBool(PrefKeys.saveMe, isChecked);

    // Save userOffer for barbers
    if (loginResponse.userOffer != null) {
      final offerJson = jsonEncode({
        'dealDateStart': loginResponse.userOffer!.dealDateStart,
        'dealDateEnd': loginResponse.userOffer!.dealDateEnd,
        'QCuteSubscription': loginResponse.userOffer!.qCuteSubscription,
        'freeUntilDate': loginResponse.userOffer!.freeUntilDate,
        'status': loginResponse.userOffer!.status,
      });
      await SharedPref().setString(PrefKeys.userOffer, offerJson);
    }

    if ((SharedPref().getBool(PrefKeys.userRole)) == false) {
      Barber barber = Barber.fromJson(responseBody);
      await SharedPref()
          .setString(PrefKeys.barber, jsonEncode(barber.toJson()));
    }
  }

  Future<void> login(BuildContext context, bool isChecked) async {
    if (!loginFormKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Get FCM token before making the request
      final fcmToken = await getFCMToken();

      final requestData = {
        'phoneNumber': phoneNumberController.text.trim().startsWith("+")
            ? phoneNumberController.text.trim().replaceAll('\u200E', '')
            : "+972${phoneNumberController.text.trim().replaceAll('\u200E', '')}",
        'password': passwordController.text,
        "fcmToken": fcmToken,
        "userType":
            SharedPref().getBool(PrefKeys.userRole) == true ? "user" : "barber",
      };
      print(requestData);

      final response =
          await _apiCall.postDataAsGuest(requestData, Variables.LOGIN);
      print(response.body);

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        loginResponse.value = LoginResponse.fromJson(responseBody);
        isLoginSuccess.value = true;

        await saveLoginData(responseBody, loginResponse.value!, isChecked);

        // You might want to show a success message
        ShowToast.showSuccessSnackBar(message: "loggedInSuccessfully".tr);

        // Check if there's a pending route to return to
        // We clear it but navigate to home to prevent crashes due to missing arguments
        if (loginResponse.value?.isBanned == true) {
          Get.offAllNamed(AppRouter.bannedPath, arguments: {
            "banReason": loginResponse.value?.banReason?.isEmpty ?? false
                ? "Account is banned"
                : loginResponse.value?.banReason ?? "Account is banned",
            "bannedUntil": loginResponse.value?.bannedUntil ?? 17000000000000,
            "daysRemaining": loginResponse.value?.daysRemaining ?? 20,
          });
          return;
        }

        Get.offAllNamed(AppRouter.bottomNavigationBar);
      } else {
        errorMessage.value = responseBody['message'] ?? 'Failed to login';
        ShowToast.showError(message: errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Network error: $e';
      Get.snackbar(
        'Error',
        'Failed to connect to server',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp(String otpValue, String userIdValue) async {
    isLoading.value = true;
    errorMessage.value = '';
    update();

    try {
      final requestData = {"userId": userIdValue, "otp": otpValue};

      final response =
          await _apiCall.postDataAsGuest(requestData, Variables.VERIFY_OTP);

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        print("dddddddddddddddddddddddd ${responseBody}");
        // Clear registration form data
        clearForm();
        ShowToast.showSuccessSnackBar(message: 'OTP verified successfully');

        // Use offAllNamed instead of direct Get.to to prevent keeping references to previous routes
        Get.offAllNamed(AppRouter.loginPath);
      } else {
        errorMessage.value = responseBody['message'] ?? 'Failed to verify OTP';
        ShowToast.showError(message: errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Network error: $e';
      ShowToast.showError(message: 'failedToConnectToServer'.tr);
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Similarly for resendOtp method, ensure it doesn't reference controllers directly
  Future<void> resendOtp(String userIdValue) async {
    isLoading.value = true;
    errorMessage.value = '';
    update();

    try {
      final requestData = {"userId": userIdValue};

      final response =
          await _apiCall.postDataAsGuest(requestData, Variables.baseUrl);

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        print("dddddddddddddddddddddddd ${responseBody}");
        ShowToast.showSuccessSnackBar(message: 'OTP resent successfully');
      } else {
        errorMessage.value = responseBody['message'] ?? 'Failed to resend OTP';
        ShowToast.showError(message: errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Network error: $e';
      Get.snackbar(
        'Error',
        'Failed to connect to server',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> resetPassword({
    required String phoneNumber,
    required String otp,
    required String newPassword,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final requestData = {
        "phoneNumber": phoneNumber,
        "otp": otp,
        "newPassword": newPassword,
      };

      final response = await _apiCall.postDataAsGuest(
          requestData, Variables.CHANGE_PASSWORD);

      if (response.statusCode == 200 || response.statusCode == 201) {
        String successMsg = "resetPasswordSuccess".tr;
        try {
          final responseBody = json.decode(response.body);
          if (responseBody is Map && responseBody.containsKey('message')) {
            successMsg = responseBody['message'];
          }
        } catch (_) {}
        ShowToast.showSuccessSnackBar(message: successMsg.tr);

        // Auto login after password reset
        await autoLoginAfterReset(phoneNumber, newPassword);
      } else {
        final errorData = json.decode(response.body);
        errorMessage.value = errorData['message'] ?? "failedToResetPassword".tr;
        ShowToast.showError(message: errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = "networkError".tr + ": $e";
      ShowToast.showError(message: errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> autoLoginAfterReset(String phoneNumber, String password) async {
    try {
      final fcmToken = await getFCMToken();
      final loginData = {
        'phoneNumber': phoneNumber,
        'password': password,
        "fcmToken": fcmToken,
        "userType":
            SharedPref().getBool(PrefKeys.userRole) == true ? "user" : "barber",
      };

      final response =
          await _apiCall.postDataAsGuest(loginData, Variables.LOGIN);
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final loginRes = LoginResponse.fromJson(responseBody);

        await saveLoginData(responseBody, loginRes, true);

        Get.to(() => const PasswordResetSuccessView());
      } else {
        Get.offAllNamed(AppRouter.loginPath);
      }
    } catch (e) {
      Get.offAllNamed(AppRouter.loginPath);
    }
  }

  // Update the clearForm method to be safer
  void clearForm() {
    // Only clear controllers that are definitely not in use
    fullNameController.clear();
    city.clear();
    confirmPasswordController.clear();
    barberShopNameController.clear();
    locationDescriptionController.clear();
    // Don't reference otpController here since it might be disposed
    errorMessage.value = '';
  }
}
