//import 'package:favour_state/src/core.dart';
//import 'package:flutter_test/flutter_test.dart';
//
//void main() {
//  test('should register controller', () {
//    final manager = TestStatesManager();
//    final firstController = FirstController(FirstState());
//    manager.registerState(firstController);
//    expect(manager.states.length, 1);
//    expect(manager.states.containsKey(FirstState), isTrue);
//  });
//
//  test('should unregister controller', () {
//    final manager = TestStatesManager();
//    final firstController = FirstController(FirstState());
//    manager.registerState(firstController);
//    expect(manager.states.length, 1);
//    expect(manager.states.containsKey(FirstState), isTrue);
//
//    manager.unregisterState(firstController);
//    expect(manager.states.length, 0);
//    expect(manager.states.containsKey(FirstState), isFalse);
//  });
//
//  test('should add observer', () {
//    void observer(FirstState state) {}
//
//    final manager = TestStatesManager();
//    final firstController = FirstController(FirstState());
//    manager.registerState(firstController);
//    // ignore: cascade_invocations
//    manager.addObserver(observer.observe());
//    expect(firstController.observers.length, 1);
//    expect(firstController.observers.containsKey(#self), isTrue);
//    expect(firstController.observers[#self].length, 1);
//  });
//
//  test('should remove observer', () {
//    void observer(FirstState state) {}
//
//    final manager = TestStatesManager();
//    final firstController = FirstController(FirstState());
//    manager.registerState(firstController);
//
//    // ignore: cascade_invocations
//    manager.addObserver(observer.observe());
//    expect(firstController.observers.length, 1);
//    expect(firstController.observers.containsKey(#self), isTrue);
//    expect(firstController.observers[#self].length, 1);
//
//    manager.removeObserver(observer.observe());
//    expect(firstController.observers.length, 1);
//    expect(firstController.observers.containsKey(#self), isTrue);
//    expect(firstController.observers[#self].length, 0);
//  });
//}
//
//class TestStatesManager with StatesManager {}
//
//class FirstController extends StateController<FirstState> {
//  FirstController(FirstState initialState) : super(initialState);
//}
//
//class FirstState extends StoreState<FirstState> {
//  @override
//  FirstState copyWith() => FirstState();
//}
