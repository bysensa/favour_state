import 'package:example/state.dart';
import 'package:favour_state/favour_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'store.dart';

void main() {
  runApp(ExampleApp());
}

// ignore: use_key_in_widget_constructors
class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: StoreScope(
          store: ExampleStore(),
          builder: (context, store, _) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StoreListenableBuilder<ExampleState, int>(
                    store: store,
                    reducer: (s) => s.controllableCounter,
                    builder: (context, value, child) => Text('$value'),
                  ),
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
          ),
        ),
      );
}
