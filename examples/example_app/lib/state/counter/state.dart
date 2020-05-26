import 'package:favour_state/favour_state.dart';

class CounterState extends StoreState<CounterState> {
  final int counter;

  CounterState({this.counter = 0});

  String get counterText => 'Counter value is $counter';

  @override
  CounterState copyWith({int counter}) => CounterState(
        counter: counter ?? this.counter,
      );
}
