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
import 'package:connectivity_plus/connectivity_plus.dart';


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
      String? token = SharedPref().getString(PrefKeys.accessToken);

      debugPrint("Splash: Checking connectivity before ban check...");
      final connectivityResult = await Connectivity().checkConnectivity();
      bool hasInternet = connectivityResult.any((result) => result != ConnectivityResult.none);

      if (hasInternet && phoneNumber != null && phoneNumber.isNotEmpty &&
          password != null && password.isNotEmpty && saveMe) {
        try {
          debugPrint("Splash: Online, performing ban check...");
          // Get FCM token only if online to avoid potential hangs
          final fcmToken = await getFCMToken().timeout(const Duration(seconds: 2), onTimeout: () => '');
          
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
                  'userType': isUserRole != null && isUserRole ? 'user' : 'barber',
                  "fcmToken": fcmToken,
                }),
              )
              .timeout(const Duration(seconds: 5));

          if (response.statusCode == 200) {
            final responseBody = jsonDecode(response.body);
            final bool isBanned = responseBody['isBanned'] ?? false;
            final String status = responseBody['status'] ?? '';

            if (hasInternet && (isBanned || status == "archived")) {
              String finalReason = "";
              if (status == "archived") {
                final String reason = responseBody['archiveReason'] ?? '';
                if (reason == "unpaid") {
                  finalReason = "Your account has been archived due to unpaid subscription.".tr;
                } else if (reason == "banned") {
                  finalReason = responseBody['banReason']?.isNotEmpty == true
                      ? responseBody['banReason']
                      : "Your account has been banned.".tr;
                } else if (reason == "deleted") {
                  finalReason = responseBody['deleteReason']?.isNotEmpty == true
                      ? responseBody['deleteReason']
                      : "Your account has been deleted.".tr;
                } else {
                  finalReason = "Your account has been archived. Please contact support.".tr;
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
              return;
            }
          }
        } catch (e) {
          debugPrint("Background ban check failed or timed out: $e");
        }
      } else {
        debugPrint("Splash: Offline or no credentials, skipping ban check.");
      }

      if (saveMe && token != null && token.isNotEmpty) {
        NavigationHelper.navigateToAndRemoveUntil(AppRouter.bottomNavigationBar);
      } else {
        if (!saveMe) {
          SharedPref().removePreference(PrefKeys.accessToken);
        }
        NavigationHelper.navigateToAndRemoveUntil(AppRouter.selectServicesPath);
      }
    });
  }
}
