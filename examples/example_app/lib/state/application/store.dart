import 'package:favour_state/favour_state.dart';

import 'state.dart';

class ApplicationStore extends BaseStore<ApplicationState> {
  @override
  void initReactions() {}

  @override
  ApplicationState initState() => ApplicationState();
}
