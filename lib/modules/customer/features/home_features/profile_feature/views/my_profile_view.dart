import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/main.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/views/widgets/show_change_your_picture_dialog.dart';
import 'package:q_cut/modules/customer/features/home_features/profile_feature/logic/profile_controller.dart';
import 'package:q_cut/modules/customer/features/home_features/profile_feature/views/widgets/show_change_user_info_bottom_sheet.dart';
import 'package:q_cut/modules/customer/features/settings/presentation/views/functions/show_log_out_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MyProfileView extends StatefulWidget {
  final bool isBack;

  const MyProfileView({
    super.key,
    this.isBack = false,
  });

  @override
  State<MyProfileView> createState() => _MyProfileViewState();
}

class _MyProfileViewState extends State<MyProfileView> {
  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.put(ProfileController());

    return RefreshIndicator(
      onRefresh: () async {
        await profileController.fetchProfileData();
      },
      child: Scaffold(
        body: Obx(() {
          if (profileController.isLoading.value) {
            return const Center(
              child: SpinKitDoubleBounce(
                color: ColorsData.primary,
              ),
            );
          }

          if (profileController.isError.value) {
            return Center(child: Text(profileController.errorMessage.value));
          }

          final profileData = profileController.profileData.value;

          final String fullName = profileData?.fullName ?? "User";
          final String phoneNumber = profileData?.phoneNumber ?? "";
          final String city = profileData?.city ?? "";

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 300.h,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 250.h,
                        decoration: BoxDecoration(
                          color: ColorsData.secondary,
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            alignment: Alignment.topCenter,
                            image: AssetImage("assets/images/pattern.png"),

                            // CachedNetworkImageProvider(
                            //     profileData!.coverPic ?? ""),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 70.h,
                        right: Get.locale?.languageCode == 'ar' ||
                                Get.locale?.languageCode == "he"
                            ? null
                            : 20.w,
                        left: Get.locale?.languageCode == 'ar' ||
                                Get.locale?.languageCode == "he"
                            ? 20.w
                            : null,
                        child: SizedBox(),
                        // editYourProfile button removed
                      ),
                      Positioned(
                        bottom: 0.h,
                        left: Get.locale?.languageCode == 'ar' ||
                                Get.locale?.languageCode == "he"
                            ? null
                            : 30.w,
                        right: Get.locale?.languageCode == 'ar' ||
                                Get.locale?.languageCode == "he"
                            ? 30.w
                            : null,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    FullScreenImageView(imageUrl: profileImage),
                              ),
                            );
                          },
                          child: SizedBox(
                            width: 120.w,
                            height: 120.h,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundColor: ColorsData.secondary,
                                  child: CircleAvatar(
                                    radius: 55,
                                    foregroundImage: CachedNetworkImageProvider(
                                        profileImage),
                                    backgroundColor: ColorsData.secondary,
                                  ),
                                ),
                                Positioned(
                                  right: 9,
                                  bottom: 0,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        showChangeYourPictureDialog(context);
                                      },
                                      borderRadius: BorderRadius.circular(45),
                                      child: Container(
                                        width: 50.17.w,
                                        height: 50.17.h,
                                        decoration: const BoxDecoration(
                                          color: ColorsData.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: SvgPicture.asset(
                                            AssetsData.addImageIcon,
                                            fit: BoxFit.fill,
                                            width: 25.w,
                                            height: 25.h,
                                            colorFilter: const ColorFilter.mode(
                                              ColorsData.font,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // if (widget.isBack)
                      Positioned(
                        top: 40.h,
                        left: Get.locale?.languageCode == 'ar' ||
                                Get.locale?.languageCode == "he"
                            ? null
                            : 16.w,
                        right: Get.locale?.languageCode == 'ar' ||
                                Get.locale?.languageCode == "he"
                            ? 16.w
                            : null,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: ColorsData.font.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: ColorsData.secondary,
                              size: 20.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 5.h, left: 16.w, right: 16.w),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    fullName,
                                    style: Styles.textStyleS16W700(),
                                  ),
                                  SizedBox(width: 8.w),
                                  GestureDetector(
                                    onTap: () {
                                      showChangeUserInfoBottomSheet(
                                        context,
                                        profileController,
                                      );
                                    },
                                    child: Icon(
                                      Icons.edit,
                                      size: 26.sp,
                                      color: ColorsData.primary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    AssetsData.mapPinIcon,
                                    height: 16.h,
                                    width: 16.w,
                                    colorFilter: const ColorFilter.mode(
                                        ColorsData.primary, BlendMode.srcIn),
                                  ),
                                  SizedBox(width: 5.w),
                                  Flexible(
                                    child: Text(
                                      city,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Styles.textStyleS14W400(),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                '\u200E${phoneNumber.replaceFirst('+972', '+972  ')}', // ← مسافتين هنا
                                style: Styles.textStyleS20W400(
                                  color: ColorsData.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                        buildDrawerItem("resetPassword".tr,
                            AssetsData.resetPasswordBottomSheetIcon, () {
                          Get.toNamed(
                            AppRouter.resetPasswordPath,
                            arguments: {
                              "phoneNumber": profileController
                                      .profileData.value?.phoneNumber ??
                                  phoneNumber,
                              "otp": '123456',
                            },
                          );
                        }),
                        buildDivider(),
                        buildDrawerItem(
                            "changeLanguage".tr, AssetsData.changeLanguagesIcon,
                            () {
                          Get.toNamed(AppRouter.changeLangugesPath);
                        }),
                        buildDivider(),
                        // changePhoneNumber removed

                        buildDrawerItem(
                            "changeYourLocation".tr, AssetsData.mapPinIcon,
                            () async {
                          await LocationHelper.requestLocationPermission(
                              context);
                          showChangeUserLocationBottomSheet(
                              context, profileController);
                        }),
                        buildDivider(),
                        buildDrawerItem(
                          "Settings".tr,
                          AssetsData.settingIcon,
                          () {
                            Get.toNamed(AppRouter.settingsPath);
                          },
                        ),
                        buildDivider(),
                        _buildDrawerItem("Terms and Conditions".tr,
                            Icons.integration_instructions_outlined, () {
                          Get.toNamed(AppRouter.termsPath);
                        }),
                        buildDivider(),
                        _buildDrawerItem(
                            "privacyPolicy".tr, Icons.policy_outlined, () {
                          Get.toNamed(AppRouter.privacyPolicyPath);
                        }),
                        buildDivider(),
                        buildDrawerItem(
                          "contact_qcut".tr,
                          AssetsData.callIcon,
                          () {
                            Get.toNamed(AppRouter.chatWithUsPath);
                          },
                        ),
                        buildDivider(),
                        buildDrawerItem("logout".tr, AssetsData.logOutIcon, () {
                          showLogoutDialog(context);
                        }),
                        SizedBox(height: 150.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  bool isClicked = true;

  Widget buildDrawerItem(String title, String imagePath, VoidCallback? onTap) {
    return InkWell(
      onTap: () async {
        if (isClicked) {
          isClicked = false;
          setState(() {});
          onTap!();
          await Future.delayed(const Duration(seconds: 2), () {
            isClicked = true;
            setState(() {});
          });
        }
      },
      child: Padding(
        padding: EdgeInsets.only(top: 5.h, bottom: 5.h),
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
                    ColorsData.primary,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(title, style: Styles.textStyleS14W500()),
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
    );
  }

  Widget buildDivider() {
    return Divider(color: ColorsData.cardStrock.withOpacity(0.3));
  }

  _buildDrawerItem(
      String tr, IconData integrationInstructions, Null Function() param2) {
    bool isClicked = true;
    return InkWell(
      onTap: () async {
        if (isClicked) {
          isClicked = false;
          setState(() {});
          param2();
          await Future.delayed(const Duration(seconds: 2), () {
            isClicked = true;
            setState(() {});
          });
        }
      },
      child: Padding(
        padding: EdgeInsets.only(top: 5.h, bottom: 5.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  integrationInstructions,
                  size: 24.sp,
                  color: ColorsData.primary,
                ),
                SizedBox(width: 12.w),
                Text(tr, style: Styles.textStyleS14W500()),
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
    );
  }
}

class FullScreenImageView extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: PhotoView(
              imageProvider: NetworkImage(imageUrl),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

class LocationHelper {
  /// يسألك عن إذن تحديد الموقع
  static Future<void> requestLocationPermission(BuildContext context) async {
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      // لو وافق "بينما تستخدم التطبيق" → يجيب الموقع عادي
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print("User location: ${position.latitude}, ${position.longitude}");
    } else if (status.isDenied) {
      // لو اختار "Don't allow" → تظهر رسالة فوق
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permissions are denied")),
      );
    } else if (status.isPermanentlyDenied) {
      // لو اختار "Don't ask again" → افتح إعدادات التطبيق
      openAppSettings();
    }
  }
}
