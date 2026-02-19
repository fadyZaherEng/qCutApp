import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_app_bar.dart';
import 'package:q_cut/core/utils/widgets/custom_big_button.dart';
import 'package:q_cut/modules/customer/features/home/presentation/views/widgets/show_delete_appointment_dialog.dart';
import 'package:q_cut/modules/customer/features/home_features/appointment_feature/logic/appointment_controller.dart';
import 'package:q_cut/modules/customer/features/home_features/appointment_feature/models/customer_appointment_model.dart';
import 'package:intl/intl.dart';

final controller = Get.find<CustomerAppointmentController>();

class AppointmentDetailView extends StatelessWidget {
  final CustomerAppointment appointment;

  const AppointmentDetailView({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: CustomAppBar(
        title: "seeDetails".tr,
        // backgroundColor: ColorsData.primary,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBarberCard(),
              SizedBox(height: 20.h),
              _buildSectionTitle("newAppointmentDetails".tr),
              SizedBox(height: 12.h),
              _buildAppointmentDetailsCard(),
              SizedBox(height: 24.h),
              _buildSectionTitle("services".tr),
              SizedBox(height: 12.h),
              _buildServicesList(),
              SizedBox(height: 40.h),
              if (appointment.status.toLowerCase() != 'cancelled' &&
                  appointment.status.toLowerCase() != 'completed' &&
                  appointment.status.toLowerCase() != 'notcome')
                CustomBigButton(
                  textData: "cancelAppointment".tr,
                  onPressed: () {
                    showDeleteAppointmentDialog(
                      context: context,
                      onYes: () async {
                        final success =
                            await controller.deleteAppointment(appointment);
                        if (success) {
                          Get.back();
                        }
                      },
                      onNo: () {
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Styles.textStyleS16W700(color: ColorsData.primary),
    );
  }

  Widget _buildBarberCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: appointment.barber.profilePic != null
                ? CachedNetworkImage(
                    imageUrl: appointment.barber.profilePic!,
                    width: 70.w,
                    height: 70.h,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: SpinKitFadingCircle(
                        color: ColorsData.primary,
                        size: 20.w,
                      ),
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      AssetsData.barberSalonImage,
                      width: 70.w,
                      height: 70.h,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    AssetsData.barberSalonImage,
                    width: 70.w,
                    height: 70.h,
                    fit: BoxFit.cover,
                  ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.barber.fullName,
                  style: Styles.textStyleS16W700(color: Colors.black),
                ),
                SizedBox(height: 4.h),
                Text(
                  appointment.barber.barberShop ?? "barberSalon".tr,
                  style: Styles.textStyleS14W400(color: Colors.grey),
                ),
                SizedBox(height: 8.h),
                _buildStatusBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color statusColor;
    String statusText = appointment.status;

    switch (appointment.status.toLowerCase()) {
      case 'pending':
        statusColor = const Color(0xFF2196F3);
        statusText = "Pending".tr;
        break;
      case 'completed':
        statusColor = const Color(0xFF4CAF50);
        statusText = "Completed".tr;
        break;
      case 'cancelled':
        statusColor = const Color(0xFFF44336);
        statusText = "Cancelled".tr;
        break;
      case 'notcome':
        statusColor = const Color(0xFFFF9800);
        statusText = "Not Attended".tr;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Text(
        statusText,
        style: Styles.textStyleS12W700(color: statusColor),
      ),
    );
  }

  Widget _buildAppointmentDetailsCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.confirmation_number_outlined,
            label: "appointmentID".tr,
            value:
                "#${appointment.id.substring(appointment.id.length - 6).toUpperCase()}",
          ),
          const Divider(height: 24),
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: "appointmentDate".tr,
            value:
                DateFormat('EEEE, MMM d, yyyy').format(appointment.startDate),
          ),
          const Divider(height: 24),
          _buildDetailRow(
            icon: Icons.access_time_outlined,
            label: "appointmentTime".tr,
            value: _formatTimeRange(appointment.startDate, appointment.endDate),
          ),
          const Divider(height: 24),
          _buildDetailRow(
            icon: Icons.payments_outlined,
            label: "paymentMethods".tr,
            value: "cashMethod".tr, // Assuming cash as most are
          ),
          const Divider(height: 24),
          _buildDetailRow(
            icon: Icons.timer_outlined,
            label: "duration".tr,
            value: "${appointment.duration} ${"minutes".tr}",
          ),
          const Divider(height: 24),
          _buildDetailRow(
            icon: Icons.attach_money_outlined,
            label: "totalAmount".tr,
            value: "${appointment.price.toStringAsFixed(0)}₪",
            valueColor: ColorsData.primary,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: ColorsData.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18.w, color: ColorsData.primary),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Styles.textStyleS12W400(color: Colors.grey),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: isBold
                    ? Styles.textStyleS14W700(color: Colors.black)
                    : Styles.textStyleS14W400(color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServicesList() {
    return Column(
      children: appointment.services.map((service) {
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBDD),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.content_cut,
                    color: ColorsData.primary, size: 20.w),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "hairCutService".tr,
                      style: Styles.textStyleS14W700(),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "${"qty".tr}: ${service.numberOfUsers}",
                      style: Styles.textStyleS12W400(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                "${service.price.toStringAsFixed(0)}₪",
                style: Styles.textStyleS14W700(color: ColorsData.primary),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    return "${DateFormat('h:mm a').format(start)} - ${DateFormat('h:mm a').format(end)}";
  }
}
