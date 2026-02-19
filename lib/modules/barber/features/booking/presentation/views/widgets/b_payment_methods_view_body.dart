import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_big_button.dart';

import '../pay_to_qcut_feature/logic/pay_to_qcut_controller.dart';
import '../pay_to_qcut_feature/view/picker.dart';

class BPaymentMethodsViewBody extends StatefulWidget {
  const BPaymentMethodsViewBody({super.key});

  @override
  State<BPaymentMethodsViewBody> createState() =>
      _BPaymentMethodsViewBodyState();
}

class _BPaymentMethodsViewBodyState extends State<BPaymentMethodsViewBody> {
  final PayToQcutController _controller = Get.put(PayToQcutController());
  final billId = Get.arguments as String?;
  DateTime? selectedDate;
  String selectedDateText = "noDateSelected".tr;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20.h),
          SvgPicture.asset(
            AssetsData.paymentIllustration,
            width: 200.w,
            height: 150.h,
          ),
          SizedBox(height: 32.h),
          Text(
            "paymentMethods".tr,
            style: Styles.textStyleS14W700(color: ColorsData.primary),
          ),
          SizedBox(height: 16.h),
          _buildPaymentOption(
            AssetsData.cashIcon,
            "cash".tr,
            () {},
          ),
          SizedBox(height: 16.h),

          CustomDaysPicker(
            selectedDate: selectedDate ?? DateTime.now(),
            onDateSelected: (date) {
              setState(() {
                selectedDate = date;

                // Format and set the selected date text
                selectedDateText =
                    "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}";
              });
            },
            titleSimpleDaysPicker: "selectDate".tr,
          ),

          SizedBox(height: 16.h),

          // _buildPaymentOption(
          //   AssetsData.creditIcon,
          //   "Credit/Debit Cards",
          //   () {
          //     showPaymentDetailsBottomSheet(context);
          //   },
          // ),
          SizedBox(
            height: 32.h,
          ),
          CustomBigButton(
            textData: "confirm".tr,
            onPressed: () async {
              await _controller.requestPayment(
                billId: billId.toString(),
                dateTimestamp: selectedDate != null
                    ? selectedDate!.millisecondsSinceEpoch
                    : DateTime.now().millisecondsSinceEpoch,
              );
            },
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
      String iconPath, String title, void Function()? onTap) {
    return GestureDetector(
      onTap: () {
        setState(() {
          onTap;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  iconPath,
                  width: 22.w,
                  height: 16.h,
                ),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: Styles.textStyleS14W400(color: Colors.white),
                ),
              ],
            ),
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Center(
                child: Container(
                  width: 10.w,
                  height: 10.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorsData.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
