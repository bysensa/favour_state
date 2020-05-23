import 'dart:async';

import '../../store_state.dart';
import '../change_set.dart';
import '../definitions.dart';

StoreAction<S> action<S extends StoreState<S>>(StoreOperation<S> operation,
    {PayloadReducer payload}) {
  final _reducePayload = payload ?? (payload) => {};
  return (state, payload) {
    final dynamic result = Function.apply(
      operation,
      <dynamic>[state],
      _reducePayload(payload),
    );
    if (result is FutureOr<ChangeSet>) {
      return result;
    }
    throw StateError('Operation return object with bad type');
  };
}
