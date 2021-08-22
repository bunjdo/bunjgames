import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'entities.dart';
import 'settings.dart';


class LoginException implements Exception {
  LoginException(this.message);

  final String message;

  @override
  String toString() {
    return message;
  }
}


typedef LoginCallback = void Function(LoginData loginData);


Future<LoginResponse> login(String game, String name, String token) async {
  final url = '$API_URL/$game/v1/${game == 'feud' ? 'teams' : 'players'}/register';
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
    LoginResponse loginResponse = LoginResponse.fromJson(jsonDecode(response.body), game);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('game', game);
    prefs.setInt('playerId', loginResponse.playerId);
    prefs.setString('name', name);
    prefs.setString('token', token);
    return loginResponse;
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
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('game');
  await prefs.remove('playerId');
  await prefs.remove('name');
  await prefs.remove('token');
}


class LoginPage extends StatefulWidget {
  final LoginCallback onLogin;

  LoginPage({required this.onLogin});

  @override
  LoginPageState createState() => LoginPageState();
}


class LoginPageState extends State<LoginPage> {

  String title = 'Bunjgames';
  final String validationError = 'This field cannot be empty';
  final formKey = GlobalKey<FormState>();

  String selectedGame = 'feud';
  final games =  {
    'feud': 'Friends feud',
    'jeopardy': 'Jeopardy',
    'weakest': 'The Weakest',
    'whirligig': 'Whirligig'
  };

  final nameController = TextEditingController();
  final tokenController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(this.title)),
      body: Container(
        margin: EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              DropdownButton(
                value: selectedGame,
                icon: Icon(Icons.keyboard_arrow_down),
                items: games.entries.map((entry) {
                  return DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value)
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedGame = value ?? 'feud';
                  });
                },
              ),
              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return validationError;
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: tokenController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Token',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return validationError;
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        final name = nameController.text.toUpperCase().trim();
                        final token = tokenController.text.toUpperCase().trim();
                        LoginResponse loginResponse = await login(
                          selectedGame, name, token,
                        );
                        widget.onLogin(LoginData(
                            game: selectedGame,
                            playerId: loginResponse.playerId,
                            name: name,
                            token: token,
                        ));
                      } on LoginException catch (exception) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(exception.toString()))
                        );
                      }
                    }
                  },
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}