import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/services/shared_pref/shared_pref.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'package:q_cut/core/utils/styles.dart';

class DeleteAccountReasonPage extends StatefulWidget {
  const DeleteAccountReasonPage({super.key});

  @override
  State<DeleteAccountReasonPage> createState() => _DeleteAccountReasonPageState();
}

class _DeleteAccountReasonPageState extends State<DeleteAccountReasonPage> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isLoading = false;

  Future<void> _deleteAccount() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      Get.snackbar(
        "Required".tr,
        "Please provide a reason for deleting your account".tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await NetworkAPICall().deleteDataWithBody(
        "${Variables.baseUrl}barber/me",
        {"deleteReason": reason},
      );

      if (response.statusCode == 200) {
        ShowToast.showSuccessSnackBar(message: "Account deleted successfully".tr);
        await SharedPref().clearPreferences();
        Get.offAllNamed(AppRouter.initialPath);
      } else {
        ShowToast.showError(message: "Failed to delete account".tr);
      }
    } catch (e) {
      print("Delete Account Error: $e");
      ShowToast.showError(message: "Something went wrong".tr);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsData.secondary,
      appBar: AppBar(
        backgroundColor: ColorsData.secondary,
        elevation: 0,
        title: Text("Delete account".tr, style: Styles.textStyleS16W700(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Why do you want to cancel the account?".tr,
              style: Styles.textStyleS18W700(color: Colors.white),
            ),
            SizedBox(height: 12.h),
            Text(
              "Your feedback helps us improve.".tr,
              style: Styles.textStyleS14W400(color: Colors.white70),
            ),
            SizedBox(height: 24.h),
            TextField(
              controller: _reasonController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter your reason...".tr,
                hintStyle: const TextStyle(color: Colors.white38),
                fillColor: Colors.white.withOpacity(0.05),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: ColorsData.primary),
                ),
              ),
            ),
            SizedBox(height: 40.h),
            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _deleteAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Delete account".tr,
                        style: Styles.textStyleS16W700(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
