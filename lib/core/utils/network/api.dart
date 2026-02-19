// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class Variables {
  static const address = 'api.qcut.org';
  static const baseUrl = "https://$address/";

  ///
  static const String AUTHENTICATION = "${baseUrl}authentication/";
  static const String SIGNUP = "${AUTHENTICATION}signup/";
  static const String LOGIN = "${AUTHENTICATION}login/";
  static const String VERIFY_OTP = "${AUTHENTICATION}verify-otp/";
  static const String CHANGE_PASSWORD = "${AUTHENTICATION}change-password"; // Added
  static const String FORGET_PASSWORD = "$baseUrl/authentication/forget-password"; // Added
  static const String GET_PROFILE = "${AUTHENTICATION}profile/";
  static const String REPORT = "${baseUrl}reports";

  ///
  ///
  static const String BARBER = "${baseUrl}barber/";
  static const String SEARCH_BARBER_NAME = "${BARBER}search-by-barberShop";
  static const String GET_BARBERS = "${BARBER}active/";
  static const String GET_BARBERS_FILTER = "${baseUrl}barber/search-by-city";
  static const String SERVICE = "${baseUrl}service/";
  static const String GET_BARBER_SERVICES = "${SERVICE}forSpecificBarber/";
  static const String UPDATE_BARBER_SERVICE = SERVICE;
  static const String CREATE_BARBER_SERVICE = "${SERVICE}create/";

// service/forSpecificBarber
  ///
  ///
  static const String APPOINTMENT = "${baseUrl}appointment/";
  static const String GET_BARBER_APPOINTMENTS =
      "${APPOINTMENT}appointment-by-dat/";
  static const String GET_BARBER_HISTORY = "${APPOINTMENT}barber-history/";
  static const String SET_APPOINTMENT_NOT_COME = "${APPOINTMENT}not-come/";
  static const String COUNT_REPORTS = "$REPORT/count/";
  static const String GET_CUSTOMER_HISTORY_APPOINTMENTS =
      "${APPOINTMENT}previous-currently/";
  static const String BARBER_STATS = "${baseUrl}barberStats/";
  static const String BARBER_PAYMENT_STATS = "${BARBER_STATS}payment/one/";
  static const String BARBER_COUNT_MOUNTH = "${BARBER_STATS}count-for-month/";
  static const String FAVORITE_FOR_USER = "${baseUrl}favoriteForUser/";
}

class ShowToast {
  const ShowToast._();
  static showError({required String message}) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.close, color: Colors.white), // Adding an icon
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                style: TextStyle(color: Colors.white, fontSize: 13.sp),
                message.toString(), // Using the passed parameter
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red, // Changing background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Setting the border radius
        ),
        behavior:
            SnackBarBehavior.floating, // Making SnackBar float above content
      ),
    );
  }

  static showSuccessSnackBar({required String message}) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.close, color: Colors.white), // Adding an icon
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                style: TextStyle(color: Colors.white, fontSize: 13.sp),
                message.toString(),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green, // Changing background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Setting the border radius
        ),
        behavior:
            SnackBarBehavior.floating, // Making SnackBar float above content
      ),
    );
  }
}
