import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/modules/customer/features/booking_features/select_appointment_time/controller/select_appointment_time_controller.dart';

class CustomBSimpleDaysPicker extends GetView<SelectAppointmentTimeController> {
  final int selectedDay;
  final ValueChanged<int> onDaySelected;
  final String? titleSimpleDaysPicker;

  const CustomBSimpleDaysPicker({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
    this.titleSimpleDaysPicker,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    if (!Get.isRegistered<SelectAppointmentTimeController>()) {
      Get.put(SelectAppointmentTimeController());
    }

    return Obx(() {
      // Dependencies to trigger rebuild when walk-in data is fetched
      controller.walkInRanges.length;
      controller.workingHoursRange.length;

      final days = controller.availableDays;

      // Handle empty days case
      if (days.isEmpty) {
        return Center(
          child: Column(
            children: [
              if (titleSimpleDaysPicker != null) ...[
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    titleSimpleDaysPicker!,
                    style: TextStyle(
                      color: ColorsData.font,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
              Text(
                "noAvailableDaysFound".tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          if (titleSimpleDaysPicker != null) ...[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                titleSimpleDaysPicker!,
                style: TextStyle(
                  color: ColorsData.font,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                  letterSpacing: 0,
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
          SizedBox(
            height: 100.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final bool isCurrentlySelected =
                    selectedDay == day["dayNumber"];
                final DateTime dayDate = day["fullDate"];
                final bool hasTimeSlots =
                    controller.hasSlotsForDay(day["dayNumber"]);
                final bool isWalkIn = controller.isWalkInDay(dayDate);

                // Format the date (day/month)
                final String formattedDate = DateFormat('d/M').format(dayDate);

                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: GestureDetector(
                    onTap: () {
                      onDaySelected(day["dayNumber"]);
                    },
                    child: Container(
                      width: 58.w,
                      height: 100.h,
                      decoration: BoxDecoration(
                        color: isWalkIn
                            ? Colors.greenAccent
                            : (isCurrentlySelected
                                ? const Color(0xFFC49A5B)
                                : (hasTimeSlots
                                    ? Colors.white
                                    : Colors.grey.shade200)),
                        borderRadius: BorderRadius.circular(24.r),
                        border: isWalkIn
                            ? Border.all(
                                color: Colors.greenAccent,
                                width: 2,
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(isCurrentlySelected ? 0.1 : 0.05),
                            blurRadius: isCurrentlySelected ? 5 : 3,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isWalkIn)
                            Padding(
                              padding: EdgeInsets.only(bottom: 2.h),
                              child: Text(
                                "Walk-In".tr,
                                style: TextStyle(
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                ),
                              ),
                            ),
                          Text(
                            day["dayName"].toString().toLowerCase().tr,
                            style: TextStyle(
                              color: isCurrentlySelected
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            width: 27.w,
                            height: 27.h,
                            decoration: BoxDecoration(
                              color: isCurrentlySelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.8),
                              shape: BoxShape.circle,
                              boxShadow: isCurrentlySelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 2,
                                        spreadRadius: 0.5,
                                      )
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "${day["dayNumber"]}",
                              style: TextStyle(
                                color: isCurrentlySelected
                                    ? const Color(0xFFC49A5B)
                                    : Colors.black,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
