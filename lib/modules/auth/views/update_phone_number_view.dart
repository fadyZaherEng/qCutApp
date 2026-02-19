import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_app_bar.dart';
import 'package:q_cut/core/utils/widgets/custom_big_button.dart';
import 'package:q_cut/modules/auth/logic/controller/otp_verification_controller.dart';
import 'package:q_cut/modules/auth/views/functions/validate_egyptian_phone_number.dart';
import 'package:q_cut/modules/auth/views/widgets/custom_text_form.dart';

class UpdatePhoneNumberView extends StatelessWidget {
  UpdatePhoneNumberView({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPhoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OtpVerificationController>();

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
                  SizedBox(height: 79.h),
                  Text(
                    'confirmPhoneNumberChange'.tr,
                    style: Styles.textStyleS16W700(color: ColorsData.primary),
                  ),
                  SizedBox(height: 24.h),
                  CustomTextFormField(
                    keyboardType: TextInputType.phone,
                    controller: _newPhoneNumberController,
                    hintText: 'enterYourPhoneNumber'.tr,
                    validator: (value) => validateEgyptianPhoneNumber(value!),
                  ),
                  SizedBox(height: 111.h),
                  Obx(() => CustomBigButton(
                    textData: controller.isLoading.value ? "Processing...".tr : "confirm".tr,
                    onPressed: controller.isLoading.value 
                      ? null 
                      : () {
                        if (_formKey.currentState!.validate()) {
                          controller.updatePhoneNumber(_newPhoneNumberController.text);
                        }
                      },
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
