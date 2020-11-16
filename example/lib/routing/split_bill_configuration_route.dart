import 'package:example/screens/split_bill_configuration_screen.dart';
import 'package:get/get.dart';

final splitBillConfigurationRoute = GetPage(
  name: '/',
  binding: SplitBillConfigurationBindings(),
  page: () => SplitBillConfigurationScreen(),
);
