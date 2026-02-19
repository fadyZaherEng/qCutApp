import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/constants/drawer_constants.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/auth/auth_helper.dart';
import 'drawer_header.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool _isNotificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        width: double.infinity,
        color: ColorsData.secondary,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomDrawerHeader(),
              _buildDrawerItems(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItems() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: DrawerConstants.horizontalPadding.w,
      ),
      child: Column(
        children: [
          _buildDivider(),
          _buildMenuItem(
            'appointments'.tr,
            AssetsData.calendarIcon,
            () {
              // Check authentication before navigating
              if (!AuthHelper.requireAuthentication(returnRoute: AppRouter.myAppointmentPath)) {
                return; // User redirected to login
              }
              Get.toNamed(AppRouter.myAppointmentPath);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'favorites'.tr,
            AssetsData.favoritesIcon,
            () {
              // Check authentication before navigating
              if (!AuthHelper.requireAuthentication(returnRoute: AppRouter.favoritePath)) {
                return; // User redirected to login
              }
              Get.toNamed(AppRouter.favoritePath);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'history'.tr,
            AssetsData.historyIcon,
            () {
              // Check authentication before navigating
              if (!AuthHelper.requireAuthentication(returnRoute: AppRouter.historyPath)) {
                return; // User redirected to login
              }
              Get.toNamed(AppRouter.historyPath);
            },
          ),
          _buildDivider(),
          _buildMenuItem("Setting".tr, AssetsData.settingIcon,
              () => Get.toNamed(AppRouter.settingsPath)),
          _buildDivider(),
          _buildNotificationsToggle(),
          _buildDivider(),
          _buildMenuItem("contact_qcut".tr, AssetsData.contactUsIcon,
              () => Get.toNamed(AppRouter.chatWithUsPath)),
          _buildDivider(),
          _buildMenuItem("share".tr, AssetsData.shareIcon, () {}),
          _buildDivider(),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, String iconPath, VoidCallback onTap) {
    bool isClicked = true;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: DrawerConstants.itemSpacing.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r), // انيميشن حلوة عند الضغط
        onTap: () async {
          if (isClicked) {
            isClicked = false;
            setState(() {});
            onTap();
            await Future.delayed(const Duration(milliseconds: 500), () {
              isClicked = true;
              setState(() {});
            });
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 4.w,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    iconPath,
                    height: DrawerConstants.iconSize.h,
                    width: DrawerConstants.iconSize.w,
                    colorFilter: const ColorFilter.mode(
                      ColorsData.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: DrawerConstants.iconSpacing.w),
                  Text(title, style: Styles.textStyleS14W400()),
                ],
              ),
              SvgPicture.asset(
                AssetsData.rightArrowIcon,
                height: DrawerConstants.iconSize.h,
                width: DrawerConstants.iconSize.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              AssetsData.notificationsIcon,
              height: DrawerConstants.iconSize.h - 2,
              width: DrawerConstants.iconSize.w - 2,
              colorFilter: const ColorFilter.mode(
                ColorsData.primary,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: DrawerConstants.iconSpacing.w - 2),
            Text("Notifications".tr, style: Styles.textStyleS14W400()),
          ],
        ),
        Transform.scale(
          scale: 0.75,
          child: Switch(
            value: _isNotificationsEnabled,
            onChanged: (value) =>
                setState(() => _isNotificationsEnabled = value),
            inactiveThumbColor: ColorsData.cardStrock,
            activeColor: ColorsData.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Divider(color: ColorsData.cardStrock);
  }
}
