 
typedef CommitFn<S> =  S Function(S);

abstract class Store<T> {
  Rx<T> _state;
  T init();
  
  @mustCallSuper
  Store() {
    final initializedState = init();
    assert(initializedState != null);
    _state = Rx(initializedState);
  }
  
  void _refresh() {
    _state.refresh();
  }
  
  void _commit(CommitFn commit) {
    final newState = commit(_state.value);
    assert(newState != null);
    _state.value = newState;
  }
}

abstract class UseCase<S,P,R> {
  Store<S> _store;
  
  @mustCallSuper
  UseCase(covariant Store<S> store) {
    assert(store != null);
    _store = store;
  }
  
  @protected
  S get state => _store._state.value;
  
  @protected
  void commit(CommitFn<S> commit) {
    _store.commit(commit);
  } 
  
  @protected
  void refresh() {
    _store.refresh();
  }
  
  Future<Result<R>> call([P param]);
}

abstract class Selector<S,P,R> {
  Store<S> _store;
  
  @mustCallSuper
  Selector(covariant Store<S> store) {
    assert(store != null);
    _store = store;
  }
  
  @protected
  S get state => _store._state.value;
  
  @protected
  S get stream => _store._state.stream;
  
  Stream<R> call([P param]) async* {
    yield mapState(state, param);
    yield* mapStream(stream, param);
  }
   
  R mapState(S state, P param);
  Stream<R> mapStream(Stream<S> stream, P param);
} 

