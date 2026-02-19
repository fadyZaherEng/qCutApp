import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/widgets/custom_app_bar.dart';
import 'package:q_cut/modules/customer/features/settings/notification_feature/logic/notification_controller.dart';
import 'package:q_cut/modules/customer/features/settings/notification_feature/view/notification_view_body.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    Get.put(NotificationController());

    return Scaffold(
      appBar: CustomAppBar(title: "Notifications".tr),
      body: const NotificationViewBody(),
    );
  }
}
