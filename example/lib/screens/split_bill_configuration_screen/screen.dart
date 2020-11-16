import 'package:example/components/payment_input_keypad.dart';
import 'package:example/components/persons_count_slider.dart';
import 'package:example/components/split_bill_control.dart';
import 'package:example/components/split_configuration_panel.dart';
import 'package:example/components/tips_selection_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class SplitBillConfigurationScreen
    extends GetView<SplitBillConfigurationController> {
  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          body: SplitBillConfigurationLayout(
            splitConfigurationPanel: SplitConfigurationPanel(),
            personsCountSlider: PersonsCountSlider(),
            tipsSelectionList: TipsSelectionList(),
            paymentInputKeypad: PaymentInputKeypad(
              onInput: controller.paymentInputUseCase,
            ),
            splitBillControl: SplitBillControl(),
          ),
        ),
      );
}

class SplitBillConfigurationLayout extends StatelessWidget {
  final Widget splitConfigurationPanel;
  final Widget personsCountSlider;
  final Widget tipsSelectionList;
  final Widget paymentInputKeypad;
  final Widget splitBillControl;

  const SplitBillConfigurationLayout({
    Key key,
    this.splitConfigurationPanel,
    this.personsCountSlider,
    this.tipsSelectionList,
    this.paymentInputKeypad,
    this.splitBillControl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          splitConfigurationPanel,
          const SizedBox(height: 16),
          personsCountSlider,
          const SizedBox(height: 16),
          tipsSelectionList,
          const SizedBox(height: 16),
          Expanded(
            child: paymentInputKeypad,
          ),
          const SizedBox(height: 16),
          splitBillControl,
        ],
      );
}
