import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/services/notification/notfication.dart';
import 'package:q_cut/core/services/shared_pref/pref_keys.dart';
import 'package:q_cut/core/services/shared_pref/shared_pref.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/modules/barber/features/home_features/appointment_feature/views/b_appointment_view.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/models/barber_profile_model.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/logic/b_profile_controller.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/views/b_profile_view.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/views/widgets/custom_add_new_service_bottom_sheet.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/views/widgets/show_working_days_bottom_sheet.dart';
import 'package:q_cut/modules/barber/features/home_features/statistics_feature/views/b_statics_view.dart';
import 'package:q_cut/modules/customer/features/home_features/home/views/home_view.dart';
import 'package:q_cut/modules/customer/features/home_features/appointment_feature/view/my_appointment_view.dart';
import 'package:q_cut/modules/customer/features/home_features/profile_feature/views/my_profile_view.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../../../core/utils/constants/assets_data.dart';
import '../../../core/utils/network/network_helper.dart';

class Deal {
  final String id;
  final int dealDateStart;
  final int dealDateEnd;
  final int qCuteSubscription;
  final int qCuteTax;
  final int freeDaysNumber;
  final String status;
  final String barber;
  final String createdAt;
  final String updatedAt;

  Deal({
    required this.id,
    required this.dealDateStart,
    required this.dealDateEnd,
    required this.qCuteSubscription,
    required this.qCuteTax,
    required this.freeDaysNumber,
    required this.status,
    required this.barber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id: json['_id'],
      dealDateStart: json['dealDateStart'],
      dealDateEnd: json['dealDateEnd'],
      qCuteSubscription: json['QCuteSubscription'],
      qCuteTax: json['QCuteTax'],
      freeDaysNumber: json['freeDaysNumber'],
      status: json['status'],
      barber: json['barber'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class DealResponse {
  final bool success;
  final List<Deal> deals;

  DealResponse({required this.success, required this.deals});

  factory DealResponse.fromJson(Map<String, dynamic> json) {
    return DealResponse(
      success: json['success'],
      deals:
          (json['deals'] as List).map((deal) => Deal.fromJson(deal)).toList(),
    );
  }
}

class MainController extends GetxController {
  final NetworkAPICall _apiCall = NetworkAPICall();
  final PageController pageController = PageController();
  final RxInt currentIndex = 0.obs;

  // Observable to hold the deal data
  final Rx<DealResponse?> dealResponse = Rx<DealResponse?>(null);
  final RxBool isLoadingDeal = false.obs;
  final RxString dealError = ''.obs;
  
  // Flag to prevent multiple dialogs overlapping
  bool _isCheckingProfile = false;

  final List<Widget> pages = (SharedPref().getBool(PrefKeys.userRole)) == false
      ? [
          const BAppointmentView(),
          const BStaticsView(),
          const BProfileView(),
        ]
      : [
          const HomeView(),
          const MyAppointmentView(),
          const MyProfileView(),
        ];
  bool? isCustomer = SharedPref().getBool(PrefKeys.userRole);

  @override
  void onInit() async {
    super.onInit();
    if (isCustomer == false) {
      final BProfileController profileController = Get.put(BProfileController());
      fetchDealById();
      // Start checking profile enforcement
      _enforceBarberProfile(profileController);
    }
    await _notificationListener();
  }

  Future<void> _notificationListener() async {
    onNotificationClick?.stream.listen((event) {
      if (event.isNotEmpty) {
        _onNotificationClick(event);
      }
    });
  }

  // Method to fetch deal by ID
  Future<void> fetchDealById() async {
    isLoadingDeal.value = true;
    dealError.value = '';
    String? id = SharedPref().getString(PrefKeys.id);
    String? act = SharedPref().getString(PrefKeys.accessToken);
    print(act);
    final BProfileController profileController = Get.find<BProfileController>();
    try {
      final response = await _apiCall.getData(
        '${Variables.baseUrl}deal/$id',
      );

      print('${Variables.baseUrl}deal/$id');
      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        dealResponse.value = DealResponse.fromJson(responseData);

        // Check if there's an accepted deal and show dialog
        if (dealResponse.value != null &&
            dealResponse.value!.deals.isNotEmpty &&
            dealResponse.value!.deals.any((deal) => deal.status == "pending")) {
          final pendingDeal = dealResponse.value!.deals
              .firstWhere((deal) => deal.status == "pending");

          showDealDialog(pendingDeal);
        } else if (dealResponse.value != null &&
            dealResponse.value!.deals.isNotEmpty &&
            dealResponse.value!.deals
                .any((deal) => deal.status == "accepted")) {
          // Triggered in onInit already
        } else {
          // Show waiting dialog when API call fails
          await showWaitingForOfferDialog();
          // Profile enforcement is already running from onInit
          // After waiting dialog, enforce profile
          await _enforceBarberProfile(profileController);
        }
      } else {
        // If API call fails (e.g., 404, 500), show waiting dialog and enforce profile
        await showWaitingForOfferDialog();
        await _enforceBarberProfile(profileController);
      }
    } catch (e) {
      dealError.value = 'Error fetching deal: $e';
      // Show waiting dialog when exception occurs and enforce profile
      await showWaitingForOfferDialog();
      await _enforceBarberProfile(profileController);
    } finally {
      isLoadingDeal.value = false;
    }
  }

  // Method to show deal dialog
  void showDealDialog(Deal deal) {
    String startDate = _formatDate(deal.dealDateStart);
    String endDate = _formatDate(deal.dealDateEnd);

    final TextStyle titleStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    final TextStyle subtitleStyle = TextStyle(
      fontSize: 16,
      color: Colors.black87,
    );

    final TextStyle boldGoldStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Color(0xFFD1A439),
    );

    Widget offerDetailRow(IconData icon, String text) {
      return Row(
        children: [
          Icon(icon, color: Color(0xFF666666), size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15.sp, color: Color(0xFF444444)),
            ),
          ),
        ],
      );
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 335.w,
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AssetsData.dealImage,
                  width: 130.w,
                  height: 130.h,
                ),
                SizedBox(height: 16.h),
                Text(
                  "Thank you for choosing us".tr,
                  style: titleStyle.copyWith(
                    fontSize: 18.sp,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  "QCut Special Offer".tr,
                  style: subtitleStyle.copyWith(
                    fontSize: 17.sp,
                    color: Color(0xFFD1A439),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(0xFFEEEEEE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.celebration,
                              color: Color(0xFFD1A439), size: 20.sp),
                          SizedBox(width: 8.w),
                          Text("Exclusive Offer".tr, style: boldGoldStyle),
                        ],
                      ),
                      Divider(height: 24.h, color: Color(0xFFEEEEEE)),
                      offerDetailRow(
                        Icons.date_range,
                        "${"Valid Period".tr}: $startDate - $endDate",
                      ),
                      SizedBox(height: 10.h),
                      offerDetailRow(
                        Icons.money_off,
                        "${"QCut Tax:".tr} ${deal.qCuteTax}% per booking",
                      ),
                      SizedBox(height: 10.h),
                      offerDetailRow(
                        Icons.payment,
                        "${"Subscription".tr}: \$${deal.qCuteSubscription}",
                      ),
                      SizedBox(height: 10.h),
                      offerDetailRow(
                        Icons.card_giftcard,
                        "${"Free Trial".tr}: ${deal.freeDaysNumber} days",
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.back();

                          Get.dialog(
                            Center(
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeOutBack,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: 0.8 + (0.2 * value),
                                    child: Opacity(
                                      opacity: value.clamp(0.0, 1.0),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 28.h, horizontal: 32.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Color(0xFFD1A439).withOpacity(0.2),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                      BoxShadow(
                                        color:
                                            Colors.black.withOpacity(0.08),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 56.w,
                                        height: 56.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFFFAF6E9),
                                              Color(0xFFF5EDD6),
                                            ],
                                          ),
                                        ),
                                        child: Center(
                                          child: SizedBox(
                                            width: 28.w,
                                            height: 28.w,
                                            child: CircularProgressIndicator(
                                              color: Color(0xFFD1A439),
                                              strokeWidth: 3,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 18.h),
                                      Text(
                                        "Processing...".tr,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                      SizedBox(height: 6.h),
                                      Text(
                                        "Please wait a moment".tr,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Color(0xFF999999),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            barrierColor: Colors.black.withOpacity(0.3),
                            barrierDismissible: false,
                          );

                          var response = await NetworkAPICall().editData(
                            '${Variables.baseUrl}deal',
                            {"status": "accepted"},
                          );

                          if (response.statusCode == 200) {
                            final BProfileController profileController =
                                Get.put(BProfileController());
                            await profileController.fetchProfileData();
                            Get.back();
                            ShowToast.showSuccessSnackBar(
                              message: "Offer accepted successfully".tr,
                            );
                            final profileData =
                                profileController.profileData.value;
                            final editProfileResult = await Get.toNamed(
                              AppRouter.beditProfilePath,
                              arguments: BarberProfileModel(
                                  fullName: profileData?.fullName.trim() ?? '',
                                  offDay: profileData?.offDay ?? [],
                                  barberShop: profileData?.barberShop ?? '',
                                  bankAccountNumber:
                                      profileData?.bankAccountNumber ?? '',
                                  instagramPage:
                                      profileData?.instagramPage ?? '',
                                  profilePic:
                                      profileData?.profilePic.trim() ?? '',
                                  coverPic: profileData?.coverPic.trim() ?? '',
                                  city: profileData?.city ?? 'New City',
                                  workingDays: profileData?.workingDays ?? [],
                                  barberShopLocation:
                                      profileData?.barberShopLocation ??
                                          BarberShopLocation(
                                              type: 'Point',
                                              coordinates: [0, 0]),
                                  phoneNumber: profileData?.phoneNumber ?? '',
                                  locationDescription:
                                      profileData?.locationDescription.trim() ??
                                          ''),
                            );
                            if (editProfileResult == true) {
                              await _enforceBarberProfile(profileController);
                            } else {
                              await _enforceBarberProfile(profileController);
                            }
                          } else {
                            Get.back();
                            ShowToast.showError(
                              message: "Failed to accept the offer".tr,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD1A439),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          "Accept Offer".tr,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Color(0xFF757575)),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Contact Us".tr,
                          style: TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Method to show waiting for offer dialog
  Future<void> showWaitingForOfferDialog() async {
    final TextStyle titleStyle = TextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeight.bold,
      color: Color(0xFF333333),
    );

    final TextStyle subtitleStyle = TextStyle(
      fontSize: 16.sp,
      color: Color(0xFF666666),
    );

    await Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 335.w,
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 130.w,
                  height: 130.h,
                  decoration: BoxDecoration(
                    color: Color(0xFFFAF6E9),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.access_time,
                      size: 60.sp,
                      color: Color(0xFFD1A439),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  "Please Wait",
                  style: titleStyle,
                ),
                SizedBox(height: 10.h),
                Text(
                  "QCut is preparing a special offer for you",
                  textAlign: TextAlign.center,
                  style: subtitleStyle,
                ),
                SizedBox(height: 8.h),
                Text(
                  "We'll notify you once your offer is ready",
                  textAlign: TextAlign.center,
                  style: subtitleStyle.copyWith(
                    fontSize: 14.sp,
                    color: Color(0xFF888888),
                  ),
                ),
                SizedBox(height: 24.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(0xFFEEEEEE)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFFD1A439),
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          "Our team is reviewing your application. You'll receive personalized terms shortly.",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Color(0xFF555555),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD1A439),
                    foregroundColor: Colors.white,
                    padding:
                        EdgeInsets.symmetric(vertical: 12.h, horizontal: 30.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: Size(double.infinity, 50.h),
                    elevation: 2,
                  ),
                  child: Text(
                    "Got It",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Helper method to format timestamp to readable date
  String _formatDate(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MM/dd/yyyy').format(date);
  }
  void changePage(int index) {
    if (index >= 0 && index < pages.length) {
      currentIndex.value = index;
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  // Consolidated method to ensure barber profile is complete
  Future<void> _enforceBarberProfile(BProfileController profileController) async {
    if (_isCheckingProfile) return;
    _isCheckingProfile = true;

    try {
      bool completed = false;
      while (!completed) {
        // Step 1: Check and force services
        bool servicesDone = await _runServiceCheck(profileController);
        if (!servicesDone) continue;

        // Step 2: Check and force working days
        bool workingDaysDone = await _runWorkingDaysCheck(profileController);
        if (!workingDaysDone) continue;

        completed = true;
      }
    } catch (e) {
      print("Error in profile enforcement: $e");
    } finally {
      _isCheckingProfile = false;
    }
  }

  // Helper method to ensure services are present
  Future<void> _ensureServices() async {
    final profileController = Get.find<BProfileController>();
    await _enforceBarberProfile(profileController);
  }

  // Returns true if services are present or successfully added
  Future<bool> _runServiceCheck(BProfileController profileController) async {
    bool hasServices = SharedPref().getBool(PrefKeys.hasServices) ?? false;

    if (!hasServices) {
      await profileController.fetchBarberServices();
      if (profileController.barberServices.isNotEmpty) {
        await SharedPref().setBool(PrefKeys.hasServices, true);
        hasServices = true;
      }
    }

    if (hasServices) return true;

    // Navigate to profile tab
    if (currentIndex.value != 2) {
      currentIndex.value = 2;
    }

    final dialogResult = await Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: _buildRequirementDialogContent(
            icon: Icons.add_business_rounded,
            title: "Add Your First Service".tr,
            description: "You must add at least one service before customers can book appointments with you.".tr,
            buttonText: "Add Service".tr,
            onPressed: () => Get.back(result: 'addService'),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    if (dialogResult == 'addService') {
      await Future.delayed(const Duration(milliseconds: 100));
      await Get.bottomSheet(
        WillPopScope(
          onWillPop: () async {
            await profileController.fetchBarberServices();
            if (profileController.barberServices.isEmpty) {
              _showRequirementSnackbar("Service Required".tr, "Please add at least one service to continue".tr);
              return false;
            }
            return true;
          },
          child: const CustomAddNewServiceBottomSheet(),
        ),
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      );

      await profileController.fetchBarberServices();
      if (profileController.barberServices.isNotEmpty) {
        await SharedPref().setBool(PrefKeys.hasServices, true);
        _showSuccessSnackbar("Setup Complete".tr, "Service added successfully!".tr);
        return true;
      }
    }
    return false;
  }

  // Returns true if working days are present or successfully added
  Future<bool> _runWorkingDaysCheck(BProfileController profileController) async {
    bool hasWorkingDays = SharedPref().getBool(PrefKeys.hasWorkingDays) ?? false;

    if (!hasWorkingDays) {
      await profileController.fetchProfileData();
      if (profileController.profileData.value?.workingDays.isNotEmpty ?? false) {
        await SharedPref().setBool(PrefKeys.hasWorkingDays, true);
        hasWorkingDays = true;
      }
    }

    if (hasWorkingDays) return true;

    final dialogResult = await Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: _buildRequirementDialogContent(
            icon: Icons.calendar_month_rounded,
            title: "Set Working Days".tr,
            description: "You must set at least one working day so customers know when you are available.".tr,
            buttonText: "Set Days".tr,
            onPressed: () => Get.back(result: 'setDays'),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    if (dialogResult == 'setDays') {
      await Future.delayed(const Duration(milliseconds: 100));
      await showBWorkingDaysBottomSheet(
        Get.context!,
        profileController.profileData.value?.workingDays ?? [],
        isDismissible: false,
      );

      await profileController.fetchProfileData();
      if (profileController.profileData.value?.workingDays.isNotEmpty ?? false) {
        await SharedPref().setBool(PrefKeys.hasWorkingDays, true);
        _showSuccessSnackbar("Setup Complete".tr, "Working days set successfully!".tr);
        Get.offAllNamed(AppRouter.bottomNavigationBar);
        return true;
      }
    }
    return false;
  }

  Widget _buildRequirementDialogContent({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: const BoxDecoration(color: Color(0xFFFAF6E9), shape: BoxShape.circle),
            child: Icon(icon, color: ColorsData.primary, size: 32.sp),
          ),
          SizedBox(height: 24.h),
          Text(title, textAlign: TextAlign.center, style: Styles.textStyleS18W700(color: ColorsData.secondary)),
          SizedBox(height: 12.h),
          Text(description, textAlign: TextAlign.center, style: Styles.textStyleS14W400(color: ColorsData.thirty)),
          SizedBox(height: 32.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsData.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              onPressed: onPressed,
              child: Text(buttonText, style: Styles.textStyleS16W600(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _showRequirementSnackbar(String title, String message) {
    ShowToast.showWarning(message: _getErrorMessage(message));
  }

  void _showSuccessSnackbar(String title, String message) {
    ShowToast.showSuccessSnackBar(message: message);
  }

  String _getErrorMessage(String message) {
    if (message.contains('|')) {
      final parts = message.split('|');
      if (Get.locale?.languageCode == 'ar' && parts.length > 1) {
        return parts[1].trim();
      }
      return parts[0].trim();
    }
    return message;
  }
  void _onNotificationClick(event) {
    // Handle navigation based on notification payload
    Get.toNamed(AppRouter.notificationPath);

    onNotificationClick?.add("");
  }
}
