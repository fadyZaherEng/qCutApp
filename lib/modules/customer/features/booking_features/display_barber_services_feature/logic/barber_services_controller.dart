import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/models/barber_profile_model.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/models/barber_service_model.dart'
    as barber_model;
import 'package:q_cut/modules/customer/features/booking_features/display_barber_services_feature/models/barber_service.dart';
import 'package:q_cut/modules/customer/features/booking_features/display_barber_services_feature/models/free_time_request_model.dart';
import 'package:q_cut/modules/customer/features/booking_features/select_appointment_time/controller/select_appointment_time_controller.dart';

class BarberServicesController extends GetxController {
  final NetworkAPICall _apiCall = NetworkAPICall();

  // Form Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController otpController = TextEditingController();

  // Profile data
  final Rx<BarberProfileData?> profileData = Rx<BarberProfileData?>(null);
  final RxList<BarberServices> barberServices = <BarberServices>[].obs;
  final RxList<barber_model.BarberService> services =
      <barber_model.BarberService>[].obs;

  // UI States
  final RxBool isLoading = false.obs;
  final RxBool isServicesLoading = false.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString barberId = ''.obs;
  final RxList<bool> selectedServices = <bool>[].obs;
  final RxInt selectedCount = 0.obs;
  final RxBool hasSelection = false.obs;

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
  void onClose() {
    fullNameController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> fetchServices(String barberId, {List<String>? preSelectedServiceIds}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _apiCall.getData(Variables.SERVICE + barberId);
      print("Fetching services for barber ID: $barberId");
      print("Request URL: ${Variables.SERVICE + barberId}");
      
      final responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseBody is List) {
          barberServices.value = responseBody
              .map((service) => BarberServices.fromJson(service))
              .toList();
        } else if (responseBody is Map<String, dynamic>) {
          final servicesResponse = BarberServiceResponse.fromJson(responseBody);
          barberServices.value = servicesResponse.services;
        }
        
        // Initialize selected status based on pre-selection or default to false
        selectedServices.value = List.generate(barberServices.length, (index) {
          if (preSelectedServiceIds != null && preSelectedServiceIds.isNotEmpty) {
            final serviceId = barberServices[index].id;
            return preSelectedServiceIds.contains(serviceId);
          }
          return false;
        });
        
        // Update selection count
        selectedCount.value = selectedServices.where((selected) => selected).length;
        hasSelection.value = selectedCount.value > 0;
        
      } else {
        errorMessage.value =
            (responseBody is Map ? responseBody['message'] : null) ?? 'failedToFetchServices'.tr;
      }
    } catch (e) {
      errorMessage.value = '${'networkError'.tr}: $e';
      print("Error in fetchServices: $e");
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> rawData = [];

  Future<void> fetchFreeTime(
      String barberId, List<BarberServices> selectedServices, Map map) async {
    SelectAppointmentTimeController selectAppointmentTimeController =
        Get.put(SelectAppointmentTimeController());
    isLoading.value = true;
    rawData.clear();

    try {
      final requestModel = FreeTimeRequestModel.fromServices(
        barberId,
        selectedServices,
      );

      final response = await _apiCall.addData(
          requestModel.toJson(), "${Variables.APPOINTMENT}free-time");

      final responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseBody is List) {
          rawData = responseBody.cast<Map<String, dynamic>>();
          selectAppointmentTimeController.rawData = rawData;
          print("Response body: $rawData");

          Get.toNamed(AppRouter.bookAppointmentPath, arguments: map);
        }
      } else {
        ShowToast.showError(message: responseBody["message"]);
      }
    } catch (e) {
      errorMessage.value = '${'networkError'.tr}: $e';
      print("Error fetching free time: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFreeTimeMultipleUsers(
      String barberId, List<BarberServices> selectedServices, Map map) async {
    SelectAppointmentTimeController selectAppointmentTimeController =
        Get.put(SelectAppointmentTimeController());
    isLoading.value = true;
    rawData.clear();

    try {
      final requestModel = FreeTimeRequestModel.fromServices(
        barberId,
        selectedServices,
      );

      final response = await _apiCall.addData(
          requestModel.toJson(), "${Variables.APPOINTMENT}free-time");

      final responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseBody is List) {
          rawData = responseBody.cast<Map<String, dynamic>>();
          selectAppointmentTimeController.rawData = rawData;
          Get.toNamed(AppRouter.bookAppointmentPath, arguments: map);
        }
      } else {
        ShowToast.showError(message: responseBody["message"]);
      }
    } catch (e) {
      errorMessage.value = '${'networkError'.tr}: $e';
      print("Error fetching free time: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchOnHoadlingFreeTime(
      String barberId,
      List<BarberServices> selectedServices,
      List<int> serviceQuantities,
      Map<String, dynamic> args) async {
    SelectAppointmentTimeController selectAppointmentTimeController =
        Get.put(SelectAppointmentTimeController());
    isLoading.value = true;
    rawData.clear();

    try {
      final requestModel = FreeTimeRequestModel.fromServices(
        barberId,
        selectedServices,
        serviceQuantities: serviceQuantities,
        onHolding: true,
      );

      final response = await _apiCall.addData(
          requestModel.toJson(), "${Variables.APPOINTMENT}free-time");

      final responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseBody is List) {
          rawData = responseBody.cast<Map<String, dynamic>>();
          selectAppointmentTimeController.rawData = rawData;
          // Make sure to include the time data in the arguments
          args['availableTimeData'] = [
            {'startInterval': 1748628000000, 'endInterval': 2018628000000},
            {'startInterval': 1748714400000, 'endInterval': 2018714400000},
            {'startInterval': 1748800800000, 'endInterval': 2018800800000}
          ];

          // For debugging
          print(
              'Passing time data to on-hold screen: ${args['availableTimeData']}');
          Get.toNamed(AppRouter.bookAppointmentPath, arguments: args);
        }
      } else {
        ShowToast.showError(message: responseBody["message"]);
      }
    } catch (e) {
      errorMessage.value = '${'networkError'.tr}: $e';
      print("Error fetching free time: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void toggleService(int index) {
    selectedServices[index] = !selectedServices[index];
    selectedCount.value = selectedServices.where((selected) => selected).length;
    hasSelection.value = selectedCount.value > 0;
    update();
  }

  bool canProceedToBooking() {
    return hasSelection.value;
  }

  getSelectedServicesList() {}
}
