import 'dart:async';
import 'dart:developer';

import 'package:favour_state/favour_state.dart';
import 'package:flutter/widgets.dart';

//class AppStateProvider extends StatefulWidget {
//  final AppStateBootstrap bootstrap;
//  final ServiceProvider serviceProvider;
//  final Widget child;
//
//  AppStateProvider({
//    @required this.bootstrap,
//    @required this.child,
//    this.serviceProvider,
//    Key key,
//  })  : assert(bootstrap != null, 'registration is null'),
//        assert(child != null, 'child is null'),
//        super(key: key);
//
//  @override
//  State<AppStateProvider> createState() => _AppStateProviderState();
//}
//
//class _AppStateProviderState extends State<AppStateProvider> {
//  AppState _appState;
//
//  @override
//  void initState() {
//    super.initState();
//    _appState = AppState(
//      bootstrap: widget.bootstrap,
//      serviceProvider: widget.serviceProvider,
//    );
//  }
//
//  @override
//  void dispose() {
//    super.dispose();
//  }
//
//  @override
//  Widget build(BuildContext context) => AppStateScope(
//        child: widget.child,
//        appState: _appState,
//      );
//}
//
//class AppStateScope extends InheritedWidget {
//  final AppState appState;
//
//  AppStateScope({@required this.appState, @required Widget child, Key key})
//      : assert(appState != null, 'appState is null'),
//        super(key: key, child: child);
//
//  @override
//  bool updateShouldNotify(InheritedWidget oldWidget) => false;
//
//  static AppState instance(BuildContext context) =>
//      context.dependOnInheritedWidgetOfExactType<AppStateScope>().appState;
//
//  static SS store<SS extends StoreInitializer>(BuildContext context) => context
//      .dependOnInheritedWidgetOfExactType<AppStateScope>()
//      .appState
//      .store<SS>();
//
//  static void removeObserver<S extends StoreState<S>>(
//    BuildContext context,
//    ValueChanged<S> observer, {
//    Set<Symbol> topics,
//  }) {
//    context
//        .dependOnInheritedWidgetOfExactType<AppStateScope>()
//        .appState
//        .removeObserver<S>(observer, topics: topics);
//  }
//
//  static void addObserver<S extends StoreState<S>>(
//    BuildContext context,
//    ValueChanged<S> observer, {
//    Set<Symbol> topics,
//  }) {
//    context
//        .dependOnInheritedWidgetOfExactType<AppStateScope>()
//        .appState
//        .addObserver<S>(observer, topics: topics);
//  }
//}
//
//class StoreMemoizer<SS extends StoreInitializer> {
//  final BuildContext context;
//  final _completer = Completer<SS>();
//
//  StoreMemoizer(this.context) : assert(context != null, 'context is null');
//
//  Future<SS> get future {
//    if (!hasStore) {
//      _completer.complete(Future.sync(_resolveStore));
//    }
//    return _completer.future;
//  }
//
//  SS _resolveStore() => AppStateScope.store<SS>(context);
//
//  bool get hasStore => _completer.isCompleted;
//}
//
//typedef StoreConsumerBuilder<T extends Store> = Widget Function(
//  BuildContext,
//  T,
//);
//
//class AppStateConsumer<T extends Store> extends StatelessWidget {
//  final StoreConsumerBuilder<T> builder;
//
//  const AppStateConsumer({
//    Key key,
//    this.builder,
//  }) : super(key: key);
//
//  @override
//  Widget build(BuildContext context) => builder(
//        context,
//        AppStateScope.store<T>(context),
//      );
//}

class StoreListenableBuilder<S extends StoreState<S>> extends StatefulWidget {
  final Set<Symbol> topics;
  final Store<S> store;
  final Widget child;
  final ValueWidgetBuilder<S> builder;

  const StoreListenableBuilder({
    @required this.builder,
    @required this.store,
    Key key,
    this.child,
    this.topics,
  })  : assert(builder != null, 'builder is null'),
        assert(store != null, 'store is null'),
        super(key: key);

  @override
  _StoreListenableBuilderState<S> createState() =>
      _StoreListenableBuilderState<S>();
}

class _StoreListenableBuilderState<S extends StoreState<S>>
    extends State<StoreListenableBuilder<S>> {
  StateChangedObserver<S> _observer;
  S value;

  @override
  void initState() {
    super.initState();
    _observer = listener.observe(widget.store, topics: widget.topics);
  }

  @override
  void didUpdateWidget(StoreListenableBuilder oldWidget) {
    if (oldWidget.store != widget.store) {
      oldWidget.store.removeObserver(_observer);
      widget.store.addObserver(_observer);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _observer.dispose();
    super.dispose();
  }

  void listener(S state) {
    setState(() {
      value = state;
    });
  }

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        value,
        widget.child,
      );
}

class StoreScope<S extends Store<StoreState>> extends StatefulWidget {
  final S store;
  final Widget child;
  final ValueWidgetBuilder<S> builder;

  const StoreScope({
    @required this.store,
    @required this.builder,
    Key key,
    this.child,
  })  : assert(store != null, 'store is null'),
        assert(builder != null, 'builder is null'),
        super(key: key);

  @override
  _StoreScopeState createState() => _StoreScopeState();
}

class _StoreScopeState extends State<StoreScope> {
  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        widget.store,
        widget.child,
      );
}

extension StoreListenable<S extends StoreState<S>> on Store<S> {
  Widget listenable(
    ValueWidgetBuilder<S> builder, {
    Set<Symbol> topics,
    Widget child,
  }) {
    assert(builder != null, 'builder is null');
    return StoreListenableBuilder<S>(
      store: this,
      builder: builder,
      topics: topics,
      child: child,
    );
  }
}

abstract class WidgetStore<T extends StatefulWidget, S extends StoreState<S>>
    extends State<T> implements Store<S> {
  // ignore: invalid_use_of_visible_for_testing_member
  StateController<S> _controller;

  @override
  S get state => _controller.state;

  @override
  void addObserver(StateChangedObserver<S> observer) {
    assert(observer != null, 'observer is null');
    _controller.addObserver(observer);
  }

  @override
  void removeObserver(StateChangedObserver<S> observer) {
    assert(observer != null, 'observer is null');
    _controller.removeObserver(observer);
  }

  @override
  @mustCallSuper
  void initState() {
    super.initState();
    _controller = StateController<S>(buildState());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Future<void> mutate(
    FutureOr<void> Function() changeClosure, {
    String debugName,
  }) async {
    final msg = debugName ?? 'change in $S';
    log('Begin $msg');
    Timeline.startSync(msg);
    try {
      await changeClosure();
    } catch (err, trace) {
      log(err, stackTrace: trace);
    }
    Timeline.finishSync();
    log('End $msg\n');
  }

  @override
  void operator []=(Symbol topic, Object value) {
    _controller[topic] = value;
  }

  @override
  // ignore: avoid_setters_without_getters
  set changes(Map<Symbol, Object> changes) {
    _controller.changes = changes;
  }

  @override
  void merge(Map<Symbol, Object> changes) {
    _controller.merge(changes);
  }

  @override
  void set(Symbol topic, Object value) {
    _controller.set(topic, value);
  }
}
