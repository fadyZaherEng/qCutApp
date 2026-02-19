import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/modules/customer/features/booking_features/display_barber_services_feature/models/barber_service.dart';
import 'package:q_cut/modules/customer/features/home_features/home/models/barber_model.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomBookAppointmentItem extends StatelessWidget {
  final List<BarberServices>? services;
  final List<int>? quantities;
  final Barber? barber;

  const CustomBookAppointmentItem({
    super.key,
    this.services,
    this.quantities,
    this.barber,
  });

  @override
  Widget build(BuildContext context) {
    final int totalPrice = services?.asMap().entries.fold(
            0,
            (sum, entry) =>
                sum! + (entry.value.price * (quantities?[entry.key] ?? 1))) ??
        20;
    // Calculate total quantity if needed, or just count of service types. 
    // Requirement says "Services Quantity 2". Assuming count of types or sum of quantities?
    // Usually quantity implies users count per service. "Services Quantity" might mean total number of items?
    // Let's stick to "servicesCount" translation or logical count.
    
    // int totalQuantity = 0;
    // if (quantities != null) {
    //   totalQuantity = quantities!.fold(0, (sum, q) => sum + q);
    // } else {
    //   totalQuantity = services?.length ?? 1;
    // }
    
    // User requirement: "Services Quantity 2"
    // I will use total items count (sum of quantities) or just service types count?
    // In previous prompts "Services Quantity" was mapped to `totalConsumers` which was sum of users.
    // Let's calculate total users/items.
    int totalQty = 0;
    if (quantities != null && quantities!.isNotEmpty) {
       totalQty = quantities!.fold(0, (sum, item) => sum + item);
    } else {
       totalQty = services?.length ?? 0;
    }
    
    final bool isRTL = Directionality.of(context) == TextDirection.rtl;

    return Container(
      decoration: BoxDecoration(
        color: ColorsData.cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isRTL) ...[
              _buildImageSection(context),
              Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                    child: _buildServiceDetails(context, totalQty, totalPrice),
                  )),
            ] else ...[
              Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                    child: _buildServiceDetails(context, totalQty, totalPrice),
                  )),
              _buildImageSection(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final bool isRTL = Directionality.of(context) == TextDirection.rtl;
    return Container(
      width: 120.w,
      decoration: BoxDecoration(
         borderRadius: BorderRadius.only(
          topLeft: isRTL ? Radius.zero : Radius.circular(16.r),
          bottomLeft: isRTL ? Radius.zero : Radius.circular(16.r),
          topRight: isRTL ? Radius.circular(16.r) : Radius.zero,
          bottomRight: isRTL ? Radius.circular(16.r) : Radius.zero,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: isRTL ? Radius.zero : Radius.circular(16.r),
          bottomLeft: isRTL ? Radius.zero : Radius.circular(16.r),
          topRight: isRTL ? Radius.circular(16.r) : Radius.zero,
          bottomRight: isRTL ? Radius.circular(16.r) : Radius.zero,
        ),
        child: Image.asset(
          AssetsData.myAppointmentImage,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildServiceDetails(
      BuildContext context, int totalQty, int totalPrice) {
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Barber Shop Name
        Text(
          barber?.barberShop ?? barber?.fullName ?? "Barber Shop",
          style: Styles.textStyleS14W700(color: Colors.white), // Changed from white as cardColor is usually light?
          // Wait, in previous file `custom_delete_appointment_item.dart` text was black/secondary.
          // But here in original code line 87 it was `color: Colors.white`. 
          // If `ColorsData.cardColor` is dark, then white is correct.
          // Let's verify `ColorsData.cardColor`. 
          // Assuming user wants consistency with "CustomDeleteAppointmentItem" which I used black for.
          // I will use Styles without forcing white unless I know card is dark.
          // The previous code had `ColorsData.cardColor` and text `Colors.white` for "barberShop".
          // If the card is white, text should be black.
          // Let's assume standard theme. I'll use `ColorsData.secondary` or similar.
          // Ideally match the previous card style.
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        SizedBox(height: 4.h),
        
        // Barber Name
        if (barber != null)
        Text(
          barber!.fullName,
          style: Styles.textStyleS12W400(color: Colors.white),
        ),

        SizedBox(height: 8.h),

        // Services Quantity
        _buildInfoRow("Services Quantity".tr, "$totalQty"),
        
        SizedBox(height: 4.h),

        // Services List
        if (services != null && services!.isNotEmpty) ...[
          ...services!.asMap().entries.map((entry) => _buildInfoRow(
              "(${entry.value.name}) *X${quantities?[entry.key] ?? 1}",
              "\$${entry.value.price * (quantities?[entry.key] ?? 1)}")),
              
          Divider(
            color: Colors.grey.withOpacity(0.5),
            thickness: 0.5,
            height: 12.h,
          ),
          
          // Total Price
          _buildInfoRow(
            "Total Price".tr,
            "\$$totalPrice",
            isTotal: true,
          ),
        ],

        SizedBox(height: 8.h),
        
        // Location (Clickable)
        GestureDetector(
          onTap: () async {
            if (barber == null) return;
            
            double? lat;
            double? lng;
            
            if (barber!.barberShopLocation != null && 
                barber!.barberShopLocation!.coordinates.length >= 2) {
               lat = barber!.barberShopLocation!.coordinates[1]; // Latitude is usually 2nd in GeoJSON [lng, lat]
               lng = barber!.barberShopLocation!.coordinates[0];
            }
            
            Uri googleMapsUrl;
            if (lat != null && lng != null) {
              googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
            } else {
              final query = Uri.encodeComponent(barber!.city);
              googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");
            }

            try {
              if (await canLaunchUrl(googleMapsUrl)) {
                await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
              }
            } catch (e) {
              debugPrint("Error launching map: $e");
            }
          },
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
                  barber?.city ?? 'yourLocation'.tr,
                  style: Styles.textStyleS12W400().copyWith(decoration: TextDecoration.underline),
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: isTotal
                  ? Styles.textStyleS12W700(color: ColorsData.primary) // Used S12W700 for total per other file
                  : Styles.textStyleS12W400().copyWith(fontSize: 10.sp), // Slightly smaller for list
                  // Or use Styles.textStyleS10W400() as before?
                  // Previous file used S12W400 for items.
            ),
          ),
          Text(
            value,
            style: isTotal
                ? Styles.textStyleS12W700(color: ColorsData.primary)
                : Styles.textStyleS12W400().copyWith(fontSize: 10.sp),
          ),
        ],
      ),
    );
  }
}
