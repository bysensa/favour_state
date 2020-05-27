import 'package:favour_state/favour_state.dart';

import 'state.dart';

class StoryStore extends BaseStore<StoryState> {
  @override
  void initReactions() {}

  @override
  StoryState initState() => StoryState();
}
