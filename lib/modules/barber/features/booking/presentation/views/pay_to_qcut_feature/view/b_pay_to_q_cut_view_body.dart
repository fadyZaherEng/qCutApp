import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/widgets/custom_big_button.dart';
import 'package:q_cut/modules/barber/features/booking/presentation/views/pay_to_qcut_feature/logic/pay_to_qcut_controller.dart';
import 'package:q_cut/modules/barber/features/booking/presentation/views/pay_to_qcut_feature/models/collection_schedule_model.dart';

class BPayToQCutViewBody extends StatefulWidget {
  const BPayToQCutViewBody({super.key});

  @override
  State<BPayToQCutViewBody> createState() => _BPayToQCutViewBodyState();
}

class _BPayToQCutViewBodyState extends State<BPayToQCutViewBody> {
  final PayToQcutController _controller = Get.put(PayToQcutController());
  bool isClicked = true;
  final RxInt _selectedTab = 0.obs; // Set to 0 (Previous) as default to show the list

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(
          child: SpinKitDoubleBounce(color: ColorsData.primary),
        );
      }

      if (_controller.isError.value) {
        return _buildErrorWidget();
      }

      return RefreshIndicator(
        onRefresh: _controller.fetchInvoiceData,
        color: ColorsData.primary,
        child: _buildMainContent(),
      );
    });
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'errorLoadingData'.tr,
            style: TextStyle(color: Colors.white, fontSize: 16.sp),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              _controller.errorMessage.value,
              style: TextStyle(color: Colors.red, fontSize: 14.sp),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsData.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (isClicked) {
                isClicked = false;
                setState(() {});
                _controller.fetchInvoiceData();
                await Future.delayed(const Duration(seconds: 2), () {
                  isClicked = true;
                  setState(() {});
                });
              }
            },
            child: Text('retry'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Scrollbar(
      thumbVisibility: true,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          SizedBox(height: 10.h),
          _buildHeaderSection(),
          SizedBox(height: 16.h),
          _buildPaymentCard(),
          SizedBox(height: 16.h),
          _buildActionButtons(),
          SizedBox(height: 55.h),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        Center(
          child: Image.asset(
            AssetsData.thanksImage,
            width: 183.w,
            height: 130.h,
          ),
        ),
        SizedBox(height: 10.h),
        Center(
          child: Text(
            'weAreGlad'.tr,
            style: TextStyle(
              color: ColorsData.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Center(
          child: Text(
            "checkSubscription".tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorsData.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20.r),
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildJoinDateSection(),
          SizedBox(height: 20.h),
          Divider(color: Colors.white24, height: 1.h),
          SizedBox(height: 20.h),
          Text(
            "monthlyPayment".trParams({
              "amount": "200"
            }),
            style: TextStyle(
              color: ColorsData.primary,
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              _buildTabItem("previousPayments".tr, 0),
              _buildTabItem("currentlyPayments".tr, 1),
            ],
          ),
          SizedBox(height: 20.h),
          Obx(() => _selectedTab.value == 0
              ? _buildPreviousPaymentsList()
              : _buildCurrentlyPaymentsGrid()),
        ],
      ),
    );
  }

  Widget _buildJoinDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'timeToJoinedQcut'.tr,
          style: TextStyle(
            color: ColorsData.primary,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        _buildJoinInfoRow('dateToJoined'.tr, _controller.getJoinDate()),
        SizedBox(height: 8.h),
        _buildJoinInfoRow('joinedSince'.tr, _controller.getJoinedSince(), isGold: true),
      ],
    );
  }

  Widget _buildJoinInfoRow(String label, String value, {bool isGold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: 13.sp),
        ),
        Text(
          value,
          style: TextStyle(
            color: isGold ? ColorsData.primary : Colors.white,
            fontSize: 13.sp,
            fontWeight: isGold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildTabItem(String title, int index) {
    return Obx(() {
      bool isSelected = _selectedTab.value == index;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            _selectedTab.value = index;
          },
          child: Column(
            children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Container(
              height: 2.h,
              width: 80.w,
              color: isSelected ? ColorsData.primary : Colors.transparent,
            ),
          ],
        ),
      ),
      );
    });
  }

  Widget _buildPreviousPaymentsList() {
    final payments = _controller.getPaymentTimeline();

    if (payments.isEmpty || (payments.length == 1 && payments[0]['date'] == 'No data')) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Center(
          child: Text(
            "No previous payments found",
            style: TextStyle(color: Colors.white70, fontSize: 13.sp),
          ),
        ),
      );
    }

    return Column(
      children: payments.map((payment) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  payment['date'],
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Text(
                    //   "totalAfterDeductions".tr,
                    //   style: TextStyle(
                    //     color: Colors.black54,
                    //     fontSize: 10.sp,
                    //   ),
                    // ),
                    Text(
                      "${payment['amount']} LE",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCurrentlyPaymentsGrid() {
    return Obx(() {
      if (_controller.schedules.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Center(
            child: Text(
              "noSchedulesAvailable".tr,
              style: TextStyle(color: Colors.white70, fontSize: 13.sp),
            ),
          ),
        );
      }

      return Row(
        children: _controller.schedules.map((schedule) {
          bool isSelected = _controller.selectedScheduleId.value == schedule.id;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: _buildCurrentPaymentCard(schedule, isSelected),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildCurrentPaymentCard(CollectionSchedule schedule, bool isSelected) {
    String startTime = DateFormat('HH:mm').format(
        DateTime.fromMillisecondsSinceEpoch(schedule.startTime));
    String endTime = DateFormat('HH:mm').format(
        DateTime.fromMillisecondsSinceEpoch(schedule.endTime));

    return GestureDetector(
      onTap: () {
        _controller.selectedScheduleId.value = schedule.id;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 24.h),
        decoration: BoxDecoration(
          color: isSelected ? ColorsData.primary : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ColorsData.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              schedule.dayOfWeek.tr,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "$startTime - $endTime",
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.black54,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Obx(() {
      if (_selectedTab.value == 1) {
        // Currently Tab - Select Schedule Slot
        return CustomBigButton(
          textData: "confirm".tr,
          onPressed: () {
            if (_controller.selectedScheduleId.value.isNotEmpty) {
              _controller.selectCollectionSlot(_controller.selectedScheduleId.value);
            } else {
              ShowToast.showWarning(message: "pleaseSelectSlot".tr);
            }
          },
        );
      } else {
        // Previous Tab - Pay Invoice
        final hasUnpaidInvoice =
            _controller.invoices.value.any((invoice) => !invoice.isPaid);

        final unpaidInvoiceId = hasUnpaidInvoice
            ? _controller.invoices.value.firstWhere((i) => !i.isPaid).id
            : null;

        return CustomBigButton(
          textData: "confirm".tr,
          onPressed: () {
            if (unpaidInvoiceId != null) {
              Get.toNamed(AppRouter.bpaymentMethodsPath,
                  arguments: unpaidInvoiceId);
            } else {
              ShowToast.showWarning(message: "noUnpaidInvoices".tr);
            }
          },
        );
      }
    });
  }
}
