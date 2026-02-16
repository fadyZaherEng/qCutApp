import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:get/get.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/main.dart';
import 'package:q_cut/modules/barber/features/settings/presentation/views/functions/show_delete_account_dialog.dart';
import 'package:q_cut/modules/barber/features/settings/presentation/views/functions/show_log_out_dialog.dart'
    show showLogoutDialog;
import 'package:q_cut/modules/barber/map_search/map_search_screen.dart';
import 'package:q_cut/modules/customer/features/settings/presentation/views/functions/show_change_your_name_bottom_sheet.dart';
import 'package:q_cut/modules/customer/features/settings/presentation/views/widgets/change_your_name_bottom_sheet.dart';

import '../../../../home_features/profile_features/profile_display/logic/b_profile_controller.dart';

class BSettingViewBody extends StatelessWidget {
  BSettingViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the profile controller to observe changes
    final BProfileController profileController =
        Get.isRegistered<BProfileController>()
            ? Get.find<BProfileController>()
            : Get.put(BProfileController());

    return Obx(() {
      // Use values from profileController if available, otherwise fallback to globals
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
                        EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w),
                    height: 161.h,
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
                  if (isLoading.value)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                          child: SpinKitDoubleBounce(
                              color: ColorsData.primary, size: 30)),
                    ),
                  SizedBox(height: 14.h),
                  buildDrawerItem("changeYourName".tr, AssetsData.profileIcon,
                      () async {
                    await Get.bottomSheet(
                      BChangeYourNameBottomSheet(),
                      isScrollControlled: true,
                    );
                    // Refresh data after bottom sheet closes to be safe
                    profileController.fetchProfileData();
                  }),
                  buildDivider(),
                  buildDrawerItem("resetPassword".tr,
                      AssetsData.resetPasswordBottomSheetIcon, () {
                    Get.toNamed(
                      AppRouter.resetPasswordPath,
                      arguments: {
                        "phoneNumber": profileController.profileData.value?.phoneNumber ??
                            phoneNumber,
                        "otp": '123456',
                      }
                    );
                  }),
                  buildDivider(),
                  buildDrawerItem(
                      "changeLanguages".tr, AssetsData.changeLanguagesIcon, () {
                    Get.toNamed(AppRouter.changeLangugesPath);
                  }),
                  buildDivider(),
                  buildDrawerItem("Change Phone number".tr, AssetsData.callIcon,
                      () {
                    Get.toNamed(AppRouter.bresetPhoneNumberPath);
                  }),
                  buildDivider(),
                  buildDrawerItem(
                    "changeYourLocation".tr,
                    AssetsData.mapPinIcon,
                    () {
                      // Future.delayed to ensure the tap is registered properly
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return MapSearchScreen(
                          initialLatitude: 32.0853,
                          initialLongitude: 34.7818,
                          onLocationSelected: (lat, lng, address) {
                            updateProfile(
                              locationLatitude: lat,
                              locationLongitude: lng,
                            );
                          },
                        );
                      }));
                    },
                  ),
                  buildDivider(),
                  buildDrawerItem("logout".tr, AssetsData.logOutIcon, () {
                    showLogoutDialog(context);
                  }),
                  buildDivider(),
                  buildDrawerItem("deleteAccount".tr, AssetsData.trashIcon, () {
                    Get.toNamed(AppRouter.bdeleteAccountReasonPath);
                  }),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  dynamic isLoading = false.obs;

  Future<void> updateProfile({
    required double locationLatitude,
    required double locationLongitude,
  }) async {
    final NetworkAPICall apiCall = NetworkAPICall();

    isLoading.value = true;
    try {
      // Build payload with properly formatted working days
      final Map<String, dynamic> payload = {
        'barberShopLocation': {
          'type': 'Point',
          'coordinates': [locationLongitude, locationLatitude],
        },
      };

      print('Payload workingDays: ${payload['workingDays']}');
      final response =
          await apiCall.editData('${Variables.baseUrl}authentication', payload);

      if (response.statusCode == 200) {
        Get.snackbar('Success'.tr, 'Location updated successfully'.tr);
        // Update local state if necessary
        // profileController.fetchUserProfile();
        // Optionally refresh the page or navigate
        // Get.offAllNamed(AppRouter.bsettingsPath);
      } else {
        Get.snackbar(
            'Error', 'Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating profile: $e');
      Get.snackbar('Error', 'Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
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
