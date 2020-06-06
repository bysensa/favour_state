import 'package:favour_state/favour_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'store.dart';

void bootstrapStores(AppState appState) {
  // Store initialized after registration
  // when method bootstrapServices called
  // Runtime setup into state and methods
  // initState and initReactions called

  // Store can be registered using this api
  // appState.registerStore(AnotherStore());
  // appState.registerDerivedStore(
  //   (store) => SomeStore(dependency: stores<AnotherStore>())
  // )
  // when you register derived store you can get already registered stores
  appState.registerStore(ExampleStore());
}

void main() {
  runApp(ExampleApp());
}

// ignore: use_key_in_widget_constructors
class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: AppStateProvider(
          bootstrap: bootstrapStores,
          serviceProvider: GetIt.I,
          child: Builder(
            builder: (context) {
              final store = AppStateScope.store<ExampleStore>(context);
              // ignore: avoid_unnecessary_containers
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ValueListenableBuilder(
                          valueListenable: store.controllableCounter,
                          builder: (context, value, child) => Text('$value')),
                      RaisedButton(
                        onPressed: () => store.multiply(2),
                        child: const Text('Doubly'),
                      ),
                      RaisedButton(
                        onPressed: store.toggle,
                        child: const Text('Toggle'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
}
