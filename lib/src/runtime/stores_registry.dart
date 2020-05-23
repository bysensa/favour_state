import 'state_provider.dart';
import 'store_factory.dart';

mixin StoresRegistry {
  void registerStore<S extends StateProvider>(StoreFactory<S> factory);

  void registerDerivedStore<S extends StateProvider>(
    DerivedStoreFactory<S> factory,
  );

  void unregisterAll();
}
