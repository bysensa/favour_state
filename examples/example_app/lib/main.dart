import 'package:favour_state/favour_state.dart';
import 'package:flutter/material.dart';

import 'state/bootstrap.dart';

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
            builder: (context) => const Placeholder(),
          ),
        ),
      );
}
