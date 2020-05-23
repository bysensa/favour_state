import 'package:flutter/foundation.dart';

import 'copyable.dart';
import 'provider.dart';
import 'reaction.dart';

class ValueReaction<S extends Copyable, T> extends ChangeNotifier
    implements ValueListenable<T>, Reaction<S> {
  @override
  final List<Symbol> topics;
  T _value;
  final Provider<T, S> valueProvider;

  ValueReaction(this.valueProvider, {this.topics});

  @override
  T get value => _value;

  @override
  void call(S state) {
    final newValue = valueProvider(state);
    if (_value != newValue) {
      _value = newValue;
      notifyListeners();
    }
  }
}
