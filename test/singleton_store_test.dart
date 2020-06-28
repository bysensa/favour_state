//import 'package:favour_state/src/core.dart';
//import 'package:flutter_test/flutter_test.dart';
//
//void main() {
//  test('should change state', () {
//    final store = TestStore();
//    store[#count] = 1;
//    expect(store.state.count, 1);
//    store.increment();
//    expect(store.state.count, 2);
//  });
//}
//
//class TestStore extends SharedStateStore<TestState> {
//  @override
//  TestState initState() => TestState();
//
//  void increment() {
//    this[#count] = state.count + 1;
//  }
//}
//
//class TestState implements StoreState<TestState> {
//  final int count;
//  final bool loading;
//
//  const TestState({
//    this.count,
//    this.loading,
//  });
//
//  @override
//  TestState copyWith({
//    int count,
//    bool loading,
//  }) {
//    if ((count == null || identical(count, this.count)) &&
//        (loading == null || identical(loading, this.loading))) {
//      return this;
//    }
//
//    return TestState(
//      count: count ?? this.count,
//      loading: loading ?? this.loading,
//    );
//  }
//}
