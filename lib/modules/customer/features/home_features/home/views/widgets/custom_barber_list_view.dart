import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/modules/customer/features/home_features/home/views/widgets/custom_barber_list_view_item.dart';
import 'package:q_cut/modules/customer/features/home_features/home/logic/home_controller.dart';
import 'package:q_cut/modules/customer/features/home_features/home/models/barber_model.dart';

class CustomBarberListView extends StatelessWidget {
  final List<Barber>? barbers;
  final bool isRecommended;
  final bool isSearching;

  const CustomBarberListView({
    super.key,
    this.barbers,
    this.isRecommended = false,
    this.isSearching = false,
  });

  static const int itemsPerRow = 5;

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: SpinKitDoubleBounce(color: ColorsData.primary),
        );
      }

      final displayBarbers = isSearching
          ? controller.searchResults.toList()
          : barbers ??
          (isRecommended
              ? controller.recommendedBarbers.toList()
              : controller.nearbyBarbers.toList());

      if (displayBarbers.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h), // Reduced from 10.h
            child: Text(
              "No barbers available".tr,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }

      final totalItems = displayBarbers.length;
      final numberOfRows = (totalItems / itemsPerRow).ceil();

      return Column(
        children: List.generate(numberOfRows, (rowIndex) {
          final startIdx = rowIndex * itemsPerRow;
          final endIdx = (startIdx + itemsPerRow > totalItems)
              ? totalItems
              : startIdx + itemsPerRow;

          final rowItems = displayBarbers.sublist(startIdx, endIdx);

          return SizedBox(
            height: 300.h,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, colIndex) {
                final barber = rowItems[colIndex];
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                  child: CustomBarberListViewItem(barber: barber),
                );
              },
              separatorBuilder: (context, index) => SizedBox(width: 8.w),
              itemCount: rowItems.length,
            ),
          );
        }),
      );
    });
  }
}