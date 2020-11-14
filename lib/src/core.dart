import 'dart:developer' as developer;

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

  @protected
  void log(String message) {
    developer.log(message, name: '$runtimeType');
  }

  @visibleForTesting
  void commit(CommitFn<S> commit) {
    assert(commit != null, 'commit closure is null');
    log('Begin commit');
    final newState = commit(_state.value);
    assert(newState != null, 'newState is null');
    _state.value = newState;
    log('Finish commit');
  }

  @mustCallSuper
  @override
  void onClose() {
    _state.close();
  }
}

abstract class UseCase<S, P> {
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
  void log(String message) {
    developer.log(message, name: '$runtimeType');
  }

  @protected
  void commit(CommitFn<S> commit) {
    _store.commit(commit);
  }

  @protected
  void refresh() {
    _store.refresh();
  }

  Future<Result<void>> call([P param]) {
    developer.Timeline.startSync('$runtimeType:call');
    log('Begin execution');
    final result = Result.capture(execute(param));
    log('Finish execution');
    developer.Timeline.finishSync();
    return result;
  }

  Future<void> execute(P param);
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

  @protected
  void log(String message) {
    developer.log(message, name: '$runtimeType');
  }

  Stream<R> call([P param]) async* {
    developer.Timeline.startSync('$runtimeType:call');
    yield mapState(state, param);
    yield* mapStream(stream, param);
    developer.Timeline.finishSync();
  }

  R mapState(S state, [P param]);
  Stream<R> mapStream(Stream<S> stream, [P param]);
}

class Provider<S,P,R> {
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
  void log(String message) {
    developer.log(message, name: '$runtimeType');
  }

  Result<R> call([P param]) => Result(() => provide(param));
  
  R provide(P param);
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
