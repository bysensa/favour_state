import 'package:favour_state/favour_state.dart';

import 'state.dart';

class UserStore extends BaseStore<UserState> {
  @override
  void initReactions() {}

  @override
  UserState initState() => UserState(id: '', name: '');
}
