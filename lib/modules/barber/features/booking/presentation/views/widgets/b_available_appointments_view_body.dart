import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_big_button.dart';
import 'package:q_cut/modules/barber/features/booking/presentation/views/widgets/CustomBAvailableTimesPicker.dart';
import 'package:q_cut/modules/customer/features/booking_features/select_appointment_time/view/widgets/custom_b_simple_days_picker.dart';

class BAvailableAppointmentsViewBody extends StatefulWidget {
  const BAvailableAppointmentsViewBody({super.key});

  @override
  State<BAvailableAppointmentsViewBody> createState() =>
      _BAvailableAppointmentsViewBodyState();
}

class _BAvailableAppointmentsViewBodyState
    extends State<BAvailableAppointmentsViewBody> {
  int selectedDay = 12;
  String? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "availableAppointments".tr,
            style: Styles.textStyleS16W700(),
          ),
          SizedBox(
            height: 24.h,
          ),
          Row(
            children: [
              SvgPicture.asset(
                height: 24.h,
                width: 31.w,
                AssetsData.calendarIcon,
              ),
              SizedBox(
                width: 9.w,
              ),
              Text(
                "availableDays".tr,
                style: Styles.textStyleS16W400(),
              ),
            ],
          ),
          SizedBox(
            height: 24.h,
          ),
          CustomBSimpleDaysPicker(
            selectedDay: selectedDay,
             onDaySelected: (value) {
              setState(() {
                selectedDay = value;
              });
            },
          ),
          SizedBox(
            height: 24.h,
          ),
          CustomBAvailableTimesPicker(
            selectedTime: selectedTime,
            onTimeSelected: (time) {
              setState(() {
                selectedTime = time;
              });
            },
          ),
          SizedBox(
            height: 24.h,
          ),
          CustomBigButton(
            textData: "confirm".tr,
            onPressed: () {
              context.push(AppRouter.bpayToQCutPath);
            },
          ),
        ],
      ),
    );
  }
}
