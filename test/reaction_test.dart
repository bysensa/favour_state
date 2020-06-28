//import 'package:favour_state/favour_state.dart';
//import 'package:flutter_test/flutter_test.dart';
//
//void main() {
//  Value<_TestState, int> valueReaction;
//  Effect<_TestState> effectReaction;
//  int effectCall;
//
//  setUp(() {
//    valueReaction = Value<_TestState, int>(
//      reducer: (s) => s.value,
//      topics: {},
//    );
//    effectReaction = Effect<_TestState>(
//      effect: (s) => effectCall += s.value,
//      topics: {},
//    );
//    effectCall = 0;
//  });
//
//  test('value reaction changed value should be set', () {
//    valueReaction.notify(_TestState(value: 0));
//    expect(valueReaction.value, 0);
//  });
//
//  test('value reaction should notify if value changed', () {
//    var notificationsCount = 0;
//    valueReaction.addListener(() {
//      notificationsCount++;
//    });
//
//    expect(notificationsCount, 0);
//    expect(valueReaction.value, null);
//
//    valueReaction.notify(_TestState(value: 1));
//    expect(notificationsCount, 1);
//    expect(valueReaction.value, 1);
//
//    valueReaction.notify(_TestState(value: 2));
//    expect(notificationsCount, 2);
//    expect(valueReaction.value, 2);
//  });
//
//  test('value reaction should not notify if value not changed', () {
//    var notificationsCount = 0;
//    valueReaction.addListener(() {
//      notificationsCount++;
//    });
//
//    expect(notificationsCount, 0);
//    expect(valueReaction.value, null);
//
//    valueReaction.notify(_TestState(value: 1));
//    expect(notificationsCount, 1);
//    expect(valueReaction.value, 1);
//
//    valueReaction.notify(_TestState(value: 1));
//    expect(notificationsCount, 1);
//    expect(valueReaction.value, 1);
//  });
//
//  test('effect reaction should call effect if value changed', () {
//    expect(effectCall, 0);
//
//    effectReaction.notify(_TestState(value: 1));
//    expect(effectCall, 1);
//
//    effectReaction.notify(_TestState(value: 2));
//    expect(effectCall, 3);
//  });
//
//  test('value reaction should not notify if value not changed', () {
//    expect(effectCall, 0);
//
//    effectReaction.notify(_TestState(value: 1));
//    expect(effectCall, 1);
//
//    effectReaction.notify(_TestState(value: 1));
//    expect(effectCall, 2);
//  });
//}
//
//class _TestState extends StoreState<_TestState> {
//  final int value;
//
//  _TestState({this.value});
//
//  @override
//  _TestState copyWith() {
//    throw UnimplementedError();
//  }
//}
