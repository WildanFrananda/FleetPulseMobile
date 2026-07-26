sealed class Failure {
  const Failure();

  String get message;
}

class NetworkFailure extends Failure {
  const NetworkFailure();

  @override
  String get message => 'network unavailable';
}

class AuthFailure extends Failure {
  const AuthFailure();

  @override
  String get message => 'session expired';
}

class ChannelFailure extends Failure {
  const ChannelFailure(this.reason);

  final String reason;
  @override
  String get message => reason;
}

class TimeoutFailure extends Failure {
  const TimeoutFailure();

  @override
  String get message => 'request timed out';
}

class PermissionFailure extends Failure {
  const PermissionFailure([this.message = 'location permission denied']);
  @override
  final String message;
}

Failure failureFromReason(String? reason) =>
    ChannelFailure(reason ?? 'unknown');
