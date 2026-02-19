import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_big_button.dart';

class PasswordResetSuccessView extends StatefulWidget {
  const PasswordResetSuccessView({super.key});

  @override
  State<PasswordResetSuccessView> createState() =>
      _PasswordResetSuccessViewState();
}

class _PasswordResetSuccessViewState extends State<PasswordResetSuccessView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            ScaleTransition(
              scale: _animation,
              child: Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: ColorsData.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 60.sp,
                ),
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              "Password updated Successfully".tr,
              textAlign: TextAlign.center,
              style: Styles.textStyleS16W700(color: ColorsData.primary)
                  .copyWith(fontSize: 20.sp),
            ),
            Spacer(),
            CustomBigButton(
              textData: "Ok".tr,
              onPressed: () {
                Get.offAllNamed(AppRouter.bottomNavigationBar); 
              },
            ),
            SizedBox(height: 50.h),
          ],
        ),
      ),
    );
  }
}
