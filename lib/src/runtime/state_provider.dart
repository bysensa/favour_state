import 'copyable.dart';

abstract class StateProvider<S extends Copyable> {
  S get value;
}
