import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_big_button.dart';
import 'package:q_cut/modules/customer/features/home_features/appointment_feature/models/customer_appointment_model.dart';
import 'package:q_cut/modules/customer/features/home_features/home/models/barber_model.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomDeleteAppointmentItem extends StatefulWidget {
  final VoidCallback onDelete;
  final CustomerAppointment appointment;

  const CustomDeleteAppointmentItem({
    super.key,
    required this.onDelete,
    required this.appointment,
  });

  @override
  State<CustomDeleteAppointmentItem> createState() =>
      _CustomDeleteAppointmentItemState();
}

class _CustomDeleteAppointmentItemState
    extends State<CustomDeleteAppointmentItem> {
  Timer? _timer;
  Duration remaining = Duration.zero;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _updateRemaining();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final diff = widget.appointment.startDate.difference(now);
    
    // Hide card 10 minutes after start time
    if (diff.inMinutes < -10) {
       if (_isVisible && mounted) {
         setState(() {
           _isVisible = false;
         });
       }
    } else {
      if (mounted) {
        setState(() {
          remaining = diff;
        });
      }
    }
  }

  Future<void> _openMap() async {
    final lat = widget.appointment.barber.locationCoordinates?[1];
    final lng = widget.appointment.barber.locationCoordinates?[0];
    
    Uri googleMapsUrl;
    if (lat != null && lng != null) {
       googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    } else {
       final query = Uri.encodeComponent(widget.appointment.barber.city);
       googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");
    }

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Error launching map: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime24(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible && widget.appointment.status.toLowerCase() != 'completed') {
      return const SizedBox.shrink();
    }

    final isExpired = remaining.isNegative;
    final hours = isExpired ? "00" : remaining.inHours.toString().padLeft(2, '0');
    final minutes = isExpired ? "00" : (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = isExpired ? "00" : (remaining.inSeconds % 60).toString().padLeft(2, '0');

    // Radius for Image Container
    final isAr = Get.locale?.languageCode == 'ar';
    final imageBorderRadius = BorderRadius.only(
      topRight: Radius.circular(isAr ? 16.r : 0),
      bottomRight: Radius.circular(isAr ? 16.r : 0),
      topLeft: Radius.circular(isAr ? 0 : 16.r),
      bottomLeft: Radius.circular(isAr ? 0 : 16.r),
    );

    // Radius for Content Container
    final contentBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(isAr ? 16.r : 0),
      bottomLeft: Radius.circular(isAr ? 16.r : 0),
      topRight: Radius.circular(isAr ? 0 : 16.r),
      bottomRight: Radius.circular(isAr ? 0 : 16.r),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image (Arabic: Right, English: Right logic specific to previous code? 
                  // Previous code: AR -> Image First (Right side in RTL?), EN -> Image Last (Right side in LTR?)
                  // Wait, usually in RTL, first child is Right. In LTR, last child is Right.
                  
                  if (isAr) _buildImageContainer(imageBorderRadius),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: contentBorderRadius,
                        color: ColorsData.cardColor,
                      ),
                      padding: EdgeInsets.all(12.w),
                      child: _buildContent(),
                    ),
                  ),

                  if (!isAr) _buildImageContainer(imageBorderRadius),
                ],
              ),
            ),
            
            SizedBox(height: 16.h),
            
             // Timer
             Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                     // "No expired" text, stays 00:00:00
                     isExpired 
                     ? (widget.appointment.status.toLowerCase() == 'completed' ? "Completed" : "00:00:00")
                     : "${"Countdown".tr} : $hours:$minutes:$seconds",
                     style: TextStyle(
                       fontSize: 14, 
                       color: isExpired && widget.appointment.status.toLowerCase() != 'completed' ? Colors.red : Colors.white,
                       fontWeight: FontWeight.bold // Kept simple style or can use Styles
                     ),
                   ),
                ],
              ),
            
            SizedBox(height: 16.h),
            
             if (widget.appointment.status.toLowerCase() == 'pending')
              CustomBigButton(
                textData: "Cancel".tr,
                onPressed: widget.onDelete,
              ),
              
            if (widget.appointment.status.toLowerCase() == 'completed')
              CustomBigButton(
                onPressed: () {
                  final serviceIds = widget.appointment.services.map((s) => s.serviceId).toList();
                  Get.toNamed(
                    AppRouter.barberServicesPath,
                    arguments: {
                       'barber': Barber(
                        id: widget.appointment.barber.id,
                        fullName: widget.appointment.barber.fullName,
                        phoneNumber: "",
                        userType: widget.appointment.barber.userType,
                        city: widget.appointment.barber.city,
                        isFavorite: false,
                        status: widget.appointment.status,
                        offDay: [],
                        workingDays: [],
                        instagramPage: "",
                      ),
                      'preSelectedServiceIds': serviceIds,
                    },
                  );
                },
                textData: "Book again".tr,
              ),
          ],
        ),
    );
  }

  Widget _buildImageContainer(BorderRadius borderRadius) {
    return Container(
      width: 126.w,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Image.asset(
          AssetsData.myAppointmentImage,
          fit: BoxFit.cover,
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Formatted strings
    final appointmentDay = DateFormat('EEEE', Get.locale?.languageCode).format(widget.appointment.startDate);
    final appointmentDate = DateFormat('dd/MM/yyyy').format(widget.appointment.startDate);
    final appointmentTime = "${_formatTime24(widget.appointment.startDate)}-${_formatTime24(widget.appointment.endDate)}";

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         // 1. Shop Name
         Text(
           widget.appointment.barber.barberShop ?? widget.appointment.barber.fullName,
           style: Styles.textStyleS12W700(), // Keeping original font size/weight preference if possible, or adjust slightly
           maxLines: 1,
           overflow: TextOverflow.ellipsis,
         ),
         
         SizedBox(height: 4.h),

         // 2. Barber Name & Cash
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Expanded(
               child: Text(
                 widget.appointment.barber.fullName,
                 style: Styles.textStyleS12W400(),
                 overflow: TextOverflow.ellipsis,
               ),
             ),
             Text(
               widget.appointment.paymentMethod,
               style: Styles.textStyleS14W400(color: ColorsData.primary),
             ),
           ],
         ),

         SizedBox(height: 4.h),

         // 3. Location
         GestureDetector(
           onTap: _openMap,
           child: Row(
             children: [
               SvgPicture.asset(
                  AssetsData.mapPinIcon,
                  width: 12.w,
                  height: 12.h,
                  colorFilter: const ColorFilter.mode(
                    ColorsData.primary,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    "${widget.appointment.barber.city} ",
                    style: Styles.textStyleS12W400().copyWith(decoration: TextDecoration.underline),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
             ],
           ),
         ),

         Divider(height: 12.h, thickness: 0.5),

         // 4. Details
         _buildCompactRow('Day'.tr, appointmentDay),
         _buildCompactRow('Date'.tr, appointmentDate),
         _buildCompactRow('Time'.tr, appointmentTime),
         
         // 5. Quantity
         _buildCompactRow('Services Quantity'.tr, widget.appointment.totalConsumers), // Extract number if needed or keeps "X consumers"

         Divider(height: 12.h, thickness: 0.5),

         // 6. Services List
         ...widget.appointment.services.map((s) => Padding(
           padding: EdgeInsets.only(bottom: 2.h),
           child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Expanded(
                 child: Text(
                    "(${s.serviceName}) *X${s.numberOfUsers}",
                    style: Styles.textStyleS12W400(),
                    overflow: TextOverflow.ellipsis,
                 ),
               ),
               Text(
                 "\$${s.price.toStringAsFixed(0)}",
                 style: Styles.textStyleS13W500(),
               ),
             ],
           ),
         )),

         Divider(height: 12.h, thickness: 0.5),

         // 7. Total
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Text('Total Price'.tr, style: Styles.textStyleS12W700()),
             Text(
               "\$${widget.appointment.price.toStringAsFixed(0)}",
               style: Styles.textStyleS14W700(color: ColorsData.primary),
             ),
           ],
         ),
      ],
    );
  }

  Widget _buildCompactRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Styles.textStyleS12W400(color: Colors.white)),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              value, 
              style: Styles.textStyleS12W700(), 
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
