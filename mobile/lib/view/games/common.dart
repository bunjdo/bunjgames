import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/model/games/feud.dart';
import 'package:mobile/model/games/jeopardy.dart';
import 'package:mobile/model/games/weakest.dart';
import 'package:mobile/model/login.dart';
import 'package:mobile/model/games/common.dart';
import 'package:mobile/services/login.dart';
import 'package:mobile/services/settings.dart';
import 'package:mobile/services/websocket.dart';
import 'package:mobile/styles.dart';
import 'package:mobile/view/games/weakest.dart';
import 'package:mobile/view/loading.dart';
import 'package:mobile/view/settings.dart';
import 'package:url_launcher/url_launcher.dart';

import 'feud.dart';
import 'jeopardy.dart';


class GameWrapper extends StatefulWidget {
  final LoginData loginData;

  const GameWrapper({required this.loginData});

  @override
  GameWrapperState createState() => GameWrapperState();
}

class GameWrapperState extends State<GameWrapper> {
  Game? game;
  WebSocketController? wsController;
  StreamSubscription<WsMessage>? subscription;

  @override
  void initState() {
    super.initState();
    SettingsService.getInstance().then((settings) {
      this.wsController = WebSocketController(
          widget.loginData.game,
          widget.loginData.token,
              () async => await LoginService().logout(),
          settings
      );
      subscription = this.wsController?.getStream().listen((message) {
        switch (message.type) {
          case WsMessage.TYPE_GAME:
            setState(() {
              this.game = message.message;
            });
            break;
          case WsMessage.TYPE_ERROR:
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message.message.toString()))
            );
        }
      });
    });
  }

  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return this.game == null || wsController == null
        ? LoadingPage() : this._buildGamePage();
  }

  Widget _buildGamePage() {
    switch(game!.name) {
      case Game.FEUD: return FeudGamePage(game as FeudGame, wsController!);
      case Game.JEOPARDY: return JeopardyGamePage(game as JeopardyGame, wsController!);
      case Game.WEAKEST: return WeakestGamePage(game as WeakestGame, wsController!);
      default: return NotImplementedGamePage(game!, wsController!);
    }
  }
}


abstract class GamePage extends StatelessWidget {
  final Game game;
  final WebSocketController wsController;

  const GamePage({required this.game, required this.wsController});
}


class NotImplementedGamePage extends GamePage {

  const NotImplementedGamePage(Game game, WebSocketController wsController)
      : super(game: game, wsController: wsController);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(this.game.name)),
      drawer: MainDrawer(),
      body: Center(
        child: Text('This game is not implemented yet. Try to update this application.'),
      ),
    );
  }
}


class MainDrawer extends StatelessWidget {
  const MainDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              child: DrawerHeader(
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
              title: Text('Main site'),
              onTap: () async {
                const url = 'https://games.bunj.app';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
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
            LoginService().getLoginData() != null ? ListTile(
              title: Text('Exit'),
              onTap: () async {
                await LoginService().logout();
              },
            ) : ListTile(),
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
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              child: DrawerHeader(
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
          child: Text(this.text, style: TextStyle(color: buttonTextColor, fontSize: 80),),
        ),
      ),
    );
  }
}
