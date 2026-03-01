import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/widgets/custom_app_bar.dart';

class LegalDocumentsView extends StatelessWidget {
  final String titleKey;
  
  const LegalDocumentsView({super.key, required this.titleKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: titleKey.tr),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Text(
              titleKey == "Terms and Conditions" 
                  ? "termsContent".tr 
                  : "privacyContent".tr,
              style: TextStyle(fontSize: 14.sp, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
