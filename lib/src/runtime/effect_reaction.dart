import 'package:flutter/foundation.dart';

import 'copyable.dart';
import 'reaction.dart';

class EffectReaction<S extends Copyable> extends Reaction<S> {
  @override
  final List<Symbol> topics;
  final ValueChanged<S> effect;

  EffectReaction({
    @required this.effect,
    @required this.topics,
  })  : assert(effect != null, 'effect is null'),
        assert(topics != null, 'topics is null');

  @override
  void call(S state) {
    effect(state);
  }
}
