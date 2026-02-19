import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:q_cut/core/utils/app_router.dart';
 import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/constants/drawer_constants.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/auth/auth_helper.dart';
import 'package:q_cut/main.dart';
import 'package:get/get.dart';

class CustomDrawerHeader extends StatelessWidget {
  const CustomDrawerHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              width: double.infinity,
              height: DrawerConstants.drawerHeaderHeight.h,
              decoration: BoxDecoration(
                color: ColorsData.secondary,
                image: DecorationImage(
                  alignment: Alignment.topCenter,
                  image: CachedNetworkImageProvider(coverImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 240.0, left: 20),
              child: _buildProfileImage(),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: DrawerConstants.horizontalPadding.w,
            vertical: DrawerConstants.itemSpacing.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fullName, style: Styles.textStyleS16W700()),
              SizedBox(height: DrawerConstants.itemSpacing.h),
              SizedBox(height: DrawerConstants.itemSpacing.h),
              Text(
                "\u200E$phoneNumber",
                style: Styles.textStyleS20W400(color: ColorsData.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    return InkWell(
      onTap: () {
        // Check authentication before accessing profile
        if (!AuthHelper.requireAuthentication(returnRoute: AppRouter.myProfilePath)) {
          return; // User redirected to login
        }
        Get.toNamed(AppRouter.myProfilePath);
      },
      child: CircleAvatar(
        radius: DrawerConstants.profileImageRadius,
        backgroundColor: ColorsData.secondary,
        child: CircleAvatar(
          radius: DrawerConstants.profileImageInnerRadius,
          foregroundImage: CachedNetworkImageProvider(profileImage),
          backgroundColor: ColorsData.secondary,
        ),
      ),
    );
  }
}
