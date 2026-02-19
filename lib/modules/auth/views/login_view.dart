import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_big_button.dart';
import 'package:q_cut/core/utils/widgets/custom_button.dart';
import 'package:q_cut/core/utils/widgets/custom_checkbox.dart';
import 'package:q_cut/modules/auth/logic/controller/auth_controller.dart';
import 'package:q_cut/modules/auth/views/widgets/custom_text_form.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _obscureText = true;
  bool isChecked = false;
  late AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
    // Ensure text fields are clear when opening login screen
    if (_authController.isSignUpSuccess.value && mounted) {
      // If coming from successful signup, make sure fields are cleared
      _authController.phoneNumberController.clear();
      _authController.passwordController.clear();
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed(AppRouter.selectServicesPath);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(children: [
            Image.asset(
              height: 102.h,
              width: 226.w,
              AssetsData.fullQCutImage,
            ),
            SizedBox(
              height: 108.h,
            ),
            Container(
              width: 220.w,
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
                      borderRadiusDirectional: BorderRadiusDirectional.only(
                        topEnd: Radius.circular(16.r),
                        bottomEnd: Radius.circular(16.r),
                      ),
                      onPressed: () {},
                      textColor: ColorsData.primary,
                      backgroundColor: ColorsData.secondary,
                    ),
                  ),
                  Expanded(
                    child: CustomButton(
                      backgroundColor: ColorsData.font,
                      text: 'signUp'.tr,
                      textStyle: Styles.textStyleS14W400(
                          color: ColorsData.cardStrock, fontSize: 15.sp),
                      borderRadiusDirectional: BorderRadiusDirectional.only(
                        topStart: Radius.circular(16.r),
                        bottomStart: Radius.circular(16.r),
                      ),
                      onPressed: () {
                        Get.toNamed(AppRouter.signUpPath);
                      },
                      textColor: ColorsData.cardStrock,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 16.h,
            ),
            Form(
              key: _authController.loginFormKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    CustomTextFormField(
                      controller: _authController.phoneNumberController,
                      hintText: 'enterYourPhoneNumber'.tr,
                      keyboardType: TextInputType.phone,
                      // validator: (value) => validateEgyptianPhoneNumber(value!),
                    ),
                    SizedBox(height: 16.h),
                    CustomTextFormField(
                      controller: _authController.passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      hintText: 'enterYourPassword'.tr,
                      obscureText: _obscureText,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'passwordreq'.tr;
                        }
                        return null;
                      },
                      suffixIcon: InkWell(
                        onTap: _togglePasswordVisibility,
                        child: Icon(
                          _obscureText
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
                        Text(
                          'rememberMe'.tr,
                          style: Styles.textStyleS14W400(),
                        ),
                        const Spacer(),
                        InkWell(
                            onTap: () {
                              Get.toNamed(AppRouter.forgetPasswordPath);
                            },
                            child: Text(
                              'forgetPassword'.tr,
                              style: Styles.textStyleS14W400(
                                  color: ColorsData.primary),
                            )),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Obx(
                      () => _authController.isLoading.value
                          ? const SpinKitDoubleBounce(
                              color: ColorsData.primary,
                            )
                          : CustomBigButton(
                              textData: 'login'.tr,
                              onPressed: () {
                                _authController.login(context, isChecked);
                              },
                            ),
                    ),
                    SizedBox(height: 16.h),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Text(
                    //       'continue'.tr,
                    //       style: Styles.textStyleS14W400(),
                    //     ),
                    //     SizedBox(width: 5.w),
                    //     InkWell(
                    //         onTap: () {
                    //           Get.offAllNamed(AppRouter.homPath);
                    //         },
                    //         child: Text(
                    //           'asAGuest'.tr,
                    //           style: Styles.textStyleS14W400(
                    //               color: ColorsData.primary),
                    //         )),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
