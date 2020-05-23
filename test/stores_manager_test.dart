import 'package:favour_state/favour_state.dart';
import 'package:favour_state/src/runtime/stores_manager.dart';
import 'package:favour_state/src/runtime/stores_provider.dart';
import 'package:favour_state/src/runtime/stores_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final manager = StoresManagerTest();

  test('should return registered store', () {
    manager.registerStore((runtime) => TestStore(runtime));
    final store = manager.store<TestStore>();
    expect(store is TestStore, true);
    manager.unregisterAll();
  });

  test('should register store', () {
    manager.registerStore((runtime) => TestStore(runtime));
    expect(StoresManager.stores.length, 1);
    expect(StoresManager.stores.containsKey(TestStore), true);
    manager.unregisterAll();
  });

  test('should register derived store', () {
    manager
      ..registerStore((runtime) => Test2Store(runtime))
      ..registerDerivedStore(
        (runtime, store) => TestStore(
          runtime,
          dep: store<Test2Store>(),
        ),
      );
    final store = manager.store<TestStore>();
    expect(store is TestStore, true);
    expect(store.dep, isNotNull);
    expect(store.dep is Test2Store, true);
    manager.unregisterAll();
  });

  test('should not register two times', () {
    manager.registerStore((runtime) => TestStore(runtime));
    expect(
      () => manager.registerStore((runtime) => TestStore(runtime)),
      throwsStateError,
    );
    manager.unregisterAll();
  });
}

class StoresManagerTest with StoresProvider, StoresRegistry, StoresManager {
  @override
  final StoreRuntime runtime = StoreRuntime();
}

class TestStore extends Store<TestState> {
  final Test2Store dep;
  TestStore(StoreRuntime runtime, {this.dep}) : super(runtime: runtime);

  @override
  TestState initStore() => TestState();
}

class TestState extends StoreState<TestState> {
  @override
  TestState copyWith() {
    throw UnimplementedError();
  }
}

class Test2Store extends Store<Test2State> {
  Test2Store(StoreRuntime runtime) : super(runtime: runtime);

  @override
  Test2State initStore() => Test2State();
}

class Test2State extends StoreState<Test2State> {
  @override
  Test2State copyWith() {
    throw UnimplementedError();
  }
}
