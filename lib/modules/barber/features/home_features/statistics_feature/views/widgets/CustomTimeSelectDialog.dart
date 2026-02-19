import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';

class CustomTimeSelectDialog extends StatefulWidget {
  final Function(DateTime)? onTimeSelected;
  final Function()? onCancel;
  final DateTime initialDateTime;

  const CustomTimeSelectDialog({
    super.key,
    this.onTimeSelected,
    this.onCancel,
    required this.initialDateTime,
  });

  @override
  State<CustomTimeSelectDialog> createState() => _CustomTimeSelectDialogState();
}

class _CustomTimeSelectDialogState extends State<CustomTimeSelectDialog> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late bool _isAm;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDateTime;
    _selectedTime = TimeOfDay.fromDateTime(_selectedDate);
    _isAm = _selectedTime.hour < 12;
  }

  DateTime _getCurrentDateTime() {
    int hour = _selectedTime.hour;
    if (_isAm && hour == 12) hour = 0;
    if (!_isAm && hour != 12) hour += 12;

    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour,
      _selectedTime.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with month and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    if (widget.onCancel != null) {
                      widget.onCancel!();
                    }
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.close, color: Colors.black54),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_selectedDate),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                // Empty SizedBox for alignment
                const SizedBox(width: 24),
              ],
            ),
            SizedBox(height: 16.h),

            // Calendar header (Days of the week)
            _buildCalendarHeader(),
            SizedBox(height: 8.h),

            // Calendar grid
            _buildCalendarGrid(),
            SizedBox(height: 24.h),

            // Time selector
            Row(
              children: [
                Text(
                  "time".tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(width: 16.w),
                _buildTimeSelector(),
                SizedBox(width: 8.w),
                _buildAmPmSelector(),
              ],
            ),
            SizedBox(height: 24.h),

            // Confirm Button
            Container(
              width: double.infinity,
              height: 48.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC49A58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  if (widget.onTimeSelected != null) {
                    widget.onTimeSelected!(_getCurrentDateTime());
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  "confirmTime".tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    final days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days
          .map((day) => SizedBox(
                width: 32.w,
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    // Get the date for the first day of the month
    final firstDay = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final firstDayOfWeek = firstDay.weekday % 7;

    // Calculate total number of days in the month
    final totalDays =
        DateUtils.getDaysInMonth(_selectedDate.year, _selectedDate.month);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: 42,
      // Show a maximum of 6 weeks
      itemBuilder: (context, index) {
        // Skip days before the first day of the month
        if (index < firstDayOfWeek) {
          return Container();
        }

        final day = index - firstDayOfWeek + 1;

        // Skip days after the end of the month
        if (day > totalDays) {
          return Container();
        }

        final date = DateTime(_selectedDate.year, _selectedDate.month, day);
        final isSelected = _selectedDate.year == date.year &&
            _selectedDate.month == date.month &&
            _selectedDate.day == date.day;

        // Highlight specific days (10 and 26)
        final isHighlighted = day == 10 || day == 26;

        return GestureDetector(
          onTap: () => setState(() => _selectedDate = date),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? const Color(0xFFC49A58) : Colors.transparent,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight:
                      isHighlighted ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : isHighlighted
                          ? const Color(0xFFC49A58)
                          : Colors.black87,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeSelector() {
    final formattedHour =
        _selectedTime.hourOfPeriod == 0 ? 12 : _selectedTime.hourOfPeriod;

    return GestureDetector(
      onTap: () => _showTimePickerBottomSheet(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Text(
          "$formattedHour:${_selectedTime.minute.toString().padLeft(2, '0')}",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  void _showTimePickerBottomSheet(BuildContext context) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFC49A58),
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
        _isAm = time.hour < 12;
      });
    }
  }

  Widget _buildAmPmSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildAmPmButton("AM", _isAm, () => setState(() => _isAm = true)),
          _buildAmPmButton("PM", !_isAm, () => setState(() => _isAm = false)),
        ],
      ),
    );
  }

  Widget _buildAmPmButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

void showCustomTimeSelectDialog(BuildContext context,
    {String? initialSelected, Function(String)? onTimeSelected}) {
  final List<String> timeOptions = [
    'today'.tr,
    'thisWeek'.tr,
    'thisMonth'.tr,
    'thisYear'.tr,
    'allTime'.tr,
  ];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: ColorsData.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'selectTimeFrame'.tr,
                style: Styles.textStyleS16W700(color: Colors.white),
              ),
              SizedBox(height: 16.h),
              ...timeOptions.map((option) => _buildTimeOption(
                    context,
                    option,
                    option == initialSelected,
                    () {
                      Navigator.pop(context);
                      if (onTimeSelected != null) {
                        onTimeSelected(option);
                      }
                    },
                  )),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildTimeOption(
    BuildContext context, String text, bool isSelected, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: isSelected ? ColorsData.primary : ColorsData.cardColor,
        borderRadius: BorderRadius.circular(8.r),
        border: isSelected
            ? Border.all(color: Colors.white.withOpacity(0.5), width: 1)
            : null,
      ),
      child: Text(
        text,
        style: Styles.textStyleS14W400(
          color: isSelected ? Colors.black : Colors.white,
        ).copyWith(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400),
      ),
    ),
  );
}
