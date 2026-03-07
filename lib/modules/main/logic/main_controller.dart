import 'dart:async';

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
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../core/utils/constants/assets_data.dart';
import '../../../core/utils/network/network_helper.dart';

class MainController extends GetxController {
  final NetworkAPICall _apiCall = NetworkAPICall();
  final PageController pageController = PageController();
  final RxInt currentIndex = 0.obs;

  // Observable to hold the deal data
  final Rx<DealResponse?> dealResponse = Rx<DealResponse?>(null);
  final RxBool isLoadingDeal = false.obs;
  final RxString dealError = ''.obs;

  // Stream Subscriptions
  StreamSubscription? _notificationClickSubscription;
  StreamSubscription? _foregroundMessageSubscription;

  // Flag to prevent multiple dialogs overlapping
  bool _isCheckingProfile = false;
  bool _isWaitingDialogOpen = false;
  bool _isDealDialogOpen = false;

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
    if (Get.arguments is int) {
      currentIndex.value = Get.arguments;
    }
    if (isCustomer == false) {
      final BProfileController profileController =
          Get.put(BProfileController());
      // Sequence: Fetch deal status, then check profile completeness
      await fetchDealById();
    }
    await _notificationListener();
  }

  Future<void> _notificationListener() async {
    // Listen for notification clicks
    _notificationClickSubscription =
        onNotificationClick?.stream.listen((event) {
      if (event.isNotEmpty) {
        if (isCustomer == false) {
          fetchDealById();
        }
        _onNotificationClick(event);
      }
    });

    // Listen for foreground messages for real-time deal updates (for Barbers)
    if (isCustomer == false) {
      _foregroundMessageSubscription =
          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint("🔔 Foreground Deal Update: ${message.notification?.title}");
        fetchDealById();
      });
    }
  }

  /// Refetches the deal status for the current barber
  Future<void> refreshDealStatus() async => await fetchDealById();

  // Method to fetch deal by ID
  Future<void> fetchDealById() async {
    if (isLoadingDeal.value) return; // Prevent multiple simultaneous calls

    debugPrint(
        "🔄 Syncing Deal Status for barber [ID: ${SharedPref().getString(PrefKeys.id)}]");
    isLoadingDeal.value = true;
    dealError.value = '';

    final id = SharedPref().getString(PrefKeys.id);
    final profileController = Get.find<BProfileController>();

    try {
      final response = await _apiCall.getData('${Variables.baseUrl}deal/$id');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        dealResponse.value = DealResponse.fromJson(responseData);
        final deals = dealResponse.value?.deals ?? [];

        // Identify the latest pending deal
        Deal? pendingDeal;
        try {
          final pendingDeals =
              deals.where((d) => d.status == "pending").toList();
          if (pendingDeals.isNotEmpty) pendingDeal = pendingDeals.last;
        } catch (e) {
          debugPrint("Error sorting deals: $e");
        }

        if (pendingDeal != null) {
          _handleReceivedPendingDeal(pendingDeal);
        } else {
          await _handleNoPendingDeals(deals, profileController);
        }
      } else {
        await _handleFetchFailure(profileController);
      }
    } catch (e) {
      debugPrint('❌ Deal Fetch Error: $e');
      dealError.value = e.toString();
      await _handleFetchFailure(profileController);
    } finally {
      isLoadingDeal.value = false;
    }
  }

  void _handleReceivedPendingDeal(Deal pendingDeal) {
    // If we were in the waiting room, close it
    if (_isWaitingDialogOpen) {
      Get.back();
      _isWaitingDialogOpen = false;
    }

    // Show the actual offer if not already visible
    if (!_isDealDialogOpen) {
      showDealDialog(pendingDeal);
    }
  }

  Future<void> _handleNoPendingDeals(
      List<Deal> deals, BProfileController profileController) async {
    final bool hasAccepted = deals.any((d) => d.status == "accepted");

    if (!hasAccepted) {
      // First-timer flow: no history of accepted deals
      final bool isFirstTime =
          SharedPref().getBool(PrefKeys.isFirstDealFlow) ?? true;
      if (isFirstTime && !_isWaitingDialogOpen && !_isDealDialogOpen) {
        await showWaitingForOfferDialog();
      }
    } else {
      // Returner flow: previously accepted deals exist
      await SharedPref().setBool(PrefKeys.isFirstDealFlow, false);
      if (_isWaitingDialogOpen) {
        Get.back();
        _isWaitingDialogOpen = false;
      }
    }

    // Always ensure profile is complete if the UI isn't blocked by a deal popup
    if (!_isDealDialogOpen) {
      await _enforceBarberProfile(profileController);
    }
  }

  Future<void> _handleFetchFailure(BProfileController profileController) async {
    final bool isFirstTime =
        SharedPref().getBool(PrefKeys.isFirstDealFlow) ?? true;
    if (isFirstTime && !_isWaitingDialogOpen && !_isDealDialogOpen) {
      await showWaitingForOfferDialog();
    }
    await _enforceBarberProfile(profileController);
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

    _isDealDialogOpen = true;
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Prevent closing by back button
        child: Dialog(
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
                          Icons.payment,
                          "${"Subscription".tr}: ${deal.qCuteSubscription} ${"currency".tr}",
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
                            _isDealDialogOpen = false;
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
                                          color: Color(0xFFD1A439)
                                              .withOpacity(0.2),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
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
                              Get.back(); // Close processing dialog
                              ShowToast.showSuccessSnackBar(
                                message: "Offer accepted successfully".tr,
                              );

                              // Mark that we are past the first deal flow
                              await SharedPref()
                                  .setBool(PrefKeys.isFirstDealFlow, false);

                              // Trigger enforcement (Services -> Working Days)
                              await _enforceBarberProfile(profileController);
                            } else {
                              Get.back(); // Close processing dialog
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
                          onPressed: () {
                            // Keep the dialog open and push the chat screen over it
                            // When the user comes back, the dialog will still be there
                            Get.toNamed(AppRouter.chatWithUsPath);
                          },
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

    _isWaitingDialogOpen = true;
    await Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
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
                    "pleaseWait".tr,
                    style: titleStyle,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "preparingOffer".tr,
                    textAlign: TextAlign.center,
                    style: subtitleStyle,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "notifyWhenReady".tr,
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
                            "reviewingApplication".tr,
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
                  // ElevatedButton(
                  //   onPressed: () => Get.back(),
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Color(0xFFD1A439),
                  //     foregroundColor: Colors.white,
                  //     padding:
                  //         EdgeInsets.symmetric(vertical: 12.h, horizontal: 30.w),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //     minimumSize: Size(double.infinity, 50.h),
                  //     elevation: 2,
                  //   ),
                  //   child: Text(
                  //     "gotIt".tr,
                  //     style: TextStyle(
                  //       fontSize: 16.sp,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
    _isWaitingDialogOpen = false;
  }

  // Helper method to format timestamp to readable date
  String _formatDate(int timestamp) {
    if (timestamp == 0) return "notJoinedYet".tr;
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void changePage(int index) {
    if (index >= 0 && index < pages.length) {
      currentIndex.value = index;
    }
  }

  @override
  void onClose() {
    _notificationClickSubscription?.cancel();
    _foregroundMessageSubscription?.cancel();
    pageController.dispose();
    super.onClose();
  }

  // Consolidated method to ensure barber profile is complete
  Future<void> _enforceBarberProfile(
      BProfileController profileController) async {
    // If the view is currently covered by a deal dialog, we might want to wait.
    // But for now, we just rely on the fact that deal cards are shown first.

    if (_isCheckingProfile) return;
    _isCheckingProfile = true;

    try {
      print("Starting barber profile enforcement...");
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: _buildRequirementDialogContent(
            icon: Icons.add_business_rounded,
            title: "Add Your First Service".tr,
            description:
                "You must add at least one service before customers can book appointments with you."
                    .tr,
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
              _showRequirementSnackbar("Service Required".tr,
                  "Please add at least one service to continue".tr);
              return false;
            }
            return true;
          },
          child: const CustomAddNewServiceBottomSheet(),
        ),
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      );

      await profileController.fetchBarberServices();
      if (profileController.barberServices.isNotEmpty) {
        await SharedPref().setBool(PrefKeys.hasServices, true);
        _showSuccessSnackbar(
            "Setup Complete".tr, "Service added successfully!".tr);
        return true;
      }
    }
    return false;
  }

  // Returns true if working days are present or successfully added
  Future<bool> _runWorkingDaysCheck(
      BProfileController profileController) async {
    bool hasWorkingDays =
        SharedPref().getBool(PrefKeys.hasWorkingDays) ?? false;

    if (!hasWorkingDays) {
      await profileController.fetchProfileData();
      if (profileController.profileData.value?.workingDays.isNotEmpty ??
          false) {
        await SharedPref().setBool(PrefKeys.hasWorkingDays, true);
        hasWorkingDays = true;
      }
    }

    if (hasWorkingDays) return true;

    final dialogResult = await Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: _buildRequirementDialogContent(
            icon: Icons.calendar_month_rounded,
            title: "Set Working Days".tr,
            description:
                "You must set at least one working day so customers know when you are available."
                    .tr,
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
      if (profileController.profileData.value?.workingDays.isNotEmpty ??
          false) {
        await SharedPref().setBool(PrefKeys.hasWorkingDays, true);
        _showSuccessSnackbar(
            "Setup Complete".tr, "Working days set successfully!".tr);
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
            decoration: const BoxDecoration(
                color: Color(0xFFFAF6E9), shape: BoxShape.circle),
            child: Icon(icon, color: ColorsData.primary, size: 32.sp),
          ),
          SizedBox(height: 24.h),
          Text(title,
              textAlign: TextAlign.center,
              style: Styles.textStyleS18W700(color: ColorsData.secondary)),
          SizedBox(height: 12.h),
          Text(description,
              textAlign: TextAlign.center,
              style: Styles.textStyleS14W400(color: ColorsData.thirty)),
          SizedBox(height: 32.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsData.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
              onPressed: onPressed,
              child: Text(buttonText,
                  style: Styles.textStyleS16W600(color: Colors.white)),
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
    int start = json['dealDateStart'] ?? 0;
    int freeUntil = json['freeUntilDate'] ?? start;
    
    int calculatedFreeDays = 0;
    if (freeUntil > start) {
      calculatedFreeDays = DateTime.fromMillisecondsSinceEpoch(freeUntil)
          .difference(DateTime.fromMillisecondsSinceEpoch(start))
          .inDays;
    }

    return Deal(
      id: json['_id'] ?? json['id'] ?? '',
      dealDateStart: start,
      dealDateEnd: json['dealDateEnd'] ?? 0,
      qCuteSubscription: json['QCuteSubscription'] ?? 0,
      qCuteTax: json['QCuteTax'] ?? 0,
      freeDaysNumber: json['freeDaysCount'] ?? json['freeDaysCount'] ?? calculatedFreeDays,
      status: json['status'] ?? '',
      barber: json['barber'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class DealResponse {
  final bool success;
  final List<Deal> deals;

  DealResponse({required this.success, required this.deals});

  factory DealResponse.fromJson(Map<String, dynamic> json) {
    List<Deal> dealsList = [];
    if (json['deals'] != null) {
      dealsList = (json['deals'] as List).map((deal) => Deal.fromJson(deal)).toList();
    } else if (json['userOffer'] != null) {
      dealsList = [Deal.fromJson(json['userOffer'])];
    }
    
    return DealResponse(
      success: json['success'] ?? true,
      deals: dealsList,
    );
  }
}
