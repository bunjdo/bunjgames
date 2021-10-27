import 'games/common.dart';


class LoginResponse {
  late final int playerId;
  late final Game game;

  LoginResponse(Map<String, dynamic> json) {
    this.playerId = json['player_id'];
    this.game = Game(json['game']);
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

}
