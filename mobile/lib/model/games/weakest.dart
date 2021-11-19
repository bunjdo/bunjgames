import "common.dart";


class WeakestQuestion {
  late final String question;
  late final String answer;

  WeakestQuestion(Map<String, dynamic> json) {
    this.question = json["question"];
    this.answer = json["answer"];
  }
}


class WeakestQuestionInfo {
  late final bool? isCorrect;
  late final bool isProcessed;

  WeakestQuestionInfo(Map<String, dynamic> json) {
    this.isCorrect = json["is_correct"];
    this.isProcessed = json["is_processed"];
  }
}


class WeakestPlayer extends Player {
  late final bool isWeak;
  late final int? weak;
  late final int rightAnswers;
  late final int bankIncome;

  WeakestPlayer(Map<String, dynamic> json): super(json) {
    this.isWeak = json["is_weak"];
    this.weak = json["weak"];
    this.rightAnswers = json["right_answers"];
    this.bankIncome = json["bank_income"];
  }
}


class WeakestGame extends Game {
  static const STATE_WAITING_FOR_PLAYERS = 'waiting_for_players';
  static const STATE_INTRO = 'intro';
  static const STATE_ROUND = 'round';
  static const STATE_QUESTIONS = 'questions';
  static const STATE_WEAKEST_CHOOSE = 'weakest_choose';
  static const STATE_WEAKEST_REVEAL = 'weakest_reveal';
  static const STATE_FINAL = 'final';
  static const STATE_FINAL_QUESTIONS = 'final_questions';
  static const STATE_END = 'end';

  late final int scoreMultiplier;
  late final int score;
  late final int bank;
  late final int tmpScore;
  late final int round;
  late final WeakestQuestion? question;
  late final int? answerer;
  late final int? weakest;
  late final int? strongest;
  late final List<WeakestQuestionInfo>? finalQuestions;
  late final int timer;
  late final List<WeakestPlayer> players;

  WeakestGame(Map<String, dynamic> json) : super(json) {
    this.scoreMultiplier = json["score_multiplier"];
    this.score = json["score"];
    this.bank = json["bank"];
    this.tmpScore = json["tmp_score"];
    this.round = json["round"];
    this.question = (json["question"] != null)
        ? WeakestQuestion(json["question"]) : null;
    this.answerer = json["answerer"];
    this.weakest = json["weakest"];
    this.strongest = json["strongest"];
    this.finalQuestions = (json["final_questions"] != null)
        ? [for (var value in json["final_questions"]) WeakestQuestionInfo(value)]
        : null;
    this.timer = json["timer"];
    this.players = [for (var value in json["players"]) WeakestPlayer(value)];
  }
}
