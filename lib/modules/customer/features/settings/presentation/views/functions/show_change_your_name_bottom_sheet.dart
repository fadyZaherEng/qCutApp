import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:q_cut/modules/customer/features/settings/presentation/views/widgets/change_your_name_bottom_sheet.dart';

Future<void> showChangeYourNameBottomSheet(BuildContext context) async {
  await showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (context) => const ChangeYourNameBottomSheet(),
  );
}

void showBChangeYourNameBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (context) =>   BChangeYourNameBottomSheet(),
  );
}
