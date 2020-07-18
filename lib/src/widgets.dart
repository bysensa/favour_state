import 'dart:async';

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
  StreamSubscription _subscription;
  S value;

  @override
  void initState() {
    super.initState();
    _subscription = widget.store.subscribe(listener, topics: widget.topics);
  }

  @override
  void didUpdateWidget(StoreListenableBuilder oldWidget) {
    if (oldWidget.store != widget.store) {
      _subscription.cancel();
      _subscription = widget.store.subscribe(listener, topics: widget.topics);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _subscription.cancel();
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
