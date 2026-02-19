import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';

class ChooseBreakDaysBottomSheet extends StatefulWidget {
  const ChooseBreakDaysBottomSheet({super.key});

  @override
  State<ChooseBreakDaysBottomSheet> createState() =>
      _ChooseBreakDaysBottomSheetState();
}

class _ChooseBreakDaysBottomSheetState
    extends State<ChooseBreakDaysBottomSheet> {
  bool isClicked = true;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  DateTime _focusedDay = DateTime.now();
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;
  List<Map<String, DateTime>> _breakRanges = [];

  @override
  void initState() {
    super.initState();
    _fetchBreaks();
  }

  Future<void> _fetchBreaks() async {
    try {
      final response =
          await NetworkAPICall().getData("${Variables.BARBER}get-break-time");

      if (response.statusCode == 200 && response.body != null) {
        final data =
            response.body is String ? jsonDecode(response.body) : response.body;
        final List breaks = data["breakTime"] ?? [];

        setState(() {
          _breakRanges = breaks.map<Map<String, DateTime>>((b) {
            int start = b["startDate"];
            int end = b["endDate"];

            return {
              "start": DateTime.fromMillisecondsSinceEpoch(start * 1000),
              "end": DateTime.fromMillisecondsSinceEpoch(end * 1000),
            };
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching breaks: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: true,
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Choose break days".tr,
                    style: Styles.textStyleS18W700(color: ColorsData.primary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 8.h),
                      Icon(Icons.access_time_rounded, size: 40.h, color: ColorsData.primary),
                      SizedBox(height: 8.h),
                      Text(
                        "Select the days you want to take a break".tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      TableCalendar(
                        firstDay: DateTime.now().subtract(const Duration(days: 0)),
                        lastDay: DateTime.now().add(const Duration(days: 365)),
                        focusedDay: _focusedDay,
                        rangeStartDay: _rangeStart,
                        rangeEndDay: _rangeEnd,
                        rangeSelectionMode: _rangeSelectionMode,
                        rowHeight: 52.h,
                        daysOfWeekHeight: 40.h,
                        onRangeSelected: (start, end, focused) {
                          setState(() {
                            _rangeStart = start;
                            _rangeEnd = end;
                            _focusedDay = focused;
                            _rangeSelectionMode = RangeSelectionMode.toggledOn;
                          });
                        },
                        onPageChanged: (focused) {
                          _focusedDay = focused;
                        },
                        calendarStyle: CalendarStyle(
                          defaultTextStyle: TextStyle(color: Colors.black, fontSize: 13.sp),
                          weekendTextStyle: TextStyle(color: Colors.black, fontSize: 13.sp),
                          outsideTextStyle: TextStyle(color: Colors.grey, fontSize: 11.sp),
                          todayDecoration: BoxDecoration(
                            color: ColorsData.primary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: TextStyle(
                            color: ColorsData.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp
                          ),
                          rangeStartDecoration: const BoxDecoration(
                            color: ColorsData.primary,
                            shape: BoxShape.circle,
                          ),
                          rangeEndDecoration: const BoxDecoration(
                            color: ColorsData.primary,
                            shape: BoxShape.circle,
                          ),
                          rangeHighlightColor: ColorsData.primary.withOpacity(0.15),
                          withinRangeTextStyle: const TextStyle(
                            color: Colors.black, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          headerPadding: EdgeInsets.symmetric(vertical: 8.h),
                          headerMargin: EdgeInsets.only(bottom: 8.h),
                          titleTextStyle: Styles.textStyleS16W700(color: Colors.black),
                          leftChevronIcon: const Icon(Icons.chevron_left, color: ColorsData.primary),
                          rightChevronIcon: const Icon(Icons.chevron_right, color: ColorsData.primary),
                        ),
                      ),
                      
                      if (_rangeStart != null) ...[
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: ColorsData.primary, size: 18.sp),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  _rangeEnd != null
                                    ? "${DateFormat.yMMMd().format(_rangeStart!)} - ${DateFormat.yMMMd().format(_rangeEnd!)}"
                                    : DateFormat.yMMMd().format(_rangeStart!),
                                  style: Styles.textStyleS14W600(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsData.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _addBreak,
                  child: Text(
                    "Confirm".tr,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addBreak() async {
    if (!isClicked) return;
    
    if (_rangeStart == null) {
      Get.snackbar("Error".tr, "Please select at least one day".tr,
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => isClicked = false);

    try {
      // Normalize dates to start/end of day
      final start = DateTime(_rangeStart!.year, _rangeStart!.month, _rangeStart!.day, 0, 0, 0);
      final end = _rangeEnd != null 
          ? DateTime(_rangeEnd!.year, _rangeEnd!.month, _rangeEnd!.day, 23, 59, 59)
          : DateTime(_rangeStart!.year, _rangeStart!.month, _rangeStart!.day, 23, 59, 59);

      final body = {
        "breaks": [
          {
            "startDate": (start.millisecondsSinceEpoch / 1000).round(),
            "endDate": (end.millisecondsSinceEpoch / 1000).round(),
          }
        ]
      };

      final response = await NetworkAPICall().putData(
        "${Variables.BARBER}take-break",
        body,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.back();
        Get.snackbar("Success".tr, "Break added successfully".tr,
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error".tr, errorData['message'] ?? "Failed to add break".tr,
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Error: $e");
      Get.snackbar("Error".tr, "An unexpected error occurred".tr,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => isClicked = true);
    }
  }
}

void showChooseBreakDaysBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const ChooseBreakDaysBottomSheet(),
  );
}
