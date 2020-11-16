import 'package:example/domain/state/bill_split_configuration.dart';
import 'package:favour_state/favour_state.dart';

import 'app_state.dart';

class AppStore extends Store<AppState> {
  @override
  AppState init() => const AppState(
        configuration: BillSplitConfiguration(
          personsCount: 0,
          tips: 0,
          payment: 0,
          maxPersonsCount: 10,
          tipsConfiguration: {0, 10, 20, 30},
        ),
      );
}
