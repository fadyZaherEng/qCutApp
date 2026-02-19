import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/modules/customer/history_feature/model/customer_history_appointment.dart';
import 'package:intl/intl.dart';

class CustomBookItem extends StatelessWidget {
  final CustomerHistoryAppointment? appointment;

  const CustomBookItem({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 0.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: ColorsData.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Left image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              bottomLeft: Radius.circular(16.r),
            ),
            child: Image.asset(
              AssetsData.myAppointmentImage,
              width: 130.w,
              // height: 140.h,
              fit: BoxFit.fitHeight,
            ),
          ),

          /// Right content
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title Row
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          appointment?.barber.barberShop ?? "barberShop".tr,
                          style: Styles.textStyleS14W700(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        appointment?.paymentMethod.toUpperCase() ?? "cash".tr,
                        style: Styles.textStyleS12W600(
                          color: ColorsData.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  /// Info Rows
                  _buildInfoRow(
                    "service".tr,
                    appointment?.services
                            .map((s) => s.service.name)
                            .join(", ") ??
                        "Hair style",
                  ),
                  _buildInfoRow(
                    "price".tr,
                    "₪ ${appointment?.price.toString() ?? "0"}",
                  ),
                  _buildInfoRow(
                    "qty".tr,
                    "${(appointment?.services ?? []).fold(0, (sum, service) => (sum as int) + service.numberOfUsers)} ${'consumer'.tr}(s)",
                  ),
                  _buildInfoRow(
                    "bookingDay".tr,
                    appointment != null
                        ? DateFormat('EEE dd/MM/yyyy')
                            .format(appointment!.startDate)
                        : "Not set".tr,
                  ),
                  _buildInfoRow(
                    "bookingTime".tr,
                    appointment != null
                        ? "${DateFormat('hh:mm a').format(appointment!.startDate)} - ${DateFormat('hh:mm a').format(appointment!.endDate)}"
                        : "Not set".tr,
                  ),
                  _buildInfoRow(
                    "status".tr,
                    appointment?.status == "NotCome" ||
                            appointment?.status == "Notcome"
                        ? "Didn't Come".tr
                        : appointment?.status ?? "Pending".tr,
                    isHighlight: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: isHighlight
                  ? Styles.textStyleS13W600(color: ColorsData.primary)
                  : Styles.textStyleS13W400(),
            ),
          ),
          Text(
            value,
            style: isHighlight
                ? Styles.textStyleS13W600(color: ColorsData.primary)
                : Styles.textStyleS13W400(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
