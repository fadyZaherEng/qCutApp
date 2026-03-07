import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_big_button.dart';

class BannedView extends StatelessWidget {
  const BannedView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final bool isArchived = args['isArchived'] ?? false;
    final String banReason = args['banReason'] ?? (isArchived 
        ? "Your account has been deleted. Please contact support for more details.".tr
        : "Your account has been banned for misuse of the app.".tr);
    final dynamic bannedUntilRaw = args['bannedUntil'];
    final int? bannedUntilMs =
        (bannedUntilRaw is int) ? bannedUntilRaw : null;
    final int? daysRemaining = args['daysRemaining'];

    String bannedUntilFormatted = "";
    if (bannedUntilMs != null && !isArchived) {
      final date = DateTime.fromMillisecondsSinceEpoch(bannedUntilMs);
      bannedUntilFormatted = DateFormat('dd/MM/yyyy').format(date);
    }
    
    String? deleteDateFormatted;
    if (args['deleteDate'] != null) {
      final date = DateTime.fromMillisecondsSinceEpoch(args['deleteDate']);
      deleteDateFormatted = DateFormat('dd/MM/yyyy HH:mm').format(date);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF3B384D), // Dark purple background
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 60.h),
              // Warning Icon inside circle
              Center(
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: const Color(0xFFD1A439),
                      size: 70.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              Text(
                isArchived 
                    ? (args['archiveReason'] == 'deleted' ? "accountDeleted".tr : "accountArchived".tr)
                    : "youGotBanned".tr,
                style: Styles.textStyleS24W600(color: const Color(0xFFD1A439)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),
              
              // Ban Info
              if (args['archiveReason'] != null) ...[
                _buildInfoSection("status".tr, args['archiveReason'].toString().tr),
                SizedBox(height: 24.h),
              ],
              
              _buildInfoSection(isArchived ? "reason".tr : "reason".tr, banReason),
              
              if (deleteDateFormatted != null) ...[
                SizedBox(height: 24.h),
                _buildInfoSection("deletionDate".tr, deleteDateFormatted),
              ],
              
              if (bannedUntilFormatted.isNotEmpty) ...[
                SizedBox(height: 24.h),
                _buildInfoSection("bannedUntil".tr, bannedUntilFormatted),
              ],
              
              if (daysRemaining != null && !isArchived) ...[
                SizedBox(height: 24.h),
                _buildInfoSection("daysRemaining".tr, "$daysRemaining ${"days".tr}"),
              ],
              
              const Spacer(),
              
              Text(
                isArchived 
                    ? (args['archiveReason'] == 'deleted' ? "contactSupportToRestoreDeleted".tr : "contactSupportToRestore".tr)
                    : "onceYouGetUnbanned".tr,
                style: Styles.textStyleS14W400(color: const Color(0xFFD1A439).withOpacity(0.8)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              CustomBigButton(
                textData: "contactQcut".tr,
                color: const Color(0xFFD1A439),
                onPressed: () {
                  Get.toNamed(AppRouter.chatWithUsPath);
                },
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Styles.textStyleS16W700(color: Colors.white),
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: Styles.textStyleS14W400(color: Colors.white.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}
