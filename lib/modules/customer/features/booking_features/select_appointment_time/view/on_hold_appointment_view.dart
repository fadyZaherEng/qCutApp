import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_app_bar.dart';
import 'package:q_cut/core/utils/widgets/custom_big_button.dart';
import 'package:q_cut/modules/customer/features/bookingAndPayment/models/booking_payment_details_model.dart';
import 'package:q_cut/modules/customer/features/booking_features/select_appointment_time/controller/select_appointment_time_controller.dart';
import 'package:q_cut/modules/customer/features/booking_features/select_appointment_time/view/widgets/custom_available_time.dart';
import 'package:q_cut/modules/customer/features/booking_features/select_appointment_time/view/widgets/custom_b_simple_days_picker.dart';
import 'package:q_cut/modules/customer/features/booking_features/select_appointment_time/view/widgets/custom_book_appointment_item.dart';
import 'package:intl/intl.dart';
import '../../display_barber_services_feature/models/free_time_request_model.dart';

class OnHoldAppointmentView extends StatefulWidget {
  const OnHoldAppointmentView({super.key});

  @override
  State<OnHoldAppointmentView> createState() => _OnHoldAppointmentViewState();
}

class _OnHoldAppointmentViewState extends State<OnHoldAppointmentView> {
  late final SelectAppointmentTimeController controller;
  FreeTimeRequestModel? selectedServices;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SelectAppointmentTimeController());
    selectedServices = Get.arguments as FreeTimeRequestModel?;

    // Defer initialization until after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllerData();
    });
  }

  void _initializeControllerData() {
    if (selectedServices != null) {
      // Set barber ID in the controller
      if (selectedServices!.barber.isNotEmpty) {
        controller.barberId.value = selectedServices!.barber;
        print("Set barber ID for on-hold: ${controller.barberId.value}");
      } else {
        print("Warning: Barber ID is null or empty in on-hold view");
      }

      // Prepare and store the services data
      if (selectedServices!.services.isNotEmpty) {
        final servicesList = selectedServices!.services
            .map(
              (service) => {
                "service": service.service,
                "numberOfUsers": service.numberOfUsers
              },
            )
            .toList();

        controller.setSelectedServices(servicesList);
        print("Set services for on-hold: ${controller.selectedServices}");
      } else {
        print("Warning: No services selected in on-hold view");
      }

      // Fetch available on-hold days with onholding flag
      final requestModel = selectedServices!.copyWith(onHolding: true);
      controller.getAvailableDays(requestModel.copyWith(onHolding: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "onHoldAppointment".tr),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Obx(() {
          // Show loading indicator if data is being loaded
          if (controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitDoubleBounce(color: ColorsData.primary),
                  SizedBox(height: 20.h),
                  Text("Loading on-hold appointments...",
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey))
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedServices != null)
                  CustomBookAppointmentItem(
                    services: selectedServices!.barberServices,
                    quantities: selectedServices!.services
                        .asMap()
                        .entries
                        .map((entry) => entry.value.numberOfUsers)
                        .toList(),
                  ),
                SizedBox(height: 17.h),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "onHoldAppointments".tr,
                    style: Styles.textStyleS16W700(),
                  ),
                ),
                SizedBox(height: 24.h),
                CustomBSimpleDaysPicker(
                  selectedDay: controller.selectedDay.value,
                   onDaySelected: (day) {
                    print("On-hold day selected in UI: $day");
                    controller.changeSelectedDay(
                        day, selectedServices!.onHolding);
                  },
                  titleSimpleDaysPicker: "Select Day",
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    SvgPicture.asset(AssetsData.clockIcon),
                    SizedBox(width: 5.w),
                    Text("availableTime".tr, style: Styles.textStyleS16W400()),
                  ],
                ),
                SizedBox(height: 24.h),
                // Use GetBuilder with specific ID for time slots to prevent full UI rebuilds
                GetBuilder<SelectAppointmentTimeController>(
                  id: 'timeSlots',
                  builder: (controller) => CustomAvailableTime(),
                ),
                SizedBox(height: 24.h),
                CustomBigButton(
                  textData: "confirm".tr,
                  onPressed: () {
                    if (controller.selectedTimeSlot.value == null ||
                        selectedServices == null) {
                      Get.snackbar('Error', 'Please select a time slot first');
                      return;
                    }

                    final startTime = DateFormat('h:mm a')
                        .format(controller.selectedTimeSlot.value!.startTime);

                    // Print booking model data with onholding flag
                    print({
                      "barber": controller.barberId.value,
                      "service": selectedServices!.services
                          .asMap()
                          .entries
                          .map((entry) => {
                                "service": entry.value.service,
                                "numberOfUsers": entry.value.numberOfUsers
                              })
                          .toList(),
                      "startDate": controller.selectedTimeSlot.value!.startTime
                          .millisecondsSinceEpoch,
                      "paymentMethod": "cash",
                      "onholding": true
                    });

                    BookingPaymentDetailsModel bookingPaymentDetailsModel =
                        BookingPaymentDetailsModel(
                            serviceTitle: selectedServices!.services
                                .asMap()
                                .entries
                                .map((entry) =>
                                    "${selectedServices!.barberServices![entry.key].name} x${entry.value.numberOfUsers}")
                                .join(", "),
                            servicePrice: selectedServices!.barberServices!
                                .asMap()
                                .entries
                                .map((entry) =>
                                    entry.value.price *
                                    selectedServices!
                                        .services[entry.key].numberOfUsers)
                                .reduce((a, b) => a + b)
                                .toDouble(),
                            totalAmount: selectedServices!.services
                                .asMap()
                                .entries
                                .map((entry) =>
                                    selectedServices!
                                        .barberServices![entry.key].price *
                                    selectedServices!
                                        .services[entry.key].numberOfUsers)
                                .reduce((a, b) => a + b)
                                .toDouble(),
                            barberName: controller.barberName.value,
                            barberImage: controller.barberImage.value,
                            salonName:
                                selectedServices!.barberServices!.first.name,
                            appointmentDate: controller
                                .selectedTimeSlot.value!.dayName
                                .toString(),
                            appointmentTime: startTime,
                            serviceDuration: "20");

                    Get.toNamed(AppRouter.bookAppointmentWithPaymentMethodsPath,
                        arguments: {
                          "pay": {
                            "barber": controller.barberId.value,
                            "service": selectedServices!.services
                                .asMap()
                                .entries
                                .map((entry) => {
                                      "service": entry.value.service,
                                      "numberOfUsers": selectedServices!
                                          .services[entry.key].numberOfUsers
                                    })
                                .toList(),
                            "startDate": controller.selectedTimeSlot.value!
                                .startTime.millisecondsSinceEpoch,
                            "paymentMethod": "cash",
                            "onholding": true
                          },
                          "bookingPaymentDetailsModel":
                              bookingPaymentDetailsModel
                        });
                  },
                ),
                SizedBox(height: 24.h),
              ],
            ),
          );
        }),
      ),
    );
  }
}
