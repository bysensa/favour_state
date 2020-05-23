import 'package:flutter/foundation.dart';

import 'copyable.dart';
import 'reactions_manager.dart';
import 'state_provider.dart';

class StateController<S extends Copyable> implements StateProvider<S> {
  final ReactionsManager reactions;
  S _state;

  StateController({
    @required S initialState,
    @required this.reactions,
  })  : assert(initialState != null, 'state is null'),
        assert(reactions != null, 'reactions is null'),
        _state = initialState;

  @override
  S get value => _state;

  S set(Symbol field, Object value) {
    final changes = {field: value};
    return _merge(changes);
  }

  S merge(Map<Symbol, Object> changes) => _merge(changes);

  S _merge(Map<Symbol, Object> changes) {
    final dynamic newState = Function.apply(
      _state.copyWith,
      null,
      changes,
    );
    if (newState is S) {
      _state = newState;
      reactions.notifyReactions(newState, [#self, ...changes.keys]);
      return newState;
    }
    throw StateError('state method "copyWith" return instance of unknown type');
  }
}
