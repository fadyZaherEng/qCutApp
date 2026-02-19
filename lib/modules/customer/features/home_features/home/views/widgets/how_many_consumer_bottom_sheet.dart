import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/auth/auth_helper.dart';
import 'package:q_cut/modules/customer/features/home_features/home/models/barber_model.dart';

class HowManyConsumerBottomSheet extends StatelessWidget {
  final Barber? barber;

  const HowManyConsumerBottomSheet({super.key, this.barber});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Icon(Icons.close, size: 24.sp),
              ),
            ),
            SizedBox(height: 5.h),
            SvgPicture.asset(
              AssetsData.profileIcon,
              height: 32.h,
              width: 24.w,
              colorFilter: const ColorFilter.mode(
                ColorsData.primary,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "howManyConsumerWillBookAppointment".tr,
              textAlign: TextAlign.center,
              style: Styles.textStyleS14W700(color: ColorsData.secondary),
            ),
            SizedBox(height: 16.h),
            _buildOption(
              context,
              "onlyOneConsumer".tr,
              () {
                // Check authentication before booking
                if (!AuthHelper.requireAuthentication(returnRoute: AppRouter.barberServicesPath)) {
                  return; // User redirected to login
                }
                Get.toNamed(AppRouter.barberServicesPath, arguments: barber);
              },
            ),
            _buildOption(
              context,
              "twoConsumers".tr,
              () {
                // Check authentication before booking
                if (!AuthHelper.requireAuthentication(returnRoute: AppRouter.qCutServicesPath)) {
                  return; // User redirected to login
                }
                Get.toNamed(AppRouter.qCutServicesPath, arguments: {
                  "barber": barber,
                  "isMultiple": 2,
                });
              },
            ),
            _buildOption(
              context,
              "threeConsumers".tr,
              () {
                // Check authentication before booking
                if (!AuthHelper.requireAuthentication(returnRoute: AppRouter.qCutServicesPath)) {
                  return; // User redirected to login
                }
                Get.toNamed(AppRouter.qCutServicesPath, arguments: {
                  "barber": barber,
                  "isMultiple": 3,
                });
              },
            ),
            _buildOption(
              context,
              "fourConsumers".tr,
              () {
                // Check authentication before booking
                if (!AuthHelper.requireAuthentication(returnRoute: AppRouter.qCutServicesPath)) {
                  return; // User redirected to login
                }
                Get.toNamed(AppRouter.qCutServicesPath, arguments: {
                  "barber": barber,
                  "isMultiple": 4,
                });
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
      BuildContext context, String text, void Function()? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: Styles.textStyleS14W400(color: ColorsData.secondary),
          ),
        ),
      ),
    );
  }
}
