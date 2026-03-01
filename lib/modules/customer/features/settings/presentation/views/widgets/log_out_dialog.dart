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

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context, false),
              ),
            ),
            SvgPicture.asset(
              AssetsData.logOutIcon,
              width: 32.w,
              height: 32.h,
              colorFilter:
                  const ColorFilter.mode(ColorsData.primary, BlendMode.srcIn),
            ),
            SizedBox(height: 16.h),
            Text(
              "Are you sure you want to log out from your account?".tr,
              style: Styles.textStyleS14W700(color: ColorsData.secondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final bool? userRole =
                          SharedPref().getBool(PrefKeys.userRole);
                      SharedPref().clearPreferences();
                      if (userRole != null) {
                        SharedPref().setBool(PrefKeys.userRole, userRole);
                      }
                      await SharedPref().setBool(PrefKeys.saveMe, false);
                      SharedPref().getBool(PrefKeys.userRole) ?? false
                          ? Get.offAllNamed(AppRouter.loginPath)
                          : Get.offAllNamed(AppRouter.bloginPath);
                      print(
                          "User logged out, preferences cleared except userRole ${SharedPref().getBool(PrefKeys.saveMe)}");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsData.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text("Yes".tr,
                        style: Styles.textStyleS14W600(color: ColorsData.font)),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsData.cardStrock,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text("No".tr,
                        style: Styles.textStyleS14W600(color: ColorsData.font)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
