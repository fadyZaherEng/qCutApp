import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/logic/b_profile_controller.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/models/barber_profile_model.dart';
import 'package:q_cut/modules/customer/features/home/presentation/views/widgets/working_days_bottom_sheet.dart';

void showWorkingDaysBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (context) => const WorkingDaysBottomSheet(),
  );
}

Future<void> showBWorkingDaysBottomSheet(
    BuildContext context, List<WorkingDay> workingDays, {bool isDismissible = true, VoidCallback? onClose}) async {
  // ✅ رتب الأيام من الأحد للسبت
  final dayOrder = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];

  // Try to get controller, but don't fail if it doesn't exist (customer viewing barber profile)
  BProfileController? controller;
  try {
    controller = Get.find<BProfileController>();
  } catch (e) {
    // Controller doesn't exist - user is viewing as customer
    controller = null;
  }

  return await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    builder: (context) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "workingDays".tr,
                  style: Styles.textStyleS14W700(color: ColorsData.primary),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(Icons.close, size: 24.sp, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // If controller exists, use Obx to listen to changes, otherwise show static list
            controller != null
                ? Obx(() {
                    final currentWorkingDays = controller!.profileData.value?.workingDays ?? [];
                    return Column(
                      children: dayOrder.map((dayName) {
                        final day = currentWorkingDays.firstWhere(
                          (wd) => wd.day == dayName,
                          orElse: () => WorkingDay(day: dayName, startHour: 0, endHour: 0),
                        );
                        final isWorking = currentWorkingDays.any((wd) => wd.day == dayName);

                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dayName.tr,
                                style: Styles.textStyleS14W700(color: ColorsData.secondary),
                              ),
                              Row(
                                children: [
                                  Text(
                                    isWorking
                                        ? "${"Working".tr}: ${day.workingHours}"
                                        : "Not working".tr,
                                    style: Styles.textStyleS14W400(
                                        color: isWorking ? ColorsData.thirty : Colors.red),
                                  ),
                                  SizedBox(width: 12.w),
                                  GestureDetector(
                                    onTap: () {
                                      _showEditDayBottomSheet(context, day, isWorking);
                                    },
                                    child: Icon(Icons.edit,
                                        size: 18.sp, color: ColorsData.primary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  })
                : Column(
                    children: dayOrder.map((dayName) {
                      final day = workingDays.firstWhere(
                        (wd) => wd.day == dayName,
                        orElse: () => WorkingDay(day: dayName, startHour: 0, endHour: 0),
                      );
                      final isWorking = workingDays.any((wd) => wd.day == dayName);

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dayName.tr,
                              style: Styles.textStyleS14W700(color: ColorsData.secondary),
                            ),
                            Text(
                              isWorking
                                  ? "${"Working".tr}: ${day.workingHours}"
                                  : "Not working".tr,
                              style: Styles.textStyleS14W400(
                                  color: isWorking ? ColorsData.thirty : Colors.red),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      );
    },
  ).whenComplete(() {
    if (onClose != null) {
      onClose();
    }
  });
}

void _showEditDayBottomSheet(
    BuildContext context, WorkingDay day, bool isWorking) {
  final RxBool rxIsWorking = isWorking.obs;
  final RxInt startH = (isWorking ? day.startHour : 9).obs;
  final RxInt startM = (isWorking ? day.startMinute : 0).obs;
  final RxInt endH = (isWorking ? day.endHour : 17).obs;
  final RxInt endM = (isWorking ? day.endMinute : 0).obs;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (context) => Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(day.day.tr,
                  style: Styles.textStyleS18W700(color: ColorsData.secondary)),
              Obx(() => Row(
                    children: [
                      Text(
                          rxIsWorking.value ? "Working".tr : "Not working".tr,
                          style: Styles.textStyleS14W400(
                              color: rxIsWorking.value
                                  ? ColorsData.primary
                                  : Colors.red)),
                      Switch(
                        value: rxIsWorking.value,
                        activeColor: ColorsData.primary,
                        onChanged: (val) => rxIsWorking.value = val,
                      ),
                    ],
                  )),
            ],
          ),
          SizedBox(height: 24.h),
          Obx(() => rxIsWorking.value
              ? Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: _buildTimePickerField(
                                context, "From".tr, startH, startM)),
                        SizedBox(width: 16.w),
                        Expanded(
                            child: _buildTimePickerField(
                                context, "To".tr, endH, endM)),
                      ],
                    ),
                    SizedBox(height: 32.h),
                  ],
                )
              : const SizedBox()),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsData.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
              onPressed: () async {
                final controller = Get.find<BProfileController>();
                List<WorkingDay> currentDays =
                    List.from(controller.profileData.value?.workingDays ?? []);

                if (rxIsWorking.value) {
                  // Validate time: start < end
                  final startTotal = startH.value * 60 + startM.value;
                  final endTotal = endH.value * 60 + endM.value;
                  if (startTotal >= endTotal) {
                    ShowToast.showError(
                        message: "Start time must be earlier than end time".tr);
                    return;
                  }

                  final newDay = WorkingDay(
                    day: day.day,
                    startHour: startH.value,
                    startMinute: startM.value,
                    endHour: endH.value,
                    endMinute: endM.value,
                  );
                  int idx = currentDays.indexWhere((wd) => wd.day == day.day);
                  if (idx != -1) {
                    currentDays[idx] = newDay;
                  } else {
                    currentDays.add(newDay);
                  }
                } else {
                  // Check if this is the last working day
                  if (currentDays.length <= 1 &&
                      currentDays.any((wd) => wd.day == day.day)) {
                    ShowToast.showError(
                        message: "You must have at least one working day".tr);
                    return;
                  }
                  currentDays.removeWhere((wd) => wd.day == day.day);
                }

                // Call direct update API
                try {
                  final payload = {
                    'workingDays': currentDays.map((d) => d.toJson()).toList(),
                  };
                  final response = await NetworkAPICall().editData(
                      '${Variables.baseUrl}barber/update-working-days',
                      payload);

                  if (response.statusCode == 200) {
                    await controller.fetchProfileData();
                    Get.back();
                    ShowToast.showSuccessSnackBar(
                        message: "Working days updated successfully".tr);
                  } else {
                    ShowToast.showError(message: "Failed to update".tr);
                  }
                } catch (e) {
                  ShowToast.showError(message: e.toString());
                }
              },
              child: Text("Confirm".tr,
                  style: Styles.textStyleS16W600(color: Colors.white)),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    ),
  );
}

Widget _buildTimePickerField(
    BuildContext context, String label, RxInt hour, RxInt minute) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Styles.textStyleS14W400(color: Colors.grey)),
      SizedBox(height: 8.h),
      InkWell(
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(hour: hour.value, minute: minute.value),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: ColorsData.primary,
                    onSurface: Colors.white,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            hour.value = picked.hour;
            minute.value = picked.minute;
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: ColorsData.cardStrock),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time, color: ColorsData.primary, size: 20.sp),
              SizedBox(width: 8.w),
              Obx(() => Text(
                    "${hour.value.toString().padLeft(2, '0')}:${minute.value.toString().padLeft(2, '0')}",
                    style:
                        Styles.textStyleS16W600(color: ColorsData.secondary),
                  )),
            ],
          ),
        ),
      ),
    ],
  );
}

// void showBWorkingDaysBottomSheet(
//     BuildContext context, List<WorkingDay> workingDays) {
//   if (workingDays.isEmpty) {
//     Get.closeAllSnackbars(); // ✅ اقفل أي Snackbar قديم
//     Get.snackbar(
//       'No Working Days'.tr,
//       'You have not set any working days yet'.tr,
//       backgroundColor: Colors.blueGrey,
//       colorText: Colors.white,
//     );
//     return;
//   }
//
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//     ),
//     builder: (context) => Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: Container(
//               width: 40.w,
//               height: 4.h,
//               margin: EdgeInsets.only(bottom: 16.h),
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(2.r),
//               ),
//             ),
//           ),
//           GestureDetector(
//             onTap: () => Get.back(),
//             child: Icon(Icons.close, size: 24.sp),
//           ),
//           SizedBox(height: 16.h),
//           Text(
//             "workingDays".tr,
//             style: Styles.textStyleS14W700(color: ColorsData.primary),
//           ),
//           SizedBox(height: 16.h),
//           ...workingDays.map((day) {
//             return Padding(
//               padding: EdgeInsets.symmetric(vertical: 8.h),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     day.day.tr,
//                     style: Styles.textStyleS14W700(color: ColorsData.secondary),
//                   ),
//                   Text(
//                     "${day.startHour} ${day.startHour > 12 ? "PM" : "AM"} - ${day.endHour - 12} ${day.endHour > 12 ? "PM" : "AM"}",
//                     style: Styles.textStyleS14W400(color: ColorsData.thirty),
//                   ),
//                 ],
//               ),
//             );
//           }),
//         ],
//       ),
//     ),
//   );
// }
