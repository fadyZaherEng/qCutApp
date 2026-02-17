import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/services/shared_pref/pref_keys.dart';
import 'package:q_cut/core/services/shared_pref/shared_pref.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'package:q_cut/modules/customer/features/home_features/profile_feature/models/customer_profile_model.dart';

class ProfileController extends GetxController {
  final NetworkAPICall _apiCall = NetworkAPICall();

  // Form Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Getters
  TextEditingController get fullNameController => _fullNameController;

  TextEditingController get phoneNumberController => _phoneNumberController;

  TextEditingController get passwordController => _passwordController;

  TextEditingController get cityController => _cityController;

  TextEditingController get confirmPasswordController =>
      _confirmPasswordController;

  TextEditingController get otpController => _otpController;

  TextEditingController get emailController => _emailController;

  // Profile data
  final Rx<CustomerProfileData?> profileData = Rx<CustomerProfileData?>(null);
  final RxList<String> favorites = <String>[].obs;

  // UI States
  final RxBool isLoading = false.obs;
  final RxBool isFavoritesLoading = false.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;

  // Tab controller
  late TabController tabController;

  // Form Keys
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  @override
  void onInit() async {
    super.onInit();
    await fetchProfileData();
  }

  @override
  void onClose() {
    // _fullNameController.dispose();
    // _phoneNumberController.dispose();
    // _passwordController.dispose();
    // _confirmPasswordController.dispose();
    // _emailController.dispose();
    // _otpController.dispose();
    super.onClose();
  }

  // Fetch profile data from API
  Future<void> fetchProfileData() async {
    // Skip fetching profile data for guest users
    final accessToken = SharedPref().getString(PrefKeys.accessToken);
    if (accessToken == null || accessToken.isEmpty) {
      isLoading.value = false;
      return; // Guest user, no profile to fetch
    }

    isLoading.value = true;
    isError.value = false;
    errorMessage.value = '';

    try {
      final response = await _apiCall.getData(Variables.GET_PROFILE);
      final responseBody = json.decode(response.body);
      print("Profile response: ${response.body}");
      if (response.statusCode == 200) {
        final profileResponse = CustomerProfileResponse.fromJson(responseBody);
        profileData.value = profileResponse.data;
        favorites.value = profileData.value?.favorites ?? [];

        _fullNameController.text = profileData.value?.fullName ?? '';
        _phoneNumberController.text = profileData.value?.phoneNumber ?? '';
        _cityController.text = profileData.value?.city ?? '';
        _emailController.text = ''; // Clear email as it's not in the response
      } else {
        isError.value = true;
        errorMessage.value =
            responseBody['message'] ?? 'Failed to fetch profile data';
        // ShowToast.showError(message: errorMessage.value);
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = 'Network error: $e';
      // Get.snackbar('Error', 'Failed to connect to server',
      //     backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Update profile data
  Future<void> updateProfile({
    bool cityChanged = false,
  }) async {
    isLoading.value = true;
    isError.value = false;
    errorMessage.value = '';

    try {
      final response = await _apiCall.putData(
        "${Variables.baseUrl}authentication/editUser",
        cityChanged
            ? {
                "city": cityController.text,
              }
            : {
                "fullName": fullNameController.text,
                // Only include email if it's provided
                if (emailController.text.isNotEmpty)
                  "email": emailController.text,
              },
      );
      final responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        await fetchProfileData();
        ShowToast.showSuccessSnackBar(
            message: "Profile updated successfully".tr);
      } else {
        isError.value = true;
        errorMessage.value =
            responseBody['message'] ?? 'Failed to update profile';
        ShowToast.showError(message: errorMessage.value);
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = 'Network error: $e';
      ShowToast.showError(message: 'Failed to connect to server'.tr);
    } finally {
      isLoading.value = false;
    }
  }
}
