import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:developer';
import 'dart:convert';

import 'game.dart';
import 'loading.dart';
import 'login.dart';
import 'styles.dart';


void main() => runApp(
  MaterialApp(
    title: 'Bunjgames',
    theme: appTheme,
    home: LoginDataWrapper(),
  ),
);


class LoginDataWrapper extends StatefulWidget {
  @override
  LoginDataWrapperState createState() => LoginDataWrapperState();
}

class LoginDataWrapperState extends State<LoginDataWrapper> {
  LoginData? loginData;

  void checkSharedPrefs(BuildContext context) async {
    log('Retrieving LoginData from Shared Prefs');
    LoginData? loginData = await LoginData.fromSharedPrefs();
    if (this.loginData != loginData) {
      log('New LoginData retrieved: ${loginData.toString()}');
      setState(() {
        this.loginData = loginData;
      });
    } else {
      log('Using existing LoginData: ${this.loginData.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    checkSharedPrefs(context);

    if (this.loginData == null) {
      return LoginPage(onLogin: (LoginData loginData) {
        setState(() {
          this.loginData = loginData;
        });
      });
    } else {
      return Main(
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


class Main extends StatefulWidget {
  final LoginData loginData;
  final VoidCallback onLogout;

  const Main({required this.loginData, required this.onLogout});

  @override
  MainState createState() => MainState();
}

class MainState extends State<Main> {
  Game? game;

  @override
  Widget build(BuildContext context) {
    log(widget.loginData.toString());
    log('wss://api.games.bunj.app/${widget.loginData.game}/ws/${widget.loginData.token}');
    final channel = WebSocketChannel.connect(
      Uri.parse(
        'wss://api.games.bunj.app/${widget.loginData.game}/ws/${widget.loginData.token}'
      ),
    );
    channel.stream.listen(
      (event) {
        log('WS EVENT: ${event?.toString() ?? ''}');
        WsMessage message = WsMessage.fromJson(jsonDecode(event));
        if (message.type == 'game') {
          setState(() {
            this.game = message.message;
          });
        }
      },
      onError: (exception) {
        log('WS ERROR: ${exception.toString()}');
      },
      onDone: () async {
        log('WS CLOSED');
        await logout();
        widget.onLogout();
      },
    );
    return this.game == null ? LoadingPage() : GamePage();
  }

}
