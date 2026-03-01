import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_big_button.dart';
import 'package:q_cut/modules/barber/features/home_features/appointment_feature/models/appointment_model.dart';
import 'package:q_cut/modules/barber/features/home_features/appointment_feature/views/custom_b_drawer.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/models/barber_profile_model.dart';
import 'package:q_cut/modules/barber/features/home_features/statistics_feature/views/widgets/choose_break_days_bottom_sheet.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/logic/b_profile_controller.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/models/barber_service_model.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/views/widgets/custom_add_new_service_bottom_sheet.dart';
import 'package:q_cut/modules/barber/features/home_features/statistics_feature/views/widgets/custom_edit_new_service_bottom_sheet.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/views/widgets/show_change_your_picture_dialog.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/views/widgets/show_working_days_bottom_sheet.dart';
import 'package:q_cut/modules/customer/features/home_features/profile_feature/views/my_profile_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:table_calendar/table_calendar.dart';

class BProfileView extends StatefulWidget {
  const BProfileView({super.key});

  @override
  State<BProfileView> createState() => _BProfileViewBodyState();
}

class _BProfileViewBodyState extends State<BProfileView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
    return Obx(
      () {
        if (controller.isLoading.value) {
          return const Center(
            child: SpinKitDoubleBounce(
              color: ColorsData.primary,
            ),
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
            child: Text(
              'No profile data available'.tr,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          );
        }

        // Handle empty data fields with defaults or placeholders
        final barberShop = profileData.barberShop.isNotEmpty
            ? profileData.barberShop
            : 'My Barber Shop'.tr;

        final location = BarberLocation(
          type: profileData.barberShopLocation.type,
          coordinates: profileData.barberShopLocation.coordinates,
        );
        final city =
            profileData.city.isNotEmpty ? profileData.city : 'Not set'.tr;

        final instagramPage = profileData.instagramPage.isNotEmpty
            ? profileData.instagramPage
            : 'Not set'.tr;

        final fullName = profileData.fullName.isNotEmpty
            ? profileData.fullName
            : 'your_name'.tr;

        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchProfileData();
            if (_tabController.index == 1) {
              await controller.fetchGallery();
            }
          },
          child: Scaffold(
            key: _scaffoldKey,
            drawer: const CustomBDrawer(),
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 300.h,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // ... existing Header content ...
                        Container(
                          width: double.infinity,
                          height: 250.h,
                          decoration: const BoxDecoration(
                            color: ColorsData.secondary,
                          ),
                          child: profileData.coverPic.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: profileData.coverPic,
                                  fit: BoxFit.fill,
                                  placeholder: (context, url) => const Center(
                                    child: SpinKitDoubleBounce(
                                      color: ColorsData.primary,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Center(
                                    child: Text(
                                      "Add Cover Photo".tr,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    "Add Cover Photo".tr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.sp,
                                    ),
                                  ),
                                ),
                        ),
                        Positioned(
                          bottom: 24.h,
                          right: 20.w,
                          child: GestureDetector(
                            onTap: () =>
                                showChooseBreakDaysBottomSheet(context),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: ColorsData.primary),
                                borderRadius: BorderRadius.circular(10.r),
                                color: ColorsData.font,
                              ),
                              width: 90.w,
                              height: 32.h,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    AssetsData.takeBreakIcon,
                                    height: 14.h,
                                    width: 14.w,
                                  ),
                                  Text(
                                    "Take break".tr,
                                    style: Styles.textStyleS13W400(
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 173.98.h,
                          left: 47.39.w,
                          child: InkWell(
                            onTap: () {
                              if (profileData.profilePic.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FullScreenImageView(
                                      imageUrl: profileData.profilePic,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: SizedBox(
                              width: 120.w,
                              height: 127.08.h,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: ColorsData.secondary,
                                child: ClipOval(
                                  child: profileData.profilePic.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: profileData.profilePic,
                                          width: 110,
                                          height: 110,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const SpinKitDoubleBounce(
                                            color: ColorsData.primary,
                                            size: 20,
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.white,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 110.w,
                          bottom: 3.h,
                          child: InkWell(
                            onTap: () => showChangeYourPictureDialog(context),
                            child: MaterialButton(
                              height: 36.16748046875.h,
                              minWidth: 36.16748046875.w,
                              padding: EdgeInsets.zero,
                              shape: const CircleBorder(),
                              onPressed: () =>
                                  showChangeYourPictureDialog(context),
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
                        Positioned(
                          top: 10.h,
                          left: Get.locale?.languageCode == "ar" ? 20.w : null,
                          right: Get.locale?.languageCode == "ar" ? null : 20.w,
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    _scaffoldKey.currentState?.openDrawer(),
                                child: SvgPicture.asset(
                                  AssetsData.menuIcon,
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
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
                                    profileData.hashtag != null
                                        ? "#${profileData.hashtag}"
                                        : "NO. 1".tr,
                                    style: Styles.textStyleS13W400(
                                      color: ColorsData.primary,
                                    ),
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
                        _buildInfoRow(
                          AssetsData.personIcon,
                          Icons.person,
                          fullName,
                          location,
                        ),
                        SizedBox(height: 8.h),
                        InkWell(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) {
                            //       return MapSearchScreen(
                            //         initialLatitude: profileData
                            //                 .barberShopLocation
                            //                 .coordinates
                            //                 .isNotEmpty
                            //             ? profileData
                            //                 .barberShopLocation.coordinates[1]
                            //             : 31.0461,
                            //         initialLongitude: profileData
                            //                 .barberShopLocation
                            //                 .coordinates
                            //                 .isNotEmpty
                            //             ? profileData
                            //                 .barberShopLocation.coordinates[0]
                            //             : 34.8516,
                            //         onLocationSelected: (lat, lng, address) {
                            //           setState(() {});
                            //         },
                            //       );
                            //     },
                            //   ),
                            // );
                          },
                          child: _buildInfoRow(
                            AssetsData.mapPinIcon,
                            Icons.location_on,
                            city,
                            location,
                            isAddress: false,
                          ),
                        ),
                        if (profileData.locationDescription.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          _buildInfoRow(
                            AssetsData.mapPinIcon,
                            Icons.description,
                            profileData.locationDescription,
                            location,
                            isAddress: false,
                          ),
                        ],
                        SizedBox(height: 8.h),
                        InkWell(
                          onTap: () {
                            launchPhoneDialer(profileData.phoneNumber);
                          },
                          child: _buildInfoRow(
                            AssetsData.callIcon,
                            Icons.call,
                            "\u200E${profileData.phoneNumber.replaceFirst('+972', '+972  ')}",
                            location,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        // InkWell(
                        //   onTap: () {
                        //     try {
                        //       launch(profileData.instagramPage);
                        //     } catch (e) {
                        //       print('Could not launch Instagram: $e');
                        //     }
                        //   },
                        //   child: _buildInfoRow(
                        //     AssetsData.instagramIcon,
                        //     instagramPage,
                        //     location,
                        //   ),
                        // ),
                        SizedBox(height: 16.h),
                        CustomBigButton(
                          color: const Color(0xA6C59D4E),
                          textData: "workingDays".tr,
                          onPressed: () {
                            showBWorkingDaysBottomSheet(
                              context,
                              profileData.workingDays,
                            );
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
                                bankAccountNumber:
                                    profileData.bankAccountNumber,
                                instagramPage: profileData.instagramPage,
                                profilePic: profileData.profilePic,
                                coverPic: profileData.coverPic,
                                city: profileData.city,
                                workingDays: profileData.workingDays,
                                barberShopLocation:
                                    profileData.barberShopLocation,
                                phoneNumber: profileData.phoneNumber,
                                locationDescription:
                                    profileData.locationDescription,
                              ),
                            );

                            if (result == true) {
                              controller.fetchProfileData();
                            }
                          },
                        ),
                        SizedBox(height: 12.h),
                        CustomBigButton(
                          color: Color(0xA6C59D4E),
                          textData: LocalizationService.getCurrentLocale() ==
                                  const Locale('ar')
                              ? "المواعيد بدون حجز"
                              : "Walk-In".tr,
                          onPressed: () {
                            _showWalkInCalendar(context, controller);
                          },
                        ),
                        SizedBox(height: 24.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildTabButton(
                              "My service".tr,
                              _tabController.index == 0,
                            ),
                            _buildTabButton(
                              "My gallery".tr,
                              _tabController.index == 1,
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: SizedBox(
                      height: 500.h, // Fixed height to prevent overflow
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildServicesTab(),
                          _buildGalleryTab(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // New method to build services tab with API data
  Widget _buildServicesTab() {
    bool isClicked = true;
    return SingleChildScrollView(
      child: Column(
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
                    onPressed: () {
                      if (isClicked) {
                        isClicked = false;
                        setState(() {});
                        controller.fetchBarberServices();
                        Future.delayed(const Duration(seconds: 2), () {
                          isClicked = true;
                          setState(() {});
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsData.primary,
                    ),
                    child: Text('Refresh'.tr),
                  ),
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.only(bottom: 24.h), // يرفع الزرار لفوق
                    child: CustomBigButton(
                      textData: "Add new service".tr,
                      onPressed: () {
                        showCustomAddNewServiceBottomSheet(context);
                      },
                    ),
                  ),
                ],
              );
            }

            // When there are services, show them in a scrollable list
            return Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.barberServices.length,
                  padding: EdgeInsets.zero,
                  separatorBuilder: (context, index) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final service = controller.barberServices[index];
                    return _buildServiceItemFromData(service);
                  },
                ),
                SizedBox(height: 16.h),
                CustomBigButton(
                  textData: "Add new service".tr,
                  onPressed: () {
                    showCustomAddNewServiceBottomSheet(context);
                  },
                ),
                const SizedBox(height: 58),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildServiceItemFromData(BarberService service) {
    print(
        "Service duration: ${service.duration}, minTime: ${service.minTime}, maxTime: ${service.maxTime}");
    bool isClicked = true;
    String durationText;
    // if (service.duration != null) {
    //   // if (service.duration! > 60000) {
    //   //   durationText = "${(service.duration! / 60000).round()} min";
    //   // } else {
    //     durationText = "${service.duration} min";
    //   // }
    // } else {
    // if (service.minTime > 60000) {
    durationText = "${(service.minTime / 60000).round()} min";
    // } else {
    //   durationText = "${service.minTime} min";
    // }
    // }

    return Container(
      padding: EdgeInsets.all(12.w),
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
            onPressed: () async {
              if (isClicked) {
                isClicked = false;
                setState(() {});
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
                await Future.delayed(const Duration(seconds: 2), () {
                  isClicked = true;
                  setState(() {});
                });
              }
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
          SizedBox(width: 8.w),
          IconButton(
            onPressed: () {
              Get.generalDialog(
                barrierDismissible: true,
                barrierLabel: '',
                barrierColor: Colors.black54,
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (context, animation1, animation2) {
                  return AlertDialog(
                    title: Text("Delete Service".tr,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        )),
                    content:
                        Text("Are you sure you want to delete this service?".tr,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                            )),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text("Cancel".tr,
                            style: TextStyle(
                              color: ColorsData.primary,
                              fontSize: 15,
                            )),
                      ),
                      TextButton(
                        onPressed: () async {
                          Get.back();
                          await controller.deleteBarberService(service.id);
                        },
                        child: Text("Delete".tr,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 15,
                            )),
                      ),
                    ],
                  );
                },
                transitionBuilder: (context, a1, a2, child) {
                  return ScaleTransition(
                    scale: CurvedAnimation(
                      parent: a1,
                      curve: Curves.easeOutBack,
                    ),
                    child: FadeTransition(
                      opacity: a1,
                      child: child,
                    ),
                  );
                },
              );
            },
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red[300],
              size: 20.sp,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String svgIconPath,
    IconData? iconData,
    String text,
    BarberLocation location, {
    bool isAddress = false,
  }) {
    return Row(
      children: [
        if (iconData != null)
          Icon(
            iconData,
            size: 18.sp,
            color: ColorsData.primary,
          )
        else
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
        if (!isAddress)
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
        if (isAddress)
          FutureBuilder(
            future: location.getAddress(Get.locale?.languageCode ?? "en"),
            builder: (context, loc) {
              return Expanded(
                child: Text(
                  loc.data ?? text,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
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
    return SingleChildScrollView(
      child: Column(
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
                          : () async {
                              controller.addPhotosToGallery();
                            },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.all(2.w),
                      ),
                      icon: controller.isUploadingPhotos.value
                          ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: const SpinKitDoubleBounce(
                                color: ColorsData.primary,
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
          Obx(
            () {
              if (controller.isGalleryLoading.value) {
                return const Center(
                  child: SpinKitDoubleBounce(color: ColorsData.primary),
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
                        icon: const Icon(Icons.add_photo_alternate),
                        label: Text('Add Photos'.tr),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsData.primary,
                        ),
                        onPressed: () async => controller.addPhotosToGallery(),
                      ),
                    ],
                  ),
                );
              }

              // When there are photos, show them in a grid
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
                          fit: BoxFit.fill,
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
              );
            },
          ),
        ],
      ),
    );
  }

  void launchPhoneDialer(String phoneNumber) {
    try {
      launch("tel:$phoneNumber");
    } catch (e) {
      print('Could not launch phone dialer: $e');
    }
  }

  void _showWalkInCalendar(
    BuildContext context,
    BProfileController controller,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(
            opacity: anim1,
            child: _buildWalkInDialog(context, controller),
          ),
        );
      },
    );
  }

  Widget _buildWalkInDialog(
      BuildContext context, BProfileController controller) {
    // Range selection state

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime? initialStart;
    DateTime? initialEnd;

    if (controller.profileData.value?.walkIn != null &&
        controller.profileData.value!.walkIn!.isNotEmpty) {
      final firstRecord = controller.profileData.value!.walkIn!.first;
      initialStart = DateTime.fromMillisecondsSinceEpoch(firstRecord.startDate);
      initialEnd = DateTime.fromMillisecondsSinceEpoch(firstRecord.endDate);
    }

    final Rx<DateTime?> rangeStart = Rx<DateTime?>(initialStart);
    final Rx<DateTime?> rangeEnd = Rx<DateTime?>(initialEnd);
    final Rx<DateTime> focusedDay = (initialStart ?? today).obs;
    final Rx<RangeSelectionMode> rangeSelectionMode =
        RangeSelectionMode.toggledOn.obs;

    DateTime firstAllowedDay = today;
    if (initialStart != null) {
      final startDay =
          DateTime(initialStart.year, initialStart.month, initialStart.day);
      if (startDay.isBefore(today)) {
        firstAllowedDay = startDay;
      }
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            )
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
                decoration: BoxDecoration(
                  color: ColorsData.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                    bottomLeft: Radius.circular(24.r),
                    bottomRight: Radius.circular(24.r),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.date_range,
                      color: ColorsData.primary,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "set_walkIn_range".tr,
                      style: Styles.textStyleS18W700(
                        color: ColorsData.primary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.grey),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.all(16.w),
                child: Obx(
                  () => TableCalendar(
                    firstDay: firstAllowedDay,
                    lastDay: today.add(const Duration(days: 365 * 2)),
                    // 2 years flexibility
                    focusedDay: focusedDay.value,
                    rangeStartDay: rangeStart.value,
                    rangeEndDay: rangeEnd.value,
                    rangeSelectionMode: rangeSelectionMode.value,
                    onRangeSelected: (start, end, focused) {
                      focusedDay.value = focused;
                      rangeStart.value = start;
                      rangeEnd.value = end;
                    },
                    onPageChanged: (focused) {
                      focusedDay.value = focused;
                    },
                    calendarStyle: CalendarStyle(
                      // Text styles for day numbers (User requested black)
                      defaultTextStyle:
                          TextStyle(color: Colors.black, fontSize: 14.sp),
                      weekendTextStyle:
                          TextStyle(color: Colors.black, fontSize: 14.sp),
                      outsideTextStyle:
                          TextStyle(color: Colors.grey, fontSize: 12.sp),

                      isTodayHighlighted: true,
                      todayDecoration: BoxDecoration(
                        color: ColorsData.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: TextStyle(
                          color: ColorsData.primary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold),

                      rangeStartDecoration: const BoxDecoration(
                        color: ColorsData.primary,
                        shape: BoxShape.circle,
                      ),
                      rangeEndDecoration: const BoxDecoration(
                        color: ColorsData.primary,
                        shape: BoxShape.circle,
                      ),
                      rangeHighlightColor: ColorsData.primary.withOpacity(0.15),
                      withinRangeTextStyle: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),

                      outsideDaysVisible: false,
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle:
                          Styles.textStyleS16W700(color: Colors.black),
                      leftChevronIcon: const Icon(Icons.chevron_left,
                          color: ColorsData.primary),
                      rightChevronIcon: const Icon(Icons.chevron_right,
                          color: ColorsData.primary),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: Styles.textStyleS12W600(color: Colors.grey),
                      weekendStyle:
                          Styles.textStyleS12W600(color: Colors.grey.shade400),
                    ),
                  ),
                ),
              ),

              // Footer Info
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Obx(() {
                  Widget content;
                  if (rangeStart.value == null) {
                    content = Text(
                      "tap_start_end_date".tr,
                      key: const ValueKey("empty_state"),
                      style: Styles.textStyleS12W400(color: Colors.grey),
                    );
                  } else {
                    final start =
                        DateFormat('MMM dd, yyyy', Get.locale?.languageCode)
                            .format(rangeStart.value!);
                    final end = rangeEnd.value != null
                        ? DateFormat('MMM dd, yyyy', Get.locale?.languageCode)
                            .format(rangeEnd.value!)
                        : "...";
                    content = Container(
                      key: const ValueKey("selected_state"),
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 18.sp, color: ColorsData.primary),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              rangeEnd.value != null
                                  ? "$start - $end"
                                  : "${"From:".tr} $start",
                              style:
                                  Styles.textStyleS14W600(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.2),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: content,
                  );
                }),
              ),

              SizedBox(height: 24.h),

              // Action Buttons
              Padding(
                padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 24.h),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text("cancel".tr,
                            style: Styles.textStyleS14W600(color: Colors.grey)),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: rangeStart.value == null
                              ? null
                              : () async {
                                  final success =
                                      await controller.updateWalkInRanges([
                                    {
                                      "start": rangeStart.value!,
                                      "end":
                                          rangeEnd.value ?? rangeStart.value!,
                                    }
                                  ]);
                                  if (success && context.mounted) {
                                    Navigator.pop(context);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsData.primary,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "update_range".tr,
                            style: Styles.textStyleS14W700(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LocalizationService {
  static Locale getCurrentLocale() {
    return Get.locale ?? const Locale('en');
  }
}
