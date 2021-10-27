import "dart:convert";


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
      case TYPE_GAME: return Game(message);
      case TYPE_INTERCOM: return message;
    }
    return json;
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
      case FEUD: return "The Weakest";
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
    this.expired = json["expired"];
    this.state = json["state"];
  }
}
