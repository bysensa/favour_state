import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

//
typedef StateObserver<S extends StoreState<S>> = void Function(S);

@immutable
class StateChangeObserver<S extends StoreState<S>> {
  final StateObserver<S> _onChange;
  final Set<Symbol> topics;

  Type get stateType => S;

  const StateChangeObserver(
    this._onChange,
    this.topics,
  )   : assert(_onChange != null, 'onChange is null'),
        assert(topics != null, 'topics is null');

  void call(StateChange<S> change) {
    final canCall = change.topics.any(topics.contains);
    if (canCall) {
      _onChange(change.state);
    }
  }
}

// STORE API
abstract class StoreState<S> {
  S copyWith();
}

class StateChange<S extends StoreState<S>> {
  final Set<Symbol> topics;
  final S state;

  const StateChange({
    @required this.topics,
    @required this.state,
  })  : assert(topics != null, 'topics is null'),
        assert(state != null, 'state is null');

  @override
  String toString() {
    return 'StateChange{topics: $topics, state: $state}';
  }
}

abstract class Operation<S extends StoreMixin<StoreState>> {
  String get topic;
  Symbol get operationBeginTopic => Symbol('begin_$topic');
  Symbol get operationEndTopic => Symbol('end_$topic');
  FutureOr<void> call(S store);
}

mixin StoreMixin<S extends StoreState<S>> {
  S get initialState;
  S _state;
  S get state {
    assert(initialState != null, 'initialState is null');
    return _state ??= initialState;
  }

  Type get stateType => S;
//  final Map<Symbol, HashedObserverList<StateObserver<S>>> observers = {};
  final StreamController<StateChange<S>> _observers =
      StreamController.broadcast();

  @mustCallSuper
  void dispose() {
    _observers.close();
  }

  StreamSubscription<StateChange<S>> subscribe(
    StateObserver<S> observer, {
    Set<Symbol> topics,
  }) {
    final _topics = <Symbol>{};
    if (topics != null) {
      _topics.addAll(topics);
    } else {
      _topics.add(#self);
    }
    observer(state);
    return _observers.stream.listen(StateChangeObserver<S>(observer, _topics));
  }

  @visibleForTesting
  void notifyObservers(S newState, Iterable<Symbol> topics) {
    final change = StateChange(state: newState, topics: topics);
    log('$change');
    _observers.add(change);
  }

  @protected
  void operator []=(Symbol topic, Object value) {
    _merge({topic: value});
  }

  @protected
  set changes(Map<Symbol, Object> changes) {
    _merge(changes);
  }

  @protected
  void merge(Map<Symbol, Object> changes) {
    _merge(changes);
  }

  @protected
  void set(Symbol topic, Object value) {
    _merge({topic: value});
  }

  void _merge(Map<Symbol, Object> changes) {
    log('$S change begin');
    Timeline.startSync('Mutate ${S}');
    final dynamic newState = Function.apply(
      state.copyWith,
      null,
      changes,
    );
    log('Changes: $changes');
    log('$S change end\n');
    Timeline.finishSync();
    if (newState is S) {
      if (newState == _state) {
        return;
      }
      _state = newState;
      Timeline.startSync('Notify $S changed');
      notifyObservers(newState, {#self, ...changes.keys});
      Timeline.finishSync();
      return;
    }
    throw StateError('state method "copyWith" return instance of unknown type');
  }

  @protected
  Future<void> mutate(
    FutureOr<void> Function() changeClosure, {
    String debugName,
  }) async {
    final msg = debugName ?? 'change in $S';
    Timeline.startSync(msg);
    try {
      await changeClosure();
    } catch (err, trace) {
      log(err, stackTrace: trace);
    }
    Timeline.finishSync();
  }

  FutureOr<void> call(Operation operation) async {
    notifyObservers(state, {operation.operationBeginTopic});
    await operation(this);
    notifyObservers(state, {operation.operationEndTopic});
  }
}

abstract class Store<S extends StoreState<S>> with StoreMixin<S> {}

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
//    // TODO(devsensa): implement registerState,
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
