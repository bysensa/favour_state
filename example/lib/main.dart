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
                    child: ListView.separated(
                      itemBuilder: (context, idx) =>
                          store.listenable((c, v, _) => Text('${v.counter}')),
                      separatorBuilder: (context, idx) => const Divider(),
                      itemCount: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => store.multiply(2),
            child: const Icon(Icons.add),
          ),
        ),
      );
}
