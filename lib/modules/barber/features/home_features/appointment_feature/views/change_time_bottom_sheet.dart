import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/modules/auth/views/widgets/custom_text_form.dart';

class ChangeTimeBottomSheet extends StatefulWidget {
  final String? day;
  final String appointmentId;

  const ChangeTimeBottomSheet(
      {super.key, this.day, required this.appointmentId});

  @override
  State<ChangeTimeBottomSheet> createState() => _ChangeTimeBottomSheetState();
}

class _ChangeTimeBottomSheetState extends State<ChangeTimeBottomSheet> {
  int selectedDayIndex = 0;
  final TextEditingController timeController = TextEditingController();
  late List<Map<String, dynamic>> dynamicDays;
  bool isLoading = false;
  final NetworkAPICall _networkAPICall = NetworkAPICall();

  @override
  void initState() {
    super.initState();
    dynamicDays = _generateDynamicDays();
  }

  List<Map<String, dynamic>> _generateDynamicDays() {
    DateTime startDate;

    // Try to parse the provided date string or fall back to today
    if (widget.day != null) {
      try {
        startDate = DateTime.parse(widget.day!);
      } catch (e) {
        print('Error parsing date: ${widget.day}. Using current date instead.');
        startDate = DateTime.now();
      }
    } else {
      startDate = DateTime.now();
    }

    final List<Map<String, dynamic>> days = [];

    // Generate 3 days starting from the provided date
    for (int i = 0; i < 3; i++) {
      final day = startDate.add(Duration(days: i));
      days.add({
        "day": DateFormat('E').format(day), // Short day name (Mon, Tue, etc.)
        "date": day.day.toString(), // Day of month
        "fullDate": day, // Store the full date for reference
      });
    }
    return days;
  }

  Future<void> _sendTimeChangeRequest() async {
    if (timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a time")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Get the selected date
      DateTime selectedDate = dynamicDays[selectedDayIndex]["fullDate"];

      // Parse the selected time
      final timeString = timeController.text;
      final timeParts = timeString.split(RegExp(r'[: ]'));

      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      // Adjust for PM if needed
      if (timeParts.length > 2 &&
          timeParts[2].toUpperCase() == 'PM' &&
          hour < 12) {
        hour += 12;
      }
      // Adjust for AM if needed (12 AM should be 0 hour)
      if (timeParts.length > 2 &&
          timeParts[2].toUpperCase() == 'AM' &&
          hour == 12) {
        hour = 0;
      }

      // Create a DateTime with the correct date and time
      final combinedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        hour,
        minute,
      );

      // Convert to milliseconds since epoch
      final startDateMillis = combinedDateTime.millisecondsSinceEpoch;

      // Send the request using NetworkAPICall
      final requestData = {
        'appointment': widget.appointmentId,
        'startDate': startDateMillis,
      };

      final response = await _networkAPICall.addData(
        requestData,
        '${Variables.baseUrl}request-change-appointment-time',
      );
      // Check if the widget is still mounted before accessing context
      if (!mounted) return;

      final dynamic responseBody =
          response.body is String ? jsonDecode(response.body) : response.body;
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        ShowToast.showSuccessSnackBar(
          message: responseBody['message'] ?? 'Request sent successfully',
        );
        Get.back();
      } else if (response.statusCode == 400) {
        // Bad request
        ShowToast.showError(
          message: responseBody['message'] ?? 'Bad request',
        );
        Get.back();
      } else {
        // Other errors
        ShowToast.showError(
          message: responseBody['message'] ?? 'An error occurred',
        );
        Get.back();
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// زر الإغلاق
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            Column(
              children: [
                SvgPicture.asset(
                  height: 36.h,
                  width: 36.w,
                  AssetsData.clockIcon,
                  colorFilter: const ColorFilter.mode(
                    ColorsData.dark,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "changeTime".tr,
                  style: Styles.textStyleS16W600(color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            Row(
              children: [
                SvgPicture.asset(
                  height: 20.h,
                  width: 20.w,
                  AssetsData.calendarIcon,
                  colorFilter: const ColorFilter.mode(
                    ColorsData.primary,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  "days".tr,
                  style: Styles.textStyleS14W500(color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(dynamicDays.length, (index) {
                bool isSelected = selectedDayIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => selectedDayIndex = index),
                  child: Container(
                    width: 60.w,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    margin: EdgeInsets.symmetric(horizontal: 6.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFC49A58)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          dynamicDays[index]["day"],
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          dynamicDays[index]["date"],
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 20.h),

            Row(
              children: [
                SvgPicture.asset(
                  height: 20.h,
                  width: 20.w,
                  AssetsData.clockIcon,
                  colorFilter: const ColorFilter.mode(
                    ColorsData.primary,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  "time".tr,
                  style: Styles.textStyleS14W500(color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            InkWell(
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    timeController.text = pickedTime.format(context);
                  });
                }
              },
              child: IgnorePointer(
                child: CustomTextFormField(
                  style: Styles.textStyleS14W400(color: ColorsData.secondary),
                  fillColor: ColorsData.font,
                  controller: timeController,
                  hintText: "When?".tr,
                ),
              ),
            ),
            SizedBox(height: 20.h),

            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC49A58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: isLoading ? null : _sendTimeChangeRequest,
                child: isLoading
                    ? const SpinKitDoubleBounce(color:ColorsData.primary)
                    : Text(
                        "sendToCustomer".tr,
                        style: Styles.textStyleS16W600(color: Colors.white),
                      ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

void showChangeTimeBottomSheet(
    BuildContext context, String day, String appointmentId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (context) => ChangeTimeBottomSheet(
      day: day,
      appointmentId: appointmentId,
    ),
  );
}
