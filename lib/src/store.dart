import 'dart:async';

import 'runtime.dart';
import 'store_state.dart';

abstract class Store<T extends StoreState<T>> extends StateProvider<T> {
  final StoreRuntime _runtime;
  StateController<T> _state;

  Store({StoreRuntime runtime}) : _runtime = runtime ?? StoreRuntime() {
    _state = runtime.state(initStore());
  }

  @override
  T get value => _state.value;

  T initStore();

  bool get isInitialized => _state != null;
  bool get isNotInitialized => !isInitialized;

  Future<void> run<SS extends Store<S>, S extends StoreState<S>>(
    SS store,
    StoreAction<SS, S> action,
  ) async {
    await _runtime.run<SS, S>(store, action);
  }
}
