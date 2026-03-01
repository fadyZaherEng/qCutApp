import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/constants/drawer_constants.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/modules/barber/features/settings/history_feature/controller/history_controller.dart';
import 'package:q_cut/modules/barber/features/settings/history_feature/view/CustomBHistoryItem.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/logic/b_profile_controller.dart';

class BHistoryViewBody extends StatelessWidget {
  const BHistoryViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    // Make sure the controller is available, if not, initialize it
    final controller = Get.isRegistered<HistoryController>()
        ? Get.find<HistoryController>()
        : Get.put(HistoryController());

    // Use BProfileController for dynamic profile image
    final profileController = Get.isRegistered<BProfileController>()
        ? Get.find<BProfileController>()
        : Get.put(BProfileController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final profileImageUrl = profileController.profileData.value?.profilePic ?? 
                             DrawerConstants.defaultProfileImage;

      return RefreshIndicator(
        onRefresh: controller.refreshHistory,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 32.r,
                      foregroundImage: CachedNetworkImageProvider(profileImageUrl),
                      backgroundColor: ColorsData.secondary,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "previousAppointments".tr,
                      style: Styles.textStyleS14W700(),
                    ),
                    SizedBox(height: 11.h),
                    Divider(
                      thickness: 1.w,
                      color: ColorsData.cardStrock,
                    ),
                    Row(
                      children: [
                        Text(
                          "youHave".tr,
                          style: Styles.textStyleS14W400(),
                        ),
                        Text(
                          "(${controller.totalHistoryCount.value}) ",
                          style: Styles.textStyleS14W400(
                              color: ColorsData.primary),
                        ),
                      ],
                    ),
                    SizedBox(height: 11.h),
                  ],
                ),
              ),
            ),
            if (controller.historyItems.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50.h),
                    child: Text(
                      "noHistoryItemsFound".tr,
                      style: Styles.textStyleS14W700(),
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Load more when reaching end of the list
                    if (index == controller.historyItems.length - 1) {
                      controller.loadMoreHistory();
                    }

                    final item = controller.historyItems[index];
                    return Padding(
                      padding:
                          EdgeInsets.only(bottom: 8.h, left: 16.w, right: 16.w),
                      child: CustomBHistoryItem(
                        imageUrl: item.user.profilePic.isNotEmpty
                            ? item.user.profilePic
                            : DrawerConstants.defaultProfileImage,
                        name: item.user.fullName.isNotEmpty
                            ? item.user.fullName
                            : item.userName,
                        location:
                            "yourLocation".tr, // Using the translation key
                        service: item.serviceNames,
                        hairStyle: "${item.totalUsers} ${"consumer".tr}",
                        qty: "${item.totalUsers} ${"consumer".tr}",
                        bookingDay: item.formattedDay,
                        bookingTime: item.formattedTime,
                        type: "booking".tr,
                        price: item.price,
                        finalPrice: item.priceAfterTax,
                      ),
                    );
                  },
                  childCount: controller.historyItems.length,
                ),
              ),

            // Show loading indicator for pagination
            if (controller.isLoadingMore.value)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.h),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildInfoRow(String title, String value,
      {bool isPrice = false, bool isFinal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Styles.textStyleS12W500().copyWith(color: Colors.white),
          ),
          Text(
            value,
            style: Styles.textStyleS12W700().copyWith(
              color: isPrice
                  ? (isFinal ? Colors.amber : Colors.white)
                  : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
