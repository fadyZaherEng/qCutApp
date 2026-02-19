import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_button.dart';
import 'package:q_cut/modules/customer/features/settings/notification_feature/models/notification_model.dart';
import 'package:get/get.dart';
import 'package:q_cut/modules/customer/features/settings/notification_feature/logic/notification_controller.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final String relativeTime;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.relativeTime,
  });

  @override
  Widget build(BuildContext context) {
    // Determine notification type based on process
    switch (notification.process) {
      case 'appointment_reminder':
        return _buildAppointmentReminder();
      case 'waiting_list_accepted':
        return _buildWaitingListAccepted();
      default:
        return _buildDefaultNotification();
    }
  }

  Widget _buildAppointmentReminder() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: ColorsData.cardColor,
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32.r,
                foregroundImage: notification.user.profilePic.isNotEmpty
                    ? CachedNetworkImageProvider(notification.user.profilePic)
                    : const AssetImage(AssetsData.circleQCutImage)
                        as ImageProvider,
                backgroundColor: ColorsData.secondary,
              ),
              SizedBox(width: 7.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Reminder for appointment",
                      style: Styles.textStyleS14W700(),
                    ),
                    Text(
                      notification.message,
                      style: Styles.textStyleS10W400(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomButton(
                      width: 138.w,
                      text: "Yes",
                      onPressed: () {
                        // Handle appointment confirmation
                      },
                    ),
                    CustomButton(
                      backgroundColor: ColorsData.cardStrock,
                      width: 138.w,
                      text: "No",
                      onPressed: () {
                        // Handle appointment rejection
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                CustomButton(
                  width: double.infinity,
                  text: "See details",
                  backgroundColor: Colors.blueGrey, // Distinct color
                  onPressed: () {
                    // Fetch and show details
                    Get.find<NotificationController>()
                        .fetchAndShowAppointmentDetails(notification.processId);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingListAccepted() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: ColorsData.cardColor,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32.r,
            foregroundImage: notification.user.profilePic.isNotEmpty
                ? CachedNetworkImageProvider(notification.user.profilePic)
                : const AssetImage(AssetsData.circleQCutImage) as ImageProvider,
            backgroundColor: ColorsData.secondary,
          ),
          SizedBox(width: 7.w),
          Expanded(
            child: Text(
              notification.message,
              style: Styles.textStyleS14W700(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultNotification() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: ColorsData.cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26.r,
                foregroundImage: notification.user.profilePic.isNotEmpty
                    ? CachedNetworkImageProvider(notification.user.profilePic)
                    : const AssetImage(AssetsData.circleQCutImage)
                        as ImageProvider,
                backgroundColor: ColorsData.secondary,
              ),
              SizedBox(width: 7.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.user.fullName.isNotEmpty
                          ? notification.user.fullName
                          : "QCUT",
                      style: Styles.textStyleS14W700(),
                    ),
                    Text(
                      notification.message,
                      style: Styles.textStyleS10W400(),
                    ),
                    Text(
                      relativeTime,
                      style: Styles.textStyleS8W400().copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (notification.processId.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: CustomButton(
                width: double.infinity,
                text: "See details",
                backgroundColor: Colors.blueGrey,
                onPressed: () {
                  Get.find<NotificationController>()
                      .fetchAndShowAppointmentDetails(notification.processId);
                },
              ),
            ),
        ],
      ),
    );
  }
}
