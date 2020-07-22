# favour\_state package

State management solution for flutter inspired by cerebraljs and property\_change\_notifier

**Documentation now in WIP status. Please look at example.**

#Example

```dart
// store.dart

import 'dart:async';

import 'package:favour_state/favour_state.dart';

import 'state.dart';

class ExampleStore extends Store<ExampleState> {
  // you can initialize your state

  Future<void> multiply(int multiplier) async {
    this(MultiplyOperation(2));
  }

  void toggle() {
    this[#enabled] = !state.enabled;
  }

  @override
  ExampleState get initialState => const ExampleState(enabled: false);
}

class MultiplyOperation extends Operation<ExampleStore> {
  final int multiplier;

  MultiplyOperation(this.multiplier);

  @override
  FutureOr<void> call(ExampleStore store) async {
    store[#counter] = 0;
    while (store.state.counter < 1000) {
      store[#counter] = store.state.counter + multiplier;
      await Future.delayed(const Duration(milliseconds: 1), () {});
    }
  }

  @override
  String get topic => 'multiply';
}

```


```dart
// state.dart

import 'package:favour_state/favour_state.dart';
import 'package:flutter/foundation.dart';

@immutable
class ExampleState implements StoreState<ExampleState> {
  final int counter;
  final bool enabled;

  const ExampleState({
    this.counter = 1,
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExampleState &&
          runtimeType == other.runtimeType &&
          counter == other.counter &&
          enabled == other.enabled;

  @override
  int get hashCode => counter.hashCode ^ enabled.hashCode;

  @override
  String toString() => 'ExampleState{counter: $counter, enabled: $enabled}';
}

```


```dart
// main.dart
import 'package:favour_state/favour_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'store.dart';

void main() {
  runApp(ExampleApp());
}

// ignore: use_key_in_widget_constructors
class ExampleApp extends StatelessWidget {
  final store = ExampleStore();

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 700,
                    child: store.listenable(
                      (context, state, child) => Visibility(
                        visible: state.enabled,
                        child: ListView.separated(
                          itemBuilder: (context, idx) => store.listenable(
                            (context, state, _) => Text('${state.counter}'),
                          ),
                          separatorBuilder: (context, idx) => const Divider(),
                          itemCount: 20,
                        ),
                      ),
                      topics: {#enabled},
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RaisedButton(
                  onPressed: () => store.multiply(2),
                  child: const Text('Increment'),
                ),
                RaisedButton(
                  onPressed: store.toggle,
                  child: const Text('Toggle'),
                ),
              ],
            ),
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
