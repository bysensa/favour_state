import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:async/async.dart';

typedef CommitFn<S> = S Function(S);

abstract class Store<S> extends DisposableInterface {
  Rx<S> _state;
  S init();

  @mustCallSuper
  Store() {
    final initializedState = init();
    assert(initializedState != null, 'initializedState is null');
    _state = Rx(initializedState);
  }

  @visibleForTesting
  S get state => _state.value;

  @visibleForTesting
  Stream<S> get stream => _state.stream;

  @visibleForTesting
  void refresh() {
    _state.refresh();
  }

  @visibleForTesting
  void commit(CommitFn<S> commit) {
    assert(commit != null, 'commit closure is null');
    final newState = commit(_state.value);
    assert(newState != null, 'newState is null');
    _state.value = newState;
  }

  @mustCallSuper
  @override
  void onClose() {
    _state.close();
  }
}

abstract class UseCase<S, P, R> {
  Store<S> _store;

  @mustCallSuper
  UseCase(Store<S> store) : assert(store != null, 'store is null') {
    _store = store;
  }

  @visibleForTesting
  Store<S> get store => _store;

  @protected
  S get state => _store._state.value;

  @protected
  void commit(CommitFn<S> commit) {
    _store.commit(commit);
  }

  @protected
  void refresh() {
    _store.refresh();
  }

  Future<Result<R>> call([P param]) => Result.capture(execute(param));

  Future<R> execute(P param);
}

abstract class Selector<S, P, R> {
  Store<S> _store;

  @mustCallSuper
  Selector(Store<S> store) : assert(store != null, 'store is null') {
    _store = store;
  }

  @visibleForTesting
  Store<S> get store => _store;

  @protected
  S get state => _store._state.value;

  @protected
  Stream<S> get stream => _store._state.stream;

  Stream<R> call([P param]) async* {
    yield mapState(state, param);
    yield* mapStream(stream, param);
  }

  R mapState(S state, [P param]);
  Stream<R> mapStream(Stream<S> stream, [P param]);
}

extension ResultExtension<T> on Result<T> {
  T get value {
    assert(isValue, 'can\'t get value from error result');
    return asValue.value;
  }

  Object get error {
    assert(isError, 'can\'t get error from value result');
    return asError.error;
  }

  StackTrace get stackTrace {
    assert(isError, 'can\'t get stackTrace from value result');
    return asError.stackTrace;
  }
}
