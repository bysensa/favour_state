//import 'package:favour_state/favour_state.dart';
//import 'package:flutter_test/flutter_test.dart';
//
//void main() {
//  StoreRuntime runtime;
//  int effectCall;
//
//  setUp(() {
//    runtime = StoreRuntime();
//    effectCall = 0;
//  });
//
//  test('should register state', () {
//    expect(runtime.states.length, 0);
//
//    final controller = runtime.state<_TestState>(_TestState(value: 0));
//    expect(controller, isInstanceOf<StateController<_TestState>>());
//    expect(runtime.states.length, 1);
//    expect(runtime.states.containsKey(_TestState), isTrue);
//  });
//
//  test('should not register state if state already registered', () {
//    runtime.state<_TestState>(_TestState(value: 0));
//    expect(
//      () => runtime.state<_TestState>(_TestState(value: 0)),
//      throwsStateError,
//    );
//  });
//
//  test('should register value reaction', () {
//    runtime.state<_TestState>(_TestState(value: 0));
//    final reaction = runtime.valueReaction<_TestState, int>(
//      (s) => s.value,
//      topics: {#value},
//    );
//    expect(reaction, isInstanceOf<Value<_TestState, int>>());
//    expect(runtime.reactions.length, 1);
//    expect(runtime.reactions.containsKey(_TestState), isTrue);
//    expect(runtime.reactions[_TestState].containsKey(#self), isTrue);
//    expect(runtime.reactions[_TestState][#self].length, 1);
//    expect(runtime.reactions[_TestState].containsKey(#value), isTrue);
//    expect(runtime.reactions[_TestState][#value].length, 1);
//  });
//
//  test('should register effect reaction', () {
//    runtime.state<_TestState>(_TestState(value: 1));
//    final reaction = runtime.effectReaction<_TestState>(
//      (s) => effectCall += s.value,
//      topics: {#value},
//    );
//
//    expect(effectCall, 1);
//    expect(reaction, isInstanceOf<Effect<_TestState>>());
//    expect(runtime.reactions.length, 1);
//    expect(runtime.reactions.containsKey(_TestState), isTrue);
//    expect(runtime.reactions[_TestState].containsKey(#self), isTrue);
//    expect(runtime.reactions[_TestState][#self].length, 1);
//    expect(runtime.reactions[_TestState].containsKey(#value), isTrue);
//    expect(runtime.reactions[_TestState][#value].length, 1);
//  });
//
//  test('should not register value reaction without registered state', () {
//    expect(
//      () => runtime.valueReaction<_TestState, int>(
//        (s) => s.value,
//        topics: {#value},
//      ),
//      throwsStateError,
//    );
//  });
//
//  test('should not register effect reaction without registered state', () {
//    expect(
//      () => runtime.effectReaction<_TestState>(
//        (s) => effectCall += s.value,
//        topics: {#value},
//      ),
//      throwsStateError,
//    );
//  });
//
//  test('should initialize value reaction when register value reaction', () {
//    runtime.state<_TestState>(_TestState(value: 1));
//    final reaction = runtime.valueReaction<_TestState, int>(
//      (s) => s.value,
//      topics: {#value},
//    );
//    expect(reaction.value, 1);
//  });
//}
//
//class _TestState extends StoreState<_TestState> {
//  final int value;
//
//  _TestState({this.value});
//
//  @override
//  _TestState copyWith({int value}) => _TestState(value: value ?? this.value);
//}
