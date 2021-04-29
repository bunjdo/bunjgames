import React, {useEffect} from "react";

import {AudioPlayer, HowlWrapper, ImagePlayer, VideoPlayer, Loading, useGame, useAuth} from "common/Essentials";
import {AdminAuth} from "common/Auth";

import {ThemesList, ThemesGrid, QuestionsGrid} from "jeopardy/Themes";
import {getRoundName, getTypeName} from "jeopardy/Common";
import {Content, ExitButton, GameView, TextContent} from "common/View";
import styles from "jeopardy/View.scss";
import {useHistory} from "react-router-dom";


const Music = {
    intro: HowlWrapper('/sounds/jeopardy/intro.mp3'),
    themes: HowlWrapper('/sounds/jeopardy/themes.mp3'),
    round: HowlWrapper('/sounds/jeopardy/round.mp3'),
    minute: HowlWrapper('/sounds/jeopardy/minute.mp3'),
    auction: HowlWrapper('/sounds/jeopardy/auction.mp3'),
    bagcat: HowlWrapper('/sounds/jeopardy/bagcat.mp3'),
    game_end: HowlWrapper('/sounds/jeopardy/game_end.mp3'),
}

const Sounds = {
    skip: HowlWrapper('/sounds/jeopardy/skip.mp3'),
}


const loadSounds = () => {
    Object.values(Music).forEach(m => m.load());
    Object.values(Sounds).forEach(m => m.load());
}

const resetSounds = () => {
    Object.values(Music).forEach(m => m.stop());
};

const QuestionMessage = ({game, text, image, audio, video}) => {
    return <div className={styles.media}>
        {text && !image && !video && <p>{text}</p>}
        {image && <ImagePlayer autoPlay game={game} url={image}/>}
        {audio && <AudioPlayer controls autoPlay={true} game={game} url={audio}/>}
        {video && <VideoPlayer controls autoPlay={true} game={game} url={video}/>}
    </div>
}

const useStateContent = (game) => {
    const {question} = game;
    const answerer = game.answerer && game.players.find(p => p.id === game.answerer);

    switch (game.state) {
        case "waiting_for_players":
            return <TextContent>{game.token}</TextContent>;
        case "themes_all":
            return <ThemesGrid game={game}/>;
        case "round":
            return <TextContent>{getRoundName(game)}</TextContent>;
        case "round_themes":
        case "final_themes":
            return <ThemesList game={game}/>;
        case "questions":
            return <QuestionsGrid game={game}/>;
        case "question_event":
            return <TextContent>{getTypeName(game.question.type)}</TextContent>;
        case "question": case "answer": case "final_question": case "final_answer":
            return <QuestionMessage
                game={game} text={question.text} image={question.image} audio={question.audio} video={question.video}
            />;
        case "question_end":
            return <QuestionMessage
                game={game} text={question.answer_text} image={question.answer_image}
                audio={question.answer_audio} video={question.answer_video}
            />;
        case "final_player_answer":
            return <TextContent>{answerer.final_answer || "⸻"}</TextContent>;
        case "final_player_bet":
            return <TextContent>{answerer.final_bet}</TextContent>;
        default:
            return <TextContent>Jeopardy</TextContent>;
    }
};

const JeopardyView = () => {
    const game = useGame(JEOPARDY_API, (game) => {
        resetSounds();
        switch (game.state) {
            case "intro": Music.intro.play(); break;
            case "round": Music.round.play(); break;
            case "round_themes": Music.themes.play(); break;
            case "question_event": {
                if (game.question.type === "auction") {
                    Music.auction.play();
                } else if (game.question.type === "bagcat") {
                    Music.bagcat.play();
                }
            } break;
            case "final_answer": Music.minute.play(); break;
            case "game_end": Music.game_end.play(); break;
        }
    }, (message) => {
        switch (message) {
            case "skip": Sounds.skip.play(); break;
            case "sound_stop": resetSounds(); break;
        }
    });

    useEffect(() => {
        loadSounds();
        return () => {
            resetSounds();
        }
    }, []);

    const [connected, setConnected] = useAuth(JEOPARDY_API);

    const history = useHistory();
    const onLogout = () => {
        JEOPARDY_API.logout();
        history.push("/admin");
    };

    if (!connected) return <AdminAuth api={JEOPARDY_API} setConnected={setConnected}/>;
    if (!game) return <Loading/>;

    return <GameView>
        <ExitButton onClick={onLogout}/>
        <Content>{useStateContent(game)}</Content>
    </GameView>
}

export default JeopardyView;
