import "dart:convert";

import 'feud.dart';
import 'jeopardy.dart';
import 'weakest.dart';


class WsMessage {
  static const TYPE_GAME = "game";
  static const TYPE_INTERCOM = "intercom";

  late final String type;
  late final dynamic message;

  WsMessage(Map<String, dynamic> json) {
    this.type = json["type"];
    this.message = _messageFrom(type, json["message"]);
  }

  static dynamic _messageFrom(String type, dynamic message) {
    switch (type) {
      case TYPE_GAME: return Game.createGameModel(message);
      case TYPE_INTERCOM: return message;
    }
    return json;
  }
}

class Player {
  late final int id;
  late final String name;

  Player(Map<String, dynamic> json) {
    this.id = json["id"];
    this.name = json["name"];
  }
}

class Game {
  static const FEUD = "feud";
  static const JEOPARDY = "jeopardy";
  static const WEAKEST = "weakest";

  static List<String> get names => [FEUD, JEOPARDY, WEAKEST];

  static String fullName(String name) {
    switch(name) {
      case FEUD: return "Friends feud";
      case JEOPARDY: return "Jeopardy";
      case WEAKEST: return "The Weakest";
      default: return "Unknown";
    }
  }

  late final String token;
  late final String name;
  late final DateTime expired;
  late final String state;

  Game(Map<String, dynamic> json) {
    this.token = json["token"];
    this.name = json["name"];
    this.expired = DateTime.parse(json["expired"]);
    this.state = json["state"];
  }

  static Game createGameModel(Map<String, dynamic> json) {
    switch(json["name"]) {
      case Game.FEUD: return FeudGame(json);
      case Game.JEOPARDY: return JeopardyGame(json);
      case Game.WEAKEST: return WeakestGame(json);
      default: return Game(json);
    }
  }
}
