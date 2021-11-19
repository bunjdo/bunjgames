import 'package:flutter/material.dart';
import 'package:mobile/model/games/common.dart';
import 'package:mobile/model/login.dart';
import 'package:mobile/services/login.dart';
import 'games/common.dart';
import 'misc.dart';


class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  LoginData? loginData;

  @override
  void initState() {
    super.initState();
    LoginService().getStream().forEach((loginData) {
      setState(() {
        this.loginData = loginData;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (this.loginData == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Bunjgames')),
        drawer: MainDrawer(),
        body: Container(
          margin: EdgeInsets.all(16),
          child: LoginForm(),
        ),
      );
    } else {
      return GameWrapper(
        loginData: this.loginData!,
      );
    }
  }
}


class LoginForm extends StatefulWidget {
  LoginForm();

  @override
  LoginFormState createState() => LoginFormState();
}


class LoginFormState extends State<LoginForm> {

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
    return Form(
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
                    await LoginService().login(
                      selectedGame, name, token,
                    );
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
    );
  }
}
