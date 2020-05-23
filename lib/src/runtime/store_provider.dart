import 'state_provider.dart';

abstract class StoreProvider<S extends StateProvider> {
  S get store;
}
