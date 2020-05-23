import 'package:favour_state/favour_state.dart';

class LoadingStore extends Store<LoadingState> {
  ValueReaction<LoadingState, int> counter;

  LoadingStore({StoreRuntime runtime}) : super(runtime: runtime);

  @override
  LoadingState initStore() => LoadingState();

  void increment() {
    run(this, IncrementAction());
  }
}

class LoadingState extends StoreState<LoadingState> {
  final int counter;

  LoadingState({this.counter = 0});

  @override
  LoadingState copyWith({int counter}) => LoadingState(
        counter: counter ?? this.counter,
      );
}

class IncrementAction extends StoreAction<LoadingStore, LoadingState> {
  IncrementAction()
      : super((store, controller, [services]) {
          controller.set(#counter, 1);
        });
}
