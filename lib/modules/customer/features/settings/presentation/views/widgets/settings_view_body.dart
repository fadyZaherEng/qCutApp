import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/main.dart';
import 'package:q_cut/modules/customer/features/settings/presentation/views/functions/show_change_your_name_bottom_sheet.dart';
import 'package:q_cut/modules/customer/features/settings/presentation/views/functions/show_delete_account_dialog.dart';
import 'package:q_cut/modules/customer/features/settings/presentation/views/functions/show_log_out_dialog.dart';
import 'package:q_cut/modules/customer/features/home_features/profile_feature/logic/profile_controller.dart';

class SettingViewBody extends StatefulWidget {
  const SettingViewBody({super.key});

  @override
  State<SettingViewBody> createState() => _SettingViewBodyState();
}

class _SettingViewBodyState extends State<SettingViewBody> {
  @override
  Widget build(BuildContext context) {
    final ProfileController profileController =
        Get.isRegistered<ProfileController>()
            ? Get.find<ProfileController>()
            : Get.put(ProfileController());

    return Obx(() {
      final displayFullName =
          profileController.profileData.value?.fullName ?? fullName;
      final displayProfileImage =
          profileController.profileData.value?.profilePic ?? profileImage;
      final displayPhoneNumber =
          profileController.profileData.value?.phoneNumber ?? phoneNumber;

      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 5.h, left: 16.w, right: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        EdgeInsets.all(16.r),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: ColorsData.cardStrock),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          foregroundImage:
                              CachedNetworkImageProvider(displayProfileImage),
                        ),
                        SizedBox(height: 5.h),
                        Text(displayFullName, style: Styles.textStyleS16W700()),
                        SizedBox(height: 3.h),
                        Text("\u200E$displayPhoneNumber",
                            style: Styles.textStyleS20W400(
                                color: ColorsData.primary)),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),
                  buildDrawerItem(
                    "changeYourName".tr,
                    AssetsData.profileIcon,
                    () async {
                      await showChangeYourNameBottomSheet(context);
                      profileController.fetchProfileData();
                    },
                  ),
                  buildDivider(),
                  buildDrawerItem(
                    "resetPassword".tr,
                    AssetsData.resetPasswordBottomSheetIcon,
                    () {
                      Get.toNamed(
                        AppRouter.resetPasswordPath,
                        arguments: {
                          "phoneNumber": profileController
                                  .profileData.value?.phoneNumber ??
                              phoneNumber,
                          "otp": '123456',
                        },
                      );
                    },
                  ),
                  buildDivider(),
                  buildDrawerItem(
                      "changeLanguages".tr, AssetsData.changeLanguagesIcon, () {
                    Get.toNamed(AppRouter.changeLangugesPath);
                  }),
                  buildDivider(),
                  buildDrawerItem("changePhoneNumber".tr, AssetsData.callIcon,
                      () {
                    Get.toNamed(AppRouter.resetPhoneNumberPath);
                  }),
                  buildDivider(),
                  buildDrawerItem("logout".tr, AssetsData.logOutIcon, () {
                    showLogoutDialog(context);
                  }),
                  buildDivider(),
                  buildDrawerItem("deleteAccount".tr, AssetsData.trashIcon, () {
                    showDeleteAccountDialog(context);
                  }),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget buildDrawerItem(String title, String imagePath, VoidCallback? onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    imagePath,
                    height: 24.h,
                    width: 24.w,
                    colorFilter: const ColorFilter.mode(
                        ColorsData.primary, BlendMode.srcIn),
                  ),
                  SizedBox(width: 12.w),
                  Text(title, style: Styles.textStyleS15W400()),
                ],
              ),
              SvgPicture.asset(
                AssetsData.downArrowIcon,
                height: 24.h,
                width: 24.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDivider() {
    return const Divider(color: ColorsData.cardStrock);
  }
}
