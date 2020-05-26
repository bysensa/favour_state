import 'package:favour_state/favour_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  final initialState = _TestState(counter: 0, loading: false);
  final notifier = _FakeNotifier();
  StateController<_TestState> controller;

  setUp(() {
    controller = StateController(initialState, notifier.notify);
  });

  test('Should change state with set method', () {
    controller.set(#counter, 1);
    expect(controller.state.counter, 1);
    expect(controller.state.loading, false);

    controller.set(#loading, true);
    expect(controller.state.counter, 1);
    expect(controller.state.loading, true);
  });

  test('Should change state with index operator', () {
    controller[#counter] = 1;
    expect(controller.state.counter, 1);
    expect(controller.state.loading, false);

    controller[#loading] = true;
    expect(controller.state.counter, 1);
    expect(controller.state.loading, true);
  });

  test('Should change state with merge method', () {
    controller.merge({#counter: 1, #loading: true});
    expect(controller.state.counter, 1);
    expect(controller.state.loading, true);

    controller.merge({#counter: 2, #loading: false});
    expect(controller.state.counter, 2);
    expect(controller.state.loading, false);
  });

  test('Should change state with changes setter', () {
    controller.changes = {#counter: 1, #loading: true};
    expect(controller.state.counter, 1);
    expect(controller.state.loading, true);

    controller.changes = {#counter: 2, #loading: false};
    expect(controller.state.counter, 2);
    expect(controller.state.loading, false);
  });
}

class _FakeNotifier extends Mock {
  void notify<S extends Copyable>(S state, Set<Symbol> changes) {}
}

class _TestState extends StoreState<_TestState> {
  final int counter;
  final bool loading;

  _TestState({this.counter, this.loading});

  @override
  _TestState copyWith({int counter, bool loading}) => _TestState(
        counter: counter ?? this.counter,
        loading: loading ?? this.loading,
      );
}
