// ignore: use_key_in_widget_constructors
import 'package:example/app_bindings.dart';
import 'package:example/domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'routing.dart';

class SplitBillApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GetMaterialApp(
        title: 'Split Bill',
        getPages: routes,
        initialBinding: AppBindings(
          stateBindings: StateBindings(),
          usecasesBindings: UsecasesBindings(),
        ),
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
      );
}
