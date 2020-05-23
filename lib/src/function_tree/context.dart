import '../store_state.dart';
import 'change_set.dart';
import 'definitions.dart';

class Context<T extends StoreState<T>> {
  final StoreMutator<T> mutateStore;
  final Map<Symbol, Object> payload;
  final StoreState<T> store;

  Context(this.store, this.mutateStore, Map<Symbol, Object> payload)
      : assert(store != null, 'store is null'),
        assert(mutateStore != null, 'mutateStore is null'),
        assert(payload != null, 'payload is null'),
        payload = Map<Symbol, Object>.unmodifiable(payload);

  Context<T> merge(ChangeSet changes) {
    if (changes is StateChange) {
      return _mergeState(changes);
    }
    if (changes is PayloadChange) {
      return _mergePayload(changes);
    }
    throw StateError('Context receive unknown ChangeSet type');
  }

  Context<T> _mergeState(StateChange changes) => Context(
        mutateStore(changes),
        mutateStore,
        payload,
      );

  Context<T> _mergePayload(PayloadChange changes) => Context(
        store,
        mutateStore,
        Map.unmodifiable(
          <Symbol, dynamic>{
            ...payload,
            ...changes.changeSet,
          },
        ),
      );
}
