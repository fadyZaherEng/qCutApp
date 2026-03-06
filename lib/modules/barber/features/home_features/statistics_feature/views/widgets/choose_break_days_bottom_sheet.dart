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
  bool _isLoading = true;

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

          // Pre-select the latest/current break if available
          if (_breakRanges.isNotEmpty) {
            final latest = _breakRanges.last;
            _rangeStart = latest["start"];
            _rangeEnd = latest["end"];
            _focusedDay = _rangeStart!;
          }
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching breaks: $e");
      setState(() => _isLoading = false);
    }
  }

  bool _isDayInOtherBreak(DateTime day) {
    if (_breakRanges.isEmpty) return false;
    final date = DateTime(day.year, day.month, day.day);
    
    // Check if day is in any break EXCEPT the currently selected one (if we want to show overlap)
    // For now, let's just highlight all breaks that aren't the current selection if needed,
    // but the user wanted it to "stay selected", so we pre-fill _rangeStart/End.
    return _breakRanges.any((range) {
      final start = DateTime(range['start']!.year, range['start']!.month, range['start']!.day);
      final end = DateTime(range['end']!.year, range['end']!.month, range['end']!.day);
      
      return (date.isAtSameMomentAs(start) || date.isAfter(start)) &&
             (date.isAtSameMomentAs(end) || date.isBefore(end));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: ColorsData.primary));
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            )
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
                decoration: BoxDecoration(
                  color: ColorsData.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                    bottomLeft: Radius.circular(24.r),
                    bottomRight: Radius.circular(24.r),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: ColorsData.primary,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "Choose break days".tr,
                      style: Styles.textStyleS18W700(
                        color: ColorsData.primary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.grey),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.all(16.w),
                child: TableCalendar(
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 365 * 2)),
                  focusedDay: _focusedDay,
                  rangeStartDay: _rangeStart,
                  rangeEndDay: _rangeEnd,
                  rangeSelectionMode: _rangeSelectionMode,
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
                    defaultTextStyle: TextStyle(color: Colors.black, fontSize: 14.sp),
                    weekendTextStyle: TextStyle(color: Colors.black, fontSize: 14.sp),
                    outsideTextStyle: TextStyle(color: Colors.grey, fontSize: 12.sp),
                    isTodayHighlighted: true,
                    todayDecoration: BoxDecoration(
                      color: ColorsData.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                      color: ColorsData.primary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold
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
                    outsideDaysVisible: false,
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: Styles.textStyleS16W700(color: Colors.black),
                    leftChevronIcon: const Icon(Icons.chevron_left, color: ColorsData.primary),
                    rightChevronIcon: const Icon(Icons.chevron_right, color: ColorsData.primary),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: Styles.textStyleS12W600(color: Colors.grey),
                    weekendStyle: Styles.textStyleS12W600(color: Colors.grey.shade400),
                  ),
                ),
              ),

              // Selection Info
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 18.sp, color: ColorsData.primary),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          _rangeStart != null
                              ? (_rangeEnd != null
                                  ? "${DateFormat('MMM dd, yyyy', Get.locale?.languageCode).format(_rangeStart!)} - ${DateFormat('MMM dd, yyyy', Get.locale?.languageCode).format(_rangeEnd!)}"
                                  : "${"From:".tr} ${DateFormat('MMM dd, yyyy', Get.locale?.languageCode).format(_rangeStart!)}")
                              : "Select the days you want to take a break".tr,
                          style: Styles.textStyleS14W600(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Action Buttons
              Padding(
                padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 24.h),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text("cancel".tr,
                            style: Styles.textStyleS14W600(color: Colors.grey)),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _rangeStart == null ? null : _addBreak,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsData.primary,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Confirm".tr,
                          style: Styles.textStyleS14W700(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
        Navigator.pop(context);
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
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (context, anim1, anim2, child) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
        ),
        child: FadeTransition(
          opacity: anim1,
          child: const ChooseBreakDaysBottomSheet(),
        ),
      );
    },
  );
}
