import 'package:favour_state/favour_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:async/async.dart';

class IntStore extends Store<int> {
  @override
  int init() => 0;
}

class BadUseCase extends UseCase<int, void, void> {
  BadUseCase(Store<int> store) : super(store);

  @override
  Future<void> execute(Object param) async {
    throw Exception();
  }
}

class GoodUseCase extends UseCase<int, Object, void> {
  GoodUseCase(Store<int> store) : super(store);

  @override
  Future<void> execute(Object param) async {
    refresh();
    commit((state) => 1);
    commit((state) => state + 1);
  }
}

class GoodUseCaseWithParam extends UseCase<int, int, void> {
  GoodUseCaseWithParam(Store<int> store) : super(store);

  @override
  Future<void> execute(int param) async {
    assert(param != null, 'param is null');
    refresh();
    commit((state) => 1);
    commit((state) => state + param);
  }
}

class GoodUseCaseWithResult extends UseCase<int, Object, int> {
  GoodUseCaseWithResult(Store<int> store) : super(store);

  @override
  Future<int> execute(Object param) async => 1;
}

void main() {
  test('Should assert on null store', () {
    expect(() => BadUseCase(null), throwsA(isA<AssertionError>()));
  });

  test('Should correctly instantiate UseCase with store instance', () {
    final store = IntStore();
    final useCase = GoodUseCase(store);
    expect(useCase.store, store);
  });

  test('Should correctly commit and refresh store', () async {
    final store = IntStore();
    final useCase = GoodUseCase(store);
    final expectation = expectLater(store.stream, emitsInOrder([0, 1, 2]));
    await useCase();
    await expectation;
  });

  test('Should correctly call use case with param', () async {
    final store = IntStore();
    final useCase = GoodUseCaseWithParam(store);
    final expectation = expectLater(store.stream, emitsInOrder([0, 1, 10]));
    await useCase(9);
    await expectation;
  });

  test('Should correctly call use case with param', () async {
    final store = IntStore();
    final useCase = GoodUseCaseWithResult(store);
    final result = await useCase();
    expect(result, isA<Result>());
    expect(result.isError, false);
    expect(result.isValue, true);
    expect(() => result.error, throwsA(isA<AssertionError>()));
    expect(() => result.stackTrace, throwsA(isA<AssertionError>()));
    expect(result.value, isA<int>());
    expect(result.value, 1);
  });

  test('Should correctly handle exception with result', () async {
    final store = IntStore();
    final useCase = BadUseCase(store);
    final result = await useCase();
    expect(result, isA<Result>());
    expect(result.isError, true);
    expect(result.isValue, false);
    expect(() => result.value, throwsA(isA<AssertionError>()));
    expect(result.error, isA<Exception>());
    expect(result.stackTrace, isNotNull);
  });
}
