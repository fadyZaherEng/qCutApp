import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/services/shared_pref/pref_keys.dart';
import 'package:q_cut/core/services/shared_pref/shared_pref.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'package:q_cut/main.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/logic/b_profile_controller.dart';
import 'package:q_cut/modules/customer/features/settings/chat_feature/logic/upload_media.dart';

import '../../../../../../core/utils/network/api.dart';
import 'profile_controller.dart';

class UpdateProfilePictureController extends GetxController {
  final NetworkAPICall _apiCall = NetworkAPICall();
  final UploadMedia _uploadMedia = UploadMedia();
  final RxBool isLoading = false.obs;
  final RxString profileImageUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    profileImageUrl.value = profileImage;
  }

  Future<void> updateProfilePicture(File imageFile) async {
    isLoading.value = true;
    try {
      // Upload the image file
      final uploadedUrl = await _uploadMedia.uploadFile(imageFile, 'image');

      if (uploadedUrl != null) {
        // Create the payload with just the profile picture
        final Map<String, dynamic> payload = {
          'profilePic': uploadedUrl,
        };
        print('Payload for updating profile picture: $payload');

        // Determine the correct endpoint based on user role
        // userRole is bool: true for user, false for barber
        final isUser = SharedPref().getBool(PrefKeys.userRole) ?? true;
        final String endpoint = !isUser
            ? '${Variables.baseUrl}authentication'
            : '${Variables.baseUrl}authentication/editUser';

        // Send the update request
        final response = await _apiCall.editData(endpoint, payload);
        print('Update profile picture response: ${response.statusCode} - ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Update local storage
          SharedPref().removePreference(PrefKeys.profilePic);
          profileImage = uploadedUrl;
          await SharedPref().setString(PrefKeys.profilePic, uploadedUrl);

          // Update local controller state
          profileImageUrl.value = uploadedUrl;

          // Show success message
          Get.snackbar(
            'Success'.tr,
            'Profile picture updated successfully'.tr,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          await reloadProfileUI();
        } else {
          Get.snackbar(
            'Error'.tr,
            '${'Failed to update profile picture'.tr}: ${response.statusCode}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error'.tr,
          'Failed to upload image'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error updating profile picture: $e');
      Get.snackbar(
        'Error'.tr,
        'Something went wrong. Please try again.'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reloadProfileUI() async {
    try {
      final isUser = SharedPref().getBool(PrefKeys.userRole) ?? true;
      if (!isUser) {
        if (Get.isRegistered<BProfileController>()) {
          final bProfileController = Get.find<BProfileController>();
          await bProfileController.fetchProfileData();
          bProfileController.update();
        }
      } else {
        if (Get.isRegistered<ProfileController>()) {
          final profileController = Get.find<ProfileController>();
          await profileController.fetchProfileData();
          profileController.update();
        }
      }
      
      // Close the dialog after UI is refreshed
      if (Get.isOverlaysOpen) {
        Get.back();
      }
    } catch (e) {
      print('Error refreshing UI: $e');
      if (Get.isOverlaysOpen) {
        Get.back();
      }
    }
  }
}
