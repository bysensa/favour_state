import 'package:example/domain/state/app_state.dart';
import 'package:favour_state/favour_state.dart';

enum PaymentInputType {
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  zero,
  blank,
  delete
}

class PaymentInputUseCase extends UseCase<AppState, PaymentInputType> {
  PaymentInputUseCase(Store<AppState> store) : super(store);

  @override
  Future<void> execute(PaymentInputType param) {
    assert(param != null, 'param is null');
  }
}
