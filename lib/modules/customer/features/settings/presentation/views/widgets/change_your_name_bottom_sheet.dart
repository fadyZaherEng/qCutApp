import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/services/shared_pref/shared_pref.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_big_button.dart';
import 'package:q_cut/main.dart';
import 'package:q_cut/main.dart' as PrefKeys;
import 'package:q_cut/modules/auth/views/widgets/custom_text_form.dart';

class ChangeYourNameBottomSheet extends StatelessWidget {
  const ChangeYourNameBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController name = TextEditingController();
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Icon(Icons.close, size: 24.sp),
              ),
            ),
            SizedBox(height: 5.h),
            Center(
              child: SvgPicture.asset(
                height: 32.h,
                width: 24.w,
                AssetsData.profileIcon,
                colorFilter: const ColorFilter.mode(
                  ColorsData.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "changeYourName".tr,
              style: Styles.textStyleS14W700(color: ColorsData.secondary),
            ),
            SizedBox(height: 16.h),
            CustomTextFormField(
              controller: name,
              hintText: "enterYourNewName".tr,
              fillColor: ColorsData.font,
              style: Styles.textStyleS14W400(color: ColorsData.secondary),
            ),
            SizedBox(height: 16.h),
            CustomBigButton(
              textData: "confirm".tr,
              onPressed: () async {
                var response = await NetworkAPICall()
                    .editData("${Variables.baseUrl}authentication/editUser", {
                  "fullName": name.text,
                });

                response.statusCode == 200
                    ? {
                        SharedPref().setString(PrefKeys.fullName, name.text),
                        fullName = name.text,
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              content: Text(
                                "${'success'.tr}: ${'nameChangedSuccessfully'.tr}",
                                style: Styles.textStyleS14W400(
                                    color: Colors.green),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "ok".tr,
                                    style: Styles.textStyleS14W400(
                                      color: ColorsData.secondary,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ) // Changed from Get.back() for consistency
                      }
                    : showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            content: Text(
                              "${'error'.tr}: ${response.statusCode}",
                              style: Styles.textStyleS14W400(color: Colors.red),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "ok".tr,
                                    style: Styles.textStyleS14W400(
                                      color: ColorsData.secondary,
                                      fontSize: 14.sp,
                                    ),
                                  )),
                            ],
                          );
                        },
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class BChangeYourNameBottomSheet extends StatelessWidget {
    BChangeYourNameBottomSheet({super.key});
  TextEditingController name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Icon(Icons.close, size: 24.sp),
              ),
            ),
            SizedBox(height: 5.h),
            Center(
              child: SvgPicture.asset(
                height: 32.h,
                width: 24.w,
                AssetsData.profileIcon,
                colorFilter: const ColorFilter.mode(
                  ColorsData.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "changeYourName".tr,
              style: Styles.textStyleS14W700(color: ColorsData.secondary),
            ),
            SizedBox(height: 16.h),
            CustomTextFormField(
              controller: name,
              hintText: "enterYourNewName".tr,
              fillColor: ColorsData.font,
              style: Styles.textStyleS14W400(color: ColorsData.secondary),
            ),
            SizedBox(height: 16.h),
            CustomBigButton(
              textData: "confirm".tr,
              onPressed: () async {
                var response = await NetworkAPICall()
                    .editData("${Variables.baseUrl}authentication", {
                  "fullName": name.text,
                });

                response.statusCode == 200
                    ? {
                        SharedPref().setString(PrefKeys.fullName, name.text),
                        fullName = name.text,
                        Get.back()
                      }
                    : showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Text(
                              "${'error'.tr}: ${response.statusCode}",
                              style: Styles.textStyleS14W400(),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("ok".tr),
                              ),
                            ],
                          );
                        },
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
