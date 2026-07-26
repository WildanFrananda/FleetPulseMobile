import 'package:fleet_pulse_mobile/services/channel/channel_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsChannelSocket implements ChannelSocket {
  WsChannelSocket(this._channel);

  final WebSocketChannel _channel;

  @override
  Future<void> get ready => _channel.ready;

  @override
  Stream<dynamic> get stream => _channel.stream;

  @override
  void add(String data) => _channel.sink.add(data);

  @override
  Future<void> close() => _channel.sink.close();
}
