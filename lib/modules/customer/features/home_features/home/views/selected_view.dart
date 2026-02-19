import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_big_button.dart';
import 'package:q_cut/core/utils/widgets/custom_button.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/views/widgets/show_how_many_consumer_bottom_sheet.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/views/widgets/show_working_days_bottom_sheet.dart';
import 'package:q_cut/modules/barber/map_search/map_search_screen.dart';
import 'package:q_cut/modules/customer/features/home_features/home/controllers/gallery_controller.dart';
import 'package:q_cut/modules/customer/features/home_features/home/models/barber_model.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:q_cut/modules/customer/features/home_features/home/models/working_hours_range_model.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
// Added for firstWhereOrNull if needed, but Get has it too. Actually WorkingHoursRangeResponse is imported.

class SelectedView extends StatefulWidget {
  const SelectedView({super.key});

  @override
  State<SelectedView> createState() => _SelectedViewState();
}

class _SelectedViewState extends State<SelectedView> {
  // Add a reactive boolean variable to track favorite status
  final RxBool isFavorite = false.obs;
  late Barber barber;
  final GalleryController galleryController = Get.put(GalleryController());
  bool isClicked = true;
  final RxList<WalkInRecord> walkInRanges = <WalkInRecord>[].obs;
  final RxList<WorkingHourDay> workingHoursRange = <WorkingHourDay>[].obs;
  final RxBool isLoadingWalkIn = false.obs;

  @override
  void initState() {
    super.initState();
    // Delay the initialization to ensure Get.arguments is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      barber = Get.arguments as Barber;
      print(
          "SelectedView initialized with arguments: ${barber.locationDescription}");

      // Set the initial favorite status
      isFavorite.value = barber.isFavorite;
      // Fetch gallery when view is initialized
      galleryController.fetchGallery(barber.id);
      // Fetch walk-in data
      fetchWalkInData(barber.id);
    });
  }

  Future<void> fetchWalkInData(String barberId) async {
    try {
      isLoadingWalkIn.value = true;
      final NetworkAPICall apiCall = NetworkAPICall();
      final url = Variables.GET_WORKING_HOURS_RANGE + barberId;

      final response = await apiCall.getData(url);
      print('Walk-in data response: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          final workingHoursData = WorkingHoursRangeResponse.fromJson(decoded);
          walkInRanges.value = workingHoursData.walkIn;
          workingHoursRange.value = workingHoursData.workingHoursRange;
        } else {
          print('Unexpected response format: $decoded');
        }
      } else {
        print(
            'Failed to fetch walk-in data: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching walk-in data: $e');
    } finally {
      isLoadingWalkIn.value = false;
    }
  }

  Future<void> navigateToLocation(double lat, double lng) async {
    final String androidUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    final String iosUrl = 'https://maps.apple.com/?daddr=$lat,$lng&dirflg=d';

    final Uri uri = Uri.parse(Platform.isIOS ? iosUrl : androidUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch map for $lat, $lng';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safely get the barber object
    final args = Get.arguments;
    if (args == null || args is! Barber) {
      return const Scaffold(
          body: Center(child: SpinKitDoubleBounce(color: ColorsData.primary)));
    }

    barber = args;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display barber's cover pic if available, otherwise use default image
                    barber.coverPic != null && barber.coverPic!.isNotEmpty
                        ? InkWell(
                            onTap: () {
                              // Handle image tap to view in full screen
                              if (barber.coverPic != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GalleryFullScreenPage(
                                      images: [barber.coverPic!],
                                      initialIndex: 0,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Image.network(
                              barber.coverPic!,
                              width: double.infinity,
                              height: 200.h,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(AssetsData.selectedViewImage),
                            ),
                          )
                        : Image.asset(AssetsData.selectedViewImage),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.r),
                        topRight: Radius.circular(24.r),
                      )),
                      padding: EdgeInsets.only(
                          top: 20.h, bottom: 30.h, left: 16.w, right: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display barber shop name with fallback
                          Row(
                            children: [
                              Text(
                                barber.barberShop ?? barber.fullName,
                                style: Styles.textStyleS14W700(),
                              ),
                              SizedBox(width: 8.w),
                              Obx(() {
                                final today = DateFormat('yyyy-MM-dd')
                                    .format(DateTime.now());
                                final todayWork =
                                    workingHoursRange.firstWhereOrNull(
                                        (d) => d.formattedDate == today);
                                if (todayWork?.isWalkIn ?? false) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4.r),
                                      border: Border.all(
                                          color:
                                              Colors.orange.withOpacity(0.5)),
                                    ),
                                    child: Text(
                                      "${"Walk-In Only".tr} (${todayWork!.workingHours})",
                                      style: Styles.textStyleS10W600(
                                          color: Colors.orange.shade900),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          const Divider(),
                          SizedBox(height: 18.h),
                          // Social media and action buttons
                          Row(
                            children: [
                              // Instagram button

                              InkWell(
                                onTap: () async {
                                  final String? instaUrl = barber.instagramPage;
                                  if (instaUrl != null && instaUrl.isNotEmpty) {
                                    launch(barber.instagramPage!);
                                  } else {
                                    ShowToast.showError(
                                        message:
                                            "Instagram link is not set".tr);
                                  }
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(7.r),
                                      height: 30.h,
                                      width: 30.w,
                                      decoration: BoxDecoration(
                                        color: ColorsData.font,
                                        borderRadius:
                                            BorderRadius.circular(25.r),
                                      ),
                                      child: SvgPicture.asset(
                                        height: 16.h,
                                        width: 16.w,
                                        AssetsData.instagramIcon,
                                        colorFilter: const ColorFilter.mode(
                                          ColorsData.primary,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text("instagram".tr,
                                        style: Styles.textStyleS14W500()),
                                  ],
                                ),
                              ),

                              const Spacer(),
                              // Direction button
                              InkWell(
                                onTap: () {
                                  // Handle Direction button tap
                                  if (barber.barberShopLocation?.coordinates
                                          .isNotEmpty ??
                                      false) {
                                    debugPrint(
                                        "📍 Navigating to barber location: ${barber.barberShopLocation!.coordinates}");
                                    final coords =
                                        barber.barberShopLocation!.coordinates;
                                    navigateToLocation(coords[1], coords[0]);
                                  } else {
                                    ShowToast.showError(
                                        message: "Location not available".tr);
                                  }
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(7.r),
                                      height: 30.h,
                                      width: 30.w,
                                      decoration: BoxDecoration(
                                        color: ColorsData.font,
                                        borderRadius:
                                            BorderRadius.circular(25.r),
                                      ),
                                      child: SvgPicture.asset(
                                        height: 16.h,
                                        width: 16.w,
                                        AssetsData.directionIcon,
                                        colorFilter: const ColorFilter.mode(
                                          ColorsData.primary,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4.h,
                                    ),
                                    Text(
                                      "direction".tr,
                                      style: Styles.textStyleS14W500(),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              // Share button
                              InkWell(
                                onTap: () {
                                  // Handle Share button tap
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(7.r),
                                      height: 30.h,
                                      width: 30.w,
                                      decoration: BoxDecoration(
                                        color: ColorsData.font,
                                        borderRadius:
                                            BorderRadius.circular(25.r),
                                      ),
                                      child: SvgPicture.asset(
                                        height: 16.h,
                                        width: 16.w,
                                        AssetsData.shareIcon,
                                        colorFilter: const ColorFilter.mode(
                                          ColorsData.primary,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4.h,
                                    ),
                                    Text(
                                      "share".tr,
                                      style: Styles.textStyleS14W500(),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 18.h,
                          ),
                          // Address information
                          InkWell(
                            onTap: () {
                              // Handle city tap if needed
                              // Future.delayed to ensure the tap is registered properly
                              if (barber.barberShopLocation == null ||
                                  barber.barberShopLocation!.coordinates
                                      .isEmpty) {
                                return;
                              }
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return MapSearchScreen(
                                  initialLatitude: barber.barberShopLocation!
                                          .coordinates.isNotEmpty
                                      ? barber
                                          .barberShopLocation!.coordinates[1]
                                      : 31.0461,
                                  initialLongitude: barber.barberShopLocation!
                                          .coordinates.isNotEmpty
                                      ? barber
                                          .barberShopLocation!.coordinates[0]
                                      : 34.8516,
                                  onLocationSelected: (lat, lng, address) {
                                    setState(() {});
                                  },
                                );
                              }));
                            },
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  AssetsData.mapPinIcon,
                                  width: 18.w,
                                  height: 18.h,
                                  colorFilter: const ColorFilter.mode(
                                    ColorsData.primary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                SizedBox(
                                  width: 2.w,
                                ),
                                // Show actual address if available
                                Expanded(
                                  child: Text(
                                    barber.city,
                                    style: Styles.textStyleS14W500(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (barber.locationDescription != null &&
                              barber.locationDescription!.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.description,
                                  size: 18.sp,
                                  color: ColorsData.primary,
                                ),
                                SizedBox(width: 2.w),
                                // Show actual address if available
                                Expanded(
                                  child: Text(
                                    barber.locationDescription ?? "",
                                    style: Styles.textStyleS14W500(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            )
                          ],
                          SizedBox(height: 8.h),
                          Obx(
                            () {
                              if (walkInRanges.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...walkInRanges.map((walkIn) {
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 8.h),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 10.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ColorsData.primary
                                            .withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                        border: Border.all(
                                          color: ColorsData.primary
                                              .withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.event_busy,
                                            color: ColorsData.primary,
                                            size: 20.sp,
                                          ),
                                          SizedBox(width: 8.w),
                                          Expanded(
                                            child: Text(
                                              "${"Walk-In from".tr} ${walkIn.formattedRange}",
                                              style: Styles.textStyleS14W500(
                                                color: ColorsData.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  SizedBox(height: 4.h),
                                ],
                              );
                            },
                          ),
                          SizedBox(
                            height: 12.h,
                          ),
                          // Working days button
                          CustomButton(
                            height: 48.h,
                            width: 343.w,
                            textStyle: Styles.textStyleS16W700(),
                            backgroundColor:
                                ColorsData.primary.withOpacity(0.65),
                            text: "workingDays".tr,
                            onPressed: () {
                              print(barber.id);
                              //  barber.id
                              showBWorkingDaysBottomSheet(
                                context,
                                barber.workingDays,
                              );
                            },
                          ),
                          SizedBox(
                            height: 12.h,
                          ),
                          // Walk-In section

                          // Gallery section with dynamic count
                          Obx(
                            () => Row(
                              children: [
                                Text(
                                  "gallery".tr,
                                  style: Styles.textStyleS14W700(),
                                ),
                                Text(
                                  "(${galleryController.photos.length} ${"photos".tr})",
                                  style: Styles.textStyleS14W700(
                                      color: ColorsData.primary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Gallery grid with API data
              Obx(() {
                if (galleryController.isLoading.value) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 20.h),
                        child: const SpinKitDoubleBounce(
                          color: ColorsData.primary,
                        ),
                      ),
                    ),
                  );
                }

                if (galleryController.hasError.value) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.h),
                        child: Column(
                          children: [
                            Text(galleryController.errorMessage.value),
                            SizedBox(height: 10.h),
                            ElevatedButton(
                              onPressed: () {
                                if (isClicked) {
                                  isClicked = false;
                                  setState(() {});
                                  galleryController.fetchGallery(barber.id);
                                  Future.delayed(const Duration(seconds: 2),
                                      () {
                                    isClicked = true;
                                    setState(() {});
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorsData.primary,
                              ),
                              child: Text("Retry".tr,
                                  style: Styles.textStyleS14W400(
                                      color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (galleryController.photos.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 20.h, bottom: 80.h),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.photo_library_outlined,
                              size: 40,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              "No photos available".tr,
                              style: Styles.textStyleS14W400(
                                  color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverFillRemaining(
                  child: GridView.builder(
                    scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                        top: 0, left: 16.w, right: 17.w, bottom: 20.h),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 110.w,
                      crossAxisSpacing: 6.h,
                      mainAxisSpacing: 9.w,
                    ),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          // Handle image tap to view in full screen if needed
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GalleryFullScreenPage(
                                images: galleryController.photos,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.network(
                              galleryController.photos[index],
                              width: 108.w,
                              height: 94.h,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 108.w,
                                height: 94.h,
                                color: Colors.grey[300],
                                child: const Center(
                                    child: Icon(Icons.broken_image,
                                        color: Colors.red)),
                              ),
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 108.w,
                                  height: 94.h,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: SpinKitDoubleBounce(
                                      color: ColorsData.primary,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: galleryController.photos.length,
                  ),
                );
              }),
              SliverToBoxAdapter(
                child: SizedBox(height: 20.h),
              ),
            ],
          ),
          // Back button at top of screen
          Positioned(
            top: 40.h,
            left: 16.w,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),
          ),

          // Favorite button at top right
          Positioned(
            top: 40.h,
            right: 16.w,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Obx(() => Icon(
                      isFavorite.value ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite.value ? Colors.red : Colors.white,
                      size: 24.sp,
                    )),
                onPressed: () async {
                  if (isClicked) {
                    isClicked = false;
                    setState(() {});
                    var response = await NetworkAPICall().addData({
                      "barberId": barber.id,
                    }, "${Variables.FAVORITE_FOR_USER}toggle");

                    if (response.statusCode == 200) {
                      isFavorite.value = !isFavorite.value;
                      barber.isFavorite = isFavorite.value;
                    } else {
                      ShowToast.showError(message: "Error occurred".tr);
                    }
                    await Future.delayed(const Duration(seconds: 2), () {
                      isClicked = true;
                      setState(() {});
                    });
                  }
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: ColorsData.secondary,
            // or transparent if desired, but consistent bg is better for stickiness
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: CustomBigButton(
            textData: "book".tr,
            onPressed: () {
              showHowManyConsumerBottomSheet(context, barber: barber);
            },
          ),
        ),
      ),
    );
  }
}

class GalleryFullScreenPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const GalleryFullScreenPage({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<GalleryFullScreenPage> createState() => _GalleryFullScreenPageState();
}

class _GalleryFullScreenPageState extends State<GalleryFullScreenPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            panEnabled: true,
            minScale: 0.8,
            maxScale: 4.0,
            child: CachedNetworkImage(
              imageUrl: widget.images[index],
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              errorWidget: (context, url, error) => const Icon(
                Icons.broken_image,
                color: Colors.white,
                size: 80,
              ),
            ),
          );
        },
      ),
    );
  }
}
