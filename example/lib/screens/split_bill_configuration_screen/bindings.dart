import 'package:get/get.dart';

import 'controller.dart';

class SplitBillConfigurationBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(
      SplitBillConfigurationController(
        paymentInputUseCase: Get.find(),
      ),
    );
  }
}
