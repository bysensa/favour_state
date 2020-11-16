import 'package:flutter/foundation.dart';

@immutable
class BillSplitConfiguration {
  final int personsCount;
  final double payment;
  final int tips;
  final Set<int> tipsConfiguration;
  final int maxPersonsCount;

  const BillSplitConfiguration({
    @required this.personsCount,
    @required this.payment,
    @required this.tips,
    @required this.tipsConfiguration,
    @required this.maxPersonsCount,
  });

  BillSplitConfiguration copyWith({
    int personsCount,
    double payment,
    int tips,
    Set<int> tipsConfiguration,
    int maxPersonsCount,
  }) {
    if ((personsCount == null || identical(personsCount, this.personsCount)) &&
        (payment == null || identical(payment, this.payment)) &&
        (tips == null || identical(tips, this.tips)) &&
        (tipsConfiguration == null ||
            identical(tipsConfiguration, this.tipsConfiguration)) &&
        (maxPersonsCount == null ||
            identical(maxPersonsCount, this.maxPersonsCount))) {
      return this;
    }

    return new BillSplitConfiguration(
      personsCount: personsCount ?? this.personsCount,
      payment: payment ?? this.payment,
      tips: tips ?? this.tips,
      tipsConfiguration: tipsConfiguration ?? this.tipsConfiguration,
      maxPersonsCount: maxPersonsCount ?? this.maxPersonsCount,
    );
  }

  @override
  String toString() =>
      // ignore: lines_longer_than_80_chars
      'BillSplitConfiguration{personsCount: $personsCount, payment: $payment, tips: $tips, tipsConfiguration: $tipsConfiguration, maxPersonsCount: $maxPersonsCount}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BillSplitConfiguration &&
          runtimeType == other.runtimeType &&
          personsCount == other.personsCount &&
          payment == other.payment &&
          tips == other.tips &&
          tipsConfiguration == other.tipsConfiguration &&
          maxPersonsCount == other.maxPersonsCount);

  @override
  int get hashCode =>
      personsCount.hashCode ^
      payment.hashCode ^
      tips.hashCode ^
      tipsConfiguration.hashCode ^
      maxPersonsCount.hashCode;
}
