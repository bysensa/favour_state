import 'package:favour_state/src/core.dart';
import 'package:flutter_test/flutter_test.dart';

void onTestStateChange1(TestState state) {}
void onTestStateChange2(TestState state) {}

void main() {
  StateController<TestState> controller;

  setUp(() {
    controller = StateController(const TestState());
  });

  test('should add observer on topic #self', () {
    final observer = onTestStateChange1.observe();
    expect(controller.observers.length, 0);
    expect(controller.observers.containsKey(#self), isFalse);
    controller.addObserver(observer);
    expect(controller.observers.length, 1);
    expect(controller.observers.containsKey(#self), isTrue);
    expect(controller.observers[#self].length, 1);
    expect(controller.observers[#self].contains(observer.onChange), isTrue);
  });

  test('should add not equal observer', () {
    final observer = onTestStateChange1.observe();
    final observer2 = onTestStateChange1.observe();
    final observer3 = onTestStateChange2.observe();
    expect(controller.observers.length, 0);
    expect(controller.observers.containsKey(#self), isFalse);
    controller.addObserver(observer);
    // ignore: cascade_invocations
    controller.addObserver(observer2);
    // ignore: cascade_invocations
    controller.addObserver(observer3);
    expect(controller.observers.length, 1);
    expect(controller.observers.containsKey(#self), isTrue);
    expect(controller.observers[#self].length, 3);
    expect(controller.observers[#self].contains(observer.onChange), isTrue);
    expect(controller.observers[#self].contains(observer2.onChange), isTrue);
    expect(controller.observers[#self].contains(observer3.onChange), isTrue);
  });

  test('should remove observer', () {
    final observer = onTestStateChange1.observe();
    expect(controller.observers.length, 0);
    expect(controller.observers.containsKey(#self), isFalse);
    controller.addObserver(observer);
    expect(controller.observers.length, 1);
    expect(controller.observers.containsKey(#self), isTrue);
    expect(controller.observers[#self].length, 1);
    expect(controller.observers[#self].contains(observer.onChange), isTrue);
    controller.removeObserver(observer);
    expect(controller.observers.length, 1);
    expect(controller.observers.containsKey(#self), isTrue);
    expect(controller.observers[#self].length, 0);
    expect(controller.observers[#self].contains(observer.onChange), isFalse);
  });
  test('should remove observer when it registered 2 times', () {
    final observer = onTestStateChange1.observe();
    final observer2 = onTestStateChange1.observe();
    expect(controller.observers.length, 0);
    expect(controller.observers.containsKey(#self), isFalse);
    controller.addObserver(observer);
    // ignore: cascade_invocations
    controller.addObserver(observer);
    expect(controller.observers.length, 1);
    expect(controller.observers.containsKey(#self), isTrue);
    expect(controller.observers[#self].length, 1);
    expect(controller.observers[#self].contains(observer.onChange), isTrue);
    controller.removeObserver(observer);
    expect(controller.observers.length, 1);
    expect(controller.observers.containsKey(#self), isTrue);
    expect(controller.observers[#self].length, 0);
    expect(controller.observers[#self].contains(observer.onChange), isFalse);
  });
  test('should notify observer', () {
    var observerCalCount = 0;
    void onChange(TestState state) {
      observerCalCount += 1;
    }

    final observer = onChange.observe();
    controller.addObserver(observer);
    // ignore: cascade_invocations
    controller.notifyObservers(const TestState(), observer.topics);
    expect(observerCalCount, 1);
  });

  test('should change state via []= operator', () {
    var observerCalCount = 0;
    void onChange(TestState state) {
      observerCalCount += 1;
    }

    final observer = onChange.observe();
    controller.addObserver(observer);

    expect(controller.state.count, 0);
    expect(controller.state.loading, false);
    controller[#count] = 1;
    expect(controller.state.count, 1);
    expect(controller.state.loading, false);
    expect(observerCalCount, 1);
    controller[#loading] = true;
    expect(controller.state.count, 1);
    expect(controller.state.loading, true);
    expect(observerCalCount, 2);
  });
  test('should change state via set method', () {
    var observerCalCount = 0;
    void onChange(TestState state) {
      observerCalCount += 1;
    }

    final observer = onChange.observe();
    controller.addObserver(observer);

    expect(controller.state.count, 0);
    expect(controller.state.loading, false);
    controller.set(#count, 1);
    expect(controller.state.count, 1);
    expect(controller.state.loading, false);
    expect(observerCalCount, 1);
    controller.set(#loading, true);
    expect(controller.state.count, 1);
    expect(controller.state.loading, true);
    expect(observerCalCount, 2);
  });
  test('should change state via merge method', () {
    var observerCalCount = 0;
    void onChange(TestState state) {
      observerCalCount += 1;
    }

    final observer = onChange.observe();
    controller.addObserver(observer);

    expect(controller.state.count, 0);
    expect(controller.state.loading, false);
    controller.merge({#count: 1});
    expect(controller.state.count, 1);
    expect(controller.state.loading, false);
    expect(observerCalCount, 1);
    controller.merge({#loading: true});
    expect(controller.state.count, 1);
    expect(controller.state.loading, true);
    expect(observerCalCount, 2);
    controller.merge({#loading: false, #count: 2});
    expect(controller.state.count, 2);
    expect(controller.state.loading, false);
    expect(observerCalCount, 3);
  });

  test('should change state via changes setter', () {
    var observerCalCount = 0;
    void onChange(TestState state) {
      observerCalCount += 1;
    }

    final observer = onChange.observe(topics: {#loading, #count});
    controller.addObserver(observer);

    expect(controller.state.count, 0);
    expect(controller.state.loading, false);
    controller.changes = {#count: 1};
    expect(controller.state.count, 1);
    expect(controller.state.loading, false);
    expect(observerCalCount, 1);
    controller.changes = {#loading: true};
    expect(controller.state.count, 1);
    expect(controller.state.loading, true);
    expect(observerCalCount, 2);
    controller.changes = {#loading: false, #count: 2};
    expect(controller.state.count, 2);
    expect(controller.state.loading, false);
    expect(observerCalCount, 3);
  });
  test('should dispose', () {});
}

class TestState implements StoreState<TestState> {
  final int count;
  final bool loading;

  const TestState({
    this.count = 0,
    this.loading = false,
  });

  @override
  TestState copyWith({
    int count,
    bool loading,
  }) {
    if ((count == null || identical(count, this.count)) &&
        (loading == null || identical(loading, this.loading))) {
      return this;
    }

    return TestState(
      count: count ?? this.count,
      loading: loading ?? this.loading,
    );
  }
}
