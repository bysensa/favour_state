import 'package:flutter/foundation.dart';

import 'bill_split_configuration.dart';
import 'splitted_bill.dart';

class AppState {
  final BillSplitConfiguration configuration;
  final SplittedBill splittedBill;

  const AppState({
    @required this.configuration,
    this.splittedBill,
  }) : assert(configuration != null, 'configuration is null');
}
