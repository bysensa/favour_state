import 'dart:async';

import 'package:flutter/widgets.dart';

import 'app_state.dart';
import 'runtime.dart';

class AppStateProvider extends StatefulWidget {
  final StoresRegistration registration;
  final ServiceProvider serviceProvider;
  final Widget child;

  AppStateProvider({
    @required this.registration,
    @required this.child,
    this.serviceProvider,
    Key key,
  })  : assert(registration != null, 'registration is null'),
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
      registration: widget.registration,
      serviceProvider: widget.serviceProvider,
    )..init();
  }

  @override
  void dispose() {
    _appState.dispose();
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

  static StoresProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppStateScope>().appState;
}

class StoreMemoizer<S extends StateProvider<Copyable>> {
  final BuildContext context;
  final _completer = Completer<S>();

  StoreMemoizer(this.context) : assert(context != null, 'context is null');

  Future<S> get future {
    if (!hasStore) {
      _completer.complete(Future.sync(_resolveStore));
    }
    return _completer.future;
  }

  S _resolveStore() => AppStateScope.of(context).store<S>();

  bool get hasStore => _completer.isCompleted;
}

mixin StoreResolver<S extends StateProvider<Copyable>> {
  StoreMemoizer<S> get store;
}
