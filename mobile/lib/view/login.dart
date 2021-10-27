import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/model/games/common.dart';
import 'package:mobile/model/login.dart';
import 'package:mobile/services/login.dart';
import 'game.dart';
import 'misc.dart';


class LoginWrapperPage extends StatefulWidget {
  @override
  LoginWrapperPageState createState() => LoginWrapperPageState();
}

class LoginWrapperPageState extends State<LoginWrapperPage> {
  LoginData? loginData;

  @override
  void initState() {
    super.initState();
    LoginService().getLoginData().then((value) => setState(() {
      this.loginData = loginData;
    }));
  }

  @override
  Widget build(BuildContext context) {
    if (this.loginData == null) {
      return LoginPage(onLogin: (LoginData loginData) {
        setState(() {
          this.loginData = loginData;
        });
      });
    } else {
      return WebSocketWrapper(
        loginData: this.loginData!,
        onLogout: () {
          setState(() {
            this.loginData = null;
          });
        },
      );
    }
  }
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

  var selectedGame = Game.FEUD;
  final games = {
    for (var name in Game.names) name: Game.fullName(name)
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
                    selectedGame = value ?? Game.FEUD;
                  });
                },
              ),
              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
                inputFormatters: [
                  UpperCaseTextFormatter(),
                ],
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
                inputFormatters: [
                  UpperCaseTextFormatter(),
                ],
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
                        var loginData = await LoginService().login(
                          selectedGame, name, token,
                        );
                        widget.onLogin(loginData);
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
