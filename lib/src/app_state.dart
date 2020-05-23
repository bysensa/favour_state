import 'package:flutter/foundation.dart';

import 'runtime.dart';

typedef StoresRegistration = void Function(StoresRegistry);

class AppState with StoresProvider, StoresRegistry, StoresManager {
  final StoresRegistration registration;
  final ServiceProvider serviceProvider;

  @override
  final StoreRuntime runtime;

  AppState({
    @required this.registration,
    this.serviceProvider,
  })  : assert(registration != null, 'registration is null'),
        runtime = StoreRuntime(serviceProvider: serviceProvider);

  void init() {
    registration(this);
  }

  void dispose() {
    runtime.dispose();
  }
}
