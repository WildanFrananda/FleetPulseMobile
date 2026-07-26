class ChannelEvent {
  const ChannelEvent(this.event, this.payload);

  final String event;
  final Map<String, dynamic> payload;
}

class ChannelReply {
  const ChannelReply(this.status, this.response);

  final String status;
  final Map<String, dynamic> response;

  bool get isOk => status == 'ok';

  String? get reason => response['reason'] as String?;
}

class ChannelException implements Exception {
  const ChannelException(this.message);

  final String message;

  @override
  String toString() => 'ChannelException: $message';
}
