import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'package:q_cut/modules/customer/features/home_features/appointment_feature/models/customer_appointment_model.dart';

class CustomerAppointmentController extends GetxController {
  final NetworkAPICall _apiCall = NetworkAPICall();

  // Data
  final RxList<CustomerAppointment> appointments = <CustomerAppointment>[].obs;
  final RxList<CustomerAppointment> filteredAppointments =
      <CustomerAppointment>[].obs;

  final Rx<CustomerAppointment?> selectedAppointment =
      Rx<CustomerAppointment?>(null);

  // Pagination
  final int limit = 10;
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final RxBool isFetching = false.obs;
  final RxBool isFetchingById = false.obs; // Added

  // Filters
  final RxString statusFilter = 'pending'.obs;

  // UI state
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAppointments();
  }

  /// Fetch Appointments with pagination
  Future<void> fetchAppointments({bool loadMore = false}) async {
    if (isFetching.value) return;

    isFetching.value = true;
    if (loadMore) {
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      final response = await _apiCall.getData(
        "${Variables.APPOINTMENT}?limit=$limit&page=${currentPage.value}",
      );

      print(
          "API URL: ${Variables.APPOINTMENT}?limit=$limit&page=${currentPage.value}");
      print("API Response: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        List<dynamic> data;
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map && decoded.containsKey("data")) {
          data = decoded["data"];
        } else {
          throw Exception("Unexpected response format");
        }

        final newAppointments =
            data.map((e) => CustomerAppointment.fromJson(e)).toList();

        if (loadMore) {
          appointments.addAll(newAppointments);
        } else {
          appointments.value = newAppointments;
        }

        applyFilters();

        // Pagination control
        if (newAppointments.length < limit) {
          hasMore.value = false;
        } else {
          hasMore.value = true;
          currentPage.value++;
        }
      } else {
        isError.value = true;
        try {
          final responseBody = json.decode(response.body);
          errorMessage.value =
              responseBody['message'] ?? 'Failed to fetch appointments';
        } catch (_) {
          errorMessage.value = 'Error: ${response.statusCode}';
        }
        ShowToast.showError(message: errorMessage.value);
      }
    } catch (e) {
      print("Exception while fetching appointments: $e");
      isError.value = true;
      errorMessage.value = 'Network error: $e';
      Get.snackbar('Error', errorMessage.value,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
      isFetching.value = false;
    }
  }

  /// Filter by status
  void applyFilters() {
    if (statusFilter.value.toLowerCase() == 'all') {
      filteredAppointments.value = appointments;
    } else {
      filteredAppointments.value = appointments
          .where(
              (a) => a.status.toLowerCase() == statusFilter.value.toLowerCase())
          .toList();
    }
  }

  void setStatusFilter(String status) {
    statusFilter.value = status;
    applyFilters();
  }

  /// Load more
  Future<void> loadMoreAppointments() async {
    if (hasMore.value && !isLoadingMore.value) {
      await fetchAppointments(loadMore: true);
    }
  }

  /// Refresh
  Future<void> refreshAppointments() async {
    currentPage.value = 1;
    hasMore.value = true;
    appointments.clear();
    filteredAppointments.clear();
    await fetchAppointments();
  }

  /// Delete appointment
  Future<bool> deleteAppointment(CustomerAppointment appointment) async {
    // Check if cancellation is allowed (at least 20 mins before)
    final now = DateTime.now();
    final difference = appointment.startDate.difference(now);

    if (difference.inMinutes < 20) {
      ShowToast.showError(
          message: 'cancellationRestrictionMessage'.tr);
      return false;
    }

    try {
      final url = "${Variables.APPOINTMENT}cancel/${appointment.id}";
      print("DELETE URL: $url");

      final response = await _apiCall.putData(url, []);
      print("DELETE Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        appointments.removeWhere((a) => a.id == appointment.id);
        filteredAppointments.removeWhere((a) => a.id == appointment.id);

        ShowToast.showSuccessSnackBar(
            message: 'Appointment deleted successfully');
        return true;
      } else {
        final responseBody = json.decode(response.body);
        ShowToast.showError(
            message: responseBody['message'] ?? 'Failed to delete appointment');
        return false;
      }
    } catch (e) {
      ShowToast.showError(message: 'Error occurred while deleting: $e');
      return false;
    }
  }

  /// Booking Again
  Future<bool> bookingAgainAppointment(
      CustomerAppointment customerAppointment) async {
    await deleteAppointment(customerAppointment);

    try {
      final response = await _apiCall.putData(Variables.APPOINTMENT, {
        "barber": customerAppointment.barber.id,
        "service": customerAppointment.services.map((e) => e.toJson()).toList(),
        "startDate": customerAppointment.startDate.millisecondsSinceEpoch,
        "paymentMethod": customerAppointment.paymentMethod,
      });

      print("BOOK AGAIN Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        ShowToast.showSuccessSnackBar(
            message: 'Appointment booked again successfully');
        return true;
      } else {
        final responseBody = json.decode(response.body);
        ShowToast.showError(
            message:
                responseBody['message'] ?? 'Failed to book again appointment');
        return false;
      }
    } catch (e) {
      ShowToast.showError(message: 'Error occurred while booking again: $e');
      return false;
    }
  }

  /// Select an appointment
  void selectAppointment(CustomerAppointment appointment) {
    selectedAppointment.value = appointment;
  }

  /// Fetch a single appointment by ID
  Future<CustomerAppointment?> fetchAppointmentById(String id) async {
    isFetchingById.value = true;
    try {
      final response = await _apiCall.getData("${Variables.APPOINTMENT}$id");
      print("Fetch Appointment By ID URL: ${Variables.APPOINTMENT}$id");
      print("Fetch Appointment By ID Response: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        // The response might be the appointment object directly or wrapped in 'data'
        final data = decoded is Map && decoded.containsKey("data")
            ? decoded["data"]
            : decoded;
        return CustomerAppointment.fromJson(data);
      } else {
        print("Failed to fetch appointment: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception while fetching appointment by ID: $e");
      return null;
    } finally {
      isFetchingById.value = false;
    }
  }
}
