import 'dart:convert';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'package:q_cut/modules/customer/features/booking_features/select_appointment_time/model/time_slot_model.dart';

import '../../../../../../core/utils/network/api.dart';
import '../../display_barber_services_feature/models/free_time_request_model.dart';
import '../../../home_features/home/models/working_hours_range_model.dart';

class SelectAppointmentTimeController extends GetxController {
  final NetworkAPICall _apiCall = NetworkAPICall();
  final RxList<TimeSlot> timeSlots = <TimeSlot>[].obs;

  final RxList<int> availableDaysTimestamps = <int>[].obs;
  final RxList<WalkInRecord> walkInRanges = <WalkInRecord>[].obs;
  final RxList<WorkingHourDay> workingHoursRange = <WorkingHourDay>[].obs;

  Future<void> getAvailableDays(FreeTimeRequestModel request) async {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';
    });

    print("Requesting available days with payload: ${request.toJson()}");

    try {
      final response = await _apiCall.addData(
          request, "${Variables.baseUrl}appointment/free-day");
      print("API Response status code: ${response.statusCode}");
      print("API Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = response.body;
        print("Data type: ${data.runtimeType}");

        // Wait until after build to update state
        SchedulerBinding.instance.addPostFrameCallback((_) {
          // Clear existing timestamps
          availableDaysTimestamps.clear();

          if (data is List) {
            // Direct list of timestamps
            for (var timestamp in data) {
              if (timestamp is int) {
                availableDaysTimestamps.add(timestamp);
                print("Added timestamp: $timestamp");
              }
            }
          } else if (data is String) {
            // If data is a string, try to parse it as JSON
            try {
              // Strip brackets and quotes, then split by comma
              String cleanData =
                  data.toString().replaceAll("[", "").replaceAll("]", "");
              List<String> parts = cleanData.split(",");

              for (String part in parts) {
                try {
                  int timestamp = int.parse(part.trim());
                  availableDaysTimestamps.add(timestamp);
                  print("Added parsed timestamp: $timestamp");
                } catch (e) {
                  print("Error parsing timestamp: $part, error: $e");
                }
              }
            } catch (e) {
              print("Error parsing string data: $e");
            }
          }

          print("Total days loaded: ${availableDaysTimestamps.length}");

          // Initialize selectedDay if available days exist
          if (availableDaysTimestamps.isNotEmpty) {
            final firstDay = DateTime.fromMillisecondsSinceEpoch(
                availableDaysTimestamps.first);
            selectedDay.value = firstDay.day;
            selectedDate.value = firstDay;

            print(
                "Selected first day: ${firstDay.day}/${firstDay.month}/${firstDay.year}");

            // Pre-fetch time slots for the first day
            if (barberId.value.isNotEmpty && selectedServices.isNotEmpty) {
              getTimeSlotsForDay(
                  availableDaysTimestamps.first, request.onHolding);
            }
          }

          // Force UI update
          update();

          isLoading.value = false;
        });
      } else {
        // Wait until after build to update error state
        SchedulerBinding.instance.addPostFrameCallback((_) {
          isError.value = true;
          errorMessage.value = 'Failed to load available times';
          isLoading.value = false;
        });
      }
    } catch (e) {
      // Wait until after build to update error state
      SchedulerBinding.instance.addPostFrameCallback((_) {
        isError.value = true;
        errorMessage.value = 'Error: $e';
        isLoading.value = false;
      });
      print("Exception in getAvailableDays: $e");
    }
  }

  late List<Map<String, dynamic>> rawData = [];

  // Replace freeTime list with a computed property
  List<TimeSlot> get freeTime => _convertFreeTime();

  List<TimeSlot> _convertFreeTime() {
    if (rawData.isEmpty) return [];
    return rawData.map((slot) => TimeSlot.fromJson(slot)).toList();
  }

  // Get unique days with proper date information
  List<Map<String, dynamic>> get availableDays {
    final List<Map<String, dynamic>> days = [];

    // Use timestamps from API directly
    for (var timestamp in availableDaysTimestamps) {
      final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      days.add({
        'dayNumber': date.day,
        'dayName': _getDayName(date.weekday),
        'date': _getFormattedDate(date),
        'fullDate': date,
        'startInterval': timestamp,
      });
    }

    // Sort by actual date
    days.sort((a, b) =>
        (a['fullDate'] as DateTime).compareTo(b['fullDate'] as DateTime));
    return days;
  }

  onState() {
    super.onInit();
  }

  // Pagination parameters
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final int limit = 10;

  // UI States
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isLoadingTimeSlots = false.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;

  // Selected date for filtering
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxInt selectedDay = 0.obs;

  // Barber profile info
  final RxString barberName = "Barber shop".obs;
  final RxString barberImage = "".obs;
  final RxString barberId = "".obs;

  // Available times
  final RxInt selectedTimeIndex = RxInt(-1);

  // Add selectedTimeSlot
  final Rx<TimeSlot?> selectedTimeSlot = Rx<TimeSlot?>(null);

  // Payment method tracking
  final Rx<String> paymentMethod = "cash".obs;

  // Selected appointment data
  final Rx<Map<String, dynamic>> selectedAppointmentData =
      Rx<Map<String, dynamic>>({});
  final RxList<Map<String, dynamic>> selectedServices =
      <Map<String, dynamic>>[].obs;
  final RxString selectedBarberId = "".obs;
  final RxInt selectedTimestamp = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if (DateTime.now().day <= availableDays.length &&
        availableDays.isNotEmpty) {
      selectedDay.value = DateTime.now().day;
    } else if (availableDays.isNotEmpty) {
      selectedDay.value = availableDays.first['dayNumber'];
    }
    ever(selectedDay, (_) => _onDayChanged());
  }

  void _onDayChanged() {
    // 1. Try to find the exact date from availableDays
    final matchingDay = availableDays.firstWhereOrNull(
      (d) => d['dayNumber'] == selectedDay.value,
    );

    DateTime newDate;
    if (matchingDay != null) {
      newDate = matchingDay['fullDate'];
    } else {
      // Fallback to current month/year logic if not found in availableDays
      final now = DateTime.now();
      if (selectedDay.value < now.day &&
          now.month == selectedDate.value.month &&
          now.day > 25) {
        final nextMonth = DateTime(now.year, now.month + 1, 1);
        newDate = DateTime(nextMonth.year, nextMonth.month, selectedDay.value);
      } else {
        newDate = DateTime(now.year, now.month, selectedDay.value);
      }
    }

    selectedDate.value = newDate;

    selectedTimeIndex.value = -1;
    selectedTimeSlot.value = null;

    update(['timeSlots']);
  }

  void changeSelectedDay(int day, bool ishold) {
    if (selectedDay.value != day) {
      print('Changing day from ${selectedDay.value} to $day');
      selectedDay.value = day;

      final selectedDayInfo = availableDays.firstWhere(
        (dayInfo) => dayInfo['dayNumber'] == day,
        orElse: () => {'startInterval': 0},
      );

      selectedTimeSlot.value = null;

      isLoadingTimeSlots.value = true;
      update(['timeSlots']);

      if (selectedDayInfo['startInterval'] != 0) {
        getTimeSlotsForDay(selectedDayInfo['startInterval'], ishold);
      } else {
        rawData.clear();
        isLoadingTimeSlots.value = false;
        update(['timeSlots']);
      }
    }
  }

  void selectTimeSlot(TimeSlot slot) {
    selectedTimeSlot.value = slot;
    print('Selected Time Slot Intervals:');
    print('Start Interval: ${slot.startTime.millisecondsSinceEpoch}');
    print('End Interval: ${slot.endTime.millisecondsSinceEpoch}');
    update();
  }

  void setSelectedServices(List<Map<String, dynamic>> services) {
    selectedServices.value = services;
  }

  bool hasSlotsForDay(int day) {
    if (rawData.isEmpty || freeTime.isEmpty) {
      return false;
    }
    return freeTime.any((slot) => slot.dayNumber == day);
  }

  // Check if a specific day is a walk-in day
  bool isWalkInDay(DateTime dateToCheck) {
    return getWorkingHourForDate(dateToCheck)?.isWalkIn ?? false;
  }

  // Get working hour details for a specific date
  WorkingHourDay? getWorkingHourForDate(DateTime dateToCheck) {
    // 1. Check walk-in ranges first for this specific date
    final isInWalkInRange = walkInRanges.any((range) {
      final start = DateTime.fromMillisecondsSinceEpoch(range.startDate);
      final end = DateTime.fromMillisecondsSinceEpoch(range.endDate);
      
      final checkDate = DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);
      final startDateNormalized = DateTime(start.year, start.month, start.day);
      final endDateNormalized = DateTime(end.year, end.month, end.day);
      
      return (checkDate.isAtSameMomentAs(startDateNormalized) || checkDate.isAfter(startDateNormalized)) &&
             (checkDate.isAtSameMomentAs(endDateNormalized) || checkDate.isBefore(endDateNormalized));
    });

    // 2. Check workingHoursRange
    final matchFromRange = workingHoursRange.firstWhereOrNull((workingDay) {
      final date = DateTime.fromMillisecondsSinceEpoch(workingDay.date);
      return date.year == dateToCheck.year && 
             date.month == dateToCheck.month && 
             date.day == dateToCheck.day;
    });

    if (matchFromRange != null) {
      if (isInWalkInRange && !matchFromRange.isWalkIn) {
        // Return a copy with isWalkIn forced to true
        return WorkingHourDay(
          date: matchFromRange.date,
          formattedDate: matchFromRange.formattedDate,
          dayName: matchFromRange.dayName,
          isOffDay: matchFromRange.isOffDay,
          isWalkIn: true,
          startHour: matchFromRange.startHour,
          endHour: matchFromRange.endHour,
        );
      }
      return matchFromRange;
    }

    // 3. If not in workingHoursRange but in walk-in range, return synthetic
    if (isInWalkInRange) {
      return WorkingHourDay(
        date: dateToCheck.millisecondsSinceEpoch,
        formattedDate: DateFormat('yyyy-MM-dd').format(dateToCheck),
        dayName: _getDayName(dateToCheck.weekday),
        isOffDay: false,
        isWalkIn: true,
        startHour: 9,
        endHour: 17, // Traditional walk-in hours
      );
    }

    return null;
  }

  // Fetch working hours range including walk-in info
  Future<void> fetchWorkingHoursRange(String barberId) async {
    try {
      final response = await _apiCall.getData(
        Variables.GET_WORKING_HOURS_RANGE + barberId,
      );
      
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final workingHoursData = WorkingHoursRangeResponse.fromJson(responseBody);
        workingHoursRange.value = workingHoursData.workingHoursRange;
        walkInRanges.value = workingHoursData.walkIn;
        update(['timeSlots']);
      }
    } catch (e) {
      print('Error fetching working hours range: $e');
    }
  }

  Future<void> getTimeSlotsForDay(int dayTimestamp, bool ishold) async {
    isLoadingTimeSlots.value = true;
    update(['timeSlots']);

    rawData.clear();

    try {
      final Map<String, dynamic> requestBody = {
        "day": dayTimestamp,
        "barber": barberId.value,
        "service": selectedServices,
        "onHolding": ishold
      };
      print("Fetching time slots with payload: $requestBody");

      final response = await _apiCall.addData(
          requestBody, "${Variables.baseUrl}appointment/free-slots");
      print("Time slots API Response status code: ${response.statusCode}");
      print("Time slots API Response body: ${response.body}");
      print("Time slots API Response type: ${response.body.runtimeType}");
      //url
      print("Time slots API URL: ${response.request.url}");

      if (response.statusCode == 200) {
        var data;

        if (response.body is String) {
          try {
            data = jsonDecode(response.body);
          } catch (e) {
            isLoading.value = false;
            return;
          }
        } else {
          data = response.body;
        }

        List<dynamic> timeSlotsList;

        if (data is List) {
          timeSlotsList = data;
        } else if (data is Map && data.containsKey('slots')) {
          timeSlotsList = data['slots'];
        } else {
          isError.value = true;
          errorMessage.value = 'Invalid data format received from server';
          isLoading.value = false;
          return;
        }

        for (var slot in timeSlotsList) {
          if (slot is Map<String, dynamic>) {
            final startInterval =
                slot['startInterval'] ?? slot['startTime'] ?? 0;
            final endInterval = slot['endInterval'] ?? slot['endTime'] ?? 0;

            if (startInterval > 0 && endInterval > 0) {
              // Create a proper TimeSlot
              final startTime =
                  DateTime.fromMillisecondsSinceEpoch(startInterval);

              rawData.add({
                'startInterval': startInterval,
                'endInterval': endInterval,
                'dayNumber': startTime.day,
                'dayName': _getDayName(startTime.weekday),
                'formattedDate': _getFormattedDate(startTime)
              });
            }
          }
        }

        update(['timeSlots']);
      } else {
        isError.value = true;
        errorMessage.value =
            'Failed to load time slots: ${response.statusText}';
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = 'Error fetching time slots: $e';
    } finally {
      isLoadingTimeSlots.value = false;
      update(['timeSlots']);
    }
  }

  void onDaySelected(int day, int timestamp, bool isHold) {
    selectedDay.value = day;

    print('Day selected: $day, timestamp: $timestamp');
    print('Barber ID: ${barberId.value}');
    print('Services: $selectedServices');

    if (barberId.value.isNotEmpty && selectedServices.isNotEmpty) {
      // Fetch time slots for this day
      getTimeSlotsForDay(timestamp, isHold);
    } else {
      print('Cannot fetch time slots: Missing barber ID or services');
      print('Barber ID: ${barberId.value}');
      print('Services: $selectedServices');
    }
  }

  // Override the getTimeSlotsByDay method to use the API data
  // List<TimeSlot> getTimeSlotsByDay(int day) {
  //   // First check if we have raw data
  //   if (rawData.isEmpty) {
  //     print('No time slots available. Raw data empty');
  //     return [];
  //   }
  //
  //   final List<TimeSlot> slots = [];
  //
  //   for (var data in rawData) {
  //     try {
  //       // Create a DateTime from the timestamps
  //       final startTime =
  //           DateTime.fromMillisecondsSinceEpoch(data['startInterval']);
  //       final endTime =
  //           DateTime.fromMillisecondsSinceEpoch(data['endInterval']);
  //
  //       // Only include slots for the selected day
  //       if (startTime.day == day) {
  //         // Create a TimeSlot
  //         final slot = TimeSlot(
  //           id: slots.length + 1,
  //           // Add an ID for uniqueness
  //           dayNumber: startTime.day,
  //           dayName: _getDayName(startTime.weekday),
  //           startTime: startTime,
  //           endTime: endTime,
  //           formattedDate: _getFormattedDate(startTime),
  //         );
  //         slots.add(slot);
  //       }
  //     } catch (e) {
  //       print('Error processing time slot: $e');
  //     }
  //   }
  //
  //   // Sort by start time
  //   slots.sort((a, b) => a.startTime.compareTo(b.startTime));
  //   return slots;
  // }
  List<TimeSlot> getTimeSlotsByDay(int day) {
    if (rawData.isEmpty) {
      print('No time slots available. Raw data empty');
      return [];
    }

    final List<TimeSlot> slots = [];
    final now = DateTime.now(); // ⬅ الوقت الحالي

    for (var data in rawData) {
      try {
        final startTime =
            DateTime.fromMillisecondsSinceEpoch(data['startInterval']);
        final endTime =
            DateTime.fromMillisecondsSinceEpoch(data['endInterval']);

        // لو اليوم نفس اليوم المختار
        if (startTime.day == day) {
          // ⬅ لو اليوم المختار النهاردة لازم نتأكد ان startTime بعد الوقت الحالي
          final isToday = startTime.year == now.year &&
              startTime.month == now.month &&
              startTime.day == now.day;

          if (isToday && startTime.isBefore(now)) {
            // ⬅ استبعد الـ slot ده
            continue;
          }

          slots.add(TimeSlot(
            id: slots.length + 1,
            dayNumber: startTime.day,
            dayName: _getDayName(startTime.weekday),
            startTime: startTime,
            endTime: endTime,
            formattedDate: _getFormattedDate(startTime),
          ));
        }
      } catch (e) {
        print('Error processing time slot: $e');
      }
    }

    slots.sort((a, b) => a.startTime.compareTo(b.startTime));
    return slots;
  }

  // Helper method to get day name
  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }

  // Helper method to format date
  String _getFormattedDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
