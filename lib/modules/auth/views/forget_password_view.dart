import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_big_button.dart';
import 'package:q_cut/modules/auth/views/functions/validate_egyptian_phone_number.dart';
import 'package:q_cut/modules/auth/views/widgets/custom_text_form.dart';

import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';

class ForgetPasswordView extends StatefulWidget {
  const ForgetPasswordView({super.key});

  @override
  State<ForgetPasswordView> createState() => _ForgetPasswordViewState();
}

class _ForgetPasswordViewState extends State<ForgetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 75.h),
            child: Center(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    SvgPicture.asset(AssetsData.forgetPasswordImage),
                    SizedBox(height: 111.h),
                    Text(
                      'forgetPassword'.tr,
                      style: Styles.textStyleS16W700(color: ColorsData.primary),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'enterYourPhoneNumberToSendOTP'.tr,
                      style: Styles.textStyleS14W400(),
                    ),
                    SizedBox(height: 24.h),
                    CustomTextFormField(
                      keyboardType: TextInputType.phone,
                      controller: _phoneNumberController,
                      hintText: 'enterYourPhoneNumber'.tr,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'enterYourPhoneNumber'.tr; // Or specific error
                        }
                        if (value.length != 9) {
                           return "Please enter valid phone number (9 digits)".tr; // Using a dummy or existing key if appropiate
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 111.h),
                    CustomBigButton(
                      textData: "sendOTPVerification".tr,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Call API to send OTP
                          print("Sending OTP to: ${_phoneNumberController.text}");
                          print("API Endpoint: ${Variables.FORGET_PASSWORD}");
                          final String phone = _phoneNumberController.text;
                          final String formattedPhone = phone.startsWith('+')
                              ? phone
                              : (phone.startsWith('972')
                                  ? '+$phone'
                                  : "+972$phone");

                          NetworkAPICall().postDataAsGuest({
                            "phoneNumber": formattedPhone
                          }, Variables.FORGET_PASSWORD).then((response) {
                            print("Response status: ${response.statusCode}");
                            print("Response body: ${response.body}");
                            if (response.statusCode == 200 || response.statusCode == 201) {
                               ShowToast.showSuccessSnackBar(message: "OTP is 123456".tr);
                               Get.toNamed(
                                AppRouter.otpVerificationResetCasePath, // Navigate to OTP screen
                                arguments: {
                                  "isFromResetPassword": true,
                                  "phoneNumber": formattedPhone,
                                },
                              );
                            } else {
                              // Extract message from response body if it's a Map
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
                          }).catchError((e){
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
      ),
    );
  }
}
