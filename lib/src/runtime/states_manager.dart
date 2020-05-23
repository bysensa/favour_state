import 'dart:async';

import 'copyable.dart';
import 'reactions_manager.dart';
import 'service_provider.dart';
import 'state_controller.dart';
import 'state_provider.dart';

typedef StoreAction<T extends StateProvider<S>, S extends Copyable>
    = FutureOr<void> Function(
  T,
  StateController<S>, [
  ServiceProvider services,
]);

mixin StatesManager on ReactionsManager {
  final Map<Type, StateController<Copyable>> _states = {};

  ServiceProvider get serviceProvider;

  StateController<S> state<S extends Copyable>(S initialState) {
    final controller = StateController<S>(
      initialState: initialState,
      reactions: this,
    );
    _states[S] = controller;
    return controller;
  }

  Future<void> run<T extends StateProvider<S>, S extends Copyable>(
    T store,
    StoreAction<T, S> action,
  ) async {
    final stateType = store.value.runtimeType;
    final controller = _states.cast<Type, StateController<S>>()[stateType];
    if (controller == null) {
      throw StateError('controller for type $stateType not found');
    }
    try {
      await action(store, controller, serviceProvider);
    } on Exception catch (err) {
      rethrow;
    }
  }
}
