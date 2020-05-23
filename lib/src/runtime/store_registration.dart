import 'state_provider.dart';
import 'store_factory.dart';
import 'store_provider.dart';
import 'store_runtime.dart';

/// class [StoreRegistration] extends [StoreProvider]
class StoreRegistration<S extends StateProvider> implements StoreProvider<S> {
  final StoreRuntime runtime;
  final StoreFactory<S> factory;
  S _store;

  StoreRegistration(this.runtime, this.factory)
      : assert(factory != null, 'initializer is null');

  @override
  S get store => _store ??= factory(runtime);
}

/// class [DerivedStoreRegistration] extends [StoreProvider]
class DerivedStoreRegistration<S extends StateProvider>
    implements StoreProvider<S> {
  final StoreRuntime runtime;
  final DerivedStoreFactory<S> factory;
  final SS Function<SS extends StateProvider>() provider;
  S _store;

  DerivedStoreRegistration(this.runtime, this.factory, this.provider)
      : assert(factory != null, 'initializer is null');

  @override
  S get store => _store ??= factory(runtime, provider);
}
