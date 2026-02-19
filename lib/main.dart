import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/localization/change_local.dart';
import 'package:q_cut/core/notification/firebase_cloud_messaging.dart';
import 'package:q_cut/core/notification/notfication.dart';
import 'package:q_cut/core/services/shared_pref/shared_pref.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/modules/customer/features/home_features/home/models/barber_model.dart';
import 'package:q_cut/qcut_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/shared_pref/pref_keys.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';

String profileImage = "";
String coverImage = "";
String fullName = "";
String phoneNumber = "";
String currentBarberId = "";
String instagramLink = "";
Barber? currentBarber;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Preferences first
  await SharedPref().instantiatePreferences();

  // 2. Initialize variables from preferences
  profileImage = SharedPref().getString(PrefKeys.profilePic) ?? " ";
  coverImage = SharedPref().getString(PrefKeys.coverPic) ?? " ";
  fullName = SharedPref().getString(PrefKeys.fullName) ?? "";
  phoneNumber = SharedPref().getString(PrefKeys.phoneNumber) ?? " ";
  currentBarberId = SharedPref().getString(PrefKeys.barberId) ?? "";
  instagramLink = SharedPref().getString(PrefKeys.instagramLink) ?? "";

  String? barberJson = SharedPref().getString(PrefKeys.barber);
  if (barberJson != null) {
    try {
      currentBarber = Barber.fromJson(jsonDecode(barberJson));
    } catch (e) {
      debugPrint("Error decoding barberJson: $e");
      currentBarber = _getDefaultBarber();
    }
  } else {
    currentBarber = _getDefaultBarber();
  }

  // 3. Date Formatting
  await initializeDateFormatting();

  // 4. Firebase & Notifications
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseCloudMessaging().init();
    await LocalNotificationService.init();

    // Listen for notification clicks AFTER init
    onNotificationClick?.stream.listen((event) {
      if (event != null && event.isNotEmpty) {
        Get.toNamed(AppRouter.notificationPath);
      }
    });
  } catch (error) {
    debugPrint('Firebase/Notification Init Error: $error');
  }

  // 5. Initialize Locale & Run
  Get.put(LocaleController(), permanent: true);
  runApp(const QCut());
}

Barber _getDefaultBarber() {
  return Barber(
    id: currentBarberId,
    fullName: fullName,
    phoneNumber: phoneNumber,
    userType: "barber",
    coverPic: coverImage,
    instagramPage: instagramLink,
    profilePic: profileImage,
    city: "",
    isFavorite: false,
    status: "active",
    offDay: [],
    workingDays: [],
  );
}
