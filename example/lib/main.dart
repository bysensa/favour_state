import 'package:favour_state/favour_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'store.dart';

void main() {
  runApp(ExampleApp());
}

// ignore: use_key_in_widget_constructors
class ExampleApp extends StatelessWidget {
  final store = ExampleStore();

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                store.listenable((c, v, _) => Text('${v.counter}')),
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
      );
}
