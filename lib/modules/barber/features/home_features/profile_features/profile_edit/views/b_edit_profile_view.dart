import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/main.dart';
import 'package:q_cut/modules/auth/views/widgets/custom_text_form.dart';
import 'package:q_cut/modules/barber/map_search/map_search_screen.dart';
import 'package:q_cut/modules/auth/views/functions/validate_arabic_text.dart';
import 'package:q_cut/modules/auth/views/functions/arabic_input_formatter.dart';
import '../../../statistics_feature/views/widgets/ChooseOffDaysBottomSheet.dart';
import '../../profile_display/models/barber_profile_model.dart';
import '../logic/b_edit_profile_controller.dart';

class BEditProfileView extends StatefulWidget {
  const BEditProfileView({super.key});

  @override
  State<BEditProfileView> createState() => _BEditProfileViewState();
}

class _BEditProfileViewState extends State<BEditProfileView> {
  bool isClicked = true;

  @override
  void initState() {
    super.initState();
    // Make sure the controller is registered
    final controller = Get.isRegistered<BEditProfileController>()
        ? Get.find<BEditProfileController>()
        : Get.put(BEditProfileController());

    if (controller.cityController.text == "New City") {
      Future.delayed(Duration(milliseconds: 500), () {
        // Ensure the controller is initialized
        Get.snackbar(
          "Complete Profile".tr,
          "Please fill out your profile to start working.".tr,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Make sure the controller is registered
    final controller = Get.isRegistered<BEditProfileController>()
        ? Get.find<BEditProfileController>()
        : Get.put(BEditProfileController());
    instagramLink = controller.instagramController.text.isNotEmpty
        ? controller.instagramController.text
        : "https://www.instagram.com/";
    return Scaffold(
      backgroundColor: ColorsData.secondary,
      appBar: AppBar(
        backgroundColor: ColorsData.secondary,
        title: Text("Edit Profile".tr, style: Styles.textStyleS16W700()),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(
            () => controller.isLoading.value
            ? Center(child: SpinKitDoubleBounce(color: ColorsData.primary))
            : SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Photo Section
              _buildTitle("Change Profile Photo".tr),
              SizedBox(height: 16.h),
              _buildProfilePhoto(controller),
              SizedBox(height: 24.h),

              // Cover Photo Section
              _buildTitle("Change Cover Photo".tr),
              SizedBox(height: 16.h),
              _buildCoverPhoto(controller),
              SizedBox(height: 32.h),

              // Personal Details Section
              _buildTitle("Change Your Details".tr),
              SizedBox(height: 20.h),
              _buildInputField("Change your name".tr, "Full Name".tr,
                  controller.nameController, controller,
                  textDirection: TextDirection.rtl,
                  inputFormatters: [ArabicInputFormatter()],
                  validator: (value) => validateArabicText(value)),
              SizedBox(height: 16.h),
              // _buildInputField(
              //   "Change Your Phone Number".tr,
              //   "Phone Number".tr,
              //   controller.phoneController,
              //   controller,
              //   isPhone: true,
              // ),
              // SizedBox(height: 16.h),
              _buildInputField(
                "change your barber shop name".tr,
                "Saloon Name".tr,
                controller.saloonController,
                controller,
                textDirection: TextDirection.rtl,
                inputFormatters: [ArabicInputFormatter()],
                validator: (value) => validateArabicText(value),
              ),
              SizedBox(height: 16.h),
              _buildInputField(
                "Change Your City".tr,
                "City".tr,
                controller.cityController,
                controller,
                readOnly: false,
                textDirection: TextDirection.rtl,
                inputFormatters: [ArabicInputFormatter()],
                validator: (value) => validateArabicText(value),
              ),
              SizedBox(height: 16.h),
              _buildInputField(
                "Change Your Location Description".tr,
                "Location Description".tr,
                controller.locationDescriptionController,
                controller,
              ),
              SizedBox(height: 16.h),
              // _buildInputField("Change Your Bank Account".tr,
              //     "Bank Account".tr, controller.bankAccountController),
              SizedBox(height: 16.h),
              _buildInputField(
                "Change your Instagram link (Optional)".tr,
                "Instagram".tr,
                controller.instagramController,
                controller,
              ),
              // _buildNoteText(
              //   "It's not necessary if you haven't".tr,
              // ),
              //
              // SizedBox(height: 24.h),
              // Divider(thickness: 1.w, color: ColorsData.cardStrock),
              // SizedBox(height: 24.h),
              //
              // // Off Days Section
              // _buildTitle("set working days".tr),
              // SizedBox(height: 16.h),
              // _buildDropdownField("Select days when you don't work".tr,
              //         () {
              //       Get.bottomSheet(
              //         ChooseOffDaysBottomSheet(
              //           onDaysSelected: (selectedDays) {
              //             // Get the current controller to use
              //             final controller =
              //             Get.find<BEditProfileController>();
              //             // Update the controller with selected off days
              //             controller.setOffDays(selectedDays);
              //           },
              //           selectedDays: Get.find<BEditProfileController>()
              //               .offDays
              //               .toList(),
              //         ),
              //         isScrollControlled: true,
              //         backgroundColor: Colors.transparent,
              //       );
              //     }),
              // _buildNoteText(
              //     "It's not necessary if you don't have off days".tr),
              //
              // SizedBox(height: 32.h),
              //
              // // Working Days Section
              // _buildTitle("Set Your Working Hours".tr),
              // SizedBox(height: 16.h),
              // _buildWorkingDaysSelector(controller),

              SizedBox(height: 16.h),

              // Confirm Button
              _buildConfirmButton(controller),
              SizedBox(height: 64.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Text(text,
        style: Styles.textStyleS14W700(color: ColorsData.primary));
  }

  Widget _buildProfilePhoto(BEditProfileController controller) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 90.r,
            height: 90.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: controller.getProfileImage,
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  print('Error loading profile image: $exception');
                },
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => controller.pickProfileImage(),
              child: CircleAvatar(
                radius: 16.r,
                backgroundColor: ColorsData.primary,
                child: const Icon(Icons.add, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverPhoto(BEditProfileController controller) {
    return Container(
      height: 150.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        image: DecorationImage(
          image: controller.getCoverImage,
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {
            print('Error loading cover image: $exception');
          },
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 8.h,
            right: 8.w,
            child: GestureDetector(
              onTap: () => controller.pickCoverImage(),
              child: CircleAvatar(
                radius: 18.r,
                backgroundColor: ColorsData.primary,
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
      String label, String hint, TextEditingController controll, controller,
      {bool isPhone = false,
      bool readOnly = false,
      TextDirection? textDirection,
      List<TextInputFormatter>? inputFormatters,
      String? Function(String?)? validator}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Styles.textStyleS14W500(color: ColorsData.thirty)),
          SizedBox(height: 8.h),
          CustomTextFormField(
            onTap: () {
              if (!readOnly) return;
              // Future.delayed to ensure the tap is registered properly

              // Make sure the controller is registered
              final controllers = Get.isRegistered<BEditProfileController>()
                  ? Get.find<BEditProfileController>()
                  : Get.put(BEditProfileController());
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return MapSearchScreen(
                  initialLatitude: controllers.locationLatitude ?? 32.0853,
                  initialLongitude: controllers.locationLongitude ?? 34.7818,
                  onLocationSelected: (lat, lng, address) {
                    controller.cityController.text = address;
                    controller.locationLatitude = lat;
                    controller.locationLongitude = lng;
                    setState(() {});
                  },
                );
              }));
            },
            readOnly: readOnly,
            fillColor: ColorsData.secondary,
            hintText: hint,
            controller: controll,
            keyboardType: isPhone ? TextInputType.phone : null,
            textDirection: textDirection,
            inputFormatters: inputFormatters,
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _buildNoteText(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child:
      Text(text, style: Styles.textStyleS14W400(color: ColorsData.primary)),
    );
  }

  Widget _buildConfirmButton(BEditProfileController controller) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorsData.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        onPressed: () async {
          if (isClicked) {
            isClicked = false;
            setState(() {});
            try {
              await controller.updateProfile();
            } finally {
              isClicked = true;
              if (mounted) setState(() {});
            }
          }
        },
        child: Text("Confirm".tr,
            style: Styles.textStyleS16W600(color: Colors.white)),
      ),
    );
  }

}
