import 'package:favour_state/favour_state.dart';

import 'counter/store.dart';

void appStateBootstrap(AppState appState) {
  appState.registerStore(CounterStore());
}
