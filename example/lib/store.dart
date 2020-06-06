import 'package:favour_state/favour_state.dart';

import 'state.dart';

class ExampleStore extends BaseStore<ExampleState> {
  // Any reaction is optional
  ValueReaction<ExampleState, bool> enabled;
  ValueReaction<ExampleState, int> controllableCounter;
  ValueReaction<ExampleState, ExampleState> self;

  EffectReaction<ExampleState> onCounterChange;

  // if you not declare reaction you can leave the method empty
  @override
  void initReactions() {
    // under the hood value reaction implement ValueListenable
    enabled = valueReaction((s) => s.enabled, topics: {#enabled});
    controllableCounter = valueReaction(
      (s) => s.controllableCounter,
      topics: {#enabled, #counter},
    );
    self = valueReaction((s) => s);

    // in closure of effect reaction you can use anything from class scope
    onCounterChange = effectReaction(
      // ignore: avoid_print
      (s) => print('counter changed'),
      topics: {#counter},
    );
  }

  // you can initialize your state
  @override
  ExampleState initState() => const ExampleState(counter: 5);

  Future<void> multiply(int multiplier) async {
    await run(MultiplyCounter(multiplier));
  }

  Future<void> toggle() async {
    await run(action<ExampleStore>((store, mutator, [services]) {
      // #name - should be equal to state copyWith named params
      // For example if copyWith is 'void copyWith({int counter, bool enabled})'
      // you can use #counter and #enabled to mutate state
      mutator[#enabled] = !store.state.enabled;
    }));
  }
}

// Action can be class based
class MultiplyCounter extends StoreAction<ExampleStore> {
  // constructor can declare positional and optional params
  MultiplyCounter(int multiplier)
      : super(
          // closure for action should declare this params
          (store, mutator, [services]) {
            // You can use any of this api to mutate state
            // mutator[#counter] = 1
            // mutator.changes = {#counter: 1, #enabled: false};
            // mutator.merge({#counter: 1, #enabled: false});
            // mutator.set(#counter, 1);
            mutator[#counter] = store.state.counter * multiplier;
          },
        );
}
