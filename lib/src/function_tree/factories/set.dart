import '../../store_state.dart';
import '../change_set.dart';
import '../definitions.dart';

StoreAction<S> set<S extends StoreState<S>>(Symbol property, Object value) =>
    (store, payload) => StateChange({property: value});
