import 'package:favour_state/favour_state.dart';

import 'state.dart';

class ExampleStore extends Store<ExampleState> {
  // you can initialize your state

  Future<void> multiply(int multiplier) async {
    this[#counter] = state.counter * multiplier;
  }

  void toggle() {
    this[#enabled] = !state.enabled;
  }

  @override
  ExampleState initState() => const ExampleState(enabled: false);
}
