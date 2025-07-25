import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/services/shared_pref/pref_keys.dart';
import 'package:q_cut/core/services/shared_pref/shared_pref.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_big_button.dart';

class SelectServicesView extends StatelessWidget {
  const SelectServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.only(top: 27.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // const Spacer(),
                  SvgPicture.asset(
                    width: 85.w,
                    height: 86.h,
                    AssetsData.logo,
                  ),
                  SizedBox(width: 5.w),
                  SvgPicture.asset(
                    width: 103.w,
                    height: 31.h,
                    AssetsData.qCutTextImage,
                  ),
                  const SizedBox(width: 15),
                  buildDrawerItem(
                      "changeLanguages".tr, AssetsData.changeLanguagesIcon, () {
                    Get.toNamed(AppRouter.changeLangugesPath);
                  }),
                  // const Spacer(),
                ],
              ),
              SizedBox(
                height: 35.h,
              ),
              SvgPicture.asset(
                width: 232.w,
                height: 232.h,
                AssetsData.selectServicesImage,
              ),
              SizedBox(
                height: 69.h,
              ),
              Text(
                'easyWayToBook'.tr,
                style: Styles.textStyleS16W400(),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 16.h,
              ),
              Text(
                'youAre'.tr,
                style: Styles.textStyleS16W700(),
              ),
              SizedBox(
                height: 39.h,
              ),
              CustomBigButton(
                textData: 'barber'.tr,
                onPressed: () async {
                  try {
                    await SharedPref().setBool(PrefKeys.userRole, false);

                    Get.offAllNamed(AppRouter.loginPath);
                  } catch (e) {
                    print('Error setting barber role: $e');
                  }
                },
              ),
              SizedBox(
                height: 24.h,
              ),
              CustomBigButton(
                textData: 'customer'.tr,
                onPressed: () async {
                  try {
                    await SharedPref().setBool(PrefKeys.userRole, true);

                    Get.offAllNamed(AppRouter.loginPath);
                  } catch (e) {
                    print('Error setting customer role: $e');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDrawerItem(String title, String imagePath, VoidCallback? onTap) {
    return Padding(
      padding: EdgeInsets.only(top: 5.h, bottom: 5.h),
      child: GestureDetector(
        onTap: onTap,
        child: SvgPicture.asset(
          imagePath,
          height: 24.h,
          width: 24.w,
          colorFilter:
              const ColorFilter.mode(ColorsData.primary, BlendMode.srcIn),
        ),
      ),
    );
  }
}
