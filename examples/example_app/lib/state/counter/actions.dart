import 'package:favour_state/favour_state.dart';

import 'state.dart';
import 'store.dart';

class IncrementAction extends StoreAction<CounterStore, CounterState> {
  IncrementAction()
      : super((store, mutator, [services]) {
          mutator[#counter] = store.state.counter + 1;
        });
}
