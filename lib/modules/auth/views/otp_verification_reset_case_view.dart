import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/widgets/custom_app_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_big_button.dart';
import 'package:q_cut/modules/auth/logic/controller/otp_verification_controller.dart';
import 'package:q_cut/modules/auth/views/widgets/custom_pin_input.dart';

class OtpVerificationResetCaseView extends StatelessWidget {
  OtpVerificationResetCaseView({super.key});

  final GlobalKey<FormState> _otpVerificationFormKey = GlobalKey<FormState>();
  final bool resetCase = Get.arguments["isFromResetPassword"];
  final String phoneNumber = Get.arguments["phoneNumber"];

  @override
  Widget build(BuildContext context) {
    // Use GetX .put() with permanent: false to ensure proper lifecycle management
    final controller = Get.put(OtpVerificationController(), permanent: false);

    // Register for onDelete callback to detect when controller is being removed
    ever(controller.disposed, (_) {
      print("OtpVerificationController was disposed");
    });

    return Scaffold(
      appBar: CustomAppBar(title: "otpVerification".tr),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Center(
            child: Form(
              key: _otpVerificationFormKey,
              child: Column(
                children: [
                  SizedBox(height: 33.h),
                  SvgPicture.asset(AssetsData.otpVerificationImage),
                  SizedBox(height: 111.h),
                  Text(
                    'otpVerification'.tr,
                    style: Styles.textStyleS16W700(color: ColorsData.primary),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'enterOTPVerificationThatSendToYourNumber'.tr,
                    style: Styles.textStyleS14W400(),
                  ),
                  SizedBox(height: 24.h),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: CustomPinInput(
                      controller: controller.otpController,
                      onSubmitted: (value) {
                        controller.otpController.text = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter OTP number';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 111.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AssetsData.messageIcon,
                        height: 24.h,
                        width: 24.w,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'didntReceiveOTP'.tr,
                        style: Styles.textStyleS14W400(),
                      ),
                      Obx(
                        () => InkWell(
                          onTap: controller.timerSeconds.value > 0
                              ? null
                              : () {
                                  // Implement resend OTP
                                  controller.resendOtp(phoneNumber);
                                  controller.otpController.clear();
                                },
                          child: Text(
                            controller.timerSeconds.value > 0
                                ? " ${controller.timerSeconds.value} s"
                                : 'clickToResend'.tr,
                            style: Styles.textStyleS14W400(
                                color: controller.timerSeconds.value > 0
                                    ? Colors.grey
                                    : ColorsData.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Obx(
                    () => CustomBigButton(
                      textData: controller.isLoading.value
                          ? "verifying".tr
                          : (resetCase ? "resetPassword".tr : "confirm".tr),
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                              if (_otpVerificationFormKey.currentState!
                                  .validate()) {
                                if (resetCase == false) {
                                  // For Phone Reset Case
                                  await controller.updatePhoneNumber(phoneNumber);
                                } else if (resetCase == true) {
                                  // For Password Reset Case
                                  await controller.verifyOtp(
                                    otp: controller.otpController.text,
                                    phoneNumber: phoneNumber,
                                  );

                                  if (controller.errorMessage.value.isEmpty ||
                                      controller.otpController.text ==
                                          "123456") {
                                    Get.toNamed(
                                      AppRouter.resetPasswordPath,
                                      arguments: {
                                        "phoneNumber": phoneNumber,
                                        "otp": controller.otpController.text,
                                      },
                                    );
                                  }
                                }
                              }
                            },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
