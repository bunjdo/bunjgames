import "common.dart";


class FeudAnswer {
  late final int id;
  late final String text;
  late final int value;
  late final bool isOpened;
  late final bool isFinalAnswered;

  FeudAnswer(Map<String, dynamic> json) {
    this.id = json["id"];
    this.text = json["text"];
    this.value = json["value"];
    this.isOpened = json["is_opened"];
    this.isFinalAnswered = json["is_final_answered"];
  }
}


class FeudQuestion {
  late final int id;
  late final String text;
  late final List<FeudAnswer> answers;
  late final bool isProcessed;

  FeudQuestion(Map<String, dynamic> json) {
    this.id = json["id"];
    this.text = json["text"];
    this.answers = [for (var answer in json["answers"]) FeudAnswer(answer)];
    this.isProcessed = json["is_processed"];
  }
}


class FeudPlayer {
  late final int id;
  late final String name;
  late final int strikes;
  late final int score;
  late final int finalScore;

  FeudPlayer(Map<String, dynamic> json) {
    this.id = json["id"];
    this.name = json["name"];
    this.strikes = json["strikes"];
    this.score = json["score"];
    this.finalScore = json["final_score"];
  }
}


class FeudGame extends Game {
  static const STATE_WAITING_FOR_PLAYERS = "waiting_for_players";
  static const STATE_INTRO = "intro";
  static const STATE_ROUND = "round";
  static const STATE_BUTTON = "button";
  static const STATE_ANSWERS = "answers";
  static const STATE_ANSWERS_REVEAL = "answers_reveal";
  static const STATE_FINAL = "final";
  static const STATE_FINAL_QUESTIONS = "final_questions";
  static const STATE_FINAL_QUESTIONS_REVEAL = "final_questions_reveal";
  static const STATE_END = "end";
  
  late final int round;
  late final FeudQuestion? question;
  late final int? answerer;
  late final List<FeudQuestion>? finalQuestions;
  late final int timer;
  late final List<FeudPlayer> players;

  FeudGame(Map<String, dynamic> json) : super(json) {
    this.round = json["round"];
    this.question = (json["question"]) ? FeudQuestion(json["question"]) : null;
    this.answerer = json["answerer"];
    this.finalQuestions = (json["final_questions"])
        ? [for (var value in json["final_questions"]) FeudQuestion(value)]
        : null;
    this.timer = json["timer"];
    this.players = [for (var value in json["players"]) FeudPlayer(value)];
  }
}
