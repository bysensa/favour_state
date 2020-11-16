import 'package:favour_state/favour_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:async/async.dart';

class IntStore extends Store<int, dynamic> {
  @override
  int init() => 1;
}

class BadProvider extends Provider<int, int, String> {
  BadProvider(Store<int, dynamic> store) : super(store);

  @override
  String provide(int param) {
    throw Exception();
  }
}

class GoodProvider extends Provider<int, void, String> {
  GoodProvider(Store<int, dynamic> store) : super(store);

  @override
  String provide(void param) => '$state';
}

class GoodProviderWithParam extends Provider<int, int, String> {
  GoodProviderWithParam(Store<int, dynamic> store) : super(store);

  @override
  String provide(int param) => '$state$param';
}

void main() {
  test('Should assert on null store', () {
    expect(() => BadProvider(null), throwsA(isA<AssertionError>()));
  });

  test('Should correctly instantiate provider with store instance', () {
    final store = IntStore();
    final provider = GoodProvider(store);
    expect(provider.store, store);
  });

  test('Should correctly call provider with param', () async {
    final store = IntStore();
    final provider = GoodProviderWithParam(store);
    final providerResult = provider(9);
    expect(providerResult, isA<Result<String>>());
    expect(providerResult.isError, false);
    expect(providerResult.isValue, true);
    expect(providerResult.value, '19');
    expect(() => providerResult.error, throwsA(isA<AssertionError>()));
    expect(() => providerResult.stackTrace, throwsA(isA<AssertionError>()));
  });

  test('Should correctly call provider with error', () async {
    final store = IntStore();
    final provider = BadProvider(store);
    final providerResult = provider(9);
    expect(providerResult, isA<Result<String>>());
    expect(providerResult.isError, true);
    expect(providerResult.isValue, false);
    expect(() => providerResult.value, throwsA(isA<AssertionError>()));
    expect(providerResult.error, isA<Exception>());
    expect(providerResult.stackTrace, isA<StackTrace>());
  });
}
