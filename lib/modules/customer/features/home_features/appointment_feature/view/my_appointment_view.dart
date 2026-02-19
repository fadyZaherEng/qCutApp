import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/modules/customer/features/home/presentation/views/widgets/show_delete_appointment_dialog.dart';
import 'package:q_cut/modules/customer/features/home_features/appointment_feature/logic/appointment_controller.dart';
import 'package:q_cut/modules/customer/features/home_features/appointment_feature/view/widgets/custom_delete_appointment_item.dart';

class MyAppointmentView extends StatefulWidget {
  const MyAppointmentView({super.key});

  @override
  State<MyAppointmentView> createState() => _MyAppointmentViewState();
}

class _MyAppointmentViewState extends State<MyAppointmentView> {
  final controller = Get.put(CustomerAppointmentController());
  final ScrollController _scrollController = ScrollController();
  bool isClicked = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setStatusFilter("pending");
      controller.refreshAppointments();
    });

    // scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !controller.isLoadingMore.value &&
          controller.hasMore.value) {
        controller.loadMoreAppointments();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.refreshAppointments();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("myAppointments".tr),
          actions: [
            _buildFilterButton(controller),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await controller.refreshAppointments();
          },
          child: Obx(() {
            if (controller.isLoading.value && controller.appointments.isEmpty) {
              return const Center(
                child: SpinKitDoubleBounce(
                  color: ColorsData.primary,
                ),
              );
            } else if (controller.isError.value &&
                controller.appointments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.errorMessage.value,
                      style: Styles.textStyleS14W400(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        if (isClicked) {
                          isClicked = false;
                          controller.refreshAppointments();
                          Future.delayed(const Duration(seconds: 2), () {
                            isClicked = true;
                          });
                        }
                      },
                      child: Text('Retry'.tr),
                    ),
                  ],
                ),
              );
            } else if (controller.filteredAppointments.isEmpty) {
              return Center(
                child: Text(
                  'noAppointmentsFound'.tr,
                  style: Styles.textStyleS14W400(),
                ),
              );
            } else {
              return ListView.separated(
                controller: _scrollController,
                itemCount: controller.filteredAppointments.length +
                    (controller.isLoadingMore.value ? 1 : 0),
                separatorBuilder: (context, index) =>
                SizedBox(height: 20.h),
                itemBuilder: (context, index) {
                  if (index < controller.filteredAppointments.length) {
                    final appointment = controller.filteredAppointments[index];
                    return CustomDeleteAppointmentItem(
                      appointment: appointment,
                      onDelete: () {
                        showDeleteAppointmentDialog(
                          context: context,
                          onYes: () async {
                            final success = await controller
                                .deleteAppointment(appointment);
                            if (success && context.mounted) {
                              Get.back();
                            }
                          },
                          onNo: () {
                            Get.back();
                          },
                        );
                      },
                    );
                  } else {
                    // loader at bottom while loading more
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: SpinKitThreeBounce(
                          color: ColorsData.primary,
                          size: 20,
                        ),
                      ),
                    );
                  }
                },
              );
            }
          }),
        ),
      ),
    );
  }

  Widget _buildFilterButton(CustomerAppointmentController controller) {
    return Obx(() {
      return PopupMenuButton<String>(
        initialValue: controller.statusFilter.value,
        onSelected: (value) {
          controller.setStatusFilter(value);
          controller.refreshAppointments();
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'pending',
            child: Row(
              children: [
                Text(
                  'Pending'.tr,
                  style: TextStyle(
                    fontWeight:
                        controller.statusFilter.value.toLowerCase() == 'pending'
                            ? FontWeight.bold
                            : FontWeight.normal,
                    color: controller.statusFilter.value == 'pending'
                        ? ColorsData.primary
                        : Colors.black,
                  ),
                ),
                if (controller.statusFilter.value == 'pending') ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.check, color: ColorsData.primary, size: 16),
                ],
              ],
            ),
          ),
          PopupMenuItem(
            value: 'completed',
            child: Row(
              children: [
                Text(
                  'Completed'.tr,
                  style: TextStyle(
                    fontWeight: controller.statusFilter.value == 'completed'
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: controller.statusFilter.value == 'completed'
                        ? ColorsData.primary
                        : Colors.black,
                  ),
                ),
                if (controller.statusFilter.value == 'completed') ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.check, color: ColorsData.primary, size: 16),
                ],
              ],
            ),
          ),
        ],
        icon: const Icon(Icons.filter_list),
      );
    });
  }
}

// class MyAppointmentView extends StatefulWidget {
//   const MyAppointmentView({super.key});
//
//   @override
//   State<MyAppointmentView> createState() => _MyAppointmentViewState();
// }
//
// class _MyAppointmentViewState extends State<MyAppointmentView> {
//   bool isClicked = true;
//   final controller = Get.put(CustomerAppointmentController());
//
//   @override
//   void initState() {
//     super.initState();
//
//     // set default filter to pending
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       controller.setStatusFilter("pending");
//       controller.refreshAppointments();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("myAppointments".tr),
//         actions: [
//           _buildFilterButton(controller),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: () => controller.refreshAppointments(),
//         child: Obx(() {
//           if (controller.isLoading.value) {
//             return Center(
//               child: SpinKitDoubleBounce(
//                 color: ColorsData.primary,
//               ),
//             );
//           } else if (controller.isError.value) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     controller.errorMessage.value,
//                     style: Styles.textStyleS14W400(color: Colors.red),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 16.h),
//                   ElevatedButton(
//                     onPressed: () {
//                       if (isClicked) {
//                         isClicked = false;
//                         setState(() {});
//                         controller.fetchAppointments();
//                         Future.delayed(const Duration(seconds: 2), () {
//                           isClicked = true;
//                           setState(() {});
//                         });
//                       }
//                     },
//                     child: Text('Retry'.tr),
//                   ),
//                 ],
//               ),
//             );
//           } else if (controller.filteredAppointments.isEmpty) {
//             return Center(
//               child: Text(
//                 'noAppointmentsFound'.tr,
//                 style: Styles.textStyleS14W400(),
//               ),
//             );
//           } else {
//             return ListView.builder(
//               itemCount: controller.filteredAppointments.length,
//               itemBuilder: (context, index) {
//                 final appointment = controller.filteredAppointments[index];
//                 return CustomDeleteAppointmentItem(
//                   appointment: appointment,
//                   onDelete: () {
//                     showDeleteAppointmentDialog(
//                       context: context,
//                       onYes: () async {
//                         final success =
//                             await controller.deleteAppointment(appointment.id);
//                         if (success && context.mounted) {
//                           Get.back();
//                         }
//                       },
//                       onNo: () {
//                         Get.back();
//                       },
//                     );
//                   },
//                 );
//               },
//             );
//           }
//         }),
//       ),
//     );
//   }
//
//   Widget _buildFilterButton(CustomerAppointmentController controller) {
//     return Obx(() {
//       return PopupMenuButton<String>(
//         initialValue: controller.statusFilter.value, // ensures default marked
//         onSelected: (value) {
//           controller.setStatusFilter(value);
//         },
//         itemBuilder: (context) => [
//           PopupMenuItem(
//             value: 'pending',
//             child: Row(
//               children: [
//                 Text(
//                   'Pending'.tr,
//                   style: TextStyle(
//                     fontWeight: controller.statusFilter.value.toLowerCase() == 'pending'
//                         ? FontWeight.bold
//                         : FontWeight.normal,
//                     color: controller.statusFilter.value == 'pending'
//                         ? ColorsData.primary
//                         : Colors.black,
//                   ),
//                 ),
//                 if (controller.statusFilter.value == 'pending') ...[
//                   const SizedBox(width: 6),
//                   const Icon(Icons.check, color: ColorsData.primary, size: 16),
//                 ],
//               ],
//             ),
//           ),
//           PopupMenuItem(
//             value: 'completed',
//             child: Row(
//               children: [
//                 Text(
//                   'Completed'.tr,
//                   style: TextStyle(
//                     fontWeight: controller.statusFilter.value == 'completed'
//                         ? FontWeight.bold
//                         : FontWeight.normal,
//                     color: controller.statusFilter.value == 'completed'
//                         ? ColorsData.primary
//                         : Colors.black,
//                   ),
//                 ),
//                 if (controller.statusFilter.value == 'completed') ...[
//                   const SizedBox(width: 6),
//                   const Icon(Icons.check, color: ColorsData.primary, size: 16),
//                 ],
//               ],
//             ),
//           ),
//         ],
//         icon: const Icon(Icons.filter_list),
//       );
//     });
//   }
// }
