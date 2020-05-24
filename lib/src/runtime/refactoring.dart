import 'dart:async';

import 'package:flutter/foundation.dart';

import 'service_provider.dart';

class StoreRuntime {
  ServiceProvider _services;

  final Map<Type, Map<Symbol, HashedObserverList<Reaction>>> _reactions = {};

  ValueReaction<S, T> valueReaction<S extends Copyable, T>(
    T Function(S) reducer, {
    Set<Symbol> topics,
  }) {
    final _topics = topics ?? {#self};
    final reaction = ValueReaction<S, T>(reducer: reducer, topics: _topics);
    _registerReaction<S>(reaction, _topics);
    return reaction;
  }

  EffectReaction<S> effectReaction<S extends Copyable>(
    void Function(S) effect, {
    Set<Symbol> topics,
  }) {
    final _topics = topics ?? {#self};
    final reaction = EffectReaction<S>(effect: effect, topics: _topics);
    _registerReaction<S>(reaction, _topics);
    return reaction;
  }

  void _registerReaction<S extends Copyable>(
    Reaction reaction,
    Set<Symbol> topics,
  ) {
    if (!_reactions.containsKey(S)) {
      _reactions[S] = {};
    }
    final reactionsForType = _reactions[S];

    void registerForTopic(Symbol topic) {
      if (!reactionsForType.containsKey(topic)) {
        reactionsForType[topic] = HashedObserverList();
      }
      reactionsForType[topic].add(reaction);
    }

    topics.forEach(registerForTopic);
  }

  void notifyReactions<S extends Copyable>(S state, Set<Symbol> topics) {
    if (!_reactions.containsKey(S)) {
      return;
    }

    final reactionsForType = _reactions[S];

    void notifyReaction(Reaction reaction) => reaction._notify(state);
    for (final topic in topics) {
      reactionsForType[topic]?.forEach((notifyReaction));
    }
  }

  void removeReaction() {}
  void removeAllReactions() {}

  final Map<Type, StateMutator> _states = {};
  StateProvider<S> state<S extends StoreState<S>>(S state) {
    if (_states.containsKey(S)) {
      throw StateError('StateController for type $S already registered');
    }
    final controller = StateController<S>(state, notifyReactions);
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

  SS registerDerivedStore<SS extends StoreInitializer>(
    SS Function(S Function<S extends StoreInitializer>()) factory,
  ) {
    if (_stores.containsKey(SS)) {
      throw StateError('Store of type $SS already registered');
    }
    final derivedStore = factory(store);
    // ignore: cascade_invocations
    derivedStore.runtime = _runtime;
    _stores[SS] = derivedStore;
    return derivedStore;
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
  void _notify(S value);
}

class ValueReaction<S extends Copyable, T> extends ChangeNotifier
    implements Reaction<S>, ValueListenable<T> {
  final T Function(S) reducer;
  final Set<Symbol> topics;
  T _value;

  ValueReaction({
    @required this.reducer,
    @required this.topics,
  })  : assert(reducer != null, 'reducer is null'),
        assert(topics != null, 'topics is null');

  @override
  T get value => _value;

  @override
  void _notify(S value) {
    final newValue = reducer(value);
    if (newValue != _value) {
      _value = newValue;
      notifyListeners();
    }
  }
}

class EffectReaction<S extends Copyable> extends Reaction<S> {
  final void Function(S) effect;
  final Set<Symbol> topics;

  EffectReaction({
    @required this.effect,
    @required this.topics,
  })  : assert(effect != null, 'reducer is null'),
        assert(topics != null, 'topics is null');

  @override
  void _notify(S value) {
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
  final void Function<S extends Copyable>(S, Set<Symbol>) _notifier;

  StateController(
    S state,
    void Function<S extends Copyable>(S, Set<Symbol>) notifier,
  )   : assert(state != null, 'state is null'),
        assert(notifier != null, 'notifier is null'),
        _state = state,
        _notifier = notifier;

  @override
  void operator []=(Symbol topic, Object value) {
    _merge({topic: value});
  }

  @override
  // ignore: avoid_setters_without_getters
  set changes(Map<Symbol, Object> changes) {
    _merge(changes);
  }

  @override
  void merge(Map<Symbol, Object> changes) {
    _merge(changes);
  }

  @override
  void set(Symbol topic, Object value) {
    _merge({topic: value});
  }

  @override
  S get state => _state;

  void _merge(Map<Symbol, Object> changes) {
    final dynamic newState = Function.apply(
      _state.copyWith,
      null,
      changes,
    );
    if (newState is S) {
      _state = newState;
      _notifier<S>(newState, {#self, ...changes.keys});
      return;
    }
    throw StateError('state method "copyWith" return instance of unknown type');
  }
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
    _runtime = runtime;
    _init();
  }

  void _init() {
    _stateProvider = _runtime.state<S>(initState());
    initReactions();
  }

  S initState();
  void initReactions();

  ValueReaction<S, T> valueReaction<T>(
    T Function(S) reducer, {
    Set<Symbol> topics,
  }) =>
      _runtime.valueReaction<S, T>(reducer, topics: topics);

  EffectReaction<SS> effectReaction<SS extends StoreState<SS>>(
    void Function(SS) effect, {
    Set<Symbol> topics,
  }) =>
      _runtime.effectReaction<SS>(effect, topics: topics);

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
