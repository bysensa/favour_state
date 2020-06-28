import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

//
typedef StateChanged<S extends StoreState<S>> = void Function(S);

abstract class Observer {}

abstract class Disposable {
  void dispose();
}

extension StateChangedExtension<S extends StoreState<S>> on StateChanged<S> {
  StateChangedObserver<S> observe({Set<Symbol> topics}) {
    final _topics = {#self, ...topics ?? <Symbol>{}};
    return StateChangedObserver<S>(this, _topics);
  }
}

class StateChangedObserver<S extends StoreState<S>> extends Disposable {
  final StateChanged<S> _onChange;
  final Set<Symbol> topics;

  Type get stateType => S;

  StateChanged<S> get onChange => didStateChange;

  S lastState;

  final bool _shared;

  StateChangedObserver(this._onChange, this.topics)
      : _shared = false,
        assert(_onChange != null, 'onChange is null');

  StateChangedObserver.shared(
    this._onChange,
    this.topics,
  )   : _shared = false,
        assert(_onChange != null, 'onChange is null') {
    SharedState().addObserver(this);
  }

  void didStateChange(S state) {
    if (state != lastState) {
      lastState = state;
      _onChange(state);
    }
  }

  @override
  void dispose() {
    if (_shared) {
      SharedState().removeObserver(this);
    }
  }
}

abstract class StoreState<S> {
  S copyWith();
}

@visibleForTesting
class StateController<S extends StoreState<S>> extends Disposable {
  S _state;
  final S initialState;

  Type get stateType => S;

  final Map<Symbol, HashedObserverList<StateChanged<S>>> observers = {};

  StateController(this.initialState)
      : assert(initialState != null, 'initialState is null'),
        _state = initialState;

  @override
  @mustCallSuper
  void dispose() {
    observers.clear();
  }

  void addObserver(StateChangedObserver<S> observer) {
    for (final topic in observer.topics) {
      if (!observers.containsKey(topic)) {
        observers[topic] = HashedObserverList();
      }
      if (!observers[topic].contains(observer.onChange)) {
        observers[topic].add(observer.onChange);
      }
    }
    observer.onChange(_state);
  }

  void removeObserver(StateChangedObserver<S> observer) {
    for (final topic in observer.topics) {
      if (observers.containsKey(topic)) {
        observers[topic].remove(observer.onChange);
      }
    }
  }

  @visibleForTesting
  void notifyObservers(S newState, Iterable<Symbol> topics) {
    void notify(StateChanged<S> observer) {
      observer(newState);
    }

    for (final topic in topics) {
      if (observers.containsKey(topic)) {
        observers[topic].forEach(notify);
      }
    }
  }

  void operator []=(Symbol topic, Object value) {
    _merge({topic: value});
  }

  // ignore: avoid_setters_without_getters
  set changes(Map<Symbol, Object> changes) {
    _merge(changes);
  }

  void merge(Map<Symbol, Object> changes) {
    _merge(changes);
  }

  void set(Symbol topic, Object value) {
    _merge({topic: value});
  }

  S get state => _state;

  void _merge(Map<Symbol, Object> changes) {
    Timeline.startSync('Mutate ${S}');
    final dynamic newState = Function.apply(
      _state.copyWith,
      null,
      changes,
    );
    Timeline.finishSync();
    if (newState is S) {
      _state = newState;
      Timeline.startSync('Notify $S changed');
      notifyObservers(newState, {#self, ...changes.keys});
      Timeline.finishSync();
      return;
    }
    throw StateError('state method "copyWith" return instance of unknown type');
  }
}

abstract class Store<S extends StoreState<S>> extends Disposable
    with StoreMutator<S> {
  @override
  final StateController<S> _controller;

  S get state => _controller.state;

  Store(S state)
      : assert(state != null, 'state is null'),
        _controller = StateController(state);

  void addObserver(StateChangedObserver<S> observer) {
    if (observer == null) {
      return;
    }
    _controller.addObserver(observer);
  }

  void removeObserver(StateChangedObserver<S> observer) {
    if (observer == null) {
      return;
    }
    _controller.removeObserver(observer);
  }

  @override
  @mustCallSuper
  void dispose() {
    _controller.dispose();
  }
}

mixin StoreMutator<S extends StoreState<S>> {
  StateController<S> get _controller;

  @protected
  void operator []=(Symbol topic, Object value) {
    _controller[topic] = value;
  }

  @protected
  // ignore: avoid_setters_without_getters
  set changes(Map<Symbol, Object> changes) {
    _controller.changes = changes;
  }

  @protected
  void merge(Map<Symbol, Object> changes) {
    _controller.merge(changes);
  }

  @protected
  void set(Symbol topic, Object value) {
    _controller.set(topic, value);
  }
}

@immutable
abstract class StateInitializer<S extends StoreState<S>> {
  Type get stateType => S;
  StateController<S> get state;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StateInitializer &&
          runtimeType == other.runtimeType &&
          identical(S, other.stateType);

  @override
  int get hashCode => S.hashCode;
}

class SharedState extends Disposable {
  static SharedState _instance;

  factory SharedState({Set<StateInitializer> initialStates}) =>
      _instance ??= SharedState._internal(initialStates);

  SharedState._internal(Set<StateInitializer> initialStates) {
    final _initialStates = initialStates ?? <StateInitializer>{};
    for (final initialState in _initialStates) {
      _states[initialState.stateType] = initialState.state;
    }
  }

  Map<Type, StateController> _states;

  StateController<S> state<S extends StoreState<S>>() {
    if (!_states.containsKey(S)) {
      throw StateError(
          'State of type $S not registered. Check SharedState initialization');
    }
    return _states[S];
  }

  void addObserver(StateChangedObserver<StoreState> observer) {
    if (!_states.containsKey(observer.stateType)) {
      throw StateError('State of type ${observer.stateType} not registered');
    }
    _states[observer.stateType].addObserver(observer);
  }

  void removeObserver(StateChangedObserver<StoreState> observer) {
    if (!_states.containsKey(observer.stateType)) {
      throw StateError('State of type ${observer.stateType} not registered');
    }
    _states[observer.stateType].removeObserver(observer);
  }

  @override
  void dispose() {
    for (final state in _states.values) {
      state.dispose();
    }
    _states.clear();
  }
}

abstract class SharedStateStore<S extends StoreState<S>> extends Disposable
    with StoreMutator<S>
    implements Store<S> {
  @override
  StateController<S> _controller;

  @override
  S get state => _controller.state;

  SharedStateStore() {
    _controller = SharedState().state<S>();
  }

  @override
  @mustCallSuper
  void dispose() {}

  @override
  void addObserver(StateChangedObserver<S> observer) {
    if (observer == null) {
      return;
    }
    _controller.addObserver(observer);
  }

  @override
  void removeObserver(StateChangedObserver<S> observer) {
    if (observer == null) {
      return;
    }
    _controller.removeObserver(observer);
  }
}

//
//class StateRuntimeBinding extends BindingBase
//    with SchedulerBinding, ServicesBinding, RuntimeBinding {
//  /// check that [RuntimeBinding] initialized
//  static RuntimeBinding ensureInitialized() {
//    if (WidgetsBinding.instance == null) {
//      StateRuntimeBinding();
//    }
//
//    return RuntimeBinding.instance;
//  }
//
//  @override
//  void registerState<S>() {
//    // TODO: implement registerState
//  }
//
//  @override
//  void runAction<SS>() {
//    // TODO: implement runAction
//  }
//}
//
//mixin RuntimeBinding on BindingBase, ServicesBinding implements RuntimeApi {
//  static RuntimeBinding get instance => _instance;
//  static RuntimeBinding _instance;
//
//  Map<Type, StateController> states;
//  Map<Type, Store> stores;
//
//  HashedObserverList<LocalesObserver> localeChangeObservers =
//      HashedObserverList();
//  HashedObserverList<LifecycleObserver> lifecycleChangeObservers =
//      HashedObserverList();
//  HashedObserverList<MemoryPressureObserver> memoryPressureObservers =
//      HashedObserverList();
//  HashedObserverList<ReassembleObserver> reassembleObservers =
//      HashedObserverList();
//  HashedObserverList<SystemMessageObserver> systemMessageObservers =
//      HashedObserverList();
//
//  @override
//  void initInstances() {
//    super.initInstances();
//    _instance = this;
//
//    window.onLocaleChanged = handleLocaleChanged;
//  }
//
//  void registerStore(Store store) {}
//
//  @protected
//  void handleLocaleChanged() {
//    didChangeLocales(window.locales);
//  }
//
//  @override
//  void handleAppLifecycleStateChanged(AppLifecycleState state) {
//    super.handleAppLifecycleStateChanged(state);
//    didChangeAppLifecycleState(state);
//  }
//
//  @override
//  void handleMemoryPressure() {
//    super.handleMemoryPressure();
//    didHaveMemoryPressure();
//  }
//
//  @override
//  Future<void> performReassemble() {
//    didPerformReassemble();
//    return super.performReassemble();
//  }
//
//  @override
//  Future<void> handleSystemMessage(Object systemMessage) async {
//    await super.handleSystemMessage(systemMessage);
//    await didReceiveSystemMessage(systemMessage);
//  }
//
//  @override
//  @mustCallSuper
//  void didChangeLocales(List<Locale> locales) {
//    for (final observer in localeChangeObservers) {
//      observer.didChangeLocales(locales);
//    }
//  }
//
//  @override
//  @mustCallSuper
//  void didChangeAppLifecycleState(AppLifecycleState state) {
//    for (final observer in lifecycleChangeObservers) {
//      observer.didChangeAppLifecycleState(state);
//    }
//  }
//
//  @override
//  @mustCallSuper
//  void didHaveMemoryPressure() {
//    for (final observer in memoryPressureObservers) {
//      observer.didHaveMemoryPressure();
//    }
//  }
//
//  @override
//  @mustCallSuper
//  void didPerformReassemble() {
//    for (final observer in reassembleObservers) {
//      observer.didPerformReassemble();
//    }
//  }
//
//  @override
//  @mustCallSuper
//  Future<void> didReceiveSystemMessage(Object systemMessage) async {
//    for (final observer in systemMessageObservers) {
//      await observer.didReceiveSystemMessage(systemMessage);
//    }
//  }
//
//  @override
//  void init() {}
//
//  @override
//  void dispose() {}
//}
//
//abstract class RuntimeApi implements RuntimeObserver {
//  @protected
//  void init();
//
//  @protected
//  void dispose();
//
//  @protected
//  void registerState<S>();
//
//  @protected
//  void runAction<SS>();
//}
//
//
//
//abstract class RuntimeObserver extends Observer
//    implements
//        LocalesObserver,
//        LifecycleObserver,
//        MemoryPressureObserver,
//        ReassembleObserver,
//        SystemMessageObserver {}
//
//abstract class LocalesObserver extends Observer {
//  void didChangeLocales(List<Locale> locales);
//}
//
//abstract class LifecycleObserver extends Observer {
//  void didChangeAppLifecycleState(AppLifecycleState state);
//}
//
//abstract class MemoryPressureObserver extends Observer {
//  void didHaveMemoryPressure();
//}
//
//abstract class ReassembleObserver extends Observer {
//  void didPerformReassemble();
//}
//
//abstract class SystemMessageObserver extends Observer {
//  Future<void> didReceiveSystemMessage(Object systemMessage);
//}
