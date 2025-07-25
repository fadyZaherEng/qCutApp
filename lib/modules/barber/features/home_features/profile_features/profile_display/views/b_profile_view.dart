import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_big_button.dart';
import 'package:q_cut/modules/barber/features/home_features/statistics_feature/views/widgets/choose_break_days_bottom_sheet.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/logic/b_profile_controller.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/models/barber_service_model.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/views/widgets/custom_add_new_service_bottom_sheet.dart';
import 'package:q_cut/modules/barber/features/home_features/statistics_feature/views/widgets/custom_edit_new_service_bottom_sheet.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/views/widgets/show_change_your_picture_dialog.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/views/widgets/show_working_days_bottom_sheet.dart';

import '../../models/barber_profile_model.dart';

class BProfileView extends StatefulWidget {
  const BProfileView({super.key});

  @override
  State<BProfileView> createState() => _BProfileViewBodyState();
}

class _BProfileViewBodyState extends State<BProfileView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Remove the tag since it can cause issues with controller finding
  final BProfileController controller = Get.put(BProfileController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    controller.tabController = _tabController;
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        controller.fetchGallery();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: SpinKitDoubleBounce(color: ColorsData.primary),
        );
      }

      if (controller.isError.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Failed to load profile'.tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: controller.fetchProfileData,
                child: Text('Retry'.tr),
              ),
            ],
          ),
        );
      }

      final profileData = controller.profileData.value;
      if (profileData == null) {
        return Center(
          child: Text('No profile data available'.tr,
              style: TextStyle(color: Colors.white)),
        );
      }

      // Handle empty data fields with defaults or placeholders
      final barberShop = profileData.barberShop.isNotEmpty
          ? profileData.barberShop
          : 'My Barber Shop'.tr;

      final city =
          profileData.city.isNotEmpty ? profileData.city : 'Not set'.tr;

      final instagramPage = profileData.instagramPage.isNotEmpty
          ? profileData.instagramPage
          : 'Not set'.tr;

      final fullName =
          profileData.fullName.isNotEmpty ? profileData.fullName : 'Your Name';

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
                        image: CachedNetworkImageProvider(
                          profileData.coverPic,
                          errorListener: (exception) =>
                              print('Error loading image: $exception'),
                        ),
                      ),
                    ),
                    child: profileData.coverPic.isNotEmpty
                        ? Image.network(
                            profileData.coverPic,
                            fit: BoxFit.fill,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: ColorsData.secondary,
                                child: Center(
                                  child: Text(
                                    "Add Cover Photo".tr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.sp,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: ColorsData.secondary,
                            child: Center(
                              child: Text(
                                "Add Cover Photo".tr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                ),
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 20.h,
                    right: 20.w,
                    child: GestureDetector(
                      onTap: () {
                        showChooseBreakDaysBottomSheet(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: ColorsData.primary),
                          borderRadius: BorderRadius.circular(10.r),
                          color: ColorsData.font,
                        ),
                        width: 104.w,
                        height: 36.h,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AssetsData.takeBreakIcon,
                              height: 18.h,
                              width: 18.w,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              "Take break".tr,
                              style:
                                  Styles.textStyleS14W500(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 200.98.h,
                    left: 47.39.w,
                    child: InkWell(
                      onTap: () {
                        showChangeYourPictureDialog(context).then((value) {
                          controller.fetchProfileData();
                        });
                      },
                      child: SizedBox(
                        width: 120.w,
                        height: 127.08.h,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: ColorsData.secondary,
                          child: CircleAvatar(
                            radius: 55,
                            backgroundImage:
                                NetworkImage(profileData.profilePic),
                            backgroundColor: ColorsData.secondary,
                            onBackgroundImageError: (exception, stackTrace) {
                              print('Error loading profile image: $exception');
                              return; // This will display the child widget
                            },
                            child: profileData.profilePic.isEmpty
                                ? Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 110.w,
                    bottom: -20.h,
                    child: InkWell(
                      onTap: () {
                        showChangeYourPictureDialog(context);
                      },
                      child: MaterialButton(
                        height: 36.16748046875.h,
                        minWidth: 36.16748046875.w,
                        padding: EdgeInsets.zero,
                        shape: const CircleBorder(),
                        onPressed: () {
                          showChangeYourPictureDialog(context);
                        },
                        child: CircleAvatar(
                          radius: 18.08.r,
                          backgroundColor: ColorsData.primary,
                          child: SvgPicture.asset(
                            height: 20.h,
                            width: 20.w,
                            AssetsData.addImageIcon,
                            colorFilter: const ColorFilter.mode(
                              ColorsData.font,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 68.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          barberShop,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: ColorsData.primary),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        width: 80.w,
                        height: 30.h,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "NO. 1".tr,
                              style: Styles.textStyleS13W400(
                                  color: ColorsData.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Divider(
                    color: ColorsData.cardStrock,
                    thickness: 1.w,
                  ),
                  SizedBox(height: 8.h),
                  _buildInfoRow(AssetsData.personIcon, fullName),
                  SizedBox(height: 8.h),
                  _buildInfoRow(AssetsData.mapPinIcon, city),
                  SizedBox(height: 8.h),
                  _buildInfoRow(
                      AssetsData.callIcon, "\u200E${profileData.phoneNumber}"),
                  SizedBox(height: 8.h),
                  _buildInfoRow(AssetsData.instagramIcon, instagramPage),
                  SizedBox(height: 16.h),
                  CustomBigButton(
                    color: const Color(0xA6C59D4E),
                    textData: "workingDays".tr,
                    onPressed: () {
                      showBWorkingDaysBottomSheet(
                          context, profileData.workingDays);
                    },
                  ),
                  SizedBox(height: 12.h),
                  CustomBigButton(
                    textData: "Edit Profile".tr,
                    onPressed: () async {
                      final result = await Get.toNamed(
                        AppRouter.beditProfilePath,
                        arguments: BarberProfileModel(
                          fullName: profileData.fullName,
                          offDay: profileData.offDay,
                          barberShop: profileData.barberShop,
                          bankAccountNumber: profileData.bankAccountNumber,
                          instagramPage: profileData.instagramPage,
                          profilePic: profileData.profilePic,
                          coverPic: profileData.coverPic,
                          city: profileData.city,
                          workingDays: profileData.workingDays,
                        ),
                      );

                      if (result == true) {
                        // Profile was updated, refresh the data
                        controller.fetchProfileData();
                      }
                    },
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTabButton(
                          "My service".tr, _tabController.index == 0),
                      _buildTabButton(
                          "My gallery".tr, _tabController.index == 1),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    // Use a fixed height that's tall enough to show content
                    height: 400.h,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Services Tab
                        _buildServicesTab(),

                        // Gallery Tab
                        _buildGalleryTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // New method to build services tab with API data
  Widget _buildServicesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${"services".tr} (${controller.totalServices})",
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 16.h),
        Obx(() {
          if (controller.isServicesLoading.value) {
            return const Center(
              child: SpinKitDoubleBounce(color: ColorsData.primary),
            );
          }

          if (controller.barberServices.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50.h),
                Text(
                  'No services available'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: controller.fetchBarberServices,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsData.primary,
                  ),
                  child: Text('Refresh'.tr),
                ),
                SizedBox(height: 16.h),
                CustomBigButton(
                  textData: "Add new service".tr,
                  onPressed: () {
                    showCustomAddNewServiceBottomSheet(context);
                  },
                ),
              ],
            );
          }

          // When there are services, show them in a scrollable list
          return Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: controller.barberServices.length,
                    separatorBuilder: (context, index) => SizedBox(height: 8.h),
                    itemBuilder: (context, index) {
                      final service = controller.barberServices[index];
                      return _buildServiceItemFromData(service);
                    },
                  ),
                ),
                // Add the button at the bottom, outside the ListView
                Padding(
                  padding: EdgeInsets.only(top: 16.h),
                  child: CustomBigButton(
                    textData: "Add new service".tr,
                    onPressed: () {
                      showCustomAddNewServiceBottomSheet(context);
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildServiceItemFromData(BarberService service) {
    String durationText;
    if (service.duration != null) {
      if (service.duration! > 60000) {
        durationText = "${(service.duration! / 60000).round()} min";
      } else {
        durationText = "${service.duration} min";
      }
    } else {
      int avgTime = ((service.minTime + service.maxTime) / 2).round();
      if (avgTime > 60000) {
        durationText = "${(avgTime / 60000).round()} min";
      } else {
        durationText = "$avgTime min";
      }
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF494B5B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22.r),
              child: CachedNetworkImage(
                imageUrl: service.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Image.asset(AssetsData.goldScissorImage),
                errorWidget: (context, url, error) =>
                    Image.asset(AssetsData.goldScissorImage),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              service.name,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "\$${service.price}",
                style: Styles.textStyleS16W500(
                  color: ColorsData.bodyFont,
                ),
              ),
              Text(
                durationText,
                style: Styles.textStyleS10W400(
                  color: ColorsData.bodyFont,
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          ElevatedButton(
            onPressed: () {
              showCustomEditNewServiceBottomSheet(
                context,
                serviceId: service.id,
                serviceName: service.name,
                servicePrice: service.price.toString(),
                serviceTime: service.duration?.toString() ??
                    ((service.minTime + service.maxTime) / 2)
                        .round()
                        .toString(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB08B4F),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              minimumSize: Size.zero,
            ),
            child: Text(
              "Edit".tr,
              style: TextStyle(fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String svgIconPath, String text) {
    return Row(
      children: [
        SvgPicture.asset(
          height: 18.h,
          width: 18.w,
          svgIconPath,
          colorFilter: const ColorFilter.mode(
            ColorsData.primary,
            BlendMode.srcIn,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String text, bool isActive) {
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(text == "My service".tr ? 0 : 1);
      },
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16.sp,
              color: isActive ? ColorsData.primary : Colors.white,
            ),
          ),
          if (isActive)
            Container(
              height: 2,
              width: 60.w,
              color: ColorsData.primary,
              margin: EdgeInsets.only(top: 4.h),
            ),
        ],
      ),
    );
  }

  Widget _buildGalleryTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() => Text(
                  "${"Gallery".tr} (${controller.galleryPhotos.length})",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                )),
            Container(
              height: 28.h,
              decoration: BoxDecoration(
                border: Border.all(color: ColorsData.primary, width: 1.w),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Obx(() => TextButton.icon(
                    onPressed: controller.isUploadingPhotos.value
                        ? null
                        : controller.addPhotosToGallery,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.all(2.w),
                    ),
                    icon: controller.isUploadingPhotos.value
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  ColorsData.primary),
                            ),
                          )
                        : SvgPicture.asset(
                            AssetsData.addImageIcon,
                            height: 20.h,
                            width: 20.w,
                            colorFilter: const ColorFilter.mode(
                              ColorsData.cardStrock,
                              BlendMode.srcIn,
                            ),
                          ),
                    label: Text(
                      controller.isUploadingPhotos.value
                          ? "Uploading...".tr
                          : "add photos".tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                      ),
                    ),
                  )),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Expanded(
          child: Obx(() {
            if (controller.isGalleryLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: ColorsData.primary),
              );
            }

            if (controller.galleryPhotos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No photos available'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton.icon(
                      icon: Icon(Icons.add_photo_alternate),
                      label: Text('Add Photos'.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsData.primary,
                      ),
                      onPressed: controller.addPhotosToGallery,
                    ),
                  ],
                ),
              );
            }

            // When there are photos, show them in a grid
            return RefreshIndicator(
              onRefresh: controller.fetchGallery,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                ),
                itemCount: controller.galleryPhotos.length,
                itemBuilder: (context, index) {
                  final photo = controller.galleryPhotos[index];
                  return GestureDetector(
                    onTap: () {
                      Get.toNamed(
                        AppRouter.imageViewPath,
                        arguments: photo,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        color: ColorsData.secondary,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: CachedNetworkImage(
                          imageUrl: photo,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: ColorsData.primary,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              color: ColorsData.secondary,
                            ),
                            child: const Icon(
                              Icons.error,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}
