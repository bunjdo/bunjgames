import 'package:flutter/material.dart';
import 'package:mobile/model/games/common.dart';
import 'package:mobile/model/games/weakest.dart';
import 'package:mobile/services/login.dart';
import 'package:mobile/services/websocket.dart';

import 'common.dart';


class WeakestGamePage extends GamePage {
  final WeakestGame game;
  late final List<WeakestPlayer> players;

  WeakestGamePage(this.game, WebSocketController wsController)
      : super(game: game, wsController: wsController) {
    this.players = this.game.players.where((player) => !player.isWeak).toList();
  }

  void onButtonClick() {
    if (this.game.answerer != null && this.game.answerer == LoginService().getLoginData()?.playerId) {
      this.wsController.send(
          "button_click",
          {
            "player_id": LoginService().getLoginData()?.playerId
          }
      );
    }
  }

  void onWeakestChoose(Player weakest) {
    this.wsController.send(
        "select_weakest",
        {
          "player_id": LoginService().getLoginData()?.playerId,
          "weakest_id": weakest.id
        }
    );
  }

  Widget _drawWeakestChooseList() {
    var currentPlayer = this.game.players.where(
            (player) => player.id == LoginService().getLoginData()?.playerId
    ).first;
    WeakestPlayer? selectedPlayer;
    try {
      selectedPlayer = this.game.players.where(
              (player) => player.id == currentPlayer.weak
      ).first;
    } on StateError {
      selectedPlayer = null;
    }

    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: Text("Choose the weakest player:"),
              padding: EdgeInsets.only(top: 16, bottom: 8),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: this.players.length,
              itemBuilder: (context, index) {
                final item = this.players[index];
                return (selectedPlayer == null) ? ListTile(
                  title: Text(item.name),
                  leading: Icon(Icons.account_box),
                  enabled: LoginService().getLoginData()?.playerId != item.id,
                  onTap: () => this.onWeakestChoose(item),
                ) : ListTile(
                  title: Text(item.name),
                  leading: Icon(Icons.account_box),
                  enabled: selectedPlayer.id == item.id,
                );
              },
            )
          ],
        ),
      )
    );
  }

  Widget _drawGameState() {
    switch (this.game.state) {
      case WeakestGame.STATE_WAITING_FOR_PLAYERS:
        return Center(
          child: Icon(Icons.pending_rounded, size: 80),
        );
      case WeakestGame.STATE_QUESTIONS:
        return Center(
          child: ButtonWidget(
            onPressed: onButtonClick,
            disabled: this.game.answerer != null,
            text: this.game.bank.toString(),
          ),
        );
      case WeakestGame.STATE_WEAKEST_CHOOSE:
        return this._drawWeakestChooseList();
      case WeakestGame.STATE_END:
        return Center(
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
      endDrawer: PlayersDrawer(players: this.players),
      body: _drawGameState(),
    );
  }
}
