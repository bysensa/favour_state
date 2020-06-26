import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class StateRuntimeBinding extends BindingBase
    with SchedulerBinding, ServicesBinding, RuntimeBinding {
  /// check that [RuntimeBinding] initialized
  static RuntimeBinding ensureInitialized() {
    if (WidgetsBinding.instance == null) {
      StateRuntimeBinding();
    }

    return RuntimeBinding.instance;
  }
}

mixin RuntimeBinding on BindingBase, ServicesBinding implements RuntimeApi {
  static RuntimeBinding get instance => _instance;
  static RuntimeBinding _instance;

  Map<Type, StateController> states;

  HashedObserverList<LocalesObserver> localeChangeObservers =
      HashedObserverList();
  HashedObserverList<LifecycleObserver> lifecycleChangeObservers =
      HashedObserverList();
  HashedObserverList<MemoryPressureObserver> memoryPressureObservers =
      HashedObserverList();
  HashedObserverList<ReassembleObserver> reassembleObservers =
      HashedObserverList();
  HashedObserverList<SystemMessageObserver> systemMessageObservers =
      HashedObserverList();

  @override
  void initInstances() {
    super.initInstances();
    _instance = this;

    window.onLocaleChanged = handleLocaleChanged;
  }

  @protected
  void handleLocaleChanged() {
    didChangeLocales(window.locales);
  }

  @override
  void handleAppLifecycleStateChanged(AppLifecycleState state) {
    super.handleAppLifecycleStateChanged(state);
    didChangeAppLifecycleState(state);
  }

  @override
  void handleMemoryPressure() {
    super.handleMemoryPressure();
    didHaveMemoryPressure();
  }

  @override
  Future<void> performReassemble() {
    didPerformReassemble();
    return super.performReassemble();
  }

  @override
  Future<void> handleSystemMessage(Object systemMessage) async {
    await super.handleSystemMessage(systemMessage);
    await didReceiveSystemMessage(systemMessage);
  }

  @override
  @mustCallSuper
  void didChangeLocales(List<Locale> locales) {
    for (final observer in localeChangeObservers) {
      observer.didChangeLocales(locales);
    }
  }

  @override
  @mustCallSuper
  void didChangeAppLifecycleState(AppLifecycleState state) {
    for (final observer in lifecycleChangeObservers) {
      observer.didChangeAppLifecycleState(state);
    }
  }

  @override
  @mustCallSuper
  void didHaveMemoryPressure() {
    for (final observer in memoryPressureObservers) {
      observer.didHaveMemoryPressure();
    }
  }

  @override
  @mustCallSuper
  void didPerformReassemble() {
    for (final observer in reassembleObservers) {
      observer.didPerformReassemble();
    }
  }

  @override
  @mustCallSuper
  Future<void> didReceiveSystemMessage(Object systemMessage) async {
    for (final observer in systemMessageObservers) {
      await observer.didReceiveSystemMessage(systemMessage);
    }
  }
}

abstract class RuntimeApi implements RuntimeObserver {
  @protected
  void init();

  @protected
  void dispose();

  @protected
  void registerState<S>();

  @protected
  void addObserver<S>();

  @protected
  void removeObserver<S>();

  @protected
  void runAction<SS>();
}

class StateController {}

abstract class RuntimeObserver
    implements
        LocalesObserver,
        LifecycleObserver,
        MemoryPressureObserver,
        ReassembleObserver,
        SystemMessageObserver {}

abstract class LocalesObserver {
  void didChangeLocales(List<Locale> locales);
}

abstract class LifecycleObserver {
  void didChangeAppLifecycleState(AppLifecycleState state);
}

abstract class MemoryPressureObserver {
  void didHaveMemoryPressure();
}

abstract class ReassembleObserver {
  void didPerformReassemble();
}

abstract class SystemMessageObserver {
  Future<void> didReceiveSystemMessage(Object systemMessage);
}

abstract class StateChangeObserver<S> {
  void didStateChange(S state);
}
