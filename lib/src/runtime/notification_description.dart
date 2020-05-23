import 'package:flutter/foundation.dart';

import 'copyable.dart';
import 'reaction.dart';
import 'reaction_key.dart';

class NotificationDescription {
  final Copyable subject;
  final Iterable<Symbol> topics;
  final Map<ReactionKey, HashedObserverList<Reaction>> reactions;

  NotificationDescription({
    @required this.subject,
    @required this.topics,
    @required this.reactions,
  })  : assert(subject != null, 'subject is null'),
        assert(topics != null, 'topics is null'),
        assert(reactions != null, 'reactions is null');
}
