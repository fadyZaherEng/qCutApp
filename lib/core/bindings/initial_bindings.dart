import 'package:get/get.dart';
import 'package:q_cut/core/localization/change_local.dart';

import 'package:q_cut/core/utils/network/network_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(NetworkController(), permanent: true);
    // Add other controllers you need to initialize here
  }
}
