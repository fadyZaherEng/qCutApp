import 'dart:convert';
import 'package:get/get.dart';
import 'package:q_cut/core/services/shared_pref/pref_keys.dart';
import 'package:q_cut/core/services/shared_pref/shared_pref.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'package:q_cut/modules/customer/features/booking_features/display_barber_services_feature/models/barber_service.dart';
import 'package:q_cut/modules/customer/features/booking_features/select_appointment_time/controller/select_appointment_time_controller.dart';

class QCutServicesController extends GetxController {
  final NetworkAPICall _apiCall = NetworkAPICall();
  final RxList<BarberServices> barberServices = <BarberServices>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString barberId = ''.obs;
  final RxList<bool> selectedServices = <bool>[].obs;
  final RxList<int> serviceQuantities = <int>[].obs;

  Future<void> fetchServices(String barberId) async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response;
      if (barberId.isEmpty ||
          SharedPref().getBool(PrefKeys.userRole) == false) {
        final String apiUrl = Variables.GET_BARBER_SERVICES;
        response = await _apiCall.getData(apiUrl);
      } else {
        response = await _apiCall.getData(Variables.SERVICE + barberId);
      }
      print("Fetching services for barber ID: $barberId");
      print("Request URL: ${Variables.SERVICE + barberId}");

      print("Fetching services for barber ID: $barberId");
      print("Request URL: ${Variables.SERVICE + barberId}");
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

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

        selectedServices.value =
            List.generate(barberServices.length, (index) => false);
        serviceQuantities.value =
            List.generate(barberServices.length, (index) => 0);
      } else {
        errorMessage.value =
            (responseBody is Map ? responseBody['message'] : null) ??
                'failedToFetchServices'.tr;
      }
    } catch (e) {
      errorMessage.value = '${'networkError'.tr}: $e';
      print("Error in fetchServices: $e");
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> rawData = [];

  Future<void> fetchFreeTimeMultipleUsers(
      String barberId, List<BarberServices> selectedServices, Map map) async {
    SelectAppointmentTimeController selectAppointmentTimeController =
        Get.put(SelectAppointmentTimeController());
    isLoading.value = true;
    rawData.clear();

    try {
      final requestBody = {
        "barber": barberId,
        "service": selectedServices
            .asMap()
            .entries
            .map((entry) => {
                  "service": entry.value.id.toString(),
                  "numberOfUsers": serviceQuantities[
                      barberServices.indexWhere((s) => s.id == entry.value.id)]
                })
            .toList(),
        "onHolding": false
      };

      final response = await _apiCall.addData(
          requestBody, "${Variables.APPOINTMENT}free-time");

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
      errorMessage.value = 'Network error: $e';
      print("Error fetching free time: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchonHoldTimeMultipleUsers(
      String barberId, List<BarberServices> selectedServices, Map map) async {
    SelectAppointmentTimeController selectAppointmentTimeController =
        Get.put(SelectAppointmentTimeController());
    isLoading.value = true;
    rawData.clear();

    try {
      final requestBody = {
        "barber": barberId,
        "service": selectedServices
            .asMap()
            .entries
            .map((entry) => {
                  "service": entry.value.id.toString(),
                  "numberOfUsers": serviceQuantities[
                      barberServices.indexWhere((s) => s.id == entry.value.id)]
                })
            .toList(),
        "onHolding": false
      };

      final response = await _apiCall.addData(
          requestBody, "${Variables.APPOINTMENT}free-time");

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
      errorMessage.value = 'Network error: $e';
      print("Error fetching free time: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void toggleService(int index) {
    selectedServices[index] = !selectedServices[index];
    update();
  }

  void updateServiceQuantity(int index, int quantity) {
    serviceQuantities[index] = quantity;
    selectedServices[index] = quantity > 0;
    update();
  }
}
