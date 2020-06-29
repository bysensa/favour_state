import 'dart:async';
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
  StateChangedObserver<S> observe(Store<S> store, {Set<Symbol> topics}) {
    final _topics = {#self, ...topics ?? <Symbol>{}};
    return StateChangedObserver<S>(store, this, _topics);
  }
}

class StateChangedObserver<S extends StoreState<S>> extends Disposable {
  final StateChanged<S> _onChange;
  final Set<Symbol> topics;
  final Store<S> _store;
  S lastState;

  Type get stateType => S;
  StateChanged<S> get onChange => didStateChange;

  StateChangedObserver(
    this._store,
    this._onChange,
    this.topics,
  )   : assert(_onChange != null, 'onChange is null'),
        assert(_store != null, 'store is null') {
    _store.addObserver(this);
  }

  void didStateChange(S state) {
    if (state != lastState) {
      lastState = state;
      _onChange(state);
    }
  }

  @override
  void dispose() {
    _store.removeObserver(this);
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
    log('$S change begin');
    Timeline.startSync('Mutate ${S}');
    final dynamic newState = Function.apply(
      _state.copyWith,
      null,
      changes,
    );
    log('Changes: $changes');
    log('$S change end\n');
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
  StateController<S> _controller;

  S get state => _controller.state;

  Store() {
    _controller = StateController<S>(initState());
    initialize();
  }

  S initState();

  @mustCallSuper
  Future<void> initialize() async {}

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

  Future<void> setState(
    FutureOr<void> Function() changeClosure, {
    String debugName,
  }) async {
    final msg = debugName ?? 'change in $S';
    log('Begin $msg');
    Timeline.startSync(msg);
    await changeClosure();
    Timeline.finishSync();
    log('End $msg\n');
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
