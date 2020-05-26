import 'package:favour_state/favour_state.dart';

import 'actions.dart';
import 'state.dart';

class CounterStore extends BaseStore<CounterState> {
  ValueReaction<CounterState, int> counter;
  ValueReaction<CounterState, String> counterText;

  @override
  void initReactions() {
    counter = valueReaction((s) => s.counter, topics: {#counter});
    counterText = valueReaction((s) => s.counterText, topics: {#counter});
  }

  @override
  CounterState initState() => CounterState();

  Future<void> increment() async {
    await run(IncrementAction());
  }
}
