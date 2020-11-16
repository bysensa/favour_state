import 'package:example/domain/state/store.dart';
import 'package:favour_state/favour_state.dart';
import 'package:get/get.dart';

import 'state/app_state.dart';

class StateBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<Store<AppState>>(AppStore());
  }
}
