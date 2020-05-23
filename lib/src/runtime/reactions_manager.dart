import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'copyable.dart';
import 'effect_reaction.dart';
import 'notification_description.dart';
import 'provider.dart';
import 'reaction.dart';
import 'reaction_key.dart';
import 'value_reaction.dart';

mixin ReactionsManager {
  final Map<ReactionKey, HashedObserverList<Reaction>> _reactions = {};

  EffectReaction<S> effect<S extends Copyable>(
    ValueChanged<S> effect, {
    List<Symbol> topics,
  }) {
    final _topics = topics ?? [#self];
    final reaction = EffectReaction<S>(effect: effect, topics: _topics);
    _registerReaction<S>(reaction, _topics);
    return reaction;
  }

  ValueReaction<S, T> value<S extends Copyable, T>(
    Provider<T, S> valueProvider, {
    List<Symbol> topics,
  }) {
    final _topics = topics ?? [#self];
    final reaction = ValueReaction<S, T>(valueProvider, topics: _topics);
    _registerReaction<S>(reaction, _topics);
    return reaction;
  }

  void _registerReaction<S extends Copyable>(
    Reaction<S> reaction,
    List<Symbol> topics,
  ) {
    topics.map((topic) => ReactionKey(stateType: S, topic: topic)).forEach(
      (key) {
        if (_reactions.containsKey(key)) {
          _reactions[key].add(reaction);
          return;
        }
        _reactions[key] = HashedObserverList()..add(reaction);
      },
    );
  }

  Future<void> notifyReactions<S extends Copyable>(
    S state,
    Iterable<Symbol> topics,
  ) async {
    _performNotifyReactions(
      NotificationDescription(
        subject: state,
        topics: topics,
        reactions: UnmodifiableMapView(_reactions),
      ),
    );
  }

  void _performNotifyReactions(NotificationDescription description) {
    if (description.topics.isEmpty) {
      return;
    }

    void callReaction(Reaction reaction) {
      reaction(description.subject);
    }

    ReactionKey reactionKey(Symbol topic) => ReactionKey(
          stateType: description.subject.runtimeType,
          topic: topic,
        );

    description.topics.map(reactionKey).forEach(
      (key) {
        if (description.reactions.containsKey(key)) {
          description.reactions[key].forEach(callReaction);
        }
      },
    );
  }
}
