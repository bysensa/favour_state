import 'state_provider.dart';

mixin StoresProvider {
  S store<S extends StateProvider>();
}
