import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/services/shared_pref/pref_keys.dart';
import 'package:q_cut/core/services/shared_pref/shared_pref.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'package:q_cut/modules/barber/features/home_features/appointment_feature/models/appointment_model.dart';
import 'package:q_cut/modules/barber/features/home_features/statistics_feature/models/statistics_model.dart';
import 'package:q_cut/modules/barber/features/home_features/statistics_feature/models/payment_stats_model.dart';
import 'package:q_cut/modules/barber/features/home_features/statistics_feature/models/monthly_stats_model.dart';
import 'package:q_cut/modules/barber/features/settings/history_feature/model/barber_history_model.dart';

class StatisticsController extends GetxController {
  final NetworkAPICall _apiCall = NetworkAPICall();

  // Appointments data
  final RxList<BarberAppointment> appointments = <BarberAppointment>[].obs;
  final RxList<BarberAppointment> filteredAppointments =
      <BarberAppointment>[].obs;
  final RxList<BarberHistory> historyList = <BarberHistory>[].obs;

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
    statsTimeFrame.value = 'allTime'.tr;
    refreshAllStats();
  }

  Future<void> refreshAllStats() async {
    await Future.wait([
      fetchHistoryForStats(),
      fetchPaymentStats(),
      fetchMonthlyStats(),
      fetchBarberStats(),
    ]);
  }

  Future<void> fetchHistoryForStats() async {
    isStatsLoading.value = true;
    try {
      final response = await _apiCall.getData(Variables.GET_BARBER_HISTORY);
      print('Variables.GET_BARBER_HISTORY: ${Variables.GET_BARBER_HISTORY}');
      print('Response body: ${json.decode(response.body)}');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        BarberHistoryResponse historyResponse =
            BarberHistoryResponse.fromJson(responseBody);
        historyList.assignAll(historyResponse.history);
        recalculateStats();
      } else {
        ShowToast.showError(message: 'Failed to load history for statistics');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load statistics data',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isStatsLoading.value = false;
    }
  }

  Future<void> recalculateStats() async {
    DateTime now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    // Unified timeframe keys (from MyTranslation class)
    const String todayKey = 'today';
    const String weekKey = 'thisWeek';
    const String monthKey = 'thisMonth';
    const String yearKey = 'thisYear';

    // Find current timeframe selection
    String selection = statsTimeFrame.value;
    
    if (selection == todayKey.tr || selection == todayKey) {
      startDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
      endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    } else if (selection == weekKey.tr || selection == weekKey) {
      int daysToSubtract = now.weekday % 7;
      startDate = now.subtract(Duration(days: daysToSubtract));
      startDate = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
      endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    } else if (selection == monthKey.tr || selection == monthKey) {
      startDate = DateTime(now.year, now.month, 1, 0, 0, 0);
      // Last day of month
      DateTime nextMonth = (now.month < 12) 
          ? DateTime(now.year, now.month + 1, 1) 
          : DateTime(now.year + 1, 1, 1);
      endDate = nextMonth.subtract(const Duration(seconds: 1));
    } else if (selection == yearKey.tr || selection == yearKey) {
      startDate = DateTime(now.year, 1, 1, 0, 0, 0);
      endDate = DateTime(now.year, 12, 31, 23, 59, 59);
    } else {
      // All time
      startDate = DateTime(2000, 1, 1);
      endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    }

    await fetchBarberStats(
      startMs: startDate.millisecondsSinceEpoch,
      endMs: endDate.millisecondsSinceEpoch,
    );
  }

  Future<void> fetchBarberStats({int? startMs, int? endMs}) async {
    final barberId = SharedPref().getString(PrefKeys.id);
    if (barberId == null) return;
    
    try {
      String url = Variables.BARBER_STATS;
      if (startMs != null && endMs != null) {
        url = '${Variables.BARBER_STATS_RANGE}$barberId?startDate=$startMs&endDate=$endMs';
      }

      final response = await _apiCall.getData(url);
      print('Barber Stats URL: $url');
      print('Response body: ${json.decode(response.body)}');
      
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody is Map<String, dynamic>) {
          barberStats.value = BarberStats.fromJson(responseBody);
        }
      }
    } catch (e) {
      print('Error fetching barber stats: $e');
    }
  }

  Future<void> fetchPaymentStats() async {
    isPaymentStatsLoading.value = true;
    final barberId = SharedPref().getString(PrefKeys.id);
    if (barberId == null) return;

    try {
      final response =
          await _apiCall.getData(Variables.BARBER_PAYMENT_STATS);
      print('Variables.BARBER_PAYMENT_STATS: ${Variables.BARBER_PAYMENT_STATS}');
      print('Response body: ${json.decode(response.body)}');
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
    final barberId = SharedPref().getString(PrefKeys.id);
    if (barberId == null) return;

    try {
      final response =
          await _apiCall.getData(Variables.BARBER_COUNT_MOUNTH);
      print('Variables.BARBER_COUNT_MOUNTH: ${Variables.BARBER_COUNT_MOUNTH}');
      print('Response body: ${json.decode(response.body)}');
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

  Future<void> updateTimeFrame(String timeFrame) async {
    isStatsLoading.value = true;
    statsTimeFrame.value = timeFrame;
    
    // UI feedback delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    await recalculateStats();
    
    isStatsLoading.value = false;
  }

  int get totalConsumers =>
      barberStats.value.newConsumers + barberStats.value.returningConsumers;

  double get incomePerHour {
    if (barberStats.value.workingHours == 0) return 0;
    return barberStats.value.totalIncome / barberStats.value.workingHours;
  }

  String get formattedIncomePerHour => incomePerHour.toStringAsFixed(2);
}
