import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:q_cut/core/services/shared_pref/pref_keys.dart';
import 'package:q_cut/core/services/shared_pref/shared_pref.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'package:q_cut/modules/auth/models/auth_response_model.dart';
import 'package:q_cut/modules/barber/features/booking/presentation/views/pay_to_qcut_feature/models/collection_schedule_model.dart';
import 'package:q_cut/modules/barber/features/booking/presentation/views/pay_to_qcut_feature/models/collection_status_model.dart';
import 'package:q_cut/modules/barber/features/booking/presentation/views/pay_to_qcut_feature/models/monthly_invoice_model.dart';

class PayToQcutController extends GetxController {
  final NetworkAPICall _apiCall = NetworkAPICall();

  // UI States
  final RxBool isLoading = false.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;

  // Data
  final Rx<List<MonthlyInvoiceModel>> invoices =
      Rx<List<MonthlyInvoiceModel>>([]);
  final Rx<MonthlyInvoiceModel?> currentInvoice =
      Rx<MonthlyInvoiceModel?>(null);

  // userOffer from login response
  final Rx<UserOffer?> userOffer = Rx<UserOffer?>(null);

  // Collection Schedules
  final RxList<CollectionSchedule> schedules = <CollectionSchedule>[].obs;
  final RxString selectedScheduleId = "".obs;
  final Rx<CollectionStatusModel?> myCollectionStatus =
      Rx<CollectionStatusModel?>(null);

  // Payment status tracking for UI
  final RxList<bool> isPaidList = <bool>[].obs;

  @override
  void onInit() {
    super.onInit();
    print("DEBUG: PayToQcutController initialized");
    _loadUserOffer();
    fetchInvoiceData();
    fetchCollectionSchedule();
    fetchMyCollectionStatus();
  }

  void _loadUserOffer() {
    final offerStr = SharedPref().getString(PrefKeys.userOffer);
    if (offerStr != null && offerStr.isNotEmpty) {
      try {
        final offerJson = jsonDecode(offerStr) as Map<String, dynamic>;
        userOffer.value = UserOffer.fromJson(offerJson);
      } catch (e) {
        print('Error loading userOffer: $e');
      }
    }
  }

  // Fetch my collection status
  Future<void> fetchMyCollectionStatus() async {
    print("DEBUG: fetchMyCollectionStatus called. URL: ${Variables.MY_COLLECTION_STATUS}");
    try {
      final response = await _apiCall.getData(Variables.MY_COLLECTION_STATUS);
      print(
          "My collection status response status code: ${response.statusCode}");
      print("My collection status response body: ${response.body}");
      print("API URL: ${Variables.MY_COLLECTION_STATUS}");
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final statusResponse = CollectionStatusResponse.fromJson(responseBody);
        myCollectionStatus.value = statusResponse.data;

        // If we have a status, let's try to match it with schedules to highlight it
        _syncSelectedSchedule();
      }
    } catch (e, stack) {
      print("CRITICAL: Error in fetchMyCollectionStatus: $e");
      print("STACKTRACE: $stack");
    }
  }

  void _syncSelectedSchedule() {
    if (myCollectionStatus.value != null && schedules.isNotEmpty) {
      final status = myCollectionStatus.value!;
      // Match by day and time since we don't have the original schedule ID in the status response directly usually,
      // but if the status response is just what was selected, we can find it in our schedules list.
      for (var schedule in schedules) {
        if (schedule.dayOfWeek == status.selectedDay &&
            schedule.startTime == status.selectedStartTime &&
            schedule.endTime == status.selectedEndTime) {
          selectedScheduleId.value = schedule.id;
          break;
        }
      }
    }
  }

  // Fetch collection schedules
  Future<void> fetchCollectionSchedule() async {
    print("DEBUG: fetchCollectionSchedule called. URL: ${Variables.COLLECTION_SCHEDULE}");
    try {
      final response = await _apiCall.getData(Variables.COLLECTION_SCHEDULE);
      print("url ${Variables.COLLECTION_SCHEDULE}");
       print("Collection schedule response body COLLECTION_SCHEDULE  : ${response.body}");
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final scheduleResponse =
            CollectionScheduleResponse.fromJson(responseBody);
        schedules.value = scheduleResponse.data;

        // After fetching schedules, sync with my status
        _syncSelectedSchedule();

        // If still empty and no status, select first one by default
        if (selectedScheduleId.isEmpty && schedules.isNotEmpty) {
          selectedScheduleId.value = schedules[0].id;
        }
      }
    } catch (e) {
      print("Error fetching collection schedule: $e");
    }
  }

  // Select a collection slot
  Future<void> selectCollectionSlot(String scheduleId) async {
    isLoading.value = true;
    try {
      final response = await _apiCall.addData(
        {"scheduleId": scheduleId},
        Variables.SELECT_SLOT,
      );

      print("Select slot response status scheduleId: ${scheduleId}");
      print("Select slot response body: ${response.body}");
      print("Selected schedule ID: $scheduleId");
      print("API URL: ${Variables.SELECT_SLOT}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        ShowToast.showSuccessSnackBar(
          message: "Slot selected successfully".tr,
        );
        // Refresh invoice data as it might change the status or create a new pending session
        fetchInvoiceData();
        fetchMyCollectionStatus();
      } else {
        final responseBody = json.decode(response.body);
        ShowToast.showError(
          message: responseBody['message'] ?? "Failed to select slot".tr,
        );
      }
    } catch (e) {
      print("CRITICAL: Network error in selectCollectionSlot: $e");
      ShowToast.showError(message: "Network error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch invoice data from API
  Future<void> fetchInvoiceData() async {
    isLoading.value = true;
    isError.value = false;
    errorMessage.value = '';

    try {
      // Define the API URL
      // print("DEBUG: fetchInvoiceData called. URL: ${Variables.OLD_PAYMENTS}");
      final response = await _apiCall.getData(Variables.OLD_PAYMENTS);

      // print("API Response status code: ${response.statusCode}");
      // print("API Response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        // print("Response body decoded type: ${responseBody.runtimeType}");

        final invoiceResponse = MonthlyInvoiceResponse.fromJson(responseBody);
        invoices.value = invoiceResponse.invoices;
        // print(
        //     "DEBUG: Fetched ${invoices.value.length} invoices total from API");

        if (invoices.value.isEmpty) {
          isError.value = false;
          errorMessage.value = '';
          updatePaymentStatusList(); // Will set up default empty state
        } else {
          invoices.value.sort((a, b) => a.fromDate.compareTo(b.fromDate));
          currentInvoice.value = invoices.value
              .reduce((a, b) => a.fromDate.isAfter(b.fromDate) ? a : b);
          updatePaymentStatusList();
          print("Current invoice set: ${currentInvoice.value?.id}");
        }
      } else {
        isError.value = true;
        try {
          final responseBody = json.decode(response.body);
          errorMessage.value =
              responseBody['message'] ?? 'Failed to fetch invoice data';
        } catch (e) {
          errorMessage.value = 'Error: ${response.statusCode}';
        }
        print("Error message: ${errorMessage.value}");
        ShowToast.showError(message: errorMessage.value);
      }
    } catch (e) {
      print("Exception while fetching invoice data: $e");
      isError.value = true;
      errorMessage.value = 'Network error: $e';
      ShowToast.showError(message: 'failedToConnectToServer'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  // Update payment status list based on actual invoice data
  void updatePaymentStatusList() {
    List<bool> statusList = [];

    if (invoices.value.isEmpty) {
      // For empty case, provide default statuses for UI
      statusList = [false, false, false];
    } else {
      // Sort invoices by date first to ensure correct order
      final sortedInvoices = List<MonthlyInvoiceModel>.from(invoices.value)
        ..sort((a, b) => b.fromDate.compareTo(a.fromDate)); // Newest first

      // Use real data if available
      for (var invoice in sortedInvoices) {
        // Mark as paid if cashMethod is "paid"
        statusList.add(invoice.isPaid);
      }
    }

    isPaidList.value = statusList;
  }

  // For UI interaction - toggle payment status (just for UI, not server state)
  void togglePaymentStatus(int index) {
    if (index >= 0 && index < isPaidList.length) {
      isPaidList[index] = !isPaidList[index];
    }
  }

  // Get join date from the earliest invoice
  String getJoinDate() {
    if (invoices.value.isEmpty) return 'Not joined yet'; // Default fallback

    // Find the earliest invoice by fromDate
    var earliestInvoice = invoices.value
        .reduce((a, b) => a.fromDate.isBefore(b.fromDate) ? a : b);

    return earliestInvoice.formattedJoinDate;
  }

  // Request payment for a specific bill
  Future<bool> requestPayment(
      {required String billId, required int dateTimestamp}) async {
    isLoading.value = true;
    isError.value = false;
    errorMessage.value = '';

    try {
      final requestBody = {"bill": billId, "date": dateTimestamp};

      print("Requesting payment for bill: $billId, date: $dateTimestamp");
      print("Request body: $requestBody");
      print("api url: ${Variables.baseUrl}request-payment");
      final response = await _apiCall.addData(
          requestBody, "${Variables.baseUrl}request-payment");

      print("Payment request response status code: ${response.statusCode}");
      print("Payment request response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.toNamed(AppRouter.successScreenPath);

        await fetchInvoiceData();

        return true;
      } else {
        isError.value = true;
        try {
          final responseBody = json.decode(response.body);
          errorMessage.value =
              responseBody['message'] ?? 'Failed to process payment request';
        } catch (e) {
          errorMessage.value = 'Error: ${response.statusCode}';
        }
        print("Error message: ${errorMessage.value}");
        ShowToast.showSuccessSnackBar(message: "Request sent successfully".tr);
        Navigator.of(Get.context!).pop();
        Navigator.of(Get.context!).pop();
        Navigator.of(Get.context!).pop();
        return false;
      }
    } catch (e) {
      print("Exception while requesting payment: $e");
      isError.value = true;
      errorMessage.value = 'Network error: $e';
      Get.snackbar('Success'.tr, "Request sent successfully".tr,
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Get months since joined
  String getJoinedSince() {
    if (invoices.value.isEmpty) return 'Not joined yet'; // Default fallback

    // Find the earliest invoice by fromDate
    var earliestInvoice = invoices.value
        .reduce((a, b) => a.fromDate.isBefore(b.fromDate) ? a : b);

    return earliestInvoice.joinedSince;
  }

  // Get payment details for the UI
  List<Map<String, dynamic>> getPaymentTimeline() {
    if (invoices.value.isEmpty) {
      return [
        {
          'date': 'No data',
          'status': 'unpaid'.tr,
          'isPaid': false,
          'amount': 0.0,
        }
      ];
    }

    // Sort invoices from newest to oldest for UI
    final sortedInvoices = List<MonthlyInvoiceModel>.from(invoices.value)
      ..sort((a, b) => b.fromDate.compareTo(a.fromDate)); // Newest first

    // Return all invoices
    return sortedInvoices.map((invoice) {
      return {
        'date': DateFormat('M/d/yyyy').format(invoice.fromDate),
        'status': invoice.isPaid ? 'paid'.tr : 'unpaid'.tr,
        'isPaid': invoice.isPaid,
        'amount': invoice.totalAfterDeductions,
      };
    }).toList();
  }
}
