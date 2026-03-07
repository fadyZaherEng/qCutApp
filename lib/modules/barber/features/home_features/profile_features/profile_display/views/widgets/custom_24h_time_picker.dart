import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';

class Custom24HTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  const Custom24HTimePicker({super.key, required this.initialTime});

  @override
  State<Custom24HTimePicker> createState() => _Custom24HTimePickerState();
}

class _Custom24HTimePickerState extends State<Custom24HTimePicker> {
  late int selectedHour;
  late int selectedMinute;
  bool isSelectingHour = true;

  @override
  void initState() {
    super.initState();
    selectedHour = widget.initialTime.hour;
    selectedMinute = widget.initialTime.minute;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isSelectingHour ? "selectHour".tr : "selectMinute".tr,
                style: Styles.textStyleS16W700(color: ColorsData.primary),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          
          // Time Display
          Container(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => setState(() => isSelectingHour = true),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: isSelectingHour ? ColorsData.primary.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                      border: isSelectingHour ? Border.all(color: ColorsData.primary) : null,
                    ),
                    child: Text(
                      selectedHour.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelectingHour ? ColorsData.primary : Colors.black,
                      ),
                    ),
                  ),
                ),
                Text(
                  ":",
                  style: TextStyle(fontSize: 48.sp, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => setState(() => isSelectingHour = false),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: !isSelectingHour ? ColorsData.primary.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                      border: !isSelectingHour ? Border.all(color: ColorsData.primary) : null,
                    ),
                    child: Text(
                      selectedMinute.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold,
                        color: !isSelectingHour ? ColorsData.primary : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Grid Content
          SizedBox(
            height: 280.h,
            child: isSelectingHour 
              ? _buildHourGrid()
              : _buildMinuteGrid(),
          ),
          
          SizedBox(height: 16.h),
          
          // Confirm Button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsData.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              onPressed: () {
                Navigator.pop(context, TimeOfDay(hour: selectedHour, minute: selectedMinute));
              },
              child: Text(
                "Confirm".tr,
                style: Styles.textStyleS16W600(color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildHourGrid() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 8.h,
        crossAxisSpacing: 8.w,
        childAspectRatio: 1,
      ),
      itemCount: 24,
      itemBuilder: (context, index) {
        final isSelected = selectedHour == index;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedHour = index;
              isSelectingHour = false; // Move to minute selection
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? ColorsData.primary : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                index.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMinuteGrid() {
    // Show 00, 05, 10... slots
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 1.5,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final minute = index * 5;
        final isSelected = selectedMinute == minute;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedMinute = minute;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? ColorsData.primary : Colors.grey[100],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                minute.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

Future<TimeOfDay?> showCustom24HTimePicker(BuildContext context, {required TimeOfDay initialTime}) {
  return showModalBottomSheet<TimeOfDay>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Custom24HTimePicker(initialTime: initialTime),
  );
}
