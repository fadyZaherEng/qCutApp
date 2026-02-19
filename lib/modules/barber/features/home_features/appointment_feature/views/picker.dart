import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/modules/barber/features/home_features/appointment_feature/logic/appointment_controller.dart';

class CustomDaysPicker extends GetView<BAppointmentController> {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String? titleSimpleDaysPicker;

  const CustomDaysPicker({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.titleSimpleDaysPicker,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<Map<String, dynamic>> days = controller.workingDays.map((item) {
        final dateTime = DateTime.fromMillisecondsSinceEpoch(item['date'] as int);
        return {
          "day": DateFormat('E', Get.locale?.languageCode).format(dateTime),
          "date": dateTime.day,
          "fullDate": dateTime,
        };
      }).toList();

      if (days.isEmpty && controller.isLoadingWorkingDays.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (titleSimpleDaysPicker != null) ...[
                Text(
                  titleSimpleDaysPicker!,
                  style: TextStyle(
                    color: ColorsData.font,
                    fontSize: Get.locale?.languageCode == 'ar' ? 13.sp : 14.sp,
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

          // ✅ Wrap Row with horizontal scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: days.map((day) {
                final dayDate = day["fullDate"] as DateTime;
                bool isSelected = dayDate.year == selectedDate.year &&
                    dayDate.month == selectedDate.month &&
                    dayDate.day == selectedDate.day;
                return Padding(
                   padding: EdgeInsets.only(right: 12.w), // spacing between items
                  child: GestureDetector(
                    onTap: () => onDateSelected(dayDate),
                    child: Container(
                      width: 70.w,
                      height: 100.h,
                      padding:
                          EdgeInsets.symmetric(horizontal: 0.w, vertical: 11.h),
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
                              fontSize:
                                  Get.locale?.languageCode == 'ar' ? 9.sp : 12.sp,
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
    });
  }
}
