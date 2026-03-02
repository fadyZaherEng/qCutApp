import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/splash/logic/splash_controller.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final SplashController controller = Get.put(SplashController());

    return Scaffold(
      body: AnimatedBuilder(
        animation: controller.animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: controller.fadeAnimation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        width: 127.w,
                        height: 130.h,
                        AssetsData.logo,
                      ),
                      SizedBox(width: 5.w),
                      SvgPicture.asset(
                        AssetsData.qCutTextImage,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}