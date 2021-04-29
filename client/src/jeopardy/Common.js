
const getStatusName = (status) => {
    switch (status) {
        case 'waiting_for_players':
            return "Waiting for players";
        case 'intro':
            return "Intro";
        case 'themes_all':
            return "All themes";
        case 'round':
            return "Round number";
        case 'round_themes':
            return "Round themes";
        case 'questions':
            return "Questions";
        case 'question_event':
            return "Question event";
        case 'question':
            return "Question";
        case 'answer':
            return "Answer";
        case 'question_end':
            return "Question end";
        case 'final_themes':
            return "Final themes";
        case 'final_bets':
            return "Final bets";
        case 'final_question':
            return "Final question";
        case 'final_answer':
            return "Final answer";
        case 'final_player_answer':
            return "Final player answer";
        case 'final_player_bet':
            return "Final player bet";
        case 'game_end':
            return "Game over";
    }
}

const getTypeName = (status) => {
    switch (status) {
        case 'standard':
            return "Standard";
        case 'auction':
            return "Auction";
        case 'bagcat':
            return "Cat in the bag";
    }
}

const getRoundName = (game) => {
    if (game.is_final_round) {
        return "FINAL";
    }
    return "ROUND " + String(game.round)
}

export {getStatusName, getTypeName, getRoundName}
