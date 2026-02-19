import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';

class CustomDaysPicker extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String? titleSimpleDaysPicker;

  const CustomDaysPicker({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.titleSimpleDaysPicker,
  });

  List<Map<String, dynamic>> _generateDynamicDays() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> days = [];

    // Generate 7 days starting from today
    for (int i = 0; i < 7; i++) {
      final day = now.add(Duration(days: i));
      // Instead of using DateFormat, use translation keys for day names
      String dayName = '';
      switch (DateFormat('E', 'en').format(day).toLowerCase()) {
        case 'sun':
          dayName = 'sun'.tr;
          break;
        case 'mon':
          dayName = 'mon'.tr;
          break;
        case 'tue':
          dayName = 'tue'.tr;
          break;
        case 'wed':
          dayName = 'wed'.tr;
          break;
        case 'thu':
          dayName = 'thu'.tr;
          break;
        case 'fri':
          dayName = 'fri'.tr;
          break;
        case 'sat':
          dayName = 'sat'.tr;
          break;
      }
      days.add({
        "day": dayName, // Translated day name
        "date": day.day,
        "fullDate": day, // Store the full date for reference
      });
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final days = _generateDynamicDays();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (titleSimpleDaysPicker != null) ...[
              Text(
                titleSimpleDaysPicker! == 'Select Day'
                    ? 'selectDay'.tr
                    : titleSimpleDaysPicker!,
                style: TextStyle(
                  color: ColorsData.font,
                  fontSize: 14.sp,
                  fontFamily: 'Alexandria',
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(width: 8.w),
            ],
          ],
        ),
        SizedBox(height: 16.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: days.map((day) {
              final dayDate = day["fullDate"] as DateTime;
              bool isSelected = selectedDate != null &&
                  dayDate.year == selectedDate!.year &&
                  dayDate.month == selectedDate!.month &&
                  dayDate.day == selectedDate!.day;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: GestureDetector(
                  onTap: () => onDateSelected(dayDate),
                  child: Container(
                    width: 60.w,
                    height: 100.h,
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 11.h),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFFC49A5B) : Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day["day"],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: 10.sp,
                            fontFamily: 'Alexandria',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "${day["date"]}",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
