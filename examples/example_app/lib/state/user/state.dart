import 'package:favour_state/favour_state.dart';

class UserState extends StoreState<UserState> {
  final bool isInitialized;
  final String id;
  final String name;

  UserState({this.id, this.name, this.isInitialized = false});

  @override
  UserState copyWith({
    String id,
    String name,
    bool isInitialized,
  }) =>
      UserState(
        id: id ?? this.id,
        name: name ?? this.name,
        isInitialized: isInitialized ?? this.isInitialized,
      );
}
