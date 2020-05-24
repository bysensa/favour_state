import 'dart:async';

import 'package:flutter/foundation.dart';

import 'service_provider.dart';

class StoreRuntime {
  ServiceProvider _services;

  final Map<Type, Map<Symbol, HashedObserverList<Reaction>>> _reactions = {};
  ValueReaction<S, T> valueReaction<S extends Copyable, T>() {}
  EffectReaction<S> effectReaction<S extends Copyable>() {}
  void notifyReactions() {}
  void removeReaction() {}
  void removeAllReactions() {}

  final Map<Type, StateMutator> _states = {};
  StateProvider<S> state<S extends StoreState<S>>(S state) {
    if (_states.containsKey(S)) {
      throw StateError('StateController for type $S already registered');
    }
    final controller = StateController<S>(state);
    _states[S] = controller;
    return controller;
  }

  FutureOr<void> run<SS extends BaseStore<S>, S extends StoreState<S>>(
    SS store,
    StoreAction<SS, S> action,
  ) {
    final stateType = store.state.runtimeType;
    final mutator = _states[stateType];
    action(store, mutator, _services);
  }
}

class AppState {
  final StoreRuntime _runtime;
  final Map<Type, StoreInitializer> _stores = {};

  AppState({@required StoreRuntime runtime})
      : assert(runtime != null, 'runtime is null'),
        _runtime = runtime;

  void registerStore<SS extends StoreInitializer>(SS store) {
    if (_stores.containsKey(SS)) {
      throw StateError('Store of type $SS already registered');
    }
    store.runtime = _runtime;
    _stores[SS] = store;
  }

  void registerDerivedStore<SS extends StoreInitializer>(
    SS Function(S Function<S extends StoreInitializer>()) factory,
  ) {
    if (_stores.containsKey(SS)) {
      throw StateError('Store of type $SS already registered');
    }
    final derivedStore = factory(store)..runtime = _runtime;
    _stores[SS] = derivedStore;
  }

  SS store<SS extends StoreInitializer>() {
    if (!_stores.containsKey(SS)) {
      throw StateError('Store of type $SS not registered');
    }
    return _stores.cast<Type, SS>()[SS];
  }
}

abstract class StoreInitializer {
  // ignore: avoid_setters_without_getters
  set runtime(StoreRuntime runtime);
}

abstract class Reaction<S extends Copyable> {
  void update(S value);
}

class ValueReaction<S extends Copyable, T> extends Reaction<S> {
  T Function(S) reducer;
  T _value;
  @override
  void update(S value) {
    _value = reducer(value);
  }
}

class EffectReaction<S extends Copyable> extends Reaction<S> {
  void Function(S) effect;
  @override
  void update(S value) {
    effect(value);
  }
}

abstract class Copyable {
  Copyable copyWith();
}

abstract class StateMutator {
  void merge(Map<Symbol, Object> changes);
  void set(Symbol topic, Object value);
  void operator []=(Symbol topic, Object value);
  // ignore: avoid_setters_without_getters
  set changes(Map<Symbol, Object> newChanges);
}

abstract class StoreState<S extends StoreState<S>> extends Copyable {
  @override
  S copyWith();
}

abstract class StateProvider<S extends StoreState<S>> {
  S get state;
}

class StateController<S extends StoreState<S>> extends StateMutator
    implements StateProvider<S> {
  S _state;

  StateController(S state)
      : assert(state != null, 'state is null'),
        _state = state;

  @override
  void operator []=(Symbol topic, Object value) {
    // TODO: implement []=
  }

  @override
  set changes(Map<Symbol, Object> changes) {
    // TODO: implement changes
  }

  @override
  void merge(Map<Symbol, Object> changes) {
    // TODO: implement merge
  }

  @override
  void set(Symbol topic, Object value) {
    // TODO: implement set
  }

  @override
  // TODO: implement state
  S get state => throw UnimplementedError();
}

abstract class BaseStore<S extends StoreState<S>>
    implements StoreInitializer, StateProvider<S> {
  StoreRuntime _runtime;
  StateProvider<S> _stateProvider;

  @override
  S get state => _stateProvider.state;

  @override
  // ignore: avoid_setters_without_getters
  set runtime(StoreRuntime runtime) {
    if (_runtime != null) {
      throw StateError('StoreRuntime already setup');
    }
    _init();
  }

  void _init() {
    _stateProvider = _runtime.state<S>(initState());
    initReactions();
  }

  S initState();
  void initReactions();

  ValueReaction<S, T> valueReaction<T>() => _runtime.valueReaction<S, T>();
  EffectReaction<S> effectReaction() => _runtime.effectReaction<S>();

  Future<void> run<SS extends BaseStore<S>>(StoreAction<SS, S> action) async {
    await _runtime.run(this, action);
  }
}

typedef StoreActionEffect<T extends BaseStore<S>, S extends StoreState<S>>
    = FutureOr<void> Function(T, StateMutator, [ServiceProvider services]);

class StoreAction<T extends BaseStore<S>, S extends StoreState<S>> {
  final StoreActionEffect<T, S> effect;

  StoreAction(this.effect) : assert(effect != null, 'effect is null');

  FutureOr<void> call(
    T store,
    StateMutator mutator, [
    ServiceProvider services,
  ]) {
    effect(store, mutator, services);
  }
}
