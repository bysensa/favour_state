mixin ExtendsChangeSet {}

class ChangeSet {
  final Map<Symbol, Object> changeSet;

  ChangeSet(Map<Symbol, Object> changeSet)
      : changeSet = Map<Symbol, dynamic>.unmodifiable(changeSet);
}

class NoChanges extends ChangeSet {
  NoChanges() : super({});
}

class StateChange = ChangeSet with ExtendsChangeSet;
class PayloadChange = ChangeSet with ExtendsChangeSet;
