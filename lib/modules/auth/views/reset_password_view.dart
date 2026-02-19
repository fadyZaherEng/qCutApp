import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_app_bar.dart';
import 'package:q_cut/core/utils/widgets/custom_big_button.dart';
import 'package:q_cut/modules/auth/views/password_reset_success_view.dart';
import 'dart:convert';
import 'package:q_cut/core/services/shared_pref/pref_keys.dart';
import 'package:q_cut/core/services/shared_pref/shared_pref.dart';
import 'package:q_cut/modules/auth/models/auth_response_model.dart';
import 'package:q_cut/modules/auth/views/widgets/custom_text_form.dart';
import 'package:q_cut/modules/customer/features/home_features/home/models/barber_model.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // final TextEditingController _otpController = TextEditingController(); // Removed
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final RxBool _isNewPasswordObscure = true.obs;
  final RxBool _isConfirmPasswordObscure = true.obs;
  final RxBool _isLoading = false.obs;

  late String phoneNumber;
  late String otp; // Restored

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      phoneNumber = args['phoneNumber'] ?? "";
      otp = args['otp'] ?? "";
    } else {
      phoneNumber = "";
      otp = "";
      // Use scheduleMicrotask or Future.delayed to pop after build
      Future.microtask(() {
        if (mounted) {
          Get.back();
          ShowToast.showError(message: "Invalid session. Please try again.".tr);
        }
      });
    }
  }

  @override
  void dispose() {
    // _otpController.dispose(); // Removed
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ShowToast.showError(message: "Passwords do not match".tr);
        return;
      }
      _isLoading.value = true;
      final NetworkAPICall apiCall = NetworkAPICall();

      final String formattedPhone = phoneNumber.startsWith('+')
          ? phoneNumber
          : (phoneNumber.startsWith('972')
              ? '+$phoneNumber'
              : "+972$phoneNumber");

      final requestData = {
        "phoneNumber": formattedPhone,
        "otp": otp, // Used variable
        "newPassword": _newPasswordController.text
      };
      print("Reset Password Data: $requestData");
      apiCall.postDataAsGuest({
        "phoneNumber": formattedPhone,
      }, Variables.FORGET_PASSWORD).then((response) {
        print("Forget Password Response: ${response.body}");
        if (response.statusCode == 200 || response.statusCode == 201) {
          // OTP sent successfully, now proceed to change password
          apiCall
              .postDataAsGuest(requestData, Variables.CHANGE_PASSWORD)
              .then((response) async {
            print("Reset Password Response: ${response.body}");
            if (response.statusCode == 200 || response.statusCode == 201) {
              // Extract success message
              String successMsg = "resetPasswordSuccess".tr;
              try {
                final responseBody = json.decode(response.body);
                if (responseBody is Map &&
                    responseBody.containsKey('message')) {
                  successMsg = responseBody['message'];
                }
              } catch (_) {}
              ShowToast.showSuccessSnackBar(message: successMsg.tr);

              // Password reset successful, now login
              String? fcmToken = "";
              // try {
              //   fcmToken = await FirebaseMessaging.instance.getToken();
              // } catch (e) {}

              final loginData = {
                'phoneNumber': formattedPhone,
                'password': _newPasswordController.text,
                "fcmToken": fcmToken,
                "userType": SharedPref().getBool(PrefKeys.userRole) == true
                    ? "user"
                    : "barber",
              };

              apiCall
                  .postDataAsGuest(loginData, Variables.LOGIN)
                  .then((loginRes) async {
                _isLoading.value = false;
                if (loginRes.statusCode == 200) {
                  final responseBody = json.decode(loginRes.body);
                  final loginResponse = LoginResponse.fromJson(responseBody);

                  await SharedPref().setString(PrefKeys.id, loginResponse.id);
                  await SharedPref()
                      .setString(PrefKeys.barberId, loginResponse.id);
                  await SharedPref().setString(
                      PrefKeys.accessToken, loginResponse.accessToken);
                  await SharedPref()
                      .setString(PrefKeys.profilePic, loginResponse.profilePic);
                  await SharedPref()
                      .setString(PrefKeys.coverPic, loginResponse.coverPic);
                  await SharedPref().setString(
                      PrefKeys.phoneNumber, loginResponse.phoneNumber);
                  await SharedPref()
                      .setString(PrefKeys.fullName, loginResponse.fullName);
                  await SharedPref().setBool(PrefKeys.saveMe, true);

                  if ((SharedPref().getBool(PrefKeys.userRole)) == false) {
                    Barber barber = Barber.fromJson(responseBody);
                    await SharedPref().setString(
                        PrefKeys.barber, jsonEncode(barber.toJson()));
                  }

                  Get.to(() => const PasswordResetSuccessView());
                } else {
                  Get.offAllNamed(AppRouter.loginPath);
                }
              });
            } else {
              _isLoading.value = false;
              // Error
              String errorMessage = "Failed to reset password".tr;
              try {
                final errorData = json.decode(response.body);
                if (errorData['message'] != null) {
                  errorMessage = errorData['message'];
                }
              } catch (e) {}
              ShowToast.showError(message: errorMessage);
            }
          }).catchError((error) {
            _isLoading.value = false;
            ShowToast.showError(message: "Network Error: $error");
          });
        } else {
          _isLoading.value = false;
          String errorMessage = "Failed to send OTP".tr;
          try {
            final errorData = json.decode(response.body);
            if (errorData['message'] != null) {
              errorMessage = errorData['message'];
            }
          } catch (e) {}
          ShowToast.showError(message: errorMessage);
        }
      }).catchError((error) {
        _isLoading.value = false;
        ShowToast.showError(message: "Network Error: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "resetPassword".tr),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Center(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  SizedBox(height: 30.h),
                  SvgPicture.asset(AssetsData.resetPasswordImage),
                  SizedBox(height: 50.h),
                  Text(
                    'resetPassword'.tr,
                    style: Styles.textStyleS16W700(color: ColorsData.primary),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'enterYourNewPassword'.tr,
                    style: Styles.textStyleS14W400(),
                  ),
                  SizedBox(height: 50.h),

                  // New Password Field
                  Obx(() => CustomTextFormField(
                        controller: _newPasswordController,
                        hintText: 'enterYourNewPassword'.tr,
                        obscureText: _isNewPasswordObscure.value,
                        keyboardType: TextInputType.visiblePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isNewPasswordObscure.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: ColorsData.primary,
                          ),
                          onPressed: () {
                            _isNewPasswordObscure.value =
                                !_isNewPasswordObscure.value;
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'passwordreq'.tr;
                          }
                          if (value.length < 6) {
                            return 'passwordLengthError'.tr;
                          }
                          return null;
                        },
                      )),
                  SizedBox(height: 16.h),

                  // Confirm Password Field
                  Obx(() => CustomTextFormField(
                        controller: _confirmPasswordController,
                        hintText: 'confirmYourPassword'.tr,
                        obscureText: _isConfirmPasswordObscure.value,
                        keyboardType: TextInputType.visiblePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordObscure.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: ColorsData.primary,
                          ),
                          onPressed: () {
                            _isConfirmPasswordObscure.value =
                                !_isConfirmPasswordObscure.value;
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'confirmYourPassword'.tr;
                          }
                          return null;
                        },
                      )),
                  SizedBox(height: 100.h),

                  // Reset Button
                  Obx(() => CustomBigButton(
                        textData: _isLoading.value
                            ? "Loading..."
                            : "resetPassword".tr,
                        onPressed: _isLoading.value ? null : _resetPassword,
                      )),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
