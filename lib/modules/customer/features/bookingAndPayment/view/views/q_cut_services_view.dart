import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_app_bar.dart';
import 'package:q_cut/core/utils/widgets/custom_big_button.dart';
import 'package:q_cut/modules/customer/features/bookingAndPayment/view/views/widgets/q_cut_service_card.dart';
import 'package:q_cut/modules/customer/features/home_features/home/models/barber_model.dart';
import 'package:q_cut/modules/customer/features/bookingAndPayment/logic/q_cut_services_controller.dart';
import '../../../booking_features/display_barber_services_feature/models/free_time_request_model.dart';

class QCutServicesView extends StatelessWidget {
  QCutServicesView({super.key});

  final QCutServicesController controller = Get.put(QCutServicesController());

  @override
  Widget build(BuildContext context) {
    if (Get.arguments == null || Get.arguments is! Map || Get.arguments["barber"] == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRouter.bottomNavigationBar);
      });
      return const Scaffold(body: Center(child: SpinKitDoubleBounce(color: ColorsData.primary)));
    }

    final barber = Get.arguments["barber"] as Barber;
    final isBarber = Get.arguments["isBarber"] as bool? ?? false;
    final numberofUsers = Get.arguments["isMultiple"] as int? ?? 1;

    print("num of users: $numberofUsers");
    controller.barberId.value = barber.id;
    controller.fetchServices(barber.id);
    return Scaffold(
      appBar: CustomAppBar(title: "qcutServices".tr),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
                child: SpinKitDoubleBounce(color: ColorsData.primary));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "${'services'.tr} ",
                    style: Styles.textStyleS16W700(color: Colors.white),
                  ),
                  Text(
                    "(${controller.barberServices.length} ${'servicesCount'.tr})",
                    style: Styles.textStyleS14W700(color: ColorsData.primary),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: .74,
                  ),
                  itemCount: controller.barberServices.length,
                  itemBuilder: (context, index) {
                    final service = controller.barberServices[index];
                    return QCutServiceCard(
                      service: service,
                      isSelected: controller.selectedServices[index],
                      onPressed: () => controller.toggleService(index),
                      numberofUsers: numberofUsers,
                      onQuantityChanged: (quantity) {
                        if(quantity>numberofUsers) {
                          Get.snackbar(
                            "warning".tr,
                            "${'youCannotSelectMoreThan'.tr} $numberofUsers ${'services'.tr}",
                            backgroundColor: Colors.red.withOpacity(0.8),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }
                        controller.updateServiceQuantity(index, quantity);
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),
              CustomBigButton(
                textData: "confirm".tr,
                onPressed: () async {
                  final selectedIndices = controller.selectedServices
                      .asMap()
                      .entries
                      .where((entry) => entry.value)
                      .map((entry) => entry.key)
                      .toList();

                  final selectedServicesList = selectedIndices
                      .map((index) => controller.barberServices[index])
                      .toList();

                  final List<int> quantities = selectedIndices
                      .map((index) => controller.serviceQuantities[index])
                      .toList();

                  // ✅ اجمالي الكمية المختارة
                  final int totalSelectedQuantity =
                      quantities.fold(0, (a, b) => a + b);

                  // ✅ تحقق ديناميكي حسب عدد الأشخاص
                  if (numberofUsers > 1 &&
                      totalSelectedQuantity < numberofUsers) {
                    Get.snackbar(
                      "warning".tr,
                      "${'youMustSelectAtLeast'.tr} $numberofUsers ${'services'.tr}",
                      backgroundColor: Colors.red.withOpacity(0.8),
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }
                  if (isBarber && selectedServicesList.isEmpty) {
                    Get.snackbar(
                      "warning".tr,
                      "${'youMustSelectAtLeast'.tr} 1 ${'services'.tr}",
                      backgroundColor: Colors.red.withOpacity(0.8),
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }
                  final freeTimeRequestModel =
                      FreeTimeRequestModel.fromServices(
                    barber.id,
                    selectedServicesList,
                    serviceQuantities: quantities,
                    onHolding: false,
                  );

                  Get.toNamed(
                    AppRouter.bookAppointmentPath,
                    arguments: {
                      "freeTimeRequestModel": freeTimeRequestModel,
                      "barber": barber,
                      "isBarber": isBarber,
                    },
                  );
                },
              ),
              SizedBox(height: 48.h),

            ],
          );
        }),
      ),
    );
  }
}
