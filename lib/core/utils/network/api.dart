// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class Variables {
  static const address = 'api.qcut.org';
  static const baseUrl = "https://$address/";

  /// AUTHENTICATION
  static const String AUTHENTICATION = "${baseUrl}authentication/";
  static const String SIGNUP = "${AUTHENTICATION}signup/";
  static const String LOGIN = "${AUTHENTICATION}login/";
  static const String VERIFY_OTP = "${AUTHENTICATION}verify-otp/";
  static const String CHANGE_PASSWORD = "${AUTHENTICATION}change-password";
  static const String FORGET_PASSWORD = "${AUTHENTICATION}forget-password";
  static const String VERIFY_CHANGE_PHONE = "${AUTHENTICATION}verify-change-phone/";
  static const String REQUEST_CHANGE_PHONE = "${AUTHENTICATION}request-change-phone";
  static const String GET_PROFILE = "${AUTHENTICATION}profile/";
  static const String REPORT = "${baseUrl}reports";

  /// BARBER
  static const String BARBER = "${baseUrl}barber/";
  static const String SEARCH_BARBER_SHOP = "${BARBER}search-by-barberShop";
  static const String SEARCH_BARBER_FULL_NAME = "${BARBER}search-by-name";
  static const String SEARCH_BARBER_NAME = SEARCH_BARBER_SHOP; 
  static const String GET_BARBERS = "${BARBER}active/";
  static const String GET_BARBERS_FILTER = "${BARBER}search-by-city";
  static const String UPDATE_WALK_IN = "${BARBER}update-walk-in";
  static const String GET_WORKING_HOURS_RANGE = "${BARBER}working-hours-range/";
  static const String GET_NEXT_WORKING_DAYS = "${BARBER}next-working-days";

  /// SERVICE
  static const String SERVICE = "${baseUrl}service/";
  static const String GET_BARBER_SERVICES = "${SERVICE}forSpecificBarber/";
  static const String UPDATE_BARBER_SERVICE = SERVICE;
  static const String CREATE_BARBER_SERVICE = "${SERVICE}create/";

  /// APPOINTMENT
  static const String APPOINTMENT = "${baseUrl}appointment/";
  static const String GET_BARBER_APPOINTMENTS = "${APPOINTMENT}appointment-by-dat/";
  static const String GET_BARBER_HISTORY = "${APPOINTMENT}barber-history/";
  static const String SET_APPOINTMENT_NOT_COME = "${APPOINTMENT}not-come/";
  static const String GET_CUSTOMER_HISTORY_APPOINTMENTS = "${APPOINTMENT}previous-currently/";

  /// STATS & OTHERS
  static const String BARBER_STATS = "${baseUrl}barberStats/";
  static const String BARBER_STATS_RANGE = "${BARBER_STATS}search/date-range/";
  static const String BARBER_PAYMENT_STATS = "${BARBER_STATS}payment/one/";
  static const String BARBER_COUNT_MOUNTH = "${BARBER_STATS}count-for-month/";
  static const String FAVORITE_FOR_USER = "${baseUrl}favoriteForUser/";
  static const String COUNT_REPORTS = "$REPORT/count/";
}

class ShowToast {
  const ShowToast._();
  static showError({required String message}) {
    Get.snackbar(
      "Error".tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      margin: EdgeInsets.all(16.r),
      borderRadius: 12.r,
      duration: const Duration(seconds: 3),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeIn,
      animationDuration: const Duration(milliseconds: 500),
      snackbarStatus: (status) {
        if (status == SnackbarStatus.OPENING) {
          // Add custom logic if needed
        }
      },
    );
  }

  static showSuccessSnackBar({required String message}) {
    Get.snackbar(
      "Success".tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      margin: EdgeInsets.all(16.r),
      borderRadius: 12.r,
      duration: const Duration(seconds: 3),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeIn,
      animationDuration: const Duration(milliseconds: 500),
    );
  }
}
