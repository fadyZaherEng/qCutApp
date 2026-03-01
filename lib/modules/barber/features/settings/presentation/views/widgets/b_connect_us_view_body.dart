import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../home_features/profile_features/profile_display/logic/b_profile_controller.dart';

class BConnectUsViewBody extends StatelessWidget {
  const BConnectUsViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SvgPicture.asset(
                AssetsData.connectUsImage,
                width: 250.w,
                height: 200.h,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 48.h),
            Text(
              "Contact Us".tr,
              style: Styles.textStyleS20W700(color: ColorsData.primary),
            ),
            SizedBox(height: 8.h),
            Text(
              "You can contact by".tr,
              style: Styles.textStyleS14W400(color: ColorsData.font.withOpacity(0.6)),
            ),
            SizedBox(height: 32.h),
            _buildContactItem(
              title: "INSTGRAM".tr,
              iconPath: AssetsData.instagramIcon,
              onTap: () async {
                const instagramUrl =
                    "https://www.instagram.com/moataz.abnha?igsh=MW12b2JyYzJtMjY0bA%3D%3D&utm_source=qr";
                try {
                  final uri = Uri.parse(instagramUrl);
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (e) {
                  ShowToast.showError(message: "Instagram link is not set".tr);
                }
              },
            ),
            SizedBox(height: 16.h),
            _buildContactItem(
              title: "Chat with us".tr,
              iconPath: AssetsData.messageIcon,
              onTap: () {
                Get.toNamed(AppRouter.chatWithUsPath);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required String title,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: ColorsData.cardStrock.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: ColorsData.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                iconPath,
                height: 20.h,
                width: 20.w,
                colorFilter: const ColorFilter.mode(
                  ColorsData.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              title,
              style: Styles.textStyleS16W500(),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: ColorsData.primary.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
