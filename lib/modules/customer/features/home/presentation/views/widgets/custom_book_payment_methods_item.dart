import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/modules/customer/features/home_features/home/models/barber_model.dart';
import 'package:url_launcher/url_launcher.dart';

class BookPaymentItemModel {
  final String? imageUrl;
  final String? shopName;
  final String? location;
  final String? service; // Kept for backward compatibility if needed, using servicesList mainly
  final double? price;
  final int? quantity;
  final String? bookingDay;
  final String? bookingTime;
  final String? type;
  
  // New fields for detailed view
  final List<dynamic>? servicesList;
  final int? totalServicesQty;
  final int? totalConsumersQty;

  BookPaymentItemModel({
    this.imageUrl,
    this.shopName,
    this.location,
    this.service,
    this.price,
    this.quantity,
    this.bookingDay,
    this.bookingTime,
    this.type,
    this.servicesList,
    this.totalServicesQty,
    this.totalConsumersQty,
  });
}

class CustomBookPaymentMethodsItem extends StatelessWidget {
  final BookPaymentItemModel? model;
  final Barber? barber;

  const CustomBookPaymentMethodsItem({
    super.key,
    this.model,
    this.barber,
  });

  @override
  Widget build(BuildContext context) {
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
              _buildImageContainer(context, isRTL),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: _buildContent(),
                ),
              ),
            ] else ...[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: _buildContent(),
                ),
              ),
              _buildImageContainer(context, isRTL),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageContainer(BuildContext context, bool isRTL) {
    return Container(
      width: 126.w,
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
          model?.imageUrl ?? AssetsData.myAppointmentImage,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shop Name
        Text(
          model?.shopName ?? "barberShop".tr,
          style: Styles.textStyleS14W700(color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4.h),

        // Barber Name
        if (barber != null)
           Text(
            barber!.fullName,
            style: Styles.textStyleS14W400(color: ColorsData.primary),
          ),
        
        SizedBox(height: 8.h),
        
        // Location
        GestureDetector(
          onTap: () async {
            if (barber == null) return;
            
            double? lat;
            double? lng;
            if (barber!.barberShopLocation != null && 
                barber!.barberShopLocation!.coordinates.length >= 2) {
               lat = barber!.barberShopLocation!.coordinates[1];
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 8.h),
        
        // Appointment Day & Time
        _buildInfoRow("Appointment Day".tr, model?.bookingDay ?? ""),
        _buildInfoRow("Appointment Time".tr, model?.bookingTime ?? ""),
        
        SizedBox(height: 8.h),

        // Quantity Info
        _buildInfoRow("Customers Quantity".tr, "${model?.totalConsumersQty ?? 1}"),
        _buildInfoRow("Services Quantity".tr, "${model?.totalServicesQty ?? 1}"),

        SizedBox(height: 8.h),

        // Services List breakdown
        if (model?.servicesList != null)
          ...model!.servicesList!.map((item) {
             final name = item['name'] ?? '';
             final qty = item['numberOfUsers'] ?? 1;
             final price = item['total'] ?? item['price'] ?? 0;
             return _buildInfoRow("($name) *X$qty", "\$${price}");
          }),

         Divider(
            color: Colors.grey.withOpacity(0.5),
            thickness: 0.5,
            height: 16.h,
          ),

        // Total Price (Yellow)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total Price".tr,
              style: Styles.textStyleS12W700(color: Colors.white),
            ),
             Text(
              "\$${model?.price ?? 0}",
              style: Styles.textStyleS12W700(color: ColorsData.primary), // Yellow/Primary
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: Styles.textStyleS12W400(color: Colors.white),
            ),
          ),
          Text(
            value,
            style: Styles.textStyleS12W700(),
          ),
        ],
      ),
    );
  }
}
