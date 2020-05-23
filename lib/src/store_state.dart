import 'runtime.dart';

abstract class StoreState<T extends StoreState<T>> with Copyable {
  @override
  T copyWith();
}
