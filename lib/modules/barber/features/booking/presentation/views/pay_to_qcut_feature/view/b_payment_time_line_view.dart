import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:q_cut/core/utils/widgets/custom_app_bar.dart';
import 'package:q_cut/modules/barber/features/booking/presentation/views/widgets/b_payment_time_line_view_body.dart';

class BPaymentTimeLineView extends StatelessWidget {
  const BPaymentTimeLineView({super.key});

  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      appBar: CustomAppBar(title: "Payment Time line".tr),
      body: BPaymentTimeLineViewBody(),
    );
  }
}
