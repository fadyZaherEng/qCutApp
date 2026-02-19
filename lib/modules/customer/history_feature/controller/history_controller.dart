import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'package:q_cut/modules/barber/features/home_features/appointment_feature/models/appointment_model.dart';
import 'package:q_cut/modules/barber/features/home_features/statistics_feature/models/statistics_model.dart';
import 'package:q_cut/modules/barber/features/home_features/statistics_feature/models/payment_stats_model.dart';
import 'package:q_cut/modules/barber/features/home_features/statistics_feature/models/monthly_stats_model.dart';
import '../model/customer_history_appointment.dart';

class HistoryController extends GetxController {
  final NetworkAPICall _apiCall = NetworkAPICall();

  // Appointments data
  final RxList<BarberAppointment> appointments = <BarberAppointment>[].obs;
  final RxList<BarberAppointment> filteredAppointments =
      <BarberAppointment>[].obs;

  final RxList<CustomerHistoryAppointment> currentAppointments =
      <CustomerHistoryAppointment>[].obs;
  final RxList<CustomerHistoryAppointment> previousAppointments =
      <CustomerHistoryAppointment>[].obs;
  final RxInt selectedTabIndex = 0.obs;

  // 🔥 النسخة الأصلية (temp lists)
  final RxList<CustomerHistoryAppointment> currentOriginal =
      <CustomerHistoryAppointment>[].obs;
  final RxList<CustomerHistoryAppointment> previousOriginal =
      <CustomerHistoryAppointment>[].obs;
  // Pagination parameters
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final int limit = 10;

  // UI States
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;

  // Selected date for filtering
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxInt selectedDay = 0.obs;

  // Barber profile info
  final RxString barberName = "Barber shop".obs;
  final RxString barberServices = "Hair Style, Cuts, Face shaving".obs;
  final RxString barberImage = "".obs;

  // Statistics data
  final Rx<BarberStats> barberStats = BarberStats.empty().obs;
  final RxBool isStatsLoading = false.obs;
  final RxString statsTimeFrame = 'All Time'.obs; // Default time frame

  // Payment Statistics data
  final Rx<PaymentStats> paymentStats = PaymentStats.empty().obs;
  final RxBool isPaymentStatsLoading = false.obs;

  // Monthly Statistics data
  final Rx<MonthlyStats> monthlyStats = MonthlyStats.empty().obs;
  final RxBool isMonthlyStatsLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with the current day
    selectedDay.value = DateTime.now().day;
    fetchAppointments("previous");
  }

  Future<void> fetchAppointments(String type) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _apiCall.getData(
          Variables.GET_CUSTOMER_HISTORY_APPOINTMENTS,
          body: {"type": type});
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['success'] == true) {
          final List<dynamic> appointmentsList = responseBody['appointments'];
          final appointments = appointmentsList
              .map((json) => CustomerHistoryAppointment.fromJson(json))
              .toList();

          if (type == "currently") {
            currentAppointments.value = appointments;
            currentOriginal.value = appointments; // ✅ خزّن نسخة أصلية
          } else {
            previousAppointments.value = appointments;
            previousOriginal.value = appointments; // ✅ خزّن نسخة أصلية
          }
        }
      } else {
        errorMessage.value = 'Failed to load appointments';
        isError.value = true;
      }
    } catch (e) {
      errorMessage.value = 'Error loading appointments';
      isError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

// -------- فلترة المواعيد --------
  void filterAppointments(String value, {required bool isPrevious}) {
    if (isPrevious) {
      if (value == 'all') {
        previousAppointments.value = previousOriginal.toList();
      } else if (value == 'attended'|| value == 'completed') {
        previousAppointments.value = previousOriginal
            .where((a) =>
                a.status.toLowerCase() == 'attended' ||
                a.status.toLowerCase() == 'completed')
            .toList();
      } else if (value == 'NotCome'|| value == 'missed') {
        previousAppointments.value = previousOriginal
            .where((a) =>
                a.status.toLowerCase() == 'notcome' ||
                a.status.toLowerCase() == 'missed')
            .toList();
      } else {
        previousAppointments.value = previousOriginal
            .where((a) => a.status.toLowerCase() == value.toLowerCase())
            .toList();
      }
    } else {
      if (value == 'all') {
        currentAppointments.value = currentOriginal.toList();
      } else {
        currentAppointments.value = currentOriginal
            .where((a) => a.status.toLowerCase() == value.toLowerCase())
            .toList();
      }
    }
  }

  void onTabChanged(int index) {
    selectedTabIndex.value = index;
    fetchAppointments(index == 0 ? "previous" : "currently");
  }

  Future<void> fetcCustomerHistory() async {
    isStatsLoading.value = true;

    try {
      final response = await _apiCall.getData(
          Variables.GET_CUSTOMER_HISTORY_APPOINTMENTS,
          body: {"type": "currently"});

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody is Map<String, dynamic>) {
          barberStats.value = BarberStats.fromJson(responseBody);
        } else {
          barberStats.value = BarberStats.empty();
        }
      } else {
        ShowToast.showError(message: 'Failed to load statistics');
      }
    } catch (e) {
      barberStats.value = BarberStats.empty();
      Get.snackbar('Error', 'Failed to load statistics data',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isStatsLoading.value = false;
    }
  }

  Future<void> fetchPaymentStats() async {
    isPaymentStatsLoading.value = true;

    try {
      final response = await _apiCall.getData(Variables.BARBER_PAYMENT_STATS);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody is Map<String, dynamic>) {
          paymentStats.value = PaymentStats.fromJson(responseBody);
        } else {
          paymentStats.value = PaymentStats.empty();
        }
      } else {
        ShowToast.showError(message: 'Failed to load payment statistics');
      }
    } catch (e) {
      paymentStats.value = PaymentStats.empty();
      Get.snackbar('Error', 'Failed to load payment statistics data',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isPaymentStatsLoading.value = false;
    }
  }

  Future<void> fetchMounthStats() async {
    isPaymentStatsLoading.value = true;

    try {
      final response = await _apiCall.getData(Variables.BARBER_COUNT_MOUNTH);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody is Map<String, dynamic>) {
          paymentStats.value = PaymentStats.fromJson(responseBody);
        } else {
          paymentStats.value = PaymentStats.empty();
        }
      } else {
        ShowToast.showError(message: 'Failed to load payment statistics');
      }
    } catch (e) {
      paymentStats.value = PaymentStats.empty();
      Get.snackbar('Error', 'Failed to load payment statistics data',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isPaymentStatsLoading.value = false;
    }
  }

  Future<void> fetchMonthlyStats() async {
    isMonthlyStatsLoading.value = true;

    try {
      final response = await _apiCall.getData(Variables.BARBER_COUNT_MOUNTH);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody is List) {
          monthlyStats.value = MonthlyStats.fromJson(responseBody);
        } else {
          monthlyStats.value = MonthlyStats.empty();
        }
      } else {
        ShowToast.showError(message: 'Failed to load monthly statistics');
      }
    } catch (e) {
      monthlyStats.value = MonthlyStats.empty();
      Get.snackbar('Error', 'Failed to load monthly statistics data',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isMonthlyStatsLoading.value = false;
    }
  }

  void updateTimeFrame(String timeFrame) {
    statsTimeFrame.value = timeFrame;
    fetcCustomerHistory();
    fetchPaymentStats();
    fetchMonthlyStats();
  }

  int get totalConsumers =>
      barberStats.value.newConsumers + barberStats.value.returningConsumers;

  double get incomePerHour {
    if (barberStats.value.workingHours == 0) return 0;
    return barberStats.value.totalIncome / barberStats.value.workingHours;
  }

  String get formattedIncomePerHour => incomePerHour.toStringAsFixed(2);
}
