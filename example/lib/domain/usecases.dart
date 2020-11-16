import 'package:example/domain/usecases/payment_input_usecase.dart';
import 'package:get/get.dart';

class UsecasesBindings extends Bindings {
  @override
  void dependencies() {
    Get.create(() => PaymentInputUseCase(Get.find()));
  }
}
