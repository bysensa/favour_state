import 'dart:async';

import 'copyable.dart';
import 'service_provider.dart';
import 'state_controller.dart';
import 'state_provider.dart';

typedef StoreActionEffect<T extends StateProvider<S>, S extends Copyable>
    = FutureOr<void> Function(T, StateController<S>,
        [ServiceProvider services]);

class StoreAction<T extends StateProvider<S>, S extends Copyable> {
  final StoreActionEffect<T, S> effect;

  StoreAction(this.effect) : assert(effect != null, 'effect is null');

  FutureOr<void> call(
    T store,
    StateController<S> controller, [
    ServiceProvider services,
  ]) {
    effect(store, controller, services);
  }
}
