import React, {useEffect, useState} from "react";
import {Loading, useGame, useAuth, HowlWrapper} from "common/Essentials";
import {AdminAuth} from "common/Auth";
import {Content, ExitButton, GameView, TextContent, QRCodeContent} from "common/View";
import {FinalQuestions, Question} from "feud/Question";
import styles from "feud/View.scss";
import {useHistory} from "react-router-dom";

const Music = {
    intro: HowlWrapper('/sounds/feud/intro.mp3', false, 0.5),
    round: HowlWrapper('/sounds/feud/round.mp3', false, 0.5),
    beat: HowlWrapper('/sounds/feud/beat.mp3', false, 0.5),
    timer: HowlWrapper('/sounds/feud/timer.mp3', false, 0.5),
    end: HowlWrapper('/sounds/feud/end.mp3', false, 0.5),
}

const Sounds = {
    button: HowlWrapper('/sounds/feud/button.mp3'),
    repeat: HowlWrapper('/sounds/feud/repeat.mp3'),
    right: HowlWrapper('/sounds/feud/right.mp3'),
    wrong: HowlWrapper('/sounds/feud/wrong.mp3'),
}

const loadSounds = () => {
    Object.values(Music).forEach(m => m.load());
    Object.values(Sounds).forEach(m => m.load());
}

const stopMusic = () => {
    Object.values(Music).forEach(m => m.stop());
};

const changeMusic = (old, next) => {
    if (old !== next) {
        stopMusic();
        if (Music[next]) Music[next].play();
        return next;
    }
}

const useStateContent = (game) => {
    const answerer = game.answerer && game.players.find(t => t.id === game.answerer);
    switch (game.state) {
        case "waiting_for_players":
            return <QRCodeContent value={'https://games.bunj.app/feud/client?token=' + game.token}>
                {game.token}
            </QRCodeContent>;
        case "round":
            return <TextContent>Round {game.round}</TextContent>;
        case "button":
        case "answers":
        case "answers_reveal":
        case "final_questions":
            return <Question
                game={game} className={styles.question} showHiddenAnswers={false}
            />;
        case "final":
            return <TextContent>Final</TextContent>;
        case "final_questions_reveal":
            return <FinalQuestions game={game} className={styles.question}/>;
        case "end":
            return <TextContent>{answerer.final_score > 200 ? "Victory" : "Defeat"}: {answerer.final_score}</TextContent>;
        default:
            return <TextContent>Friends Feud</TextContent>
    }
};

const FeudView = () => {
    const [music, setMusic] = useState();
    const game = useGame(FEUD_API, (game) => {
        if (game.state === "intro") {
            setMusic(changeMusic(music, "intro"));
        } else if (game.state === "round") {
            setMusic(changeMusic(music, "round"));
        } else if (game.state === "answers") {
            setMusic(changeMusic(music, "beat"));
        } else if (game.state === "final_questions") {
            setMusic(changeMusic(music, "timer"));
        } else if (game.state === "final_questions_reveal") {
            stopMusic();
        } else if (game.state === "end") {
            setMusic(changeMusic(music, "end"));
        }
    }, (message) => {
        switch (message) {
            case "button":
                Sounds.button.play();
                break;
            case "repeat":
                Sounds.repeat.play();
                break;
            case "right":
                Sounds.right.play();
                break;
            case "wrong":
                Sounds.wrong.play();
                break;
            case "sound_stop":
                setMusic(changeMusic(music, ""));
                break;
        }
    });

    useEffect(() => {
        loadSounds();
        return () => {
            stopMusic();
        }
    }, []);

    const [connected, setConnected] = useAuth(FEUD_API);

    const history = useHistory();
    const onLogout = () => {
        FEUD_API.logout();
        history.push("/admin");
    };

    if (!connected) return <AdminAuth api={FEUD_API} setConnected={setConnected}/>;
    if (!game) return <Loading/>;

    return <GameView>
        <ExitButton onClick={onLogout}/>
        <Content>{useStateContent(game)}</Content>
    </GameView>
}

export default FeudView;
