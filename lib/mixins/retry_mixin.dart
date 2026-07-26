import 'package:fleet_pulse_mobile/core/core.dart';

mixin RetryMixin {
  Future<Result<T>> retry<T>(
    Future<Result<T>> Function() action, {
    int maxAttempts = 6,
    Duration initialDelay = const Duration(seconds: 1),
    Duration maxDelay = const Duration(seconds: 15),
    bool Function(Failure failure)? retryIf,
  }) async {
    Duration delay = initialDelay;
    Result<T> result = await action();

    for (int attempt = 1; attempt < maxAttempts; attempt++) {
      if (result case Ok<T>()) {
        return result;
      }

      final Failure failure = (result as Err<T>).failure;
      final bool again = retryIf?.call(failure) ?? _transient(failure);

      if (!again) {
        return result;
      }

      await Future<void>.delayed(delay);

      final Duration next = delay * 2;
      delay = next > maxDelay ? maxDelay : next;
      result = await action();
    }

    return result;
  }

  bool _transient(Failure f) => f is NetworkFailure || f is TimeoutFailure;
}
