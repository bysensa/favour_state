import 'package:example/domain/usecases/payment_input_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PaymentInputKeypad extends StatelessWidget {
  final AsyncValueSetter<PaymentInputType> onInput;

  const PaymentInputKeypad({
    Key key,
    this.onInput,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => KeypadGrid(
          onCellTap: onInput,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          columns: 3,
          cells: PaymentInputType.values,
        ),
      );
}

class KeypadGrid extends StatelessWidget {
  final AsyncValueSetter<PaymentInputType> onCellTap;
  final double height;
  final double width;
  final int columns;
  final List<PaymentInputType> cells;

  const KeypadGrid({
    Key key,
    this.width,
    this.columns,
    this.cells,
    this.height,
    this.onCellTap,
  }) : super(key: key);

  double get cellWidth => width / columns;
  double get cellHeight => height / (cells.length / columns);

  @override
  Widget build(BuildContext context) => Wrap(
        key: ValueKey(cells.length),
        children: List.generate(
          cells.length,
          (index) => GridCell(
            key: ValueKey(index),
            onTap: onCellTap,
            width: cellWidth,
            height: cellHeight,
            value: cells[index],
          ),
        ),
      );
}

class GridCell extends StatelessWidget {
  final AsyncValueSetter<PaymentInputType> onTap;
  final double height;
  final double width;
  final PaymentInputType value;

  const GridCell({
    Key key,
    this.width,
    this.value,
    this.height,
    this.onTap,
  }) : super(key: key);

  void tapHandler() => onTap?.call(value);

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        height: height,
        child: InkWell(
          onTap: tapHandler,
          child: Center(
            child: Text.rich(
              TextSpan(text: value.toString().split('.').last),
            ),
          ),
        ),
      );
}
