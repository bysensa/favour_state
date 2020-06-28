import 'package:favour_state/favour_state.dart';

class ExampleState implements StoreState<ExampleState> {
  final int counter;
  final bool enabled;

  int get controllableCounter => enabled ? counter : 0;

  const ExampleState({
    this.counter = 1,
    this.enabled = true,
  });

  @override
  ExampleState copyWith({
    int counter,
    bool enabled,
  }) {
    if ((counter == null || identical(counter, this.counter)) &&
        (enabled == null || identical(enabled, this.enabled))) {
      return this;
    }

    return ExampleState(
      counter: counter ?? this.counter,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExampleState &&
          runtimeType == other.runtimeType &&
          counter == other.counter &&
          enabled == other.enabled;

  @override
  int get hashCode => counter.hashCode ^ enabled.hashCode;
}
