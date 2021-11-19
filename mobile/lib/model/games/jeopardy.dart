import "common.dart";


class JeopardyQuestion {
  static const TYPE_STANDARD = "standard";
  static const TYPE_AUCTION = "auction";
  static const TYPE_BAG_CAT = "bagcat";

  late final int id;
  late final String customTheme;

  late final String text;
  late final String? image;
  late final String? audio;
  late final String? video;

  late final String? answerText;
  late final String? answerImage;
  late final String? answerAudio;
  late final String? answerVideo;

  late final int value;
  late final String answer;
  late final String comment;
  late final String type;
  late final bool isProcessed;

  JeopardyQuestion(Map<String, dynamic> json) {
    this.id = json["id"];
    this.customTheme = json["custom_theme"];

    this.text = json["text"];
    this.image = json["image"];
    this.audio = json["audio"];
    this.video = json["video"];

    this.answerText = json["answer_text"];
    this.answerImage = json["answer_image"];
    this.answerAudio = json["answer_audio"];
    this.answerVideo = json["answer_video"];

    this.value = json["value"];
    this.answer = json["answer"];
    this.comment = json["comment"];
    this.type = json["type"];
    this.isProcessed = json["is_processed"];
  }
}


class JeopardyTheme {
  late final int id;
  late final String name;
  late final bool isRemoved;
  late final List<JeopardyQuestion> questions;

  JeopardyTheme(Map<String, dynamic> json) {
    this.id = json["id"];
    this.name = json["name"];
    this.isRemoved = json["is_removed"];
    this.questions = [for (var value in json["questions"]) JeopardyQuestion(value)];
  }
}


class JeopardyPlayer extends Player {
  late final int balance;
  late final int finalBet;
  late final String finalAnswer;

  JeopardyPlayer(Map<String, dynamic> json): super(json) {
    this.balance = json["balance"];
    this.finalBet = json["final_bet"];
    this.finalAnswer = json["final_answer"];
  }
}


class JeopardyGame extends Game {
  static const STATE_WAITING_FOR_PLAYERS = "waiting_for_players";
  static const STATE_INTRO = "intro";
  static const STATE_THEMES_ALL = "themes_all";
  static const STATE_ROUND = "round";
  static const STATE_ROUND_THEMES = "round_themes";
  static const STATE_QUESTIONS = "questions";
  static const STATE_QUESTION_EVENT = "question_event";
  static const STATE_QUESTION = "question";
  static const STATE_ANSWER = "answer";
  static const STATE_QUESTION_END = "question_end";
  static const STATE_FINAL_THEMES = "final_themes";
  static const STATE_FINAL_BETS = "final_bets";
  static const STATE_FINAL_QUESTION = "final_question";
  static const STATE_FINAL_ANSWER = "final_answer";
  static const STATE_FINAL_PLAYER_ANSWER = "final_player_answer";
  static const STATE_FINAL_PLAYER_BET = "final_player_bet";
  static const STATE_GAME_END = "game_end";

  late final int round;
  late final int roundsCount;
  late final bool isFinalRound;
  late final JeopardyQuestion? question;
  late final List<JeopardyTheme>? themes;
  late final List<JeopardyPlayer> players;
  late final int? answerer;

  JeopardyGame(Map<String, dynamic> json) : super(json) {
    this.round = json["round"];
    this.roundsCount = json["rounds_count"];
    this.isFinalRound = json["is_final_round"];
    this.question = (json["question"] != null)
        ? JeopardyQuestion(json["question"]) : null;
    this.themes = (json["themes"] != null)
        ? [for (var value in json["themes"]) JeopardyTheme(value)]
        : null;
    this.players = [for (var value in json["players"]) JeopardyPlayer(value)];
    this.answerer = json["answerer"];
  }
}
