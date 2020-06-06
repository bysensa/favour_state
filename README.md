# favour\_state

State management solution for flutter inspired by cerebraljs and property\_change\_notifier

**Documentation now in WIP status. Please look at example.**

#Example

```dart
// state.dart

import 'package:favour_state/favour_state.dart';

class ExampleState implements StoreState<ExampleState> {
  final int counter;
  final bool enabled;

  int get controllableCounter => enabled ? counter : 0;

  const ExampleState({
    this.counter = 0,
    this.enabled = true,
  });

  @override
  ExampleState copyWith({
    int counter,
    bool enabled,
  }) {
    if ((counter == null || identical(counter, this.counter)) &&
        (enabled == null || identical(enabled, this.enabled))) {
      return this;
    }

    return ExampleState(
      counter: counter ?? this.counter,
      enabled: enabled ?? this.enabled,
    );
  }
}
```


```dart
// store.dart

import 'package:favour_state/favour_state.dart';

import 'state.dart';

class ExampleStore extends BaseStore<ExampleState> {
  // Any reaction is optional
  ValueReaction<ExampleState, bool> enabled;
  ValueReaction<ExampleState, int> controllableCounter;
  ValueReaction<ExampleState, ExampleState> self;

  EffectReaction<ExampleState> onCounterChange;

  // if you not declare reaction you can leave the method empty
  @override
  void initReactions() {
    // under the hood value reaction implement ValueListenable
    enabled = valueReaction((s) => s.enabled, topics: {#enabled});
    controllableCounter = valueReaction(
      (s) => s.controllableCounter,
      topics: {#enabled, #counter},
    );
    self = valueReaction((s) => s);

    // in closure of effect reaction you can use anything from class scope
    onCounterChange = effectReaction(
      // ignore: avoid_print
      (s) => print('counter changed'),
      topics: {#counter},
    );
  }

  // you can initialize your state
  @override
  ExampleState initState() => const ExampleState(counter: 1);

  Future<void> multiply(int multiplier) async {
    await run(MultiplyCounter(multiplier));
  }

  Future<void> toggle() async {
    await run(action<ExampleStore>((store, mutator, [services]) {
      // #name - should be equal to state copyWith named params
      // For example if copyWith is 'void copyWith({int counter, bool enabled})'
      // you can use #counter and #enabled to mutate state
      mutator[#enabled] = !store.state.enabled;
    }));
  }
}

// Action can be class based
class MultiplyCounter extends StoreAction<ExampleStore> {
  // constructor can declare positional and optional params
  MultiplyCounter(int multiplier)
      : super(
          // closure for action should declare this params
          (store, mutator, [services]) {
            // You can use any of this api to mutate state
            // mutator[#counter] = 1
            // mutator.changes = {#counter: 1, #enabled: false};
            // mutator.merge({#counter: 1, #enabled: false});
            // mutator.set(#counter, 1);
            mutator[#counter] = store.state.counter * multiplier;
          },
        );
}
```


```dart
// main.dart

import 'package:favour_state/favour_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'store.dart';

void bootstrapStores(AppState appState) {
  // Store initialized after registration
  // when method bootstrapServices called
  // Runtime setup into state and methods
  // initState and initReactions called

  // Store can be registered using this api
  // appState.registerStore(AnotherStore());
  // appState.registerDerivedStore(
  //   (store) => SomeStore(dependency: stores<AnotherStore>())
  // )
  // when you register derived store you can get already registered stores
  appState.registerStore(ExampleStore());
}

void main() {
  runApp(ExampleApp());
}

// ignore: use_key_in_widget_constructors
class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: AppStateProvider(
          bootstrap: bootstrapStores,
          serviceProvider: GetIt.I,
          child: Builder(
            builder: (context) {
              final store = AppStateScope.store<ExampleStore>(context);
              // ignore: avoid_unnecessary_containers
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ValueListenableBuilder(
                          valueListenable: store.controllableCounter,
                          builder: (context, value, child) => Text('$value')),
                      RaisedButton(
                        onPressed: () => store.multiply(2),
                        child: const Text('Doubly'),
                      ),
                      RaisedButton(
                        onPressed: store.toggle,
                        child: const Text('Toggle'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
}
```

## Introduction

### Goals

### ToDo
- [x] core functionality 
- [x] basic tests
- [ ] more tests
- [ ] error handling
- [ ] logging
- [ ] dev tools
- [ ] improve documentation

## State

A simple **State** can be declared as follows
```dart
import 'package:favour_state/favour_state.dart';

class ExampleState extends StoreState<ExampleState> {
  @override
  ExampleState copyWith() => ExampleState();
}
```

Any state used in the store must extend or implement `StoreState<T>`
where `T` is the state type that extends or implements `StoreState`

Any state must implement the `copyWith` method. Since the state must be immutable, 
the `copyWith` method is the only way to partially change the state.

---- 

## Store

A simple **Store** can be declared as follows
```dart
import 'package:favour_state/favour_state.dart';

import 'state.dart';

class ExampleStore extends BaseStore<ExampleState> {
  @override
  void initReactions() {}

  @override
  ExampleState initState() => ExampleState();
}
```

Any Store must extend `BaseStore<T>`
where `T` is the state type that extend or implement `StoreState` and used 
with this Store.

Any Store must implement `initReactions` and `initState` methods. Method `initState` 
should return instance of state which conforms to `T`. Method initReactions could be empty.


### Internals
**Work in progress**

---- 

## Reactions
**Work in progress**

### Value Reaction
**Work in progress**

### Effect Reaction
**Work in progress**

### Internals
**Work in progress**

---- 

## Actions

### Class-based action
**Work in progress**

### Action from helper function
**Work in progress**

### Internals
**Work in progress**

---- 

## AppState
**Work in progress**

### Services provider
**Work in progress**

### Store registration
**Work in progress**

### Get store by type
**Work in progress**

### Internals
**Work in progress**

---- 

## Widgets
**Work in progress**

### AppStateProvider
**Work in progress**

### AppStateScope
**Work in progress**

### Internals
**Work in progress**

---- 

## Internals
**Work in progress**

### StoreRuntime
**Work in progress**