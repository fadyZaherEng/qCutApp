import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/modules/auth/views/widgets/custom_text_form.dart';
import 'package:q_cut/modules/customer/features/home_features/city_selection/logic/city_controller.dart';
import 'package:q_cut/modules/customer/features/home_features/city_selection/models/city_model.dart';

class CitySelectionView extends StatelessWidget {
  final bool isSelectionMode;
  final String? selectedCity;

  const CitySelectionView({
    super.key,
    this.isSelectionMode = true,
    this.selectedCity,
  });

  @override
  Widget build(BuildContext context) {
    final CityController controller = Get.find<CityController>();

    /// ✅ تحميل الاختيارات القديمة عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.loadSelectedCities();
    });

    return Scaffold(
      backgroundColor: ColorsData.secondary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isSelectionMode ? 'chooseCity'.tr : 'availableCities'.tr,
          style: Styles.textStyleS20W700(),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            final selected = controller.getSelectedCitiesAsString();
            Get.back(result: selected);
          },
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (isSelectionMode) {
            Get.back();
          }
          return true;
        },
        child: Column(
          children: [
            // Available Cities Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 24.0,
                ),
                decoration: BoxDecoration(
                  color: ColorsData.primary,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      AssetsData.creditIcon,
                      height: 24,
                      width: 24,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'availableCities'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomTextFormField(
                hintText: 'searchCity'.tr,
                prefixIcon: SvgPicture.asset(
                  AssetsData.searchIcon,
                  height: 20,
                  width: 20,
                  fit: BoxFit.scaleDown,
                ),
                onChanged: (value) {
                  controller.searchCities(value);
                },
              ),
            ),

            // City List Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'cityList'.tr,
                        style: Styles.textStyleS16W700(),
                      ),
                      if (isSelectionMode) ...[
                        const SizedBox(width: 8),
                        Obx(() => GestureDetector(
                          onTap: () => controller.toggleSelectAll(),
                          child: Row(
                            children: [
                              Text(
                                "(${'selectAll'.tr})",
                                style: Styles.textStyleS14W400(color: ColorsData.primary),
                              ),
                              Checkbox(
                                value: controller.isAllSelected(),
                                onChanged: (val) => controller.toggleSelectAll(),
                                activeColor: ColorsData.primary,
                              ),
                            ],
                          ),
                        )),
                      ],
                    ],
                  ),
                  Obx(() => Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: const BoxDecoration(
                          color: ColorsData.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${controller.filteredCities.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                ],
              ),
            ),

            // City List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.filteredCities.isEmpty) {
                  return const Center(
                      child: SpinKitDoubleBounce(color: ColorsData.primary));
                }

                if (controller.isError.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(controller.errorMessage.value),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: controller.refresh,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.filteredCities.isEmpty) {
                  return Center(
                    child: Text('noCitiesAvailable'.tr),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  itemCount: controller.filteredCities.length,
                  itemBuilder: (context, index) {
                    final city = controller.filteredCities[index];
                    return _buildCityItem(context, city, controller);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isSelectionMode
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          controller.clearSelections();
                          Get.back(); // إلغاء الاختيارات
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Cancel'.tr),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await controller.saveSelectedCities();
                          final selected =
                              controller.getSelectedCitiesAsString();
                          Get.back(result: selected);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsData.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Confirm'.tr),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildCityItem(
      BuildContext context, City city, CityController controller) {
    final isSelected = controller.isCitySelected(city);

    return Card(
      color: ColorsData.cardColor,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: const Icon(Icons.location_city,
            color: ColorsData.primary, size: 28),
        title: Text(
          city.name,
          style: Styles.textStyleS16W600(),
        ),
        trailing: isSelectionMode
            ? Obx(
                () => Checkbox(
                  value: controller.isCitySelected(city),
                  onChanged: (_) => controller.toggleCitySelection(city),
                  activeColor: ColorsData.primary,
                ),
              )
            : Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: ColorsData.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    city.name.isNotEmpty ? city.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
        onTap: () async {
          controller.toggleCitySelection(city);

          await controller.saveSelectedCities();
        },
      ),
    );
  }
}
