import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/modules/customer/features/booking_features/display_barber_services_feature/models/barber_service.dart';

class QCutServiceCard extends StatefulWidget {
  final BarberServices? service;
  final bool? isSelected;
  final Function(int)? onQuantityChanged;
  final VoidCallback? onPressed;
  final int numberofUsers;

  const QCutServiceCard({
    super.key,
    this.service,
    this.isSelected,
    this.onPressed,
    this.onQuantityChanged,
    this.numberofUsers = 1,
  });

  @override
  _QCutServiceCardState createState() => _QCutServiceCardState();
}

class _QCutServiceCardState extends State<QCutServiceCard> {
  int serviceCount = 0;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPressed,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: ColorsData.cardStrock),
          color: ColorsData.secondary,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              child: Image.network(
                widget.service?.imageUrl ?? AssetsData.hairCutInGallery,
                height: 110.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  AssetsData.hairCutInGallery,
                  height: 110.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.service?.name.tr ?? "Hair cut",
                          style: Styles.textStyleS14W700(
                            color: ColorsData.bodyFont,
                          ),
                        ),
                        Text(
                          "\$${widget.service?.price ?? '20'}",
                          style: Styles.textStyleS14W700(
                            color: ColorsData.bodyFont,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "${widget.service!.getDisplayDuration()}${'minutes'.tr}",
                      style: Styles.textStyleS12W400(
                        color: ColorsData.bodyFont,
                      ),
                    ),
                    Spacer(),
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 4.h),
                        height: 30.h,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: ColorsData.cardStrock),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (serviceCount > 0) {
                                    serviceCount--;
                                    widget.onQuantityChanged
                                        ?.call(serviceCount);
                                  }
                                });
                              },
                              child: Container(
                                width: 28.w,
                                height: double.infinity,
                                alignment: Alignment.center,
                                child: Text(
                                  "-",
                                  style: Styles.textStyleS14W500(
                                    color: ColorsData.font,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Text(
                                "$serviceCount",
                                style: Styles.textStyleS14W500(
                                  color: ColorsData.font,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (serviceCount > widget.numberofUsers - 1) {
                                  return;
                                }
                                setState(() {
                                  serviceCount++;
                                  widget.onQuantityChanged?.call(serviceCount);
                                });
                              },
                              child: Container(
                                width: 28.w,
                                height: double.infinity,
                                alignment: Alignment.center,
                                child: Text(
                                  "+",
                                  style: Styles.textStyleS14W500(
                                    color: ColorsData.font,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
