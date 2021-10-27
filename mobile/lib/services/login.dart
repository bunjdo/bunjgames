import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:mobile/model/login.dart';
import 'settings.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginException implements Exception {
  LoginException(this.message);

  final String message;

  @override
  String toString() {
    return message;
  }
}


typedef LoginCallback = void Function(LoginData loginData);


class LoginService {

  static final LoginService _singleton = LoginService._internal();

  factory LoginService() {
    return _singleton;
  }

  LoginService._internal();

  SharedPreferences? _sharedPreferences;
  LoginData? _loginData;

  Future<SharedPreferences> _getSharedPreferences() async {
    if (this._sharedPreferences == null) {
      this._sharedPreferences = await SharedPreferences.getInstance();
    }
    return this._sharedPreferences!;
  }

  Future<LoginData?> getLoginData() async {
    var sharedPreferences = await this._getSharedPreferences();
    if (this._loginData == null) {
      log('Retrieving LoginData from Shared Prefs');
      if (sharedPreferences.getString('game') == null) {
        this._loginData = null;
      } else {
        this._loginData = LoginData(
            game: sharedPreferences.getString('game')!,
            playerId: sharedPreferences.getInt('playerId')!,
            name: sharedPreferences.getString('name')!,
            token: sharedPreferences.getString('token')!
        );
      }
    }
    log('Using LoginData: ${this._loginData.toString()}');
    return this._loginData;
  }

  Future<void> _setLoginData(LoginData? loginData) async {
    var sharedPreferences = await this._getSharedPreferences();
    if (_loginData == null) {
      await sharedPreferences.remove('game');
      await sharedPreferences.remove('playerId');
      await sharedPreferences.remove('name');
      await sharedPreferences.remove('token');
    } else {
      loginData!;
      sharedPreferences.setString('game', loginData.game);
      sharedPreferences.setInt('playerId', loginData.playerId);
      sharedPreferences.setString('name', loginData.name);
      sharedPreferences.setString('token', loginData.token);
    }
    this._loginData = loginData;
  }

  Future<LoginData> login(String game, String name, String token) async {
    final url = '$API_URL/$game/v1/players/register';
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'token': token,
      }),
    );
    if (response.statusCode == 200) {
      var loginResponse = LoginResponse(jsonDecode(response.body));
      var loginData = LoginData(
        game: game,
        playerId: loginResponse.playerId,
        name: name,
        token: token,
      );
      await this._setLoginData(loginData);
      return loginData;
    } else {
      try {
        var responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        throw LoginException(responseJson['detail']);
      } catch (exception) {
        throw LoginException('Error while login in');
      }
    }
  }

  Future<void> logout() async {
    await this._setLoginData(null);
  }

}