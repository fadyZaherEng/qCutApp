import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/services/shared_pref/pref_keys.dart';
import 'package:q_cut/core/services/shared_pref/shared_pref.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_big_button.dart';
import 'package:q_cut/core/utils/widgets/custom_button.dart';
import 'package:q_cut/core/utils/widgets/custom_checkbox.dart';
import 'package:q_cut/modules/auth/logic/controller/auth_controller.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/modules/auth/views/functions/validate_egyptian_phone_number.dart';
import 'package:q_cut/modules/auth/views/functions/validate_arabic_text.dart';
import 'package:q_cut/modules/auth/views/widgets/custom_text_form.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  bool isChecked = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.only(top: 30.h),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(children: [
              Image.asset(
                height: 102.h,
                width: 226.w,
                AssetsData.fullQCutImage,
              ),
              SizedBox(
                height: 57.h,
              ),
              Container(
                width: 260.w,
                height: 48.h,
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: ColorsData.font,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'logIn'.tr,
                        textStyle: Styles.textStyleS14W400(
                            color: ColorsData.cardStrock, fontSize: 15.sp),
                        borderRadiusDirectional: BorderRadiusDirectional.only(
                          topStart: Radius.circular(16.r),
                          bottomStart: Radius.circular(16.r),
                        ),
                        onPressed: () {
                          Get.back();
                        },
                        backgroundColor: ColorsData.font,
                        textColor: ColorsData.cardStrock,
                      ),
                    ),
                    Expanded(
                      child: CustomButton(
                        text: 'signUp'.tr,
                        borderRadiusDirectional: BorderRadiusDirectional.only(
                          topStart: Radius.circular(16.r),
                          bottomStart: Radius.circular(16.r),
                        ),
                        onPressed: () {},
                        backgroundColor: ColorsData.secondary,
                        textColor: ColorsData.primary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16.h,
              ),
              Form(
                key: _authController.signupFormKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      CustomTextFormField(
                        keyboardType: TextInputType.name,
                        controller: _authController.fullNameController,
                        hintText: 'enterYourFullName'.tr,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name'.tr;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        keyboardType: TextInputType.number,
                        controller: _authController.phoneNumberController,
                        hintText: 'enterYourPhoneNumber'.tr,
                        validator: (value) =>
                            validateEgyptianPhoneNumber(value!),
                      ),
                      (SharedPref().getBool(PrefKeys.userRole)) == false
                          ? Column(
                              children: [
                                SizedBox(height: 16.h),
                                CustomTextFormField(
                                  controller: _authController.barberShopNameController,
                                  hintText: 'enterYourBarberShopName'.tr,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'pleaseEnterYourBarberShopName'.tr;
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16.h),
                                CustomTextFormField(
                                  controller: _authController.locationDescriptionController,
                                  hintText: 'locationDescription'.tr,
                                  // maxLines: 3,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'pleaseEnterLocationDescription'.tr;
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16.h),
                              ],
                            )
                          : SizedBox(height: 16.h),
                      (SharedPref().getBool(PrefKeys.userRole)) == false
                          ? CustomTextFormField(
                              controller: _authController.city,
                              hintText: 'pleaseEnterCityNameInArabic'.tr,
                              textDirection: TextDirection.rtl,
                              // Set text direction to RTL for Arabic
                              // Use custom formatter to allow only Arabic characters and show toast
                              inputFormatters: [
                                ArabicInputFormatter(),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your City'.tr;
                                }
                                // Validate that city name is in Arabic
                                final arabicValidation =
                                    validateArabicText(value);
                                if (arabicValidation != null) {
                                  return arabicValidation;
                                }
                                return null;
                              },
                            )
                          : SizedBox(height: 16.h),
                      (SharedPref().getBool(PrefKeys.userRole)) == false
                          ? SizedBox(height: 16.h)
                          : SizedBox.shrink(),
                      CustomTextFormField(
                        controller: _authController.passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        hintText: 'enterYourPassword'.tr,
                        obscureText: _obscurePassword,
                        suffixIcon: InkWell(
                          onTap: _togglePasswordVisibility,
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        controller: _authController.confirmPasswordController,
                        keyboardType: TextInputType.visiblePassword,
                        hintText: 'confirmYourPassword'.tr,
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password'.tr;
                          } else if (value !=
                              _authController.passwordController.text) {
                            return 'Passwords do not match'.tr;
                          }
                          return null;
                        },
                        suffixIcon: InkWell(
                          onTap: _toggleConfirmPasswordVisibility,
                          child: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          CustomCheckbox(
                            isChecked: isChecked,
                            onChanged: (value) {
                              setState(() {
                                isChecked = value;
                              });
                            },
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Wrap(
                              children: [
                                Text(
                                  'iAgreeWith'.tr,
                                  style: Styles.textStyleS14W400(),
                                ),
                                InkWell(
                                  onTap: () {
                                    Get.toNamed(AppRouter.privacyPolicyPath);
                                  },
                                  child: Text(
                                    'privacyPolicy'.tr,
                                    style: Styles.textStyleS14W400().copyWith(
                                      color: ColorsData.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                Text(
                                  " ${'and'.tr} ",
                                  style: Styles.textStyleS14W400(),
                                ),
                                InkWell(
                                  onTap: () {
                                    Get.toNamed(AppRouter.termsPath);
                                  },
                                  child: Text(
                                    'Terms and Conditions'.tr,
                                    style: Styles.textStyleS14W400().copyWith(
                                      color: ColorsData.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Obx(
                        () => _authController.isLoading.value
                            ? const SpinKitDoubleBounce(
                                color: ColorsData.primary,
                              )
                            : CustomBigButton(
                                textData: 'request'.tr,
                                onPressed: () {
                                  if (isChecked) {
                                    if (_authController.city.text.isEmpty) {
                                      _authController.city.text = "Not Set".tr;
                                    }
                                    _authController.signUp(context);
                                  } else {
                                    Get.snackbar(
                                      'Error'.tr,
                                      'Please agree to Privacy & Policy'.tr,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                },
                              ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class ArabicInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Regex match (Arabic characters and spaces)
    final validChars = RegExp(r'^[\u0600-\u06FF\s]+\$');

    // If the new text is fully valid, allow it
    if (validChars.hasMatch(newValue.text)) {
      return newValue;
    }

    // Check if we are adding text
    if (newValue.text.length > oldValue.text.length) {
      // Check if the NEWLY added characters are invalid
      // For simplicity, just check if the new text has ANY invalid char (which it does, otherwise the previous check would pass)

      // Show toast error
      ShowToast.showError(message: 'pleaseEnterCityNameInArabic'.tr);
      return oldValue; // Reject change
    }

    // If we are here, it might be deletion or complex change, allow valid subset if feasible or assume blocking was handled above.
    // However, if validChars failed, it means there are invalid chars.
    // If it was a paste, we reject it. If it was typing, we reject it.

    return oldValue;
  }
}
