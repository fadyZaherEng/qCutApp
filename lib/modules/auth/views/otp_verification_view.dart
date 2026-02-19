import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/widgets/custom_arrow_left.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_svg/svg.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_big_button.dart';
import 'package:q_cut/modules/auth/logic/controller/auth_controller.dart';
import 'package:q_cut/modules/auth/views/widgets/custom_pin_input.dart';

class OtpVerificationView extends StatefulWidget {
  final String userId;

  const OtpVerificationView({super.key, required this.userId});

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController otpController = TextEditingController();
  late AuthController authController;

  @override
  void initState() {
    super.initState();
    authController = Get.find<AuthController>();
  }

  @override
  void dispose() {
    // Ensure this controller is disposed properly
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CustomArrowLeft(),
      ),
      body: GetBuilder<AuthController>(builder: (controller) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Center(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    SizedBox(
                      height: 33.h,
                    ),
                    SvgPicture.asset(AssetsData.otpVerificationImage),
                    SizedBox(
                      height: 111.h,
                    ),
                    Text(
                      'otpVerification'.tr,
                      style: Styles.textStyleS16W700(color: ColorsData.primary),
                    ),
                    SizedBox(
                      height: 24.h,
                    ),
                    Text(
                      'enterOTPVerificationThatSendToYourNumber'.tr,
                      style: Styles.textStyleS14W400(),
                    ),
                    SizedBox(
                      height: 24.h,
                    ),
                    CustomPinInput(
                      controller: otpController,
                      onSubmitted: (value) {
                        otpController.text = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter OTP number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 111.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AssetsData.messageIcon,
                          height: 24.h,
                          width: 24.w,
                        ),
                        SizedBox(
                          width: 8.w,
                        ),
                        Text(
                          'didntReceiveOTP'.tr,
                          style: Styles.textStyleS14W400(),
                        ),
                        InkWell(
                            onTap: () {
                              // Implement resend OTP functionality
                              authController.resendOtp(widget.userId);
                            },
                            child: Text(
                              'clickToResend'.tr,
                              style: Styles.textStyleS14W400(
                                  color: ColorsData.primary),
                            )),
                      ],
                    ),
                    SizedBox(
                      height: 8.h,
                    ),
                    Obx(() => CustomBigButton(
                          textData: controller.isLoading.value
                              ? "verifying".tr
                              : "confirm".tr,
                          onPressed: controller.isLoading.value
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    // Store the OTP value locally before calling verifyOtp
                                    final String otpValue = otpController.text;
                                    // Pass the stored value rather than accessing the controller later
                                    controller.verifyOtp(
                                        otpValue, widget.userId);
                                  }
                                },
                        )),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
