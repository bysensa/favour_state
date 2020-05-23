abstract class Reaction<S> {
  List<Symbol> get topics;
  void call(S state);
}
