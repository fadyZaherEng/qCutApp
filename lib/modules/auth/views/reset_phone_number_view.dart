import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_app_bar.dart';
import 'package:q_cut/core/utils/widgets/custom_big_button.dart';
import 'package:q_cut/modules/auth/views/functions/validate_egyptian_phone_number.dart';
import 'package:q_cut/modules/auth/views/widgets/custom_text_form.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'dart:convert';

class ResetPhoneNumberView extends StatelessWidget {
  ResetPhoneNumberView({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "changePhoneNumber".tr),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 65.h),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SvgPicture.asset(
                    AssetsData.resetPhoneNumberImage,
                    height: 183.h,
                    width: 97.w,
                  ),
                  SizedBox(
                    height: 79.h,
                  ),
                  Text(
                    'enterYourNewPhoneNumber'.tr,
                    style: Styles.textStyleS16W700(color: ColorsData.primary),
                  ),
                  SizedBox(
                    height: 24.h,
                  ),
                  Text(
                    'enterYourNewPhoneNumberToSendOTP'.tr,
                    style: Styles.textStyleS14W400(),
                  ),
                  SizedBox(
                    height: 24.h,
                  ),
                  CustomTextFormField(
                    keyboardType: TextInputType.phone,
                    controller: _phoneNumberController,
                    hintText: 'enterYourPhoneNumber'.tr,
                    validator: (value) => validateEgyptianPhoneNumber(value!),
                  ),
                  SizedBox(
                    height: 111.h,
                  ),
                  CustomBigButton(
                    textData: "sendOTPVerification".tr,
                    onPressed: () {
                      String successMsg = "OTP is 123456".tr;

                      if (_formKey.currentState!.validate()) {
                        final String phone = _phoneNumberController.text;
                        final String formattedPhone = phone.startsWith('+')
                            ? phone
                            : (phone.startsWith('972')
                                ? '+$phone'
                                : "+972$phone");

                        // Call API to send OTP
                        print("url: ${Variables.REQUEST_CHANGE_PHONE}");
                        NetworkAPICall().addData({
                          "newPhoneNumber": formattedPhone,
                        }, Variables.REQUEST_CHANGE_PHONE).then((response) {
                          print("Response status: ${response.statusCode}");
                          print("Response body: ${response.body}");
                          if (response.statusCode == 200 ||
                              response.statusCode == 201) {
                            try {
                              final responseBody = json.decode(response.body);
                              if (responseBody is Map &&
                                  responseBody.containsKey('message')) {
                                // successMsg = responseBody['message'];
                              }
                            } catch (_) {}
                            ShowToast.showSuccessSnackBar(
                                message: successMsg.tr);
                            Get.toNamed(
                              AppRouter.otpVerificationResetCasePath,
                              arguments: {
                                "isFromResetPassword": false,
                                "phoneNumber": formattedPhone,
                              },
                            );
                          } else {
                            // Extract message from response body if it's available
                            String errorMsg = "Failed to send OTP".tr;
                            if (response.body is Map && response.body.containsKey('message')) {
                              errorMsg = response.body['message'];
                            } else if (response.body is String) {
                              try {
                                final decoded = json.decode(response.body);
                                if (decoded is Map && decoded.containsKey('message')) {
                                  errorMsg = decoded['message'];
                                }
                              } catch (_) {}
                            }
                            ShowToast.showError(message: errorMsg.tr);
                          }
                        }).catchError((e) {
                          ShowToast.showError(message: "Error: $e");
                        });

                      }
                    },
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
