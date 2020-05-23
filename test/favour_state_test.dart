import 'dart:async';

import 'package:favour_state/favour_state.dart';
import 'package:favour_state/src/runtime/store_runtime.dart';
import 'package:favour_state/src/runtime/value_reaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adds one to input values', () async {
    final store = SomeStore(StoreRuntime());
//    expect(store.state.counter, 0);
//    //await store.inc();
//    expect(store.state.counter, 50);
    await store.doubly(3);
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
        super(runtime: runtime);

  Future<void> doubly(int multiplier) async {
    await run(this, DoublyAction(multiplier));
  }

  @override
  SomeState initStore() => SomeState();
}

class DoublyAction extends StoreAction<SomeStore, SomeState> {
  DoublyAction(
    int multiplier,
  ) : super((store, controller, [services]) {
          final s = controller;
          s
            ..merge({#counter: s.value.counter * multiplier})
            ..merge({#counter: s.value.counter * multiplier})
            ..merge({#counter: s.value.counter * multiplier})
            ..merge({#counter: s.value.counter * multiplier});
        });
}
