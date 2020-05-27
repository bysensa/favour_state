import 'package:favour_state/favour_state.dart';

import 'state.dart';

class SessionStore extends BaseStore<SessionState> {
  @override
  void initReactions() {}

  @override
  SessionState initState() => SessionState(name: 'New session');
}
