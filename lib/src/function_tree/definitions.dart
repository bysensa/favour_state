import 'dart:async';

import '../store_state.dart';
import 'change_set.dart';

typedef StoreAction<S extends StoreState<S>> = FutureOr<ChangeSet> Function(
  S state,
  Map<Symbol, Object> payload,
);
typedef StoreValueProvider<S, T> = T Function(S store);
typedef PayloadReducer = Map<Symbol, Object> Function(Map<Symbol, Object>);
typedef StoreOperation<S extends StoreState<S>> = FutureOr<ChangeSet> Function(
  S state,
);

typedef Mutator<S extends StoreState<S>> = S Function(Map<Symbol, Object>);
typedef Mutation<S extends StoreState<S>> = FutureOr<void> Function(
    S, Mutator<S>);
typedef StoreMutator<S extends StoreState<S>> = S Function(StateChange);
typedef StoreMutation<S extends StoreState<S>> = FutureOr<void> Function(
  S,
  StoreMutator,
);

typedef Provider<T, S> = T Function(S);
