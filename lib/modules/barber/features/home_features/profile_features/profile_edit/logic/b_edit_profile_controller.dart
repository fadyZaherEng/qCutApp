import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'package:q_cut/main.dart';
import '../../../../../../../core/services/shared_pref/pref_keys.dart';
import '../../../../../../../core/services/shared_pref/shared_pref.dart';
import '../../../../../../../core/utils/constants/drawer_constants.dart';
import '../../../../../../../core/utils/network/api.dart';
import '../../../../../../customer/features/settings/chat_feature/logic/upload_media.dart';
import '../../models/barber_profile_model.dart';
import '../../profile_display/logic/b_profile_controller.dart';
import '../../profile_display/models/barber_profile_model.dart';

class BEditProfileController extends GetxController {
  final NetworkAPICall _apiCall = NetworkAPICall();
  final UploadMedia _uploadMedia = UploadMedia();

  // Profile controller reference
  BProfileController? _profileController;

  late final BarberProfileModel initialData;
  late Rx<BarberProfileModel> profileData;
  final RxBool isLoading = false.obs;

  // Working days management
  final RxList<WorkingDay> workingDays = <WorkingDay>[].obs;

  // Off days management
  final RxList<String> offDays = <String>[].obs;

  // List of all available days for selection
  final List<String> availableDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  final Rx<File?> _newProfileImage = Rx<File?>(null);
  final Rx<File?> _newCoverImage = Rx<File?>(null);

  ImageProvider get getProfileImage => _newProfileImage.value != null
      ? FileImage(_newProfileImage.value!)
      : NetworkImage(initialData.profilePic.isNotEmpty
          ? initialData.profilePic
          : DrawerConstants.defaultProfileImage) as ImageProvider;

  ImageProvider get getCoverImage => _newCoverImage.value != null
      ? FileImage(_newCoverImage.value!)
      : NetworkImage(initialData.coverPic.isNotEmpty
          ? initialData.coverPic
          : DrawerConstants.defaultProfileImage) as ImageProvider;

  // Form controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final saloonController = TextEditingController();
  final cityController = TextEditingController();
  // final bankAccountController = TextEditingController();
  final instagramController = TextEditingController();
  final locationDescriptionController = TextEditingController();
  double locationLatitude = 0.0;
  double locationLongitude = 0.0;

  @override
  void onInit() {
    super.onInit();
    initialData = Get.arguments as BarberProfileModel;
    profileData = Rx<BarberProfileModel>(initialData);
    _initializeControllers();

    // Initialize working days from the profile data
    if (initialData.workingDays.isNotEmpty) {
      workingDays.value = List<WorkingDay>.from(initialData.workingDays);
    }

    // Initialize off days from the profile data
    if (initialData.offDay.isNotEmpty) {
      offDays.value = List<String>.from(initialData.offDay);
    }

    // Initialize profile controller if available
    try {
      _profileController = Get.find<BProfileController>();
    } catch (e) {
      // If not found, we'll handle it when needed
      print('BProfileController not found, will create when needed');
    }
  }

  void _initializeControllers() {
    nameController.text = initialData.fullName;
    phoneController.text =
        initialData.phoneNumber.replaceFirst("+972", "") ?? '';
    saloonController.text = initialData.barberShop;
    cityController.text = initialData.city;
    // bankAccountController.text = initialData.bankAccountNumber;
    instagramController.text = initialData.instagramPage;
    locationDescriptionController.text = initialData.locationDescription;
    if (initialData.barberShopLocation.coordinates.length == 2) {
      locationLongitude = initialData.barberShopLocation.coordinates[0];
      locationLatitude = initialData.barberShopLocation.coordinates[1];
    }
  }

  Future<void> pickProfileImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _newProfileImage.value = File(picked.path);
    }
  }

  Future<void> pickCoverImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _newCoverImage.value = File(picked.path);
    }
  }

  // Add a new working day
  void addWorkingDay() {
    // Check if we've used all available days
    if (workingDays.length >= availableDays.length) {
      Get.snackbar(
        'Maximum Reached',
        'You\'ve already added all available days',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Get currently used days
    final usedDays = workingDays.map((wd) => wd.day).toList();

    // Find an available day that's not already in the list and not in off days
    String? availableDay;
    for (final day in availableDays) {
      if (!usedDays.contains(day) && !offDays.contains(day)) {
        availableDay = day;
        break;
      }
    }

    if (availableDay != null) {
      workingDays.add(WorkingDay(
        day: availableDay,
        startHour: 9, // Default start hour
        endHour: 17, // Default end hour
      ));
    } else {
      Get.snackbar(
        'No Days Available',
        'All days are either already added or set as off days',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  // Update a working day at the given index
  void updateWorkingDay(int index, WorkingDay newWorkingDay) {
    if (index >= 0 && index < workingDays.length) {
      // Check if the new day is not in off days
      if (offDays.contains(newWorkingDay.day)) {
        Get.snackbar(
          'Day Unavailable',
          '${newWorkingDay.day} is already set as an off day',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      workingDays[index] = newWorkingDay;
      workingDays.refresh(); // Force UI update
    }
  }

  // Remove a working day at the given index
  void removeWorkingDay(int index) {
    if (workingDays.length <= 1) {
      Get.snackbar(
        'Action Denied',
        'You must have at least one working day',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    if (index >= 0 && index < workingDays.length) {
      workingDays.removeAt(index);
    }
  }

  // Set off days and update working days accordingly
  void setOffDays(List<String> selectedOffDays) {
    // Update off days
    offDays.value = selectedOffDays;

    // Remove any working days that are now off days
    workingDays
        .removeWhere((workingDay) => selectedOffDays.contains(workingDay.day));

    workingDays.refresh();
  }

  Future<void> updateProfile() async {
    isLoading.value = true;
    try {
      String? profilePicUrl = initialData.profilePic;
      String? coverPicUrl = initialData.coverPic;

      if (_newProfileImage.value != null) {
        final uploaded =
            await _uploadMedia.uploadFile(_newProfileImage.value!, 'image');
        if (uploaded != null) profilePicUrl = uploaded;
      }

      if (_newCoverImage.value != null) {
        final uploaded =
            await _uploadMedia.uploadFile(_newCoverImage.value!, 'image');
        if (uploaded != null) coverPicUrl = uploaded;
      }

      // Build payload with properly formatted working days
      final Map<String, dynamic> payload = {
        'fullName': nameController.text,
        'phoneNumber': phoneController.text,
        'barberShop': saloonController.text,
        'city': cityController.text,
        'instagramPage': instagramController.text,
        'locationDescription': locationDescriptionController.text,
        'bankAccountNumber': "123456", // bankAccountController.text,
        'offDay': offDays,
        'workingDays': workingDays
            .map((day) => {
                  "day": day.day,
                  "startHour": day.startHour,
                  "startMinute": day.startMinute,
                  "endHour": day.endHour,
                  "endMinute": day.endMinute,
                })
            .toList(),
        'profilePic': profilePicUrl,
        'coverPic': coverPicUrl,
        'barberShopLocation': {
          'type': 'Point',
          'coordinates': [locationLongitude, locationLatitude],
        },
      };

      print('Payload workingDays: ${payload['workingDays']}');
      final response = await _apiCall.editData(
          '${Variables.baseUrl}authentication', payload);

      if (response.statusCode == 200) {
        // Also update working days in a separate call
        final workingDaysPayload = {
          'workingDays': workingDays
                  .map((day) => {
                    "day": day.day,
                    "startHour": day.startHour,
                    "startMinute": day.startMinute,
                    "endHour": day.endHour,
                    "endMinute": day.endMinute,
                  })
              .toList(),
        };

        await _apiCall.editData(
            '${Variables.baseUrl}barber/update-working-days',
            workingDaysPayload);

        SharedPref().removePreference(PrefKeys.profilePic);
        SharedPref().removePreference(PrefKeys.coverPic);
        profileImage = profilePicUrl;
        coverImage = coverPicUrl;
        fullName = nameController.text;
        await SharedPref().setString(PrefKeys.profilePic, profilePicUrl);
        await SharedPref().setString(PrefKeys.coverPic, coverPicUrl);
        try {
          final profileController = Get.find<BProfileController>();
          await profileController.fetchProfileData();
        } catch (e) {
          try {
            final profileController = Get.put(BProfileController());
            await profileController.fetchProfileData();
          } catch (e2) {
            print("Error refreshing profile data: $e2");
          }
        }

        Get.back(result: true);
      } else {
        Get.snackbar(
            'Error', 'Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating profile: $e');
      Get.snackbar('Error', 'Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    saloonController.dispose();
    cityController.dispose();
    // bankAccountController.dispose();
    instagramController.dispose();
    locationDescriptionController.dispose();
    super.onClose();
  }
}
