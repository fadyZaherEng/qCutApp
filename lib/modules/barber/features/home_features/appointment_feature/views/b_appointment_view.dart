// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/main.dart';
import 'package:q_cut/modules/barber/features/home_features/appointment_feature/models/appointment_model.dart';
import 'package:q_cut/modules/barber/features/home_features/appointment_feature/views/custom_b_drawer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/constants/constants.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/modules/barber/features/home_features/appointment_feature/logic/appointment_controller.dart';
import 'package:q_cut/modules/barber/features/home_features/appointment_feature/views/custom_b_appointment_app_bar.dart';
import 'package:q_cut/modules/barber/features/home_features/appointment_feature/views/custom_b_appointment_list_item.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/models/barber_profile_model.dart';
import '../../../../../../core/utils/network/network_helper.dart';
import 'picker.dart';

class BAppointmentView extends StatefulWidget {
  const BAppointmentView({super.key});

  @override
  State<BAppointmentView> createState() => _BAppointmentViewState();
}

class _BAppointmentViewState extends State<BAppointmentView> {
  BarberLocation? location;
  String? city;

  late final BAppointmentController controller;

  Future<void> fetchProfileData() async {
    final NetworkAPICall apiCall = NetworkAPICall();

    try {
      final response = await apiCall.getData(Variables.GET_PROFILE);
      final responseBody = json.decode(response.body);
      print(responseBody);
      if (response.statusCode == 200) {
        final profileResponse = BarberProfileResponse.fromJson(responseBody);

        location = BarberLocation(
          type: profileResponse.data.barberShopLocation.type,
          coordinates: profileResponse.data.barberShopLocation.coordinates,
        );
        city = profileResponse.data.city;
      } else {}
    } finally {}
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller = Get.put(BAppointmentController());
    fetchProfileData();
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

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        drawer: const CustomBDrawer(),
        body: RefreshIndicator(
          onRefresh: () => controller.refreshAppointments(),
          child: Obx(
            () {
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 16.w, right: 16.w, top: 24.h),
                      child: Column(
                        children: [
                          CustomBAppointmentAppBar(
                            location: location,
                            city: city,
                          ),
                          SizedBox(height: 16.h),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (profileImage.isNotEmpty)
                                CircleAvatar(
                                  radius: 32.r,
                                  foregroundImage:
                                      CachedNetworkImageProvider(profileImage),
                                  backgroundColor: ColorsData.secondary,
                                ),
                              if (profileImage.isNotEmpty)
                                SizedBox(height: 10.h),
                              Text(
                                controller.barberName,
                                style: Styles.textStyleS14W700(),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                controller.barberServices,
                                style: Styles.textStyleS12W400(),
                              ),
                            ],
                          ),
                          SizedBox(height: 5.h),
                          const Divider(
                            color: ColorsData.cardStrock,
                          ),
                          SizedBox(height: 12.h),
                          CustomDaysPicker(
                            titleSimpleDaysPicker: "myAppointments".tr,
                            selectedDate: controller.selectedDate.value,
                            onDateSelected: (date) =>
                                controller.changeSelectedDate(date),
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),
                  if (controller.isLoading.value)
                    const SliverToBoxAdapter(
                      child: Center(
                        child: SpinKitDoubleBounce(color: ColorsData.primary),
                      ),
                    ),
                  if (!controller.isLoading.value &&
                      controller.appointments.isEmpty)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 50.h),
                          child: Column(
                            children: [
                              Text(
                                "noAppointmentsFound".tr,
                                style: Styles.textStyleS14W500(),
                              ),
                              if (controller.isError.value)
                                Padding(
                                  padding: EdgeInsets.only(top: 8.h),
                                  child: Text(
                                    _getErrorMessage(controller.errorMessage.value),
                                    style: Styles.textStyleS12W400()
                                        .copyWith(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (!controller.isLoading.value &&
                      controller.appointments.isNotEmpty &&
                      controller.filteredAppointments.isEmpty)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 50.h),
                          child: Text(
                            "noAppointmentsForThisDay".tr,
                            style: Styles.textStyleS14W500(),
                          ),
                        ),
                      ),
                    ),
                  if (!controller.isLoading.value &&
                      controller.filteredAppointments.isNotEmpty)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount: controller.filteredAppointments.length,
                        (context, index) {
                          final appointment =
                              controller.filteredAppointments[index];

                          print("appointment item # $index:${appointment.id}");

                          // Load more when reaching the end of the list
                          if (index ==
                              controller.filteredAppointments.length - 1) {
                            print("Reached last item, loading more");
                            controller.loadMoreAppointments();
                          }

                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 300 + (index * 100)),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 30 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 16.w, right: 16.w, bottom: 12.h),
                              child: CustomBAppointmentListItem(
                                id: appointment.id,
                                onDidNotComeTap: () => controller
                                    .didntComeAppointment(appointment.id),
                                imageUrl: profileDrawerImage,
                                name: appointment.user.fullName,
                                controller: controller,
                                appointment: appointment,
                                location: "location".tr,
                                service: appointment.services.isNotEmpty
                                    ? appointment.services[0].service.name
                                    : "service".tr,
                                hairStyle: appointment.runtimeType.toString(),
                                qty: "${appointment.services.length}",
                                bookingDay: appointment.formattedDate,
                                bookingTime: appointment.formattedTime,
                                type: appointment.status,
                                price: appointment.price,
                                finalPrice: appointment.price,
                                services: appointment.services,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  if (controller.isLoadingMore.value)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.h),
                        child: const Center(
                          child: SpinKitDoubleBounce(color: ColorsData.primary),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
          onPressed: () {
            // controller.openAddAppointmentDialog();
            // Get.toNamed(AppRouter.selectedPath, arguments: currentBarber);
            Get.toNamed(
              AppRouter.qCutServicesPath,
              arguments: {
                "barber": currentBarber,
                "isMultiple": 1,
                "isBarber":true,
              },
            );
          },
          backgroundColor: ColorsData.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
