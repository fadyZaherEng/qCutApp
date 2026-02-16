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
import 'package:q_cut/modules/customer/features/home_features/home/models/barber_model.dart';

import '../../display_barber_services_feature/models/free_time_request_model.dart';

class BookAppointmentView extends GetView<SelectAppointmentTimeController> {
  const BookAppointmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SelectAppointmentTimeController());
    if (Get.arguments == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRouter.bottomNavigationBar);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final selectedServices =
        Get.arguments["freeTimeRequestModel"] as FreeTimeRequestModel?;
    final barber = Get.arguments["barber"] as Barber;
    final isBarberBooking = Get.arguments["isBarber"] as bool? ?? false;

    if (selectedServices != null) {
      if (selectedServices.barber.isNotEmpty) {
        controller.barberId.value = selectedServices.barber;
        print("${"setBarberID".tr}: ${controller.barberId.value}");
      } else {
        print("warningBarberIDEmpty".tr);
      }

      // Prepare and store the services data
      if (selectedServices.services.isNotEmpty) {
        final servicesList = selectedServices.services
            .map((service) => {
                  "service": service.service,
                  "numberOfUsers": service.numberOfUsers
                })
            .toList();

        controller.setSelectedServices(servicesList);
        print("${"setServices".tr}: ${controller.selectedServices}");
      } else {
        print("warningNoServices".tr);
      }

      // Fetch available days immediately without any delay
      controller.getAvailableDays(selectedServices);

      // Fetch working hours range to get walk-in info
      controller.fetchWorkingHoursRange(barber.id);

      // Manually add test timestamps if needed for debugging
      if (controller.availableDaysTimestamps.isEmpty) {
        print("addingTestTimestamps".tr);
        final now = DateTime.now().millisecondsSinceEpoch;
        const oneDayMs = 86400000; // 24 hours in milliseconds

        // Add the next 7 days as test data
        for (int i = 0; i < 7; i++) {
          final dayTimestamp = now + (i * oneDayMs);
          print(
              "${"addingTestDay".tr}: ${DateTime.fromMillisecondsSinceEpoch(dayTimestamp)}");
          controller.availableDaysTimestamps.add(dayTimestamp);
        }
      }
    }

    return Scaffold(
      appBar: CustomAppBar(title: "bookAppointment".tr),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Obx(() {
          // Show loading indicator if data is being loaded
          if (controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SpinKitDoubleBounce(color: ColorsData.primary),
                  SizedBox(height: 20.h),
                  Text(
                    "loadingAvailableAppointments".tr,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey,
                    ),
                  )
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
                    services: selectedServices.barberServices,
                    quantities: selectedServices.services
                        .asMap()
                        .entries
                        .map((entry) => entry.value.numberOfUsers)
                        .toList(),
                    barber: barber,
                  )
                else
                  Center(child: Text("errorLoadingData".tr)),
                SizedBox(height: 17.h),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "availableAppointments".tr,
                    style: Styles.textStyleS16W700(),
                  ),
                ),
                SizedBox(height: 24.h),
                Obx(() {
                  print(
                      "${"daysPickerRebuilding".tr} ${controller.availableDaysTimestamps.length} ${"days".tr}");
                  return CustomBSimpleDaysPicker(
                    selectedDay: controller.selectedDay.value,
                    onDaySelected: (day) {
                      print("${"daySelectedInUI".tr}: $day");
                      if (selectedServices != null) {
                        controller.changeSelectedDay(
                            day, selectedServices.onHolding);
                      }
                    },
                    titleSimpleDaysPicker: "selectDay".tr,
                  );
                }),
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
                  builder: (controller) => const CustomAvailableTime(),
                ),
                SizedBox(height: 24.h),
                if (!isBarberBooking) ...[
                  Text(
                    "ifAppointmentsDontFit".tr,
                    style: Styles.textStyleS16W400(),
                  ),
                  Row(
                    children: [
                      Text(
                        "youCanSelectFrom".tr,
                        style: Styles.textStyleS16W400(),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (selectedServices != null) {
                            Get.toNamed(AppRouter.onHoldAppointmentPath,
                                arguments:
                                    selectedServices.copyWith(onHolding: true));
                          }
                        },
                        child: Text(
                          textAlign: TextAlign.left,
                          "onHoldAppointments".tr,
                          style:
                              Styles.textStyleS16W400(color: ColorsData.primary),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                ],
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: Obx(() {
        final isSlotSelected = controller.selectedTimeSlot.value != null;
        return SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: ColorsData.secondary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomBigButton(
                    textData: "cancel".tr,
                    color: Colors.grey.shade300,
                    onPressed: () => Get.back(),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Opacity(
                    opacity: isSlotSelected ? 1.0 : 0.5,
                    child: CustomBigButton(
                      textData: "confirm".tr,
                      onPressed: isSlotSelected
                          ? () {
                              if (selectedServices == null) return;
                              print("confirmButtonPressed".tr);
                              final slot = controller.selectedTimeSlot.value!;
                              final startTime =
                                  DateFormat('HH:mm').format(slot.startTime);
                              final endTime =
                                  DateFormat('HH:mm').format(slot.endTime);
                              final timeRange = "$startTime-$endTime";

                              // 🟢 جهز بيانات الخدمات مرة واحدة
                              final services = selectedServices.services;
                              final barberServices =
                                  selectedServices.barberServices!;

                              final serviceList =
                                  services.asMap().entries.map((entry) {
                                final index = entry.key;
                                final selected = entry.value;
                                final barberService = barberServices[index];
                                return {
                                  "service": selected.service,
                                  "numberOfUsers": selected.numberOfUsers,
                                  "name": barberService.name,
                                  "price": barberService.price,
                                  "total": barberService.price *
                                      selected.numberOfUsers,
                                };
                              }).toList();

                              // 🟢 العناوين + الأسعار
                              final serviceTitle = serviceList
                                  .map((s) =>
                                      "${s["name"]} x${s["numberOfUsers"]}")
                                  .join(", ");
                              final servicePrice = serviceList.fold<double>(
                                0,
                                (sum, s) =>
                                    sum +
                                    ((s["price"] as num).toDouble() *
                                        (s["numberOfUsers"] as int)),
                              );

                              final totalAmount = serviceList.fold<double>(
                                  0,
                                  (sum, s) =>
                                      sum + (s["total"] as num).toDouble());

                              // 🟢 إنشاء الموديل
                              final bookingPaymentDetailsModel =
                                  BookingPaymentDetailsModel(
                                serviceTitle: serviceTitle,
                                servicePrice: servicePrice,
                                totalAmount: totalAmount,
                                barberName: controller.barberName.value,
                                barberImage: controller.barberImage.value,
                                salonName: barberServices.first.name,
                                appointmentDate: slot.dayName.toString(),
                                appointmentTime: timeRange,
                                serviceDuration:
                                    "20", // TODO: احسبها ديناميك لو متاحة
                              );

                              // 🟢 بيانات الدفع
                              final bookingData = {
                                "barber": controller.barberId.value,
                                "service": serviceList
                                    .map((s) => {
                                          "service": s["service"],
                                          "numberOfUsers": s["numberOfUsers"],
                                        })
                                    .toList(),
                                "startDate":
                                    slot.startTime.millisecondsSinceEpoch,
                                "paymentMethod": "cash",
                              };

                              // Debug log
                              print(bookingData);
                              final barber = Get.arguments["barber"] as Barber;

                              // 🟢 الانتقال مع البيانات
                              Get.toNamed(
                                AppRouter.bookAppointmentWithPaymentMethodsPath,
                                arguments: {
                                  "pay": bookingData,
                                  "bookingPaymentDetailsModel":
                                      bookingPaymentDetailsModel,
                                  "barber": barber,
                                  "serviceList": serviceList,
                                },
                              );
                            }
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
