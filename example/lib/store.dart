import 'package:favour_state/favour_state.dart';

import 'state.dart';

class ExampleStore extends Store<ExampleState> {
  ExampleStore({
    ExampleState state = const ExampleState(),
  }) : super(state);

  // you can initialize your state

  Future<void> multiply(int multiplier) async {
    this[#counter] = state.counter * multiplier;
  }

  void toggle() {
    this[#enabled] = !state.enabled;
  }
}
