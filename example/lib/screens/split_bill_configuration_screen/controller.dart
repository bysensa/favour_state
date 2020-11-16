import 'package:example/domain/usecases/payment_input_usecase.dart';
import 'package:get/get.dart';

class SplitBillConfigurationController extends GetxController {
  final PaymentInputUseCase paymentInputUseCase;

  SplitBillConfigurationController({
    this.paymentInputUseCase,
  });
}
