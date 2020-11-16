import 'package:favour_state/favour_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class IntStore extends Store<int, dynamic> {
  @override
  int init() => 0;
}

class BadSelector extends Selector<int, Object, Object> {
  BadSelector(Store<int, dynamic> store) : super(store);

  @override
  Object mapState(int state, [Object param]) {
    throw Exception();
  }

  @override
  Stream<Object> mapStream(Stream<int> stream, [Object param]) {
    throw Exception();
  }
}

class GoodSelector extends Selector<int, String, Object> {
  GoodSelector(Store<int, dynamic> store) : super(store);

  @override
  Object mapState(int state, [Object param]) => '$state';

  @override
  Stream<Object> mapStream(Stream<int> stream, [Object param]) =>
      stream.map(mapState);
}

class HelperUseCase extends UseCase<int, dynamic, void> {
  HelperUseCase(Store<int, dynamic> store) : super(store);

  @override
  Future<void> execute(void param) async {
    await Future.delayed(1.seconds);
    commit((state) => 1);
    await Future.delayed(1.seconds);
    commit((state) => 2);
    await Future.delayed(1.seconds);
    return;
  }
}

void main() {
  test('Should assert on null store', () {
    expect(() => BadSelector(null), throwsA(isA<AssertionError>()));
  });

  test('Should correctly instantiate UseCase with store instance', () {
    final store = IntStore();
    final selector = GoodSelector(store);
    expect(selector.store, store);
  });

  test('Should correctly handle exception', () async {
    final store = IntStore();
    final selector = BadSelector(store);
    await expectLater(selector(), emitsError(isA<Exception>()));
  });

  test('Should correctly stream values with initial value', () async {
    final store = IntStore();
    final selector = GoodSelector(store);
    final useCase = HelperUseCase(store);

    final streamData = [];
    final stream = selector()..listen(streamData.add);
    await useCase();
    expect(streamData, ['0', '1', '2']);
  });
}
