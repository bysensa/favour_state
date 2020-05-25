import 'package:favour_state/src/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AppState appState;
  CounterStore counterStore;
  LoadingStore loadingStore;

  setUp(() {
    appState = AppState();
    loadingStore = LoadingStore();
    appState.registerStore(loadingStore);
    counterStore = appState.registerDerivedStore(
      (stores) => CounterStore(
        loadingStore: stores(),
      ),
    );
  });

  test('should work', () async {
    var counterReactionCall = 0;
    counterStore.counter.addListener(() {
      counterReactionCall++;
    });

    await counterStore.multiply(3);
    expect(counterStore.state.counter, 3);
    expect(counterReactionCall, 1);

    await counterStore.multiply(4);
    expect(counterStore.state.counter, 12);
    expect(counterReactionCall, 2);

    await counterStore.setCounter(13);
    expect(counterStore.state.counter, 13);
    expect(counterReactionCall, 3);

    await loadingStore.toggle();
  });
}

void checkIsCounterState(CounterState state) =>
    expect(state, isInstanceOf<CounterState>());
void checkIsLoadingState(LoadingState state) =>
    expect(state, isInstanceOf<LoadingState>());

class CounterStore extends BaseStore<CounterState> {
  final LoadingStore loadingStore;

  ValueReaction<CounterState, int> counter;
  EffectReaction<CounterState> self;
  EffectReaction<LoadingState> loadingReaction;

  CounterStore({this.loadingStore});

  @override
  void initReactions() {
    counter = valueReaction((state) => state.counter, topics: {#counter});
    self = effectReaction((state) => checkIsCounterState, topics: {#self});
    loadingReaction =
        effectReaction((state) => checkIsLoadingState, topics: {#self});
  }

  @override
  CounterState initState() => CounterState(counter: 1);

  Future<void> multiply(int multiplier) async {
    await run(MultiplyAction(multiplier));
  }

  Future<void> setCounter(int value) async {
    await run(SetCounterAction(value));
  }
}

class CounterState extends StoreState<CounterState> {
  final int counter;

  CounterState({this.counter = 0});

  @override
  CounterState copyWith({int counter}) => CounterState(
        counter: counter ?? this.counter,
      );
}

class MultiplyAction extends StoreAction<CounterStore, CounterState> {
  MultiplyAction(int multiplier)
      : super((store, mutator, [services]) {
          mutator[#counter] = store.state.counter * multiplier;
        });
}

class SetCounterAction extends StoreAction<CounterStore, CounterState> {
  SetCounterAction(int value)
      : super((store, mutator, [services]) {
          mutator.changes = {#counter: value};
        });
}

class LoadingStore extends BaseStore<LoadingState> {
  @override
  void initReactions() {}

  @override
  LoadingState initState() => LoadingState();

  Future<void> toggle() async {
    await run(ToggleAction());
  }
}

class LoadingState extends StoreState<LoadingState> {
  final bool loading;

  LoadingState({this.loading = false});

  @override
  LoadingState copyWith({bool loading}) =>
      LoadingState(loading: loading ?? this.loading);
}

class ToggleAction extends StoreAction<LoadingStore, LoadingState> {
  ToggleAction()
      : super((store, mutator, [services]) {
          mutator[#loading] = !store.state.loading;
        });
}
