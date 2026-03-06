import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/constants.dart';
import 'package:q_cut/core/utils/navigation_helper.dart';
import 'package:q_cut/core/services/shared_pref/pref_keys.dart';
import 'package:q_cut/core/services/shared_pref/shared_pref.dart';

import 'package:q_cut/core/utils/network/api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> fadeAnimation;

  @override
  void onInit() {
    super.onInit();
    _initAnimation();
    _configureSystemUI(true);
    _navigateAfterDelay();
    print("SplashController initialized bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb");
  }

  @override
  void onClose() {
    _configureSystemUI(false);
    animationController.dispose();
    super.onClose();
  }

  void _initAnimation() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: kSplashDelay),
    );

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    ));

    animationController.forward();
  }

  void _configureSystemUI(bool immersive) {
    if (immersive) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    }
  }

  // Get FCM token
  Future<String> getFCMToken() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $fcmToken");
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      fcmToken = newToken;
      // Handle token refresh if needed
      print('FCM Token refreshed: $newToken');
    });
    if (fcmToken == null) {
      print('Failed to get FCM token');
    } else {
      print('FCM Token: $fcmToken');
    }
    return fcmToken ?? '';
  }

  void _navigateAfterDelay() {
    Future.delayed(const Duration(seconds: kSplashDelay), () async {
      bool saveMe = SharedPref().getBool(PrefKeys.saveMe) ?? false;
      String? phoneNumber = SharedPref().getString(PrefKeys.phoneNumber);
      String? password = SharedPref().getString(PrefKeys.password);
      bool? isUserRole = SharedPref().getBool(PrefKeys.userRole);
      // Get FCM token before making the request
      final fcmToken = await getFCMToken();
      String? token = SharedPref().getString(PrefKeys.accessToken);
      print(
          "Saved credentials: phoneNumber=$phoneNumber, password=${password != null ? '***' : null}, isUserRole=$isUserRole, saveMe=$saveMe");
      // Verify ban status in background if we have credentials
      if (phoneNumber != null &&
          phoneNumber.isNotEmpty &&
          password != null &&
          password.isNotEmpty &&
          saveMe) {
        try {
          final response = await http
              .post(
                Uri.parse(Variables.LOGIN),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
                body: jsonEncode({
                  'phoneNumber': phoneNumber,
                  'password': password,
                  'userType':
                      isUserRole != null && isUserRole ? 'user' : 'barber',
                  "fcmToken": token,
                }),
              )
              .timeout(const Duration(seconds: 5));
          print(
              "Ban check response: ${response.statusCode} - ${response.body}");
          print("Ban check request body: ${jsonEncode({
                'phoneNumber': phoneNumber,
                'password': password,
                'userType':
                    isUserRole != null && isUserRole ? 'user' : 'barber',
                "fcmToken": token,
              })}");

          if (response.statusCode == 200) {
            final responseBody = jsonDecode(response.body);
            final bool isBanned = responseBody['isBanned'] ?? false;
            final String status = responseBody['status'] ?? '';

            if (isBanned || status == "archived") {
              String finalReason = "";
              if (status == "archived") {
                final String reason = responseBody['archiveReason'] ?? '';
                if (reason == "unpaid") {
                  NavigationHelper.navigateToAndRemoveUntil(AppRouter.unpaidPath);
                  return;
                } else if (reason == "banned") {
                  finalReason = responseBody['banReason']?.isNotEmpty == true
                      ? responseBody['banReason']
                      : "Your account has been banned.".tr;
                } else if (reason == "deleted") {
                  finalReason = responseBody['deleteReason']?.isNotEmpty == true
                      ? responseBody['deleteReason']
                      : "Your account has been deleted.".tr;
                } else {
                  finalReason =
                      "Your account has been archived. Please contact support.".tr;
                }
              } else {
                finalReason = responseBody['banReason']?.isNotEmpty == true
                    ? responseBody['banReason']
                    : "Account is banned".tr;
              }

              NavigationHelper.navigateToAndRemoveUntil(AppRouter.bannedPath,
                  arguments: {
                    "isArchived": status == "archived",
                    "archiveReason": responseBody['archiveReason'],
                    "banReason": finalReason,
                    "bannedUntil": responseBody['bannedUntil'],
                    "daysRemaining": responseBody['daysRemaining'],
                    "deleteDate": responseBody['deleteDate'],
                    "deleteReason": responseBody['deleteReason'],
                  });
              return; // Stop further navigation
            }
          }
        } catch (e) {
          debugPrint("Background ban check failed: $e");
        }
      }

      if (saveMe && token != null && token.isNotEmpty) {
        NavigationHelper.navigateToAndRemoveUntil(
            AppRouter.bottomNavigationBar);
      } else {
        if (!saveMe) {
          SharedPref().removePreference(PrefKeys.accessToken);
        }
        NavigationHelper.navigateToAndRemoveUntil(AppRouter.selectServicesPath);
      }
    });
  }
}
