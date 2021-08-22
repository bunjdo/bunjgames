import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class WsMessage {
  final String type;
  final dynamic message;

  WsMessage({
    required this.type,
    required this.message,
  });

  static dynamic _messageFrom(String type, dynamic message) {
    switch (type) {
      case 'game': return Game.fromJson(message);
      case 'intercom': return message;
    }
    return json;
  }

  factory WsMessage.fromJson(Map<String, dynamic> json) {
    final String type = json['type'];
    return WsMessage(
      type: type,
      message: _messageFrom(type, json['message']),
    );
  }
}


class Game {
  final String token;

  Game({
    required this.token,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      token: json['token'],
    );
  }
}


class LoginResponse {
  final int playerId;
  final Game game;

  LoginResponse({
    required this.playerId,
    required this.game,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json, String game) {
    return LoginResponse(
      playerId: json[game == 'feud' ? 'team_id' : 'player_id'],
      game: Game.fromJson(json['game']),
    );
  }
}


class LoginData {
  final String game;
  final int playerId;
  final String name;
  final String token;

  LoginData({
    required this.game,
    required this.playerId,
    required this.name,
    required this.token,
  });

  @override bool operator ==(Object other) {
    if (other is LoginData) {
      LoginData _other = other;
      return this.game == _other.game
          && this.playerId == _other.playerId
          && this.name == _other.name
          && this.token == _other.token;
    }
    return false;
  }

  @override int get hashCode => this.game.hashCode
      + this.playerId.hashCode
      + this.name.hashCode
      + this.token.hashCode;

  @override String toString() {
    return 'game: $game, playerId: $playerId, name: $name, token: $token';
  }

  static Future<LoginData?> fromSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('game') == null) {
      return null;
    }
    return LoginData(
        game: prefs.getString('game')!,
        playerId: prefs.getInt('playerId')!,
        name: prefs.getString('name')!,
        token: prefs.getString('token')!
    );
  }

}
