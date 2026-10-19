import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:socket_io_client/src/manager.dart';

/// Real event registration, with only network connection establishment replaced.
class HintSocket extends io.Socket {
  HintSocket()
      : super(
            Manager(
                uri: 'https://example.test', options: {'autoConnect': false}),
            '/',
            {});
  final callbacks = <String, dynamic Function(dynamic)>{};
  @override
  void on(String event, dynamic Function(dynamic) handler) {
    callbacks[event] = handler;
    super.on(event, handler);
  }

  @override
  io.Socket connect() => this;

  void receive(String event, dynamic data) => callbacks[event]!(data);
}
