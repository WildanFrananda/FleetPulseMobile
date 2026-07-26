abstract interface class ChannelSocket {
  Stream<dynamic> get stream;
  void add(String data);
  Future<void> get ready;
  Future<void> close();
}
