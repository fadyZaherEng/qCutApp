import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_big_button.dart';

class UnpaidView extends StatelessWidget {
  const UnpaidView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B384D),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              // SizedBox(height: 20.h),
              // Text(
              //   "payToQcut".tr,
              //   style: Styles.textStyleS20W700(color: Colors.white),
              // ),
              const Spacer(flex: 1),
              SvgPicture.asset(
                AssetsData.paymentIllustration,
                height: 250.h,
              ),
              const Spacer(flex: 1),
              Text(
                "unpaidAccountReason".tr,
                style: Styles.textStyleS16W600(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                "pleasePayToActivate".tr,
                style: Styles.textStyleS14W600(color: const Color(0xFFD1A439)),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              Row(
                children: [
                  Expanded(
                    child: CustomBigButton(
                      font: 12,
                      textData: "contactQcut".tr,
                      color: const Color(0xFFD1A439),
                      onPressed: () {
                        Get.toNamed(AppRouter.chatWithUsPath);
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomBigButton(
                      font: 12,
                      textData: "payToQcutBtn".tr,
                      color: const Color(0xFF7E7B91),
                      onPressed: () {
                        Get.toNamed(AppRouter.bpayToQCutPath);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
    );
  }
}
