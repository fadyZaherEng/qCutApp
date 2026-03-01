import 'dart:async';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/modules/barber/features/home_features/appointment_feature/models/appointment_model.dart';
import 'package:q_cut/modules/barber/features/home_features/appointment_feature/views/change_time_bottom_sheet.dart';
import 'package:q_cut/modules/customer/features/home/presentation/views/widgets/show_delete_appointment_dialog.dart';

import '../logic/appointment_controller.dart';

class CustomBAppointmentListItem extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String id;
  final String location;
  final String service;
  final String hairStyle;
  final String qty;
  final String bookingDay;
  final String bookingTime;
  final String type;
  final double price;
  final double finalPrice;
  final void Function() onDidNotComeTap;
  final BAppointmentController controller;
  final List<ServiceItem> services;

  final BarberAppointment appointment;

  const CustomBAppointmentListItem({
    super.key,
    required this.imageUrl,
    required this.id,
    required this.name,
    required this.location,
    required this.service,
    required this.hairStyle,
    required this.qty,
    required this.bookingDay,
    required this.bookingTime,
    required this.type,
    required this.price,
    required this.finalPrice,
    required this.onDidNotComeTap,
    required this.controller,
    required this.appointment,
    required this.services,
  });

  @override
  State<CustomBAppointmentListItem> createState() =>
      _CustomBAppointmentListItemState();
}

class _CustomBAppointmentListItemState extends State<CustomBAppointmentListItem>
    with TickerProviderStateMixin {
  late DateTime now;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    now = DateTime.now();

    // ✅ يحدث الوقت كل دقيقة عشان الأزرار تتغير أوتوماتيك
    timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {
        now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appointmentStart = widget.appointment.startDate;
    final canDelete =
        now.isBefore(appointmentStart.subtract(const Duration(minutes: 20)));
    final canMarkDidntCome =
        now.isAfter(appointmentStart.add(const Duration(minutes: 5)));

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: ColorsData.cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28.r,
                foregroundImage: CachedNetworkImageProvider(widget.imageUrl),
                backgroundColor: ColorsData.secondary,
              ),
              SizedBox(width: 12.w),
              if (widget.appointment.user.phoneNumber.isNotEmpty)
                IconButton(
                  onPressed: () => _showCallDialog(
                      context, widget.appointment.user.phoneNumber),
                  icon: SvgPicture.asset(
                    AssetsData.callIcon,
                    height: 24.h,
                    width: 24.w,
                    colorFilter: const ColorFilter.mode(
                      Colors.green,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
                decoration: BoxDecoration(
                  color: ColorsData.font,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      height: 16.h,
                      width: 16.w,
                      AssetsData.paymentIcon,
                      colorFilter: const ColorFilter.mode(
                        ColorsData.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "cashMethod".tr,
                      style:
                          Styles.textStyleS10W400(color: ColorsData.secondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // **Name**
          Text(
            widget.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          _infoRow(
              "Appointment Day".tr,
              DateFormat('EEEE', Get.locale?.languageCode)
                  .format(widget.appointment.startDate)),
          _infoRow(
              "Appointment Time".tr, widget.appointment.formattedTimeRange),
          _infoRow("Customers Quantity".tr,
              widget.appointment.totalUsers.toString()),
          _infoRow("Services Quantity".tr,
              widget.appointment.totalServices.toString()),

          SizedBox(height: 8.h),
          Text(
            "Services:".tr,
            style: Styles.textStyleS12W400(color: ColorsData.primary),
          ),
          SizedBox(height: 4.h),
          ...widget.appointment.services.map((item) => Padding(
                padding: EdgeInsets.only(left: 8.w, bottom: 4.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${item.service.name} *X${item.numberOfUsers}",
                      style: Styles.textStyleS12W400(color: Colors.white),
                    ),
                    Text(
                      "\$ ${item.price.toStringAsFixed(2)}",
                      style: Styles.textStyleS12W400(color: Colors.white70),
                    ),
                  ],
                ),
              )),

          SizedBox(height: 12.h),

          // **Price Details**
          Divider(color: Colors.white.withOpacity(0.3)),
          SizedBox(height: 8.h),
          _infoRow("Total Price".tr,
              "\$ ${widget.appointment.price.toStringAsFixed(2)}",
              color: ColorsData.primary),
          SizedBox(height: 12.h),

          Row(
            children: [
              if (canDelete)
                Expanded(
                  child: _customButton(
                    "delete".tr,
                    Colors.red,
                    () => showDeleteAppointmentDialog(
                      context: context,
                      onYes: () => widget.controller
                          .deleteAppointment(widget.appointment.id),
                      onNo: () {},
                    ),
                  ),
                ),
              if (canMarkDidntCome)
                Expanded(
                  child: _customButton(
                    "Didn’t come".tr,
                    Colors.orange,
                    () => showDidNotComeDialog(
                      context: context,
                      onYes: () => widget.controller
                          .didntComeAppointment(widget.appointment.id),
                    ),
                  ),
                ),
              SizedBox(width: 12.w),
              Expanded(
                child: _customButton(
                  "change".tr,
                  ColorsData.primary,
                  () => showChangeTimeBottomSheet(
                    context,
                    widget.bookingDay,
                    widget.id,
                    widget.services,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> showDidNotComeDialog({
    required BuildContext context,
    required Future Function() onYes,
  }) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ColorsData.secondary,
        title: Text("Confirmation".tr,
            style: Styles.textStyleS16W700(color: Colors.white)),
        content: Text("Are you sure the customer didn’t come?".tr,
            style: Styles.textStyleS14W400(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("No".tr, style: const TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: ColorsData.primary),
            onPressed: () async {
              await onYes();
              Navigator.of(ctx).pop();
            },
            child: Text("Yes".tr, style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _showCallDialog(BuildContext context, String phoneNumber) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ColorsData.secondary,
        title: Text("Customer Phone".tr,
            style: Styles.textStyleS16W700(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(phoneNumber,
                style: Styles.textStyleS18W700(color: ColorsData.primary)),
            SizedBox(height: 16.h),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("Cancel".tr,
                style: const TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              final Uri launchUri = Uri.parse('tel:$phoneNumber');
              if (await canLaunchUrl(launchUri)) {
                await launchUrl(launchUri);
              } else {
                 ShowToast.showError(message: "Invalid phone number".tr);
              }
              Navigator.of(ctx).pop();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.call, color: Colors.white, size: 18),
                SizedBox(width: 8.w),
                Text("Call".tr, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value, {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Styles.textStyleS12W400(),
          ),
          Text(
            value,
            style: Styles.textStyleS12W400(color: color),
          ),
        ],
      ),
    );
  }

  Widget _customButton(String text, Color color, void Function()? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
