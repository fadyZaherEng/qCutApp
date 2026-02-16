import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_button.dart';
import 'package:q_cut/modules/customer/features/settings/notification_feature/logic/notification_view_controller.dart';

class NotificationViewBody extends StatelessWidget {
  const NotificationViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the view model for data
    final viewModel = Get.put(NotificationViewModel());

    return Obx(() {
      // Show loading spinner only when actively loading
      if (viewModel.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            color: ColorsData.primary,
          ),
        );
      }

      // Show empty state if no notifications
      if (viewModel.displayedNotifications.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_off_outlined,
                size: 80.sp,
                color: ColorsData.primary.withOpacity(0.5),
              ),
              SizedBox(height: 16.h),
              Text(
                'noNotifications'.tr,
                style: Styles.textStyleS16W700(
                  color: ColorsData.primary.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'noNotificationsMessage'.tr,
                style: Styles.textStyleS14W400(
                  color: ColorsData.primary.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      // Display notifications if not empty
      return RefreshIndicator(
        onRefresh: () async => viewModel.refreshNotifications(),
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
          itemCount: viewModel.displayedNotifications.length,
          separatorBuilder: (context, index) =>
              index != viewModel.displayedNotifications.length - 1
                  ? SizedBox(height: 16.h)
                  : SizedBox(height: 32.h),
          itemBuilder: (context, index) {
            final notification = viewModel.displayedNotifications[index];
            print(notification.process);
            return NotificationCard(
              notification: notification,
              viewModel: viewModel,
              isLast: index == viewModel.displayedNotifications.length - 1,
            );
          },
        ),
      );
    });
  }
}

class NotificationCard extends StatelessWidget {
  final dynamic notification;
  final NotificationViewModel viewModel;
  final bool isLast;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.viewModel,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: ColorsData.cardColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 28.r,
                    foregroundImage: CachedNetworkImageProvider(
                      viewModel.getProfileImage(notification),
                    ),
                    backgroundColor: ColorsData.secondary,
                  ),
                  SizedBox(width: 7.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          viewModel.getNotificationTitle(notification),
                          style: Styles.textStyleS14W700(),
                        ),
                        Text(
                          viewModel.getNotificationMessage(notification),
                          style: Styles.textStyleS13W400(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Only show action buttons if notification has a process
              if (viewModel.hasActions(notification))
                Padding(
                  padding: EdgeInsets.only(top: 16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomButton(
                        width: 138.w,
                        text: "Yes".tr,
                        onPressed: () => viewModel
                            .handleAppointmentConfirmation(notification, true),
                      ),
                      CustomButton(
                        backgroundColor: ColorsData.cardStrock,
                        width: 138.w,
                        text: "No".tr,
                        onPressed: () => viewModel
                            .handleAppointmentConfirmation(notification, false),
                      ),
                    ],
                  ),
                ),

              // Add "See Details" button for appointment related notifications
              if (notification.appointmentId.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Center(
                    child: CustomButton(
                      width: 200.w,
                      text: "seeDetails".tr,
                      onPressed: () =>
                          viewModel.goToAppointmentDetails(notification),
                    ),
                  ),
                ),

              SizedBox(height: 4.h),
              // Time ago
              Align(
                alignment: Get.locale!.languageCode == 'ar'
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Text(
                  viewModel.getTimeAgo(notification),
                  style: Styles.textStyleS13W400(
                    color: ColorsData.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isLast) SizedBox(height: 48.h),
      ],
    );
  }
}
