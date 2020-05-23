import 'package:flutter/foundation.dart';

import '../../store_state.dart';
import '../change_set.dart';
import '../definitions.dart';

StoreAction<S> callback<S extends StoreState<S>>(VoidCallback callback) =>
    (state, payload) {
      callback();
      return NoChanges();
    };
