import 'package:favour_state/favour_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Should create value reaction for topic #self', () {
    final runtime = StoreRuntime();
    final reaction = runtime.value<State, int>((state) => 1);
//    expect(runtime.reactions.length, 1);
    expect(reaction.topics.length, 1);
    expect(reaction.topics[0], #self);
  });

  test('Should create value reaction for topics #one, #two', () {
    final runtime = StoreRuntime();
    final reaction = runtime.value<State, int>(
      (state) => 1,
      topics: [#one, #two],
    );
//    expect(runtime.reactions.length, 2);
    expect(reaction.topics.length, 2);
    expect(reaction.topics[0], #one);
    expect(reaction.topics[1], #two);
  });

  test('Should create effect reaction for topic #self', () {
    final runtime = StoreRuntime();
    final reaction = runtime.effect<State>(
      (state) => expect(
        state is State,
        isTrue,
      ),
    );
//    expect(runtime.reactions.length, 1);
    expect(reaction.topics.length, 1);
    expect(reaction.topics[0], #self);
  });

  test('Should create value reaction for topics #one, #two', () {
    final runtime = StoreRuntime();
    final reaction = runtime.effect<State>(
      (state) => expect(
        state is State,
        isTrue,
      ),
      topics: [#one, #two],
    );
//    expect(runtime.reactions.length, 2);
    expect(reaction.topics.length, 2);
    expect(reaction.topics[0], #one);
    expect(reaction.topics[1], #two);
  });
}

class State with Copyable {
  final int counter;

  State({this.counter});

  @override
  Copyable copyWith({int counter}) => State(counter: counter ?? this.counter);
}
