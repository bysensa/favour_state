import 'dart:async';

import 'package:favour_state/favour_state.dart';

import 'state.dart';

class ExampleStore extends Store<ExampleState> {
  // you can initialize your state

  Future<void> multiply(int multiplier) async {
    this(MultiplyOperation(2));
  }

  void toggle() {
    this[#enabled] = !state.enabled;
  }

  @override
  ExampleState get initialState => const ExampleState(enabled: false);
}

class MultiplyOperation extends Operation<ExampleStore> {
  final int multiplier;

  MultiplyOperation(this.multiplier);

  @override
  FutureOr<void> call(ExampleStore store) async {
    while (store.state.counter < 1000) {
      store[#counter] = store.state.counter + multiplier;
      await Future.delayed(const Duration(milliseconds: 1), () {});
    }
    store[#counter] = 0;
  }

  @override
  String get topic => 'multiply';
}
