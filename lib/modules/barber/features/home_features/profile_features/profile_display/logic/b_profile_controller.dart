import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:q_cut/core/services/shared_pref/shared_pref.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/models/barber_profile_model.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/models/barber_service_model.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/models/gallery_model.dart';
import 'package:q_cut/modules/customer/features/settings/chat_feature/logic/upload_media.dart';

import '../../../../../../../core/services/shared_pref/pref_keys.dart';
import '../../../../../../../main.dart';

class BProfileController extends GetxController {
  final NetworkAPICall _apiCall = NetworkAPICall();
  final UploadMedia _uploadMedia = UploadMedia();

  // Form Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController otpController = TextEditingController();

  // Profile data
  final Rx<BarberProfileData?> profileData = Rx<BarberProfileData?>(null);
  final RxList<BarberService> barberServices = <BarberService>[].obs;
  final RxList<String> galleryPhotos = <String>[].obs;
  final RxBool isGalleryLoading = false.obs;
  final RxBool isUploadingPhotos = false.obs;

  // Walk-in days
  final RxList<DateTime> walkInDates = <DateTime>[].obs;

  // UI States
  final RxBool isLoading = false.obs;
  final RxBool isServicesLoading = false.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;

  // Update state for service operations
  final RxBool isUpdatingService = false.obs;
  final RxString updateServiceMessage = ''.obs;

  // Create state for service operations
  final RxBool isCreatingService = false.obs;
  final RxString createServiceMessage = ''.obs;

  // Tab controller
  late TabController tabController;

  // Form Keys
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  @override
  void onInit() async {
    super.onInit();
    await fetchProfileData();
    loadWalkInDaysFromProfile();
    await fetchBarberServices();
    await fetchGallery(); // Fetch gallery on init
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Fetch profile data from API
  Future<void> fetchProfileData() async {
    isLoading.value = true;
    isError.value = false;
    errorMessage.value = '';

    try {
      final response = await _apiCall.getData(Variables.GET_PROFILE);
      final responseBody = json.decode(response.body);
      print(responseBody);
      if (response.statusCode == 200) {
        final profileResponse = BarberProfileResponse.fromJson(responseBody);
        profileData.value = profileResponse.data;
        SharedPref().removePreference(PrefKeys.profilePic);
        SharedPref().removePreference(PrefKeys.coverPic);
        profileImage = profileResponse.data.profilePic;
        coverImage = profileResponse.data.coverPic;
        currentBarberId = profileResponse.data.id;
        instagramLink = profileResponse.data.instagramPage;
        await SharedPref()
            .setString(PrefKeys.profilePic, profileResponse.data.profilePic);
        await SharedPref()
            .setString(PrefKeys.coverPic, profileResponse.data.coverPic);
        // await SharedPref().setString(PrefKeys.fullName, profileResponse.data.fullName);
        // await SharedPref()
        //     .setString(PrefKeys.phoneNumber, profileResponse.data.phoneNumber);
        await SharedPref()
            .setString(PrefKeys.barberId, profileResponse.data.id);
        await SharedPref().setString(
            PrefKeys.instagramLink, profileResponse.data.instagramPage);
        if (profileData.value != null) {
          if (profileData.value!.barberShop.isEmpty) {
            profileData.value!.barberShop = 'My Barber Shop';
          }

          if (profileData.value!.instagramPage.isEmpty) {
            profileData.value!.instagramPage = 'Not set';
          }

          // Ensure workingDays is initialized
          if (profileData.value!.workingDays.isEmpty) {
            profileData.value!.workingDays = [];
          }

          // Ensure offDay is initialized
          if (profileData.value!.offDay.isEmpty) {
            profileData.value!.offDay = [];
          }

          // Update form controllers with profile data
          fullNameController.text = profileData.value?.fullName ?? '';
          phoneNumberController.text = profileData.value?.phoneNumber ?? '';

          // Update cache for working days
          await SharedPref().setBool(PrefKeys.hasWorkingDays,
              profileData.value!.workingDays.isNotEmpty);
        }
      } else {
        isError.value = true;
        errorMessage.value =
            responseBody['message'] ?? 'Failed to fetch profile data'.tr;
        ShowToast.showError(message: _getErrorMessage(errorMessage.value));
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = '${'networkError'.tr}: $e';
      Get.snackbar('Error'.tr, 'Failed to connect to server'.tr,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  String _getErrorMessage(String message) {
    if (message.contains('|')) {
      final parts = message.split('|');
      if (Get.locale?.languageCode == 'ar' && parts.length > 1) {
        return parts[1].trim();
      }
      return parts[0].trim();
    }
    return message;
  }
  // Modified fetchGallery method
  Future<void> fetchGallery() async {
    isGalleryLoading.value = true;
    isError.value = false;
    errorMessage.value = '';

    try {
      final response = await _apiCall.getData("${Variables.baseUrl}gallery");
      final responseBody = json.decode(response.body);
      print("=====> $responseBody");
      if (response.statusCode == 200) {
        final galleryResponse = GalleryResponse.fromJson(responseBody);
        galleryPhotos.value = galleryResponse.photos;
      } else {
        isError.value = true;
        errorMessage.value =
            responseBody['message'] ?? 'Failed to fetch gallery'.tr;
        ShowToast.showError(message:_getErrorMessage(errorMessage.value));
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = '${'networkError'.tr}: $e';
      Get.snackbar('Error'.tr, 'Failed to load gallery'.tr,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isGalleryLoading.value = false;
    }
  }

  // Fetch barber services from API
  Future<void> fetchBarberServices() async {
    isServicesLoading.value = true;

    try {
      final response = await _apiCall.getData(Variables.GET_BARBER_SERVICES);
      final responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseBody is List) {
          // Direct list response - clear list first, then add new items
          barberServices.clear();
          final newServices = responseBody
              .map((service) => BarberService.fromJson(service))
              .toList();
          barberServices.addAll(newServices);
        } else if (responseBody is Map) {
          // Response with wrapper object - clear list first, then add new items
          final servicesResponse = BarberServicesResponse.fromJson(
              responseBody as Map<String, dynamic>);
          barberServices.clear();
          barberServices.addAll(servicesResponse.data);
        }

        // Update cache for services
        await SharedPref()
            .setBool(PrefKeys.hasServices, barberServices.isNotEmpty);

        // Force UI update
        update(['barber_services']); // Use named update for better performance
      } else {
        isError.value = true;
        final errorMsg =
            responseBody['message'] ?? 'Failed to fetch barber services'.tr;
        errorMessage.value = errorMsg;
        ShowToast.showError(message: _getErrorMessage(errorMessage.value));
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = '${'networkError'.tr}: $e';
      Get.snackbar('Error'.tr, 'Failed to load services data'.tr,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isServicesLoading.value = false;
    }
  }

  // New method to upload service image and get URL
  Future<String?> uploadServiceImage(File imageFile) async {
    try {
      final uploadedUrl = await _uploadMedia.uploadFile(imageFile, 'image');
      return uploadedUrl;
    } catch (e) {
      print('Error uploading service image: $e');
      ShowToast.showError(message: 'Failed to upload service image'.tr);
      return null;
    }
  }

  // Update barber service with API
  Future<Map<String, dynamic>> updateBarberService({
    required String serviceId,
    required String serviceName,
    required String servicePrice,
    required String serviceTime,
    String? imageUrl,
  }) async {
    isUpdatingService.value = true;
    updateServiceMessage.value = '';

    try {
      // Prepare request data
      final Map<String, dynamic> requestData = {
        'name': serviceName,
        'price': int.tryParse(servicePrice) ?? 0,
        "imageUrl": imageUrl ??
            "https://qcute-test-bucket.s3.us-east-1.amazonaws.com/images/1738787141939",
        // 'duration': int.tryParse(serviceTime) ?? 30, // Added duration field
      };

      // Ensure the URL is properly formatted with the API base URL
      const endpoint = Variables.UPDATE_BARBER_SERVICE;
      final url = endpoint + (endpoint.endsWith('/') ? '' : '/') + serviceId;

      print('API URL: $url');
      print('Request data: ${jsonEncode(requestData)}');

      // Make API call - passing the Map directly instead of pre-encoding it
      // Let the network helper handle the JSON encoding
      final response = await _apiCall.editData(
        url,
        requestData, // Pass the Map directly instead of encoding it here
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        updateServiceMessage.value = 'Service updated successfully'.tr;
        ShowToast.showSuccessSnackBar(message: updateServiceMessage.value);

        // Refresh services list after successful update
        await fetchBarberServices();

        // Force UI updates with explicit IDs
        update(['barber_services']);
        Get.forceAppUpdate(); // Force GetX to refresh the entire app's state

        // Check if the response is a valid JSON before decoding
        var responseBody;
        try {
          responseBody = json.decode(response.body);
        } catch (e) {
          responseBody = {'message': 'Service updated successfully'};
        }

        return {
          'success': true,
          'message': updateServiceMessage.value,
          'data': responseBody
        };
      } else {
        // Handle error response - safely parse response body
        var responseBody;
        try {
          responseBody = json.decode(response.body);
        } catch (e) {
          // If response body isn't valid JSON (like HTML error page)
          responseBody = {
            'message': '${'Failed to update service'.tr}: ${response.statusCode}'
          };
        }

        updateServiceMessage.value = (responseBody is Map)
            ? (responseBody['message'] ?? 'Failed to update service'.tr)
            : 'Failed to update service'.tr;
        ShowToast.showError(message: updateServiceMessage.value);
        return {
          'success': false,
          'message': updateServiceMessage.value,
          'error': responseBody
        };
      }
    } catch (e) {
      print("=====> $e");
      updateServiceMessage.value = '${'networkError'.tr}: $e';
      Get.snackbar('Error'.tr, 'Failed to update service'.tr,
          backgroundColor: Colors.red, colorText: Colors.white);
      return {
        'success': false,
        'message': updateServiceMessage.value,
        'error': e.toString()
      };
    } finally {
      isUpdatingService.value = false;
    }
  }

  Future<void> addPhotosToGallery() async {
    try {
      print('Starting photo selection...');
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isEmpty) return;

      isUploadingPhotos.value = true;
      final List<String> uploadedUrls = [];

      // Upload each image one by one
      for (final image in images) {
        final uploaded =
            await _uploadMedia.uploadFile(File(image.path), 'image');
        if (uploaded != null) {
          uploadedUrls.add(uploaded);
        }
      }

      if (uploadedUrls.isNotEmpty) {
        // Send all uploaded URLs to server
        // Fix: The API expects a proper format for the photos parameter
        final requestData = {
          'photos': uploadedUrls, // This is already a List<String>
        };

        print('Adding photos to gallery: $requestData');

        final response = await _apiCall.addData(
          requestData, // Pass the Map directly
          '${Variables.baseUrl}gallery/add-photos',
        );

        print(
            'Gallery upload response: ${response.statusCode}, ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          await fetchGallery(); // Refresh gallery
          // Get.snackbar(
          //   'Success'.tr,
          //   'Photos added successfully'.tr,
          //   backgroundColor: ColorsData.primary,
          //   colorText: Colors.white,
          // );
        } else {
          // Get.snackbar(
          //   'Error',
          //   'Failed to add photos to gallery: ${response.statusCode}',
          //   backgroundColor: Colors.red,
          //   colorText: Colors.white,
          // );
        }
      }
    } catch (e) {
      print('Error adding photos: $e');
      // Get.snackbar(
      //   'Error',
      //   'Failed to upload photos: ${e.toString()}',
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      // );
    } finally {
      isUploadingPhotos.value = false;
    }
  }

  // Create new barber service
  Future<Map<String, dynamic>> createBarberService({
    required String serviceName,
    required String servicePrice,
    required int min,
    required int max,
    String? imageUrl,
  }) async {
    isCreatingService.value = true;
    createServiceMessage.value = '';

    try {
      // Prepare request data
      final Map<String, dynamic> requestData = {
        'name': serviceName,
        'price': int.tryParse(servicePrice) ?? 0,
        'minTime': min,
        'maxTime': max,
        'imageUrl': imageUrl ??
            "https://qcute-test-bucket.s3.us-east-1.amazonaws.com/images/1738787141939"
      };

      print('Creating service with data: ${jsonEncode(requestData)}');

      // Make API call
      final response = await _apiCall.addData(
        requestData,
        Variables.CREATE_BARBER_SERVICE,
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        createServiceMessage.value = 'Service created successfully'.tr;
        ShowToast.showSuccessSnackBar(message: createServiceMessage.value);

        // Refresh services list after successful creation
        await fetchBarberServices();

        // Update cache
        await SharedPref().setBool(PrefKeys.hasServices, true);

        // Force UI updates with explicit IDs
        update(['barber_services']);
        Get.forceAppUpdate(); // Force GetX to refresh the entire app's state

        // Parse response body
        var responseBody;
        try {
          responseBody = json.decode(response.body);
        } catch (e) {
          responseBody = {'message': 'Service created successfully'};
        }

        return {
          'success': true,
          'message': createServiceMessage.value,
          'data': responseBody
        };
      } else {
        // Handle error response
        var responseBody;
        try {
          responseBody = json.decode(response.body);
        } catch (e) {
          responseBody = {
            'message': '${'Failed to create service'.tr}: ${response.statusCode}'
          };
        }

        createServiceMessage.value = (responseBody is Map)
            ? (responseBody['message'] ?? 'Failed to create service'.tr)
            : 'Failed to create service'.tr;
        ShowToast.showError(message: createServiceMessage.value);
        return {
          'success': false,
          'message': createServiceMessage.value,
          'error': responseBody
        };
      }
    } catch (e) {
      print("=====> Error creating service: $e");
      createServiceMessage.value = '${'networkError'.tr}: $e';
      ShowToast.showError(message: 'Failed to create service'.tr);
      return {
        'success': false,
        'message': createServiceMessage.value,
        'error': e.toString()
      };
    } finally {
      isCreatingService.value = false;
    }
  }

  // Helper method to get total number of services
  int get totalServices => barberServices.length;

  // Helper method to get total price range
  String getServicesRangeAsString() {
    if (barberServices.isEmpty) {
      return 'No services available'.tr;
    }

    int minPrice =
        barberServices.map((s) => s.price).reduce((a, b) => a < b ? a : b);
    int maxPrice =
        barberServices.map((s) => s.price).reduce((a, b) => a > b ? a : b);

    return '\$${minPrice.toString()} - \$${maxPrice.toString()}';
  }

  // Helper method to get working days as formatted string
  String getWorkingDaysAsString() {
    if (profileData.value == null || profileData.value!.workingDays.isEmpty) {
      return 'No working days set'.tr;
    }

    final List<String> formattedDays =
        profileData.value!.workingDays.map((day) {
      return '${day.day} (${day.workingHours})';
    }).toList();

    return formattedDays.join(', ');
  }

  // Helper method to get off days as string
  String getOffDaysAsString() {
    if (profileData.value == null || profileData.value!.offDay.isEmpty) {
      return 'No off days set'.tr;
    }

    return profileData.value!.offDay.join(', ');
  }

  // Helper method to format address
  String getAddress() {
    if (profileData.value == null) {
      return 'No address set'.tr;
    }

    return profileData.value!.city;
  }

  // Walk-in days management
  // Delete barber service
  Future<bool> deleteBarberService(String serviceId) async {
    if (barberServices.length <= 1) {
      ShowToast.showError(message: "At least one service is required".tr);
      return false;
    }

    try {
      final url = "${Variables.SERVICE}$serviceId";
      final response = await _apiCall.deleteData(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ShowToast.showSuccessSnackBar(
            message: "Service deleted successfully".tr);
        await fetchBarberServices();
        return true;
      } else {
        final responseBody = json.decode(response.body);
        ShowToast.showError(
            message: responseBody['message'] ?? 'Failed to delete service'.tr);
        return false;
      }
    } catch (e) {
      ShowToast.showError(message: '${'networkError'.tr}: $e');
      return false;
    }
  }

  // Check if a date is a walk-in day
  bool isWalkInDay(DateTime date) {
    if (profileData.value?.walkIn == null || profileData.value!.walkIn!.isEmpty) {
      return false;
    }
    
    // Check if the date falls within any walk-in range
    return profileData.value!.walkIn!.any((record) => record.containsDate(date));
  }

  // Load walk-in days from profile data
  void loadWalkInDaysFromProfile() {
    if (profileData.value?.walkIn != null) {
      walkInDates.clear();
      // Extract all dates from walk-in ranges
      for (var record in profileData.value!.walkIn!) {
        final start = DateTime.fromMillisecondsSinceEpoch(record.startDate);
        final end = DateTime.fromMillisecondsSinceEpoch(record.endDate);
        
        // Add all dates in the range
        for (var date = start; 
             date.isBefore(end) || date.isAtSameMomentAs(end); 
             date = date.add(const Duration(days: 1))) {
          walkInDates.add(DateTime(date.year, date.month, date.day));
        }
      }
    }
  }

  // Update walk-in ranges
  Future<bool> updateWalkInRanges(List<Map<String, DateTime>> ranges) async {
    try {
      if (ranges.isEmpty) {
        ShowToast.showError(message: "Please select at least one range".tr);
        return false;
      }

      List<Map<String, dynamic>> walkInRecords = [];
      
      for (var range in ranges) {
        final start = range['start']!;
        final end = range['end'] ?? start;
        
        // Ensure start is at 00:00:00 and end is at 23:59:59
        final startOfDay = DateTime(start.year, start.month, start.day, 0, 0, 0);
        final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
        
        walkInRecords.add({
          "startDate": startOfDay.millisecondsSinceEpoch,
          "endDate": endOfDay.millisecondsSinceEpoch,
        });
      }
      print("Walk-in records to update: $walkInRecords");
      final response = await _apiCall.putData(Variables.UPDATE_WALK_IN, {
        "walkInRecords": walkInRecords
      });
         print("Update walk-in response: ${response.statusCode}, ${response.body}");
      if (response.statusCode == 200) {
        // Refresh profile to get updated walk-in data
        await fetchProfileData();
        loadWalkInDaysFromProfile();
        ShowToast.showSuccessSnackBar(message: "Walk-In ranges updated successfully".tr);
        update();
        return true;
      } else {
        final responseBody = json.decode(response.body);
        ShowToast.showError(message: responseBody['message'] ?? "Failed to update walk-in days".tr);
        return false;
      }
    } catch (e) {
      ShowToast.showError(message: "${'Error updating walk-in days'.tr}: $e");
      return false;
    }
  }
}

