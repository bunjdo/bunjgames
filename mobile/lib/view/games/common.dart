import 'package:flutter/material.dart';
import 'package:mobile/model/games/feud.dart';
import 'package:mobile/model/games/jeopardy.dart';
import 'package:mobile/model/games/weakest.dart';
import 'package:mobile/model/login.dart';
import 'package:mobile/model/games/common.dart';
import 'package:mobile/services/login.dart';
import 'package:mobile/services/websocket.dart';
import 'package:mobile/styles.dart';
import 'package:mobile/view/loading.dart';
import 'package:mobile/view/settings.dart';

import 'feud.dart';


class WebSocketWrapper extends StatefulWidget {
  final LoginData loginData;

  const WebSocketWrapper({required this.loginData});

  @override
  WebSocketWrapperState createState() => WebSocketWrapperState();
}

class WebSocketWrapperState extends State<WebSocketWrapper> {
  late final LoginData loginData;
  late final WebSocketController wsController;

  @override
  void initState() {
    super.initState();
    this.loginData = widget.loginData;
    this.wsController = WebSocketController(loginData.game, loginData.token, () async {
        await LoginService().logout();
    });
    this.wsController.getStream().forEach((message) {
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
    return this.game == null
        ? LoadingPage() : GamePage.createGamePage(this.game!, wsController);
  }

}


abstract class GamePage extends StatelessWidget {
  final Game game;
  final WebSocketController wsController;

  const GamePage({required this.game, required this.wsController});

  static createGamePage(Game game, WebSocketController wsController) {
    switch(game.name) {
      case Game.FEUD: return FeudGamePage(game as FeudGame, wsController);
      case Game.JEOPARDY: return null;
      case Game.WEAKEST: return null;
      default: return NotImplementedGamePage(game, wsController);
    }
  }
}


class NotImplementedGamePage extends GamePage {

  const NotImplementedGamePage(Game game, WebSocketController wsController)
      : super(game: game, wsController: wsController);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(this.game.name)),
      drawer: GameDrawer(game: this.game),
      body: Center(
        child: Text('This game is not implemented yet. Try to update this application.'),
      ),
    );
  }
}


class GameDrawer extends StatelessWidget {
  final Game game;
  const GameDrawer({required this.game});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: baseBackground,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: Scaffold.of(context).appBarMaxHeight,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: baseBackgroundDark,
                ),
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    Padding(padding: EdgeInsets.all(5)),
                    Text("BUNJGAMES"),
                  ],
                ),
              ),
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
            ListTile(
              title: Text('Exit'),
              onTap: () async {
                await LoginService().logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PlayersDrawer extends StatelessWidget {
  final List<Player> players;
  const PlayersDrawer({required this.players});

  Widget drawPlayer(Player player) {
    switch (player.runtimeType) {
      case FeudPlayer: return Row(children: [
        Text(player.name),
        Text((player as FeudPlayer).score.toString())
      ], mainAxisAlignment: MainAxisAlignment.spaceBetween);
      case JeopardyPlayer: return Row(children: [
        Text(player.name),
        Text((player as JeopardyPlayer).balance.toString())
      ], mainAxisAlignment: MainAxisAlignment.spaceBetween);
      case WeakestPlayer: return Text(player.name);
    }
    return Text(player.name);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: baseBackground,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: Scaffold.of(context).appBarMaxHeight,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: baseBackgroundDark,
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_box),
                    Padding(padding: EdgeInsets.all(5)),
                    Text(LoginService().getLoginData()?.name ?? ''),
                  ],
                )
              ),
            ),
            for (var player in players) ListTile(title: drawPlayer(player))
          ],
        ),
      ),
    );
  }
}

class ButtonWidget extends StatelessWidget {

  final VoidCallback onPressed;
  final String text;
  final bool disabled;

  ButtonWidget({this.text = "", required this.onPressed, required this.disabled});

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
          fillColor: (this.disabled) ? buttonColorGray: buttonColorRed,
          padding: EdgeInsets.all(16),
          shape: CircleBorder(),
          onPressed: this.onPressed,
          child: Text(this.text),
        ),
      ),
    );
  }
}
