import 'reactions_manager.dart';
import 'service_provider.dart';
import 'states_manager.dart';

class StoreRuntime with ReactionsManager, StatesManager {
  @override
  final ServiceProvider serviceProvider;

  StoreRuntime({this.serviceProvider});

  void dispose() {}
}
