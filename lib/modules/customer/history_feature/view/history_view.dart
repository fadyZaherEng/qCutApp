import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/modules/customer/history_feature/view/previous_bookings_view.dart';
import 'package:q_cut/modules/customer/history_feature/controller/history_controller.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 الحالة المختارة للفلتر (افتراضي All)
    final RxString selectedFilter = 'all'.obs;

    return Scaffold(
      appBar: AppBar(
        title: Text('History'.tr),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          _buildFilterButton(
            context: context,
            selectedFilter: selectedFilter,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.previousAppointments.isEmpty) {
          return   const Center(
            child: SpinKitDoubleBounce(color: ColorsData.primary),
          );
        }
        
        if (controller.isError.value && controller.previousAppointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessage.value.tr,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchAppointments("previous"),
                  child: Text('Retry'.tr),
                ),
              ],
            ),
          );
        }

        return PreviousBookingsView(
          appointments: controller.previousAppointments,
        );
      }),
    );
  }

  Widget _buildFilterButton({
    required BuildContext context,
    required RxString selectedFilter,
  }) {
    return Obx(() {
      return PopupMenuButton<String>(
        initialValue: selectedFilter.value, // 🔥 يحافظ على الاختيار الحالي
        onSelected: (value) {
          selectedFilter.value = value;
          controller.filterAppointments(
            value,
            isPrevious: true,
          );
        },
        itemBuilder: (context) => [
          _buildMenuItem('all', 'All'.tr, selectedFilter.value),
          _buildMenuItem('attended', 'Completed'.tr, selectedFilter.value),
          _buildMenuItem('NotCome', 'Missed'.tr, selectedFilter.value),
        ],
        icon: const Icon(Icons.filter_list),
      );
    });
  }

  PopupMenuItem<String> _buildMenuItem(
      String value, String label, String selectedValue) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight:
                  selectedValue == value ? FontWeight.bold : FontWeight.normal,
              color: selectedValue == value ? ColorsData.primary : Colors.black,
            ),
          ),
          if (selectedValue == value) ...[
            const SizedBox(width: 6),
            const Icon(Icons.check, color: ColorsData.primary, size: 16),
          ],
        ],
      ),
    );
  }
}
