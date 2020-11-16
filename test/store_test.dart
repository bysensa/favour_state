import 'package:favour_state/favour_state.dart';
import 'package:flutter_test/flutter_test.dart';

enum TestActivity { test1, test2 }

class IntStore extends Store<int, TestActivity> {
  final int Function() initializer;

  IntStore(this.initializer);

  @override
  int init() => initializer();
}

void main() {
  test('Should assert on null state value from init', () {
    expect(
      () => IntStore(() => null),
      throwsA(isInstanceOf<AssertionError>()),
    );
  });

  test('Should correctly instantiate store with correct initial value', () {
    final store = IntStore(() => 0);
    expect(store.state, 0);
  });

  test('Should not emit value when subscribe on stream', () async {
    final store = IntStore(() => 0);
    await expectLater(store.stream, emitsInOrder([]));
  });

  test('Should emit value on refresh', () async {
    final store = IntStore(() => 0);
    final expect = expectLater(store.stream, emitsInOrder([0]));
    store.refresh();
    await expect;
  });

  test('Should emit value on commit', () async {
    final store = IntStore(() => 0);
    final expect = expectLater(store.stream, emitsInOrder([1]));
    store.commit((state) => 1);
    await expect;
  });

  test('Should provide actual state value for commit', () async {
    final store = IntStore(() => 0);
    final expectation = expectLater(store.stream, emitsInOrder([1, 2]));

    store.commit((state) {
      expect(state, 0);
      return 1;
    });

    // ignore: cascade_invocations
    store.commit((state) {
      expect(state, 1);
      return state + 1;
    });

    await expectation;
  });

  test('Should assert on null commit closure', () async {
    final store = IntStore(() => 0);
    final expectation = expectLater(store.stream, emitsInOrder([]));
    expect(() => store.commit(null), throwsA(isInstanceOf<AssertionError>()));
    await expectation;
  });

  test('Should assert on null commit closure result', () async {
    final store = IntStore(() => 0);
    final expectation = expectLater(store.stream, emitsInOrder([]));
    expect(
      () => store.commit((state) => null),
      throwsA(isInstanceOf<AssertionError>()),
    );
    await expectation;
  });
}
