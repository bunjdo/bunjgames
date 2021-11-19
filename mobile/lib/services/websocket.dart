import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:mobile/model/games/common.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'settings.dart';

class WebSocketController {

  StreamController<WsMessage> _streamController = new StreamController.broadcast(sync: true);
  final VoidCallback _onError;
  late final String _url;
  WebSocketChannel? _channel;
  final SettingsService settings;

  WebSocketController(String game, String token, this._onError, this.settings) {
    var wsUrl = this.settings.getString(SettingsType.WS_URL);
    this._url = '$wsUrl/$game/ws/$token';
    this._init();
  }

  _init() {
    print("WS CONNECTING...");
    try {
      this._channel = WebSocketChannel.connect(Uri.parse(this._url));
      print("WS CONNECTED");
    } catch  (e) {
      print("WS CONNECTION ERROR");
      this._onError();
    }

    this._channel!.stream.listen((payload) {
      WsMessage message = WsMessage(jsonDecode(payload));
      _streamController.add(message);
    }, onDone: () {
      print("WS DISCONNECTED");
      this._init();
    }, onError: (e) {
      print('WS ERROR: $e');
      this._onError();
    });

  }

  void send(String method, Map<String, dynamic> params) {
    this._channel?.sink.add(jsonEncode({
      "method": method,
      "params": params
    }));
  }

  Stream<WsMessage> getStream() {
    return this._streamController.stream;
  }

  close() async {
    await this._channel?.sink.close();
    await this._streamController.close();
  }

}
