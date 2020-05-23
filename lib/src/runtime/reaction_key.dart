import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

@immutable
class ReactionKey {
  final Type stateType;
  final Symbol topic;

  ReactionKey({@required this.stateType, Symbol topic})
      : topic = topic ?? #self,
        assert(stateType != null, 'stateType is null');

  @override
  int get hashCode => hash2(stateType.hashCode, topic.hashCode);

  @override
  bool operator ==(Object other) =>
      other is ReactionKey &&
      stateType == other.stateType &&
      topic == other.topic;
}
