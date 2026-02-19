import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/modules/auth/views/widgets/custom_text_form.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/logic/b_profile_controller.dart';

class CustomAddNewServiceBottomSheet extends StatefulWidget {
  const CustomAddNewServiceBottomSheet({super.key});

  @override
  State<CustomAddNewServiceBottomSheet> createState() =>
      _CustomAddNewServiceBottomSheetState();
}

class _CustomAddNewServiceBottomSheetState
    extends State<CustomAddNewServiceBottomSheet> {
  final TextEditingController serviceNameController = TextEditingController();
  final TextEditingController servicePriceController = TextEditingController();
  final TextEditingController serviceMinTimeController =
      TextEditingController();
  final TextEditingController serviceMaxTimeController =
      TextEditingController();
  File? _selectedImage;
  late final BProfileController _profileController;

  String? _uploadedImageUrl;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    // Register the controller if it doesn't exist yet
    if (!Get.isRegistered<BProfileController>()) {
      _profileController = Get.put(BProfileController());
    } else {
      _profileController = Get.find<BProfileController>();
    }
  }

  /// Function to pick an image from gallery or camera
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text('Take a photo'.tr),
                onTap: () async {
                  final XFile? file =
                      await picker.pickImage(source: ImageSource.camera);
                  Navigator.pop(context, file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: Text('Choose from gallery'.tr),
                onTap: () async {
                  final XFile? file =
                      await picker.pickImage(source: ImageSource.gallery);
                  Navigator.pop(context, file);
                },
              ),
            ],
          ),
        );
      },
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// Handle the creation of a new service
  Future<void> _handleCreateService() async {
    // Validate inputs
    if (serviceNameController.text.isEmpty ||
        servicePriceController.text.isEmpty ||
        serviceMinTimeController.text.isEmpty ||
        serviceMaxTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Upload image if selected but not yet uploaded
    if (_selectedImage != null && _uploadedImageUrl == null) {
      setState(() {
        _isUploadingImage = true;
      });

      _uploadedImageUrl =
          await _profileController.uploadServiceImage(_selectedImage!);

      setState(() {
        _isUploadingImage = false;
      });

      if (_uploadedImageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to upload image. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    print("min time: ${serviceMinTimeController.text}");
    print("max time: ${serviceMaxTimeController.text}");

    // Call the controller method to create the service
    final result = await _profileController.createBarberService(
      serviceName: serviceNameController.text,
      servicePrice: servicePriceController.text,
      min: int.parse( serviceMinTimeController.text),
      max: int.parse( serviceMaxTimeController.text),
      imageUrl: _uploadedImageUrl, // Pass the uploaded image URL
    );

    if (result['success']) {
      Navigator.of(context).pop();

      // Explicitly fetch services to ensure data is up to date
      await _profileController.fetchBarberServices();

      // Force a rebuild of any widgets that depend on barberServices
      _profileController.update(['barber_services']);

      // Force the entire app to rebuild - this ensures even non-GetX widgets update
      Get.forceAppUpdate();

      // Delay slightly to allow state to propagate
      await Future.delayed(const Duration(milliseconds: 100));

      // Close the bottom sheet on success
      // Navigator.pop(context);

      // Show a success message after navigation
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text("Service created successfully".tr),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Call Get.reset to refresh injected dependencies (if needed)
      // Get.reset(clearRouteBindings: false);
    }else{
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? "Failed to create service".tr),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int? selectedMinTime;
  int? selectedMaxTime;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Container(
              height: 6.h,
              width: 100.w,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            const SizedBox(height: 12),
            SvgPicture.asset(
              height: 32.h,
              width: 32.w,
              AssetsData.addnewservicebottonicon,
            ),
            const SizedBox(height: 8),
            Text(
              "Add new service".tr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ColorsData.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Add Service photo".tr,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: ColorsData.secondary,
              ),
            ),
            const SizedBox(height: 12),

            /// Image Picker
            GestureDetector(
              onTap: _isUploadingImage ? null : _pickImage,
              child: _isUploadingImage
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: ColorsData.primary,
                      ),
                    )
                  : _selectedImage != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _selectedImage!,
                                width: 100.w,
                                height: 100.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                            if (_uploadedImageUrl != null)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                          ],
                        )
                      : SvgPicture.asset(
                          AssetsData.addImageIcon,
                          height: 89.h,
                          width: 89.w,
                          colorFilter: const ColorFilter.mode(
                            ColorsData.primary,
                            BlendMode.srcIn,
                          ),
                        ),
            ),
            SizedBox(height: 16.h),

            /// Service Name Input
            CustomTextFormField(
              style: Styles.textStyleS14W400(
                color: ColorsData.secondary,
              ),
              fillColor: ColorsData.font,
              controller: serviceNameController,
              hintText: "Enter Service Name".tr,
            ),
            SizedBox(height: 24.h),

            /// Service Price Input
            CustomTextFormField(
              style: Styles.textStyleS14W400(
                color: ColorsData.secondary,
              ),
              fillColor: ColorsData.font,
              controller: servicePriceController,
              hintText: "Enter Service Price".tr,
            ),
            SizedBox(height: 24.h),

            /// Service Time Input
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    /// --- Minimum Time ---
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'From'.tr,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          SizedBox(
                            width: 164.w,
                            height: 36.h,
                            child: DropdownButtonFormField<int>(
                              value: selectedMinTime,
                              items: List.generate(24, (index) {
                                final value = (index + 1) * 5;
                                // لو الماكس موجود، خلي المين أقل منه فقط
                                if (selectedMaxTime != null &&
                                    value >= selectedMaxTime!) {
                                  return null;
                                }
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(
                                    "$value ${"mins".tr}",
                                    style: Styles.textStyleS14W400(
                                      color: ColorsData.secondary,
                                    ),
                                  ),
                                );
                              }).whereType<DropdownMenuItem<int>>().toList(),
                              onChanged: (value) {
                                if (selectedMaxTime != null &&
                                    value! >= selectedMaxTime!) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'From time must be less than To time'
                                            .tr,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }
                                setState(() {
                                  selectedMinTime = value;
                                  serviceMinTimeController.text =
                                      value.toString();
                                });
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 0),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4.r)),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFAAA8BD),
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 24.w),

                    /// --- Maximum Time ---
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'To'.tr,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          SizedBox(
                            width: 164.w,
                            height: 36.h,
                            child: DropdownButtonFormField<int>(
                              value: selectedMaxTime,
                              items: List.generate(24, (index) {
                                final value = (index + 1) * 5;
                                // لو المين موجود، خلي الماكس أكبر منه فقط
                                if (selectedMinTime != null &&
                                    value <= selectedMinTime!) {
                                  return null;
                                }
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(
                                    "$value ${"mins".tr}",
                                    style: Styles.textStyleS14W400(
                                      color: ColorsData.secondary,
                                    ),
                                  ),
                                );
                              }).whereType<DropdownMenuItem<int>>().toList(),
                              onChanged: (value) {
                                if (selectedMinTime != null &&
                                    value! <= selectedMinTime!) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'To time must be greater than From time'
                                            .tr,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }
                                setState(() {
                                  selectedMaxTime = value;
                                  serviceMaxTimeController.text =
                                      value.toString();
                                });
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 0),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4.r)),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFAAA8BD),
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 24.h),

            /// Confirm Button
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC49A58),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: (_profileController.isCreatingService.value ||
                            _isUploadingImage)
                        ? null
                        : _handleCreateService,
                    child: (_profileController.isCreatingService.value ||
                            _isUploadingImage)
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          )
                        : Text(
                            "Confirm".tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                )),
            SizedBox(height: 64.h),
          ],
        ),
      ),
    );
  }
}

/// Show Bottom Sheet Function
void showCustomAddNewServiceBottomSheet(BuildContext context) {
  // Ensure BProfileController is registered before showing the bottom sheet
  if (!Get.isRegistered<BProfileController>()) {
    Get.put(BProfileController());
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (context) => const CustomAddNewServiceBottomSheet(),
  );
}
