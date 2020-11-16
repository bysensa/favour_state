import 'package:get/get.dart';

import 'domain.dart';

class AppBindings extends Bindings {
  final StateBindings stateBindings;
  final UsecasesBindings usecasesBindings;

  AppBindings({
    this.stateBindings,
    this.usecasesBindings,
  });

  @override
  void dependencies() {
    stateBindings.dependencies();
    usecasesBindings.dependencies();
  }
}
