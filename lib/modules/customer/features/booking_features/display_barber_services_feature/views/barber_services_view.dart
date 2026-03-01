import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/widgets/custom_app_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_big_button.dart';
import 'package:q_cut/modules/customer/features/booking_features/display_barber_services_feature/logic/barber_services_controller.dart';
import 'package:q_cut/modules/customer/features/booking_features/display_barber_services_feature/models/free_time_request_model.dart';
import 'package:q_cut/modules/customer/features/booking_features/display_barber_services_feature/views/barber_service_card.dart';
import 'package:q_cut/modules/customer/features/home_features/home/models/barber_model.dart';

class BarberServicesView extends StatelessWidget {
  BarberServicesView({
    super.key,
  });

  final BarberServicesController controller =
      Get.put(BarberServicesController());

  @override
  Widget build(BuildContext context) {
    final dynamic arguments = Get.arguments;
    final Barber barber;
    List<String>? preSelectedServiceIds;

    if (arguments is Barber) {
      barber = arguments;
    } else if (arguments is Map) {
      barber = arguments['barber'];
      preSelectedServiceIds = arguments['preSelectedServiceIds'];
    } else {
      // Fallback redirect to home if arguments are missing
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRouter.bottomNavigationBar);
      });
      return Scaffold(
          body: Center(child: SpinKitDoubleBounce(color: ColorsData.primary)));
    }

    controller.barberId.value = barber.id;
    controller.fetchServices(barber.id,
        preSelectedServiceIds: preSelectedServiceIds);

    return Scaffold(
      appBar: CustomAppBar(title: "barberServices".tr),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
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
                    childAspectRatio: .81,
                  ),
                  itemCount: controller.barberServices.length,
                  itemBuilder: (context, index) {
                    final service = controller.barberServices[index];
                    return BarberServiceCard(
                      name: service.name,
                      imageUrl: service.imageUrl,
                      price: service.price,
                      duration: service.getDisplayDuration(),
                      isSelected: controller.selectedServices[index],
                      onPressed: () => controller.toggleService(index),
                    );
                  },
                ),
              ),
              SizedBox(height: 10.h),
              CustomBigButton(
                textData: "confirm".tr,
                onPressed: () async {
                  final selectedServicesList = controller.barberServices
                      .asMap()
                      .entries
                      .where((entry) => controller.selectedServices[entry.key])
                      .map((entry) => entry.value)
                      .toList();
                  if (selectedServicesList.isEmpty) {
                    Get.snackbar(
                      "noServiceSelected".tr,
                      "pleaseSelectAtLeastOneService".tr,
                      backgroundColor: ColorsData.primary,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  final freeTimeRequestModel =
                      FreeTimeRequestModel.fromServices(
                    barber.id,
                    selectedServicesList,
                  );

                  // Ensure the model exactly matches the required format when converted to JSON
                  print(freeTimeRequestModel.toJson());

                  Get.toNamed(
                    AppRouter.bookAppointmentPath,
                    arguments: {
                      'freeTimeRequestModel': freeTimeRequestModel,
                      'barber': barber,
                    },
                  );
                },
              ),
              SizedBox(height: 10.h),
            ],
          );
        }),
      ),
    );
  }
}
