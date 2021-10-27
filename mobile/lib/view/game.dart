import 'package:flutter/material.dart';
import 'package:mobile/model/login.dart';
import 'package:mobile/model/games/common.dart';
import 'package:mobile/services/login.dart';
import 'package:mobile/services/websocket.dart';
import 'package:mobile/styles.dart';
import 'loading.dart';


class WebSocketWrapper extends StatefulWidget {
  final LoginData loginData;
  final VoidCallback onLogout;

  const WebSocketWrapper({required this.loginData, required this.onLogout});

  @override
  WebSocketWrapperState createState() => WebSocketWrapperState();
}

class WebSocketWrapperState extends State<WebSocketWrapper> {
  late final LoginData loginData;
  late final WebSocketController controller;

  @override
  void initState() {
    super.initState();
    this.loginData = widget.loginData;
    this.controller = WebSocketController(loginData.game, loginData.token, () async {
        await LoginService().logout();
        widget.onLogout();
    });
    this.controller.getStream().forEach((message) {
      if (message.type == 'game') {
        this.onGame(message.message);
      }
    });
  }

  void onGame(Game game) {
    setState(() {
      this.game = game;
    });
  }

  Game? game;

  @override
  Widget build(BuildContext context) {
    return this.game == null ? LoadingPage() : GamePage(game: this.game!);
  }

}


class GamePage extends StatefulWidget {
  final Game game;

  const GamePage({required this.game});

  @override
  GamePageState createState() => GamePageState();
}


class GamePageState extends State<GamePage> {

  String title = "Bunjgames";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(this.title)),
      drawer: GameDrawer(),
      body: Center(
        child: Button(),
      ),
    );
  }
}


class GameDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: baseBackground,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: baseBackgroundDark,
              ),
              child: Text('Title'),
            ),
            ListTile(
              title: Text('Item 1'),
            ),
            ListTile(
              title: Text('Item 2'),
            ),
          ],
        ),
      ),
    );
  }
}


class Button extends StatelessWidget {

  final VoidCallback onPressed = () {};
  final String text = "";

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: double.infinity,
        minHeight: double.infinity,
      ),
      child: new Container(
        margin: EdgeInsets.all(24),
        child: RawMaterialButton(
          elevation: 2.0,
          fillColor: buttonColorRed,
          padding: EdgeInsets.all(16),
          shape: CircleBorder(),
          onPressed: this.onPressed,
          child: Text(this.text),
        ),
      ),
    );
  }
}
