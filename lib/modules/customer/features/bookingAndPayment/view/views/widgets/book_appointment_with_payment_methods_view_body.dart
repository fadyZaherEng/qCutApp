import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/services/shared_pref/pref_keys.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_big_button.dart';
import 'package:q_cut/modules/customer/features/bookingAndPayment/models/booking_payment_details_model.dart';
import 'package:q_cut/modules/customer/features/booking_features/select_appointment_time/controller/select_appointment_time_controller.dart';
import 'package:q_cut/modules/customer/features/home/presentation/views/widgets/custom_book_payment_methods_item.dart';
import '../../../../../../../core/services/shared_pref/shared_pref.dart';
import '../../../../../../../core/utils/app_router.dart';
import '../../../../../../../core/utils/network/network_helper.dart';

bool isClick = true;

class BookAppointmentWithPaymentMethodsViewBody
    extends GetView<SelectAppointmentTimeController> {
  const BookAppointmentWithPaymentMethodsViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final payment = Get.arguments["bookingPaymentDetailsModel"]
        as BookingPaymentDetailsModel;
    final pay = Get.arguments["pay"];
    final barber = Get.arguments["barber"];
    final serviceList = Get.arguments["serviceList"] as List<dynamic>?;
    
    int totalConsumers = 0;
    if (serviceList != null) {
      totalConsumers = serviceList.fold<int>(0, (sum, item) => sum + (item['numberOfUsers'] as int));
    }

    BookPaymentItemModel ff = BookPaymentItemModel(
      shopName: payment.salonName,
      bookingDay: payment.appointmentDate,
      bookingTime: payment.appointmentTime,
      price: payment.servicePrice,
      service: payment.serviceTitle,
      servicesList: serviceList,
      totalServicesQty: serviceList?.length ?? 1,
      totalConsumersQty: totalConsumers > 0 ? totalConsumers : 1,
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 17.w),
      child: SingleChildScrollView(
        child: Column(
          children: [
            CustomBookPaymentMethodsItem(
              model: ff,
              barber: barber,
            ),
            SizedBox(height: 24.h),
            Container(
              decoration: BoxDecoration(
                color: ColorsData.cardColor,
                borderRadius: BorderRadius.circular(16.r),
              ),
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 22.h,
                bottom: 38.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "totalRequiredAmount".tr,
                    style: Styles.textStyleS12W700(color: ColorsData.primary),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "servicePrice".tr,
                        style: Styles.textStyleS14W400(),
                      ),
                      Text(
                        "\$ ${payment.servicePrice}",
                        style: Styles.textStyleS10W700(),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "totalAmount".tr,
                        style: Styles.textStyleS14W400(),
                      ),
                      Text(
                        "\$ ${payment.servicePrice}",
                        style:
                            Styles.textStyleS10W700(color: ColorsData.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 32.h,
            ),
            const Divider(
              color: ColorsData.cardStrock,
            ),
            SizedBox(
              height: 16.h,
            ),
            CustomPaymentMethod(
              svgPath: AssetsData.cashIcon,
              title: "cash".tr,
              isSelected: true,
              onTap: () {
                //controller.toggleCashPayment();
              },
            ),
            const SizedBox(
              height: 20
            ),
            CustomBigButton(
              textData: "confirm".tr,
              onPressed: () async {
                if (!isClick) return; // ⛔ منع الضغط المتكرر
                isClick = false;
                // setState(() => isClick = false);

                try {
                  // 🟢 تجهيز الـ Payload
                  final bool isUserRole =
                      SharedPref().getBool(PrefKeys.userRole) ?? false;

                  final payload = isUserRole
                      ? {
                          "barber": pay["barber"],
                          "service": pay["service"],
                          "startDate": pay["startDate"],
                          "paymentMethod": "cash",
                        }
                      : {
                          "currentUser": {"userId": pay["barber"]},
                          "userName": "unknown",
                          "service": pay["service"],
                          "startDate": pay["startDate"],
                          "paymentMethod": "cash",
                        };

                  final endpoint = isUserRole
                      ? Variables.APPOINTMENT
                      : "${Variables.APPOINTMENT}barber-create-appointment";

                  print("➡️ API Request: $payload");
                  print("User Role: ${isUserRole ? "User" : "Barber"}");
                  print("Endpoint: $endpoint");

                  // ShowToast.showLoading(); // 🔄 إظهار لودينج

                  final response =
                      await NetworkAPICall().addData(payload, endpoint);

                  print(
                      "⬅️ API Response (${response.statusCode}): ${response.body}");

                  if (response.statusCode == 200) {
                    ShowToast.showSuccessSnackBar(
                      message: "appointmentBookedSuccessfully".tr,
                    );
                    Get.offAllNamed(AppRouter.bottomNavigationBar);
                  } else {
                    final String errorMessage = () {
                      try {
                        final data = jsonDecode(response.body);
                        return data["message"] ?? "failedToBookAppointment".tr;
                      } catch (_) {
                        return "failedToBookAppointment".tr;
                      }
                    }();
                    ShowToast.showError(message: _getErrorMessage(errorMessage));
                  }
                } catch (e, s) {
                  print("❌ Booking Error: $e\n$s");
                  ShowToast.showError(message: "somethingWentWrong".tr);
                } finally {
                  // ShowToast.hideLoading(); // ✅ إخفاء اللودينج
                  // if (mounted) {
                  await Future.delayed(const Duration(seconds: 2));
                  isClick = true;
                  // setState(() => isClick = true);
                  // }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  String _getErrorMessage(String message) {
    if (message.contains('|')) {
      final parts = message.split('|');
      if (Get.locale?.languageCode == 'ar' && parts.length > 1) {
        return parts[1].trim();
      }
      return parts[0].trim();
    }
    return message;
  }
}

class CustomPaymentMethod extends StatelessWidget {
  final String svgPath;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomPaymentMethod({
    super.key,
    required this.svgPath,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: ColorsData.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  svgPath,
                  width: 22.w,
                  height: 16.h,
                ),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: TextStyle(
                    color: ColorsData.font,
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ColorsData.bodyFont, width: 1),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorsData.primary,
                          ),
                        ),
                      )
                    : null),
          ],
        ),
      ),
    );
  }
}
