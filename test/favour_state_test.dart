import 'dart:async';

import 'package:favour_state/favour_state.dart';
import 'package:favour_state/src/runtime/service_provider.dart';
import 'package:favour_state/src/runtime/state_controller.dart';
import 'package:favour_state/src/runtime/store_runtime.dart';
import 'package:favour_state/src/runtime/value_reaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adds one to input values', () async {
    final store = SomeStore(StoreRuntime());
//    expect(store.state.counter, 0);
//    //await store.inc();
//    expect(store.state.counter, 50);
    await store.doubly();
  });
}

class SomeState extends StoreState<SomeState> {
  final int counter;
  String get text => 'Counter value is ${counter}';

  SomeState({this.counter = 2});

  @override
  SomeState copyWith({int counter}) => SomeState(
        counter: counter ?? this.counter,
      );
}

class SomeStore extends Store<SomeState> {
  final ValueReaction<SomeState, int> counter;

  SomeStore(StoreRuntime runtime)
      : counter = runtime.value((s) => s.counter, topics: [#counter]),
        super(runtime);

  Future<void> doubly() async {
    await run(this, doublyAction);
  }

  @override
  SomeState initStore() => SomeState();
}

Future<void> doublyAction(
    SomeStore store, StateController<SomeState> controller,
    [ServiceProvider services]) async {
  final s = controller;
  s
    ..merge({#counter: s.value.counter * 2})
    ..merge({#counter: s.value.counter * 2})
    ..merge({#counter: s.value.counter * 2})
    ..merge({#counter: s.value.counter * 2});
}
