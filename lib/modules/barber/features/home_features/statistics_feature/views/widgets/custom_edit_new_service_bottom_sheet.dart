import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/logic/b_profile_controller.dart';

class CustomEditNewServiceBottomSheet extends StatefulWidget {
  final String serviceId;
  final String serviceName;
  final String servicePrice;
  final int minTime;
  final int maxTime;
  final String? serviceImagePath;
  final Function(bool success)? onServiceUpdated;

  const CustomEditNewServiceBottomSheet({
    super.key,
    required this.serviceId,
    required this.serviceName,
    required this.servicePrice,
    required this.minTime,
    required this.maxTime,
    this.serviceImagePath,
    this.onServiceUpdated,
  });

  @override
  State<CustomEditNewServiceBottomSheet> createState() =>
      _CustomEditNewServiceBottomSheetState();
}

class _CustomEditNewServiceBottomSheetState
    extends State<CustomEditNewServiceBottomSheet> {
  late TextEditingController serviceNameController;
  late TextEditingController servicePriceController;
  int? selectedMinTime;
  int? selectedMaxTime;
  File? _selectedImage;
  late final BProfileController _profileController;
  bool _isSubmitting = false;
  bool _isUploadingImage = false;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    serviceNameController = TextEditingController(text: widget.serviceName);
    servicePriceController = TextEditingController(text: widget.servicePrice);
    selectedMinTime = widget.minTime;
    selectedMaxTime = widget.maxTime;
    _uploadedImageUrl = widget.serviceImagePath;

    // Register the controller if it doesn't exist yet
    if (!Get.isRegistered<BProfileController>()) {
      _profileController = Get.put(BProfileController());
    } else {
      _profileController = Get.find<BProfileController>();
    }
  }

  @override
  void dispose() {
    serviceNameController.dispose();
    servicePriceController.dispose();
    super.dispose();
  }

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
        _uploadedImageUrl =
            null; // Reset uploaded URL when new image is selected
      });

      // Upload the selected image
      await _uploadSelectedImage();
    }
  }

  // New method to upload selected image
  Future<void> _uploadSelectedImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      _uploadedImageUrl =
          await _profileController.uploadServiceImage(_selectedImage!);

      if (_uploadedImageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to upload image. Please try again.".tr),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error uploading image: $e".tr),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _updateService() async {
    if (serviceNameController.text.isEmpty ||
        servicePriceController.text.isEmpty ||
        selectedMinTime == null ||
        selectedMaxTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all fields".tr),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if image is selected but not uploaded yet
    if (_selectedImage != null && _uploadedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please wait for image upload to complete".tr),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _profileController.updateBarberService(
        serviceId: widget.serviceId,
        serviceName: serviceNameController.text,
        servicePrice: servicePriceController.text,
        min: selectedMinTime,
        max: selectedMaxTime,
        imageUrl: _uploadedImageUrl, // Pass the uploaded image URL
      );

      if (response['success'] == true) {
        // Explicitly fetch services to ensure data is up to date
        await _profileController.fetchBarberServices();

        // Force UI updates with explicit IDs
        _profileController.update(['barber_services']);

        // Force the entire app to rebuild - this ensures even non-GetX widgets update
        Get.forceAppUpdate();

        // Notify any parent widgets through the callback
        if (mounted) {
          // Delay the pop slightly to allow state to propagate
          await Future.delayed(const Duration(milliseconds: 100));

          Navigator.pop(context);
          if (widget.onServiceUpdated != null) {
            widget.onServiceUpdated!(true);
          }

          // Show a success message after navigation
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(
              content: Text("Service updated successfully".tr),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? "Failed to update service".tr),
              backgroundColor: Colors.red,
            ),
          );
          // Still call onServiceUpdated with false to indicate failure
          if (widget.onServiceUpdated != null) {
            widget.onServiceUpdated!(false);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error updating service: $e".tr),
            backgroundColor: Colors.red,
          ),
        );
        if (widget.onServiceUpdated != null) {
          widget.onServiceUpdated!(false);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Text(
              "Edit Service".tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC49A58),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Edit Service photo".tr,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),

            /// Image Picker with upload status
            _isUploadingImage
                ? const Center(
                    child: SpinKitDoubleBounce(
                      color: ColorsData.primary,
                    ),
                  )
                : Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _selectedImage != null
                              ? Image.file(_selectedImage!,
                                  width: 120, height: 120, fit: BoxFit.cover)
                              : (_uploadedImageUrl != null)
                                  ? Image.network(_uploadedImageUrl!,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, e, s) => Container(
                                            width: 120,
                                            height: 120,
                                            color: Colors.grey[300],
                                            child: const Icon(
                                                Icons.broken_image,
                                                size: 50,
                                                color: Colors.grey),
                                          ))
                                  : Container(
                                      width: 120,
                                      height: 120,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image,
                                          size: 50, color: Colors.grey),
                                    ),
                        ),
                      ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add,
                                size: 20, color: Colors.black),
                          ),
                        ),
                      ),
                      if (_uploadedImageUrl != null && _selectedImage != null)
                        Positioned(
                          right: 4,
                          top: 4,
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
                  ),
            const SizedBox(height: 16),

            /// Service Name Input
            _buildTextField(serviceNameController, "Change Service Name".tr),
            const SizedBox(height: 12),

            /// Service Price Input
            _buildTextField(servicePriceController, "Change Service Price".tr,
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),

            /// Service Time Input (From-To)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From'.tr,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<int>(
                        value: selectedMinTime,
                        isExpanded: true,
                        items: List.generate(24, (index) {
                          final value = (index + 1) * 5;
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(
                              "$value ${"mins".tr}",
                              style: Styles.textStyleS14W400(
                                color: ColorsData.secondary,
                              ),
                            ),
                          );
                        }),
                        onChanged: (value) {
                          if (selectedMaxTime != null && value! >= selectedMaxTime!) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('From time must be less than To time'.tr),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          setState(() => selectedMinTime = value);
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'To'.tr,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<int>(
                        value: selectedMaxTime,
                        isExpanded: true,
                        items: List.generate(24, (index) {
                          final value = (index + 1) * 5;
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(
                              "$value ${"mins".tr}",
                              style: Styles.textStyleS14W400(
                                color: ColorsData.secondary,
                              ),
                            ),
                          );
                        }),
                        onChanged: (value) {
                          if (selectedMinTime != null && value! <= selectedMinTime!) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('To time must be greater than From time'.tr),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          setState(() => selectedMaxTime = value);
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            /// Confirm Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC49A58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: (_isSubmitting || _isUploadingImage)
                    ? null
                    : _updateService,
                child: (_isSubmitting || _isUploadingImage)
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Confirm".tr,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Custom TextField
  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      style: Styles.textStyleS14W400(color: ColorsData.dark),
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: ColorsData.dark),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// Show Bottom Sheet Function
void showCustomEditNewServiceBottomSheet(
  BuildContext context, {
  required String serviceId,
  required String serviceName,
  required String servicePrice,
  required int minTime,
  required int maxTime,
  String? serviceImagePath,
  Function(bool success)? onServiceUpdated,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => CustomEditNewServiceBottomSheet(
      serviceId: serviceId,
      serviceName: serviceName,
      servicePrice: servicePrice,
      minTime: minTime,
      maxTime: maxTime,
      serviceImagePath: serviceImagePath,
      onServiceUpdated: onServiceUpdated,
    ),
  );
}
