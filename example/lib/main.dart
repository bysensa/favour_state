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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 700,
                    child: store.listenable(
                      (context, state, child) => Visibility(
                        visible: state.enabled,
                        child: ListView.separated(
                          itemBuilder: (context, idx) => store.listenable(
                            (context, state, _) => Text('${state.counter}'),
                          ),
                          separatorBuilder: (context, idx) => const Divider(),
                          itemCount: 20,
                        ),
                      ),
                      topics: {#enabled},
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RaisedButton(
                  onPressed: () => store.multiply(2),
                  child: const Text('Increment'),
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
