import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:q_cut/modules/barber/features/home_features/appointment_feature/models/appointment_model.dart';

class CustomBAppointmentAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final BarberLocation? location;
  final String?city;

  const CustomBAppointmentAppBar({
    super.key,
    this.location,
    this.city,
  });

  @override
  Widget build(BuildContext context) {
    final addressController = Get.put(AddressController());

    return Row(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AssetsData.mapPinIcon,
              width: 24.w,
              height: 24.h,
              colorFilter: const ColorFilter.mode(
                ColorsData.primary,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 4.w),

            /// ✅ العنوان الحالي

            SizedBox(
              width: 200.w,
              child: Text(
                city ?? "Loading...",
                style: Styles.textStyleS12W400(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),


              // FutureBuilder(
              //   future: location?.getAddress(Get.locale?.languageCode ?? "en"),
              //   builder: (context, loc) {
              //     return Text(
              //       loc.data ?? "Loading...",
              //       //addressController.currentAddress.value,
              //       style: Styles.textStyleS12W400(),
              //       maxLines: 3,
              //       overflow: TextOverflow.ellipsis,
              //     );
              //   },
              // ),
            ),
            SizedBox(width: 4.w),

            /// ⟳ زرار تحديث العنوان أو لودينج
            Obx(() => addressController.isLoading.value
                ? SizedBox(
                    width: 18.sp,
                    height: 18.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ColorsData.primary,
                    ),
                  )
                : InkWell(
                    onTap: () async {
                      await addressController.getCurrentAddress();
                    },
                    child: Icon(
                      Icons.refresh,
                      size: 18.sp,
                      color: ColorsData.primary,
                    ),
                  )),

            SizedBox(width: 4.w),
          ],
        ),
        const Spacer(),
        InkWell(
            onTap: () {
              Get.toNamed(AppRouter.notificationPath);
            },
            child: SvgPicture.asset(
              AssetsData.notificationsIcon,
              width: 24,
              height: 24,
            )),
        SizedBox(width: 11.w),
        InkWell(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: SvgPicture.asset(
              AssetsData.menuIcon,
              width: 24,
              height: 24,
            )),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(67.h);
}

class AddressController extends GetxController {
  RxString currentAddress = "Loading...".obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentAddress(
      language: Get.locale?.languageCode ?? "en",
    );
  }

  String googleApiKey = "AIzaSyDIC2N5UajvIfWd0858c1Z0JDZ6R-78e2w";

  Future<void> getCurrentAddress({String language = "en"}) async {
    try {
      isLoading.value = true;

      // ✅ Check service
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        currentAddress.value = language == "ar"
            ? "خدمات الموقع معطلة"
            : "Location services are disabled";
        return;
      }

      // ✅ Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          currentAddress.value =
              language == "ar" ? "تم رفض الإذن" : "Permission denied";
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        currentAddress.value = language == "ar"
            ? "تم رفض الإذن بشكل دائم"
            : "Permission permanently denied";
        return;
      }

      // ✅ Get position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // ✅ Call Google Geocoding API
      final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json"
        "?latlng=${position.latitude},${position.longitude}"
        "&language=$language"
        "&key=$googleApiKey",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["status"] == "OK" && data["results"].isNotEmpty) {
          final result = data["results"].first;
          final components = result["address_components"];

          String street = "";
          String city = "";
          String country = "";
          for (var comp in components) {
            final types = List<String>.from(comp["types"]);

            if (types.contains("route")) {
              street = comp["long_name"];
            }

            if (types.contains("locality")) {
              city = comp["long_name"];
            }

            // ✅ fallback لو locality فاضية
            if (city.isEmpty && types.contains("administrative_area_level_2")) {
              city = comp["long_name"];
            }

            if (city.isEmpty && types.contains("sublocality")) {
              city = comp["long_name"];
            }

            if (types.contains("country")) {
              country = comp["long_name"];
            }
          }

          currentAddress.value = "$street, $city, $country".trim();
        } else {
          currentAddress.value =
              language == "ar" ? "لم يتم العثور على عنوان" : "No address found";
        }
      } else {
        currentAddress.value =
            language == "ar" ? "خطأ في جلب البيانات" : "Error fetching data";
      }
    } catch (e, stack) {
      debugPrint("Error fetching address: $e\n$stack");
      currentAddress.value = language == "ar"
          ? "تعذر الحصول على العنوان"
          : "Unable to fetch address";
    } finally {
      isLoading.value = false;
    }
  }
}
