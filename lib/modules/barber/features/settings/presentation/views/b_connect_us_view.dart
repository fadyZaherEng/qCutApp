import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:q_cut/core/utils/widgets/custom_app_bar.dart';
import 'package:q_cut/modules/barber/features/settings/presentation/views/widgets/b_connect_us_view_body.dart';

class BConnectUsView extends StatelessWidget {
  const BConnectUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return   Scaffold(
        appBar: CustomAppBar(title: "contact us".tr), body: BConnectUsViewBody());
  }
}
