import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'package:q_cut/modules/customer/features/booking_features/display_barber_services_feature/models/barber_service.dart';
import 'package:q_cut/modules/customer/features/home_features/home/views/widgets/custom_barber_list_view_item.dart';
import 'package:q_cut/modules/customer/features/home_features/home/logic/home_controller.dart';
import 'package:q_cut/modules/customer/features/home_features/home/models/barber_model.dart';

class CustomBarberListView extends StatelessWidget {
  final List<Barber>? barbers;
  final bool isRecommended;
  final bool isSearching;

  const CustomBarberListView({
    super.key,
    this.barbers,
    this.isRecommended = false,
    this.isSearching = false,
  });

  static const int itemsPerRow = 5;

  /// ✅ check if barber has services
  Future<bool> fetchServices(String barberId) async {
    final NetworkAPICall apiCall = NetworkAPICall();
    final RxList<BarberServices> barberServices = <BarberServices>[].obs;

    try {
      final response = await apiCall.getData(Variables.SERVICE + barberId);
      final responseBody = json.decode(response.body);
      print("response for services: $responseBody");
      print("response status code: ${response.statusCode}");
      print("response body type: ${responseBody.runtimeType}");

      if (response.statusCode == 200) {
        if (responseBody is List) {
          barberServices.value = responseBody
              .map((service) => BarberServices.fromJson(service))
              .toList();
        } else if (responseBody is Map<String, dynamic>) {
          final servicesResponse = BarberServiceResponse.fromJson(responseBody);
          barberServices.value = servicesResponse.services;
        }

        return barberServices.isNotEmpty;
      }
    } catch (e) {
      debugPrint("Error fetching services: $e");
    }

    return false;
  }

  /// ✅ filter barbers using API
  Future<List<Barber>> _filterBarbers(List<Barber> barbers) async {
    List<Barber> validBarbers = [];

    for (var barber in barbers) {
      final hasServices = await fetchServices(barber.id.toString());

      if (hasServices) {
        validBarbers.add(barber);
      }
    }
    print("Valid barbers count: ${validBarbers.length}");

    return validBarbers;
  }

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: SpinKitDoubleBounce(color: ColorsData.primary),
        );
      }

      final rawBarbers = isSearching
          ? controller.searchResults.toList()
          : barbers ??
              (isRecommended
                  ? controller.recommendedBarbers.toList()
                  : controller.nearbyBarbers.toList());

      return FutureBuilder<List<Barber>>(
        future: _filterBarbers(rawBarbers),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: SpinKitDoubleBounce(
                color: ColorsData.primary,
              ),
            );
          }

          final displayBarbers = snapshot.data!;

          if (displayBarbers.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h),
                child: Text(
                  "No barbers available".tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }

          final totalItems = displayBarbers.length;
          final numberOfRows = (totalItems / itemsPerRow).ceil();

          return Column(
            children: List.generate(numberOfRows, (rowIndex) {
              final startIdx = rowIndex * itemsPerRow;
              final endIdx = (startIdx + itemsPerRow > totalItems)
                  ? totalItems
                  : startIdx + itemsPerRow;

              final rowItems = displayBarbers.sublist(startIdx, endIdx);

              return SizedBox(
                height: 300.h,
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: rowItems.length,
                  itemBuilder: (context, colIndex) {
                    final barber = rowItems[colIndex];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 3.h),
                      child: CustomBarberListViewItem(
                        barber: barber,
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                ),
              );
            }),
          );
        },
      );
    });
  }
}
