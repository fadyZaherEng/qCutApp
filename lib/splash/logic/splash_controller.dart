import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/constants.dart';
import 'package:q_cut/core/utils/navigation_helper.dart';
import 'package:q_cut/core/services/shared_pref/pref_keys.dart';
import 'package:q_cut/core/services/shared_pref/shared_pref.dart';

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


  void _navigateAfterDelay() {
    Future.delayed(const Duration(seconds: kSplashDelay), () {
      String? token = SharedPref().getString(PrefKeys.accessToken);
      if (token != null && token.isNotEmpty) {
        NavigationHelper.navigateToAndRemoveUntil(AppRouter.bottomNavigationBar);
      } else {
        NavigationHelper.navigateToAndRemoveUntil(AppRouter.selectServicesPath);
      }
    });
  }
}