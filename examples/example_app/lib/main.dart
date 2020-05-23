import 'package:flutter/material.dart';

import 'state/loading/loading_store.dart';

void main() {
  runApp(ExampleApp());
}

class ExampleApp extends StatelessWidget {
  ExampleApp({Key key}) : super(key: key);

  LoadingStore store = LoadingStore();

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Column(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: null,
              builder: (context, value, child) {
                return Placeholder();
              },
            )
          ],
        ),
      );
}
