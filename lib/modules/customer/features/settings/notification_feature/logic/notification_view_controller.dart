import 'dart:ui';

import 'package:get/get.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'package:q_cut/modules/customer/features/settings/notification_feature/logic/notification_controller.dart';
import 'package:q_cut/modules/customer/features/settings/notification_feature/models/notification_model.dart';
import 'package:q_cut/modules/customer/features/home_features/appointment_feature/logic/appointment_controller.dart';
import 'package:q_cut/modules/customer/features/home_features/appointment_feature/view/appointment_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class NotificationViewModel extends GetxController {
  final NotificationController _controller = Get.find<NotificationController>();

  // Observable for UI state
  final RxBool isLoading = false.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;

  // Observable list of notifications
  final RxList<NotificationModel> displayedNotifications =
      <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize from controller's current state
    isLoading.value = _controller.isLoading.value;
    isError.value = _controller.isError.value;
    errorMessage.value = _controller.errorMessage.value;

    // Listen to changes in the notification controller
    ever(_controller.notifications, _updateViewModel);
    ever(_controller.isLoading, (loading) => isLoading.value = loading);
    ever(_controller.isError, (error) => isError.value = error);
    ever(_controller.errorMessage, (message) => errorMessage.value = message);

    // Initial load
    if (_controller.notifications.isNotEmpty) {
      _updateViewModel(_controller.notifications);
    }
  }

  void _updateViewModel(List<NotificationModel> notifications) {
    if (notifications.isEmpty) return;

    // Simply store all notifications for display
    displayedNotifications.clear();
    displayedNotifications.addAll(notifications);
  }

  // Utility methods
  String getFormattedAppointmentInfo(NotificationModel notification) {
    return notification.message;
  }

  String getWaitingListText(NotificationModel notification) {
    return notification.message;
  }

  String getNotificationTitle(NotificationModel notification) {
    return notification.user.fullName.isNotEmpty
        ? notification.user.fullName
        : "QCUT";
  }

  String getNotificationMessage(NotificationModel notification) {
    //check for language
    Locale currentLocale = Get.locale ?? const Locale('en');
    print("Current Locale: ${currentLocale.languageCode}");
    if (currentLocale.languageCode == 'ar' &&
        notification.messageAr.isNotEmpty) {
      return notification.messageAr;
    } else if (currentLocale.languageCode == 'he' &&
        notification.messageHe.isNotEmpty) {
      return notification.messageHe;
    }
    return notification.messageEn.isNotEmpty
        ? notification.messageEn
        : notification.message;
  }

  String getProfileImage(NotificationModel notification) {
    return notification.user.profilePic.isNotEmpty
        ? notification.user.profilePic
        : "https://via.placeholder.com/150";
  }

  // Check if a notification should have action buttons
  bool hasActions(NotificationModel notification) {
    return notification.process.isNotEmpty &&
        notification.process.startsWith("Request");
  }

  bool isAppointmentRelated(NotificationModel notification) {
    return notification.processId.isNotEmpty &&
        (notification.process.contains("Appointment") ||
            notification.process.contains("Request") ||
            notification.process.contains("Booking"));
  }

  // Actions
  void refreshNotifications() {
    _controller.refreshNotifications();
  }

  void handleAppointmentConfirmation(
      NotificationModel notification, bool confirmed) async {
    print(
        "Handling appointment ${confirmed ? 'confirmation' : 'rejection'} for notification ID: ${notification.id}");
    var response = await NetworkAPICall().editData(
      "${Variables.baseUrl}request-change-appointment-time/${confirmed ? "approve" : "reject"}/${notification.processId}/${notification.id}",
      {},
    );
    print(response.body);
    response.statusCode == 200
        ? ShowToast.showSuccessSnackBar(
            message: "Appointment ${confirmed ? 'confirmed' : 'rejected'}")
        : ShowToast.showError(message: "Notification is Expired".tr);

    refreshNotifications();
  }

  void goToAppointmentDetails(NotificationModel notification) async {
    if (notification.processId.isEmpty) return;

    // Show loading dialog
    Get.dialog(
      const Center(
        child: SpinKitDoubleBounce(
          color: ColorsData.primary,
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final appointmentController = Get.put(CustomerAppointmentController());
      final appointment =
          await appointmentController.fetchAppointmentById(notification.appointmentId);
      print("Fetched appointment: ${notification.appointmentId}");
      Get.back(); // Close loading dialog

      if (appointment != null) {
        Get.to(() => AppointmentDetailView(appointment: appointment));
      } else {
        ShowToast.showError(message: "Could not find appointment details".tr);
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      ShowToast.showError(message: "Error fetching appointment details".tr);
    }
  }

  String getTimeAgo(notification) {
    final now = DateTime.now();
    final difference = now.difference(notification.createdAt);

    if (difference.inSeconds < 60) {
      return 'just now'.tr;
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${'minutes ago'.tr}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${'hours ago'.tr}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${'days ago'.tr}';
    } else {
      // format as dd/mm/yyyy hh:mm with leading zeros
      final day = notification.createdAt.day.toString().padLeft(2, '0');
      final month = notification.createdAt.month.toString().padLeft(2, '0');
      final year = notification.createdAt.year;
      final hour = notification.createdAt.hour.toString().padLeft(2, '0');
      final minute = notification.createdAt.minute.toString().padLeft(2, '0');

      return '$day/$month/$year $hour:$minute';
    }
  }
}
