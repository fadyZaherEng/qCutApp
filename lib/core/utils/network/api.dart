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

  /// COLLECTION
  static const String COLLECTION = "${baseUrl}collection/";
  static const String COLLECTION_SCHEDULE = "${COLLECTION}schedule";
  static const String SELECT_SLOT = "${COLLECTION}select-slot";
}

class ShowToast {
  const ShowToast._();

  static showError({String? title, required String message}) {
    Get.rawSnackbar(
      titleText: Text(
        title ?? "error".tr,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14.sp,
          fontFamily: 'Alexandria',
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontWeight: FontWeight.w400,
          fontSize: 13.sp,
          fontFamily: 'Alexandria',
        ),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFE53935),
      icon: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.error_outline_rounded, color: Colors.white, size: 20.sp),
      ),
      margin: EdgeInsets.all(16.r),
      borderRadius: 16.r,
      duration: const Duration(seconds: 4),
      forwardAnimationCurve: Curves.easeOutBack,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      shouldIconPulse: false,
    );
  }

  static showSuccessSnackBar({String? title, required String message}) {
    Get.rawSnackbar(
      titleText: Text(
        title ?? "success".tr,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14.sp,
          fontFamily: 'Alexandria',
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontWeight: FontWeight.w400,
          fontSize: 13.sp,
          fontFamily: 'Alexandria',
        ),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF2E7D32),
      icon: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check_circle_outline_rounded,
            color: Colors.white, size: 20.sp),
      ),
      margin: EdgeInsets.all(16.r),
      borderRadius: 16.r,
      duration: const Duration(seconds: 4),
      forwardAnimationCurve: Curves.easeOutBack,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      shouldIconPulse: false,
    );
  }

  static showWarning({String? title, required String message}) {
    Get.rawSnackbar(
      titleText: Text(
        title ?? "warning".tr,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14.sp,
          fontFamily: 'Alexandria',
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontWeight: FontWeight.w400,
          fontSize: 13.sp,
          fontFamily: 'Alexandria',
        ),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFF57C00),
      icon: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child:
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20.sp),
      ),
      margin: EdgeInsets.all(16.r),
      borderRadius: 16.r,
      duration: const Duration(seconds: 4),
      forwardAnimationCurve: Curves.easeOutBack,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      shouldIconPulse: false,
    );
  }
}
