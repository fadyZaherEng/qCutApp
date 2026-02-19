import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/widgets/custom_big_button.dart';
import 'package:q_cut/modules/auth/views/widgets/custom_text_form.dart';
import 'package:q_cut/modules/barber/map_search/map_search_screen.dart';
import 'package:q_cut/modules/customer/features/home_features/profile_feature/logic/profile_controller.dart';

class ChangeUserInfoBottomSheet extends StatefulWidget {
  final ProfileController? profileController;

  const ChangeUserInfoBottomSheet({super.key, this.profileController});

  @override
  State<ChangeUserInfoBottomSheet> createState() =>
      _ChangeUserInfoBottomSheetState();
}

class _ChangeUserInfoBottomSheetState extends State<ChangeUserInfoBottomSheet> {
  bool isClicked = true;

  @override
  Widget build(BuildContext context) {
    // Initialize controllers with current values
    widget.profileController!.fullNameController.text =
        widget.profileController!.profileData.value?.fullName ?? '';
    widget.profileController!.emailController.text =
        widget.profileController!.profileData.value?.phoneNumber ?? '';

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Icon(Icons.close, size: 24.sp),
                  ),
                ),
                SizedBox(height: 12.h),
                SvgPicture.asset(
                  height: 32.h,
                  width: 24.w,
                  AssetsData.profileIcon,
                  colorFilter: const ColorFilter.mode(
                    ColorsData.primary,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "changeYourName".tr,
                  style: Styles.textStyleS14W700(color: ColorsData.secondary),
                ),
                SizedBox(height: 8.h),
                CustomTextFormField(
                  style: TextStyle(color: Colors.black, fontSize: 12.sp),
                  controller: widget.profileController!.fullNameController,
                  fillColor: ColorsData.font,
                  hintText: "enterYourName".tr,
                  keyboardType: TextInputType.name,
                ),
                SizedBox(height: 20.h),
                CustomBigButton(
                  textData: widget.profileController!.isLoading.value
                      ? "updating".tr
                      : "confirm".tr,
                  onPressed: widget.profileController!.isLoading.value
                      ? null
                      : () async {
                          if (isClicked == true) {
                            isClicked = false;
                            setState(() {});
                            await widget.profileController!.updateProfile();
                            Navigator.pop(context);
                            await Future.delayed(const Duration(seconds: 2),
                                () {
                              isClicked = true;
                              setState(() {});
                            });
                          }
                        },
                ),
              ],
            )),
      ),
    );
  }
}

class ChangeUserLocationBottomSheet extends StatefulWidget {
  final ProfileController? profileController;

  const ChangeUserLocationBottomSheet({super.key, this.profileController});

  @override
  State<ChangeUserLocationBottomSheet> createState() =>
      _ChangeUserLocationBottomSheetState();
}

class _ChangeUserLocationBottomSheetState
    extends State<ChangeUserLocationBottomSheet> {
  @override
  void initState() {
    super.initState();
    // Initialize controllers with current values
    widget.profileController!.cityController.text =
        widget.profileController!.profileData.value?.city ?? '';
  }

  bool isClicked = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Icon(Icons.close, size: 24.sp),
                  ),
                ),
                SizedBox(height: 12.h),
                SvgPicture.asset(
                  height: 32.h,
                  width: 24.w,
                  AssetsData.profileIcon,
                  colorFilter: const ColorFilter.mode(
                    ColorsData.primary,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "changeYourCity".tr,
                  style: Styles.textStyleS14W700(color: ColorsData.secondary),
                ),
                SizedBox(height: 8.h),
                CustomTextFormField(
                  style: TextStyle(color: Colors.black, fontSize: 12.sp),
                  controller: widget.profileController!.cityController,
                  fillColor: ColorsData.font,
                  hintText: "enterYourCity".tr,
                  keyboardType: TextInputType.name,
                  suffixIcon: InkWell(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) {
                      //       return MapSearchScreen(
                      //         initialLatitude: 32.0853,
                      //         initialLongitude: 34.7818,
                      //         onLocationSelected: (lat, lng, address) {
                      //           // Navigator.pop(context, address); // رجّع العنوان مع الـ pop
                      //           print(address);
                      //           widget.profileController!.cityController.text =
                      //               address;
                      //         },
                      //       );
                      //     },
                      //   ),
                      // ).then((selectedAddress) {
                      //   if (selectedAddress != null) {
                      //     print(selectedAddress);
                      //     widget.profileController!.cityController.text =
                      //         selectedAddress;
                      //     setState(() {}); // يحدث الـ TextField
                      //   }
                      // });
                    },
                    child: const Icon(
                      Icons.location_on,
                      color: ColorsData.primary,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                CustomBigButton(
                  textData: widget.profileController!.isLoading.value
                      ? "updating".tr
                      : "confirm".tr,
                  onPressed: widget.profileController!.isLoading.value
                      ? null
                      : () async {
                          if (isClicked == true) {
                            isClicked = false;
                            setState(() {});
                            await widget.profileController!
                                .updateProfile(cityChanged: true);
                            Navigator.pop(context);
                            await Future.delayed(const Duration(seconds: 2),
                                () {
                              isClicked = true;
                              setState(() {});
                            });
                          }
                        },
                ),
              ],
            )),
      ),
    );
  }
}
