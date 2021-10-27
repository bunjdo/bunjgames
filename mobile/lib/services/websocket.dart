import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:mobile/model/games/common.dart';
import 'settings.dart';

class WebSocketController {

  StreamController<WsMessage> _streamController = new StreamController.broadcast(sync: true);
  final VoidCallback _onError;
  late final String _url;
  late WebSocket _channel;

  WebSocketController(String game, String token, this._onError) {
    this._url = '$WS_URL/$game/ws/$token';
    this._init();
  }

  _init() async {
    print("WS CONNECTING...");
    try {
      this._channel = await WebSocket.connect(this._url);
      print("WS CONNECTED");
    } catch  (e) {
      print("WS CONNECTION ERROR");
      this._onError();
    }

    this._channel.done.then((dynamic _) => this._init());

    this._channel.listen((payload) {
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

  Stream<WsMessage> getStream() {
    return this._streamController.stream;
  }

  close() async {
    await this._channel.close();
  }

}
