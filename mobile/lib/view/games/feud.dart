import 'package:flutter/material.dart';
import 'package:mobile/model/games/common.dart';
import 'package:mobile/model/games/feud.dart';
import 'package:mobile/services/login.dart';
import 'package:mobile/services/websocket.dart';

import 'common.dart';

class FeudGamePage extends GamePage {
  final FeudGame game;

  const FeudGamePage(this.game, WebSocketController wsController)
      : super(game: game, wsController: wsController);

  void onButtonClick() {
    this.wsController.send(
        "button_click",
        {
          "player_id": LoginService().getLoginData()?.playerId
        }
    );
  }

  Widget _drawGameState() {
    switch (this.game.state) {
      case FeudGame.STATE_WAITING_FOR_PLAYERS:
        return Center(
          child: Icon(Icons.pending_rounded, size: 80),
        );
      case FeudGame.STATE_ROUND:
      case FeudGame.STATE_BUTTON:
        return Center(
          child: ButtonWidget(
              onPressed: onButtonClick,
              disabled: this.game.answerer != null
          ),
        );
      case FeudGame.STATE_END:
        Center(
          child: IconButton(
            icon: Icon(Icons.exit_to_app, size: 80),
            onPressed: () {
              LoginService().logout();
            }
          ),
        );
    }
    return Center(
      child: Icon(Icons.monitor, size: 80),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Game.fullName(this.game.name)),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.account_box),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
          ),
        ],
      ),
      drawer: MainDrawer(),
      endDrawer: PlayersDrawer(players: this.game.players),
      body: _drawGameState(),
    );
  }
}
