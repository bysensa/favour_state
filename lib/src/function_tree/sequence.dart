import 'dart:async';

import 'package:async/async.dart';

import '../store_state.dart';
import 'change_set.dart';
import 'context.dart';
import 'definitions.dart';

Future<void> runSequence<S extends StoreState<S>>(
  Context<S> ctx,
  Iterable<StoreAction<S>> sequence, {
  String sequenceName,
}) async {
//  TODO(sensa): notify about run sequence if sequenceName provided
  var currentCtx = ctx;
  for (final action in sequence) {
    final actionCallResult = await _runAction(currentCtx, action);
    if (actionCallResult.isValue) {
      currentCtx = actionCallResult.asValue.value;
    }
    // TODO (sensa): handle sequence execution error
  }
}

Future<Result<Context<S>>> _runAction<S extends StoreState<S>>(
  Context<S> ctx,
  StoreAction<S> action,
) async {
  assert(action != null, 'action is null');

  final actionCallResult = Result<dynamic>(
    () => Function.apply(
      action,
      <dynamic>[ctx.store, ctx.payload],
      null,
    ),
  );

  if (actionCallResult.isError) {
    return Result.error(
      actionCallResult.asError.error,
      actionCallResult.asError.stackTrace,
    );
  }

  final dynamic resultValue = actionCallResult.asValue.value;

  if (resultValue is FutureOr<ChangeSet>) {
    return Result.capture(_resolveActionResult(ctx, resultValue));
  }

  throw StateError('Action result has invalid type');
}

Future<Context<S>> _resolveActionResult<S extends StoreState<S>>(
  Context<S> ctx,
  FutureOr<ChangeSet> result,
) async =>
    ctx.merge(await result);
