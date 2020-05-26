import 'package:favour_state/favour_state.dart';
import 'package:flutter/material.dart';

import 'state/bootstrap.dart';
import 'state/counter/store.dart';

void main() {
  runApp(ExampleApp());
}

class ExampleApp extends StatelessWidget {
  ExampleApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AppStateProvider(
          bootstrap: appStateBootstrap,
          child: Builder(
            builder: (context) {
              final counterStore = AppStateScope.store<CounterStore>(context);

              return Column(
                children: [
                  ValueListenableBuilder<String>(
                    valueListenable: counterStore.counterText,
                    builder: (context, value, child) => Text(value),
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: counterStore.counter,
                    builder: (context, value, child) => Text('$value'),
                  ),
                  RaisedButton(
                    child: const Text('Increment'),
                    onPressed: counterStore.increment,
                  ),
                ],
              );
            },
          ),
        ),
      );
}
