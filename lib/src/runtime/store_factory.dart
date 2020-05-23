import 'state_provider.dart';
import 'store_runtime.dart';

typedef StoreFactory<S extends StateProvider> = S Function(StoreRuntime);
typedef DerivedStoreFactory<S extends StateProvider> = S Function(
  StoreRuntime,
  SS Function<SS extends StateProvider>(),
);
