import 'package:favour_state/favour_state.dart';

class SessionState extends StoreState<SessionState> {
  final String sessionId;
  final String name;
  final int createdOn;
  final String ownerId;

  SessionState({
    this.sessionId,
    this.name,
    this.createdOn,
    this.ownerId,
  });

  @override
  SessionState copyWith({String name}) => SessionState(
        sessionId: sessionId,
        ownerId: ownerId,
        createdOn: createdOn,
        name: name ?? this.name,
      );
}
