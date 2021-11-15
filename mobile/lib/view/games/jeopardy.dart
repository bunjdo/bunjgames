import 'package:flutter/material.dart';
import 'package:mobile/model/games/common.dart';
import 'package:mobile/model/games/jeopardy.dart';
import 'package:mobile/services/login.dart';
import 'package:mobile/services/websocket.dart';
import 'package:mobile/view/misc.dart';

import 'common.dart';


class JeopardyGamePage extends GamePage {
  final JeopardyGame game;

  const JeopardyGamePage(this.game, WebSocketController wsController)
      : super(game: game, wsController: wsController);

  void onButtonClick() {
    this.wsController.send(
        "button_click",
        {
          "player_id": LoginService().getLoginData()?.playerId
        }
    );
  }

  Widget _finalBetsForm() {
    return SingleFieldForm(
      label: "Place your bet",
      type: SingleFieldFormType.UNSIGNED_INT,
      callback: (value) {
        this.wsController.send(
            "final_bet",
            {
              "player_id": LoginService().getLoginData()?.playerId,
              "bet": int.parse(value)
            }
        );
      },
    );
  }

  Widget _finalAnswerForm() {
    return SingleFieldForm(
      label: "Answer",
      type: SingleFieldFormType.TEXT,
      callback: (value) {
        this.wsController.send(
            "final_answer",
            {
              "player_id": LoginService().getLoginData()?.playerId,
              "answer": value
            }
        );
      },
    );
  }

  Widget _drawGameState() {
    var currentPlayer = this.game.players.where(
            (player) => player.id == LoginService().getLoginData()?.playerId
    ).first;
    switch (this.game.state) {
      case JeopardyGame.STATE_WAITING_FOR_PLAYERS:
        return Center(
          child: Icon(Icons.pending_rounded, size: 80),
        );
      case JeopardyGame.STATE_QUESTION:
      case JeopardyGame.STATE_ANSWER:
        return Center(
          child: ButtonWidget(
              onPressed: onButtonClick,
              disabled: this.game.state != JeopardyGame.STATE_ANSWER || this.game.answerer != null
          ),
        );
      case JeopardyGame.STATE_FINAL_BETS:
        if (currentPlayer.finalBet == 0) {
          return this._finalBetsForm();
        }
        break;
      case JeopardyGame.STATE_FINAL_ANSWER:
        if (currentPlayer.finalAnswer.isEmpty) {
          return this._finalAnswerForm();
        }
        break;
      case JeopardyGame.STATE_GAME_END:
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
      endDrawer: PlayersDrawer(players: this.game.players),
      body: _drawGameState(),
    );
  }
}
