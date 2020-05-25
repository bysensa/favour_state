import 'dart:async';

import 'package:flutter/widgets.dart';

import 'core.dart';

class AppStateProvider extends StatefulWidget {
  final AppStateBootstrap bootstrap;
  final ServiceProvider serviceProvider;
  final Widget child;

  AppStateProvider({
    @required this.bootstrap,
    @required this.child,
    this.serviceProvider,
    Key key,
  })  : assert(bootstrap != null, 'registration is null'),
        assert(child != null, 'child is null'),
        super(key: key);

  @override
  State<AppStateProvider> createState() => _AppStateProviderState();
}

class _AppStateProviderState extends State<AppStateProvider> {
  AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState(
      bootstrap: widget.bootstrap,
      serviceProvider: widget.serviceProvider,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppStateScope(
        child: widget.child,
        appState: _appState,
      );
}

class AppStateScope extends InheritedWidget {
  final AppState appState;

  AppStateScope({@required this.appState, @required Widget child, Key key})
      : assert(appState != null, 'appState is null'),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;

  static SS of<SS extends Store>(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<AppStateScope>()
      .appState
      .store();
}

class StoreMemoizer<SS extends Store> {
  final BuildContext context;
  final _completer = Completer<SS>();

  StoreMemoizer(this.context) : assert(context != null, 'context is null');

  Future<SS> get future {
    if (!hasStore) {
      _completer.complete(Future.sync(_resolveStore));
    }
    return _completer.future;
  }

  SS _resolveStore() => AppStateScope.of<SS>(context);

  bool get hasStore => _completer.isCompleted;
}
