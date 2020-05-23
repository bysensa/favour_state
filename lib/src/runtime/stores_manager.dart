import 'package:favour_state/src/runtime/state_provider.dart';

import 'store_factory.dart';
import 'store_provider.dart';
import 'store_registration.dart';
import 'store_runtime.dart';
import 'stores_provider.dart';
import 'stores_registry.dart';

mixin StoresManager on StoresProvider, StoresRegistry {
  StoreRuntime get runtime;

  static final Map<Type, StoreProvider> stores = {};

  @override
  void registerStore<S extends StateProvider>(StoreFactory<S> factory) {
    if (stores.containsKey(S)) {
      throw StateError('Type $S already registered');
    }
    stores[S] = StoreRegistration<S>(runtime, factory);
  }

  @override
  void registerDerivedStore<S extends StateProvider>(
    DerivedStoreFactory<S> factory,
  ) {
    if (stores.containsKey(S)) {
      throw StateError('Type $S already registered');
    }
    stores[S] = DerivedStoreRegistration<S>(runtime, factory, store);
  }

  @override
  S store<S extends StateProvider>() {
    if (!stores.containsKey(S)) {
      throw StateError('Type $S not registered');
    }
    return stores.cast<Type, StoreProvider<S>>()[S].store;
  }

  @override
  void unregisterAll() {
    stores.clear();
  }
}
