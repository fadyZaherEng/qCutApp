import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_button.dart';

class BarberServiceCard extends StatefulWidget {
  final String name;
  final String imageUrl;
  final int price;
  final int duration;
  final bool isSelected;
  final VoidCallback onPressed;

  const BarberServiceCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.duration,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  _BarberServiceCardState createState() => _BarberServiceCardState();
}

class _BarberServiceCardState extends State<BarberServiceCard> {
  late bool isSelectedLocal;

  @override
  void initState() {
    super.initState();
    isSelectedLocal = widget.isSelected;
  }

  @override
  void didUpdateWidget(covariant BarberServiceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      isSelectedLocal = widget.isSelected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 0,
      ),
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        border: Border.all(
            color:
                isSelectedLocal ? ColorsData.primary : ColorsData.cardStrock),
        color: ColorsData.secondary,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
            child: FadeInImage.assetNetwork(
              placeholder: AssetsData.hairCutInGallery,
              image: widget.imageUrl,
              height: 110.h,
              width: double.infinity,
              fit: BoxFit.cover,
              imageErrorBuilder: (context, error, stackTrace) => Image.asset(
                AssetsData.hairCutInGallery,
                height: 110.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.name,
                        style: Styles.textStyleS14W700(
                          color: ColorsData.bodyFont,
                        ),
                      ),
                    ),
                    Text(
                      "${widget.duration}${'minutes'.tr}",
                      style: Styles.textStyleS12W400(
                        color: ColorsData.bodyFont,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "\$${widget.price}",
                      style: Styles.textStyleS14W700(
                        color: ColorsData.bodyFont,
                      ),
                    ),
                    SizedBox(
                      height: 34.h,
                      width: 80.w,
                      child: CustomButton(
                        height: 34.h,
                        width: 80.w,
                        text: isSelectedLocal ? "booked".tr : "book".tr,
                        textStyle: Styles.textStyleS12W400(),
                        onPressed: () {
                          setState(() {
                            isSelectedLocal = !isSelectedLocal;
                          });
                          widget.onPressed();
                        },
                        backgroundColor: isSelectedLocal
                            ? ColorsData.cardStrock
                            : ColorsData.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
