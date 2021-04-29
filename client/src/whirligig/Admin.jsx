import React, {useState, useEffect} from "react";
import {useHistory} from "react-router-dom";

import {
    Loading,
    AudioPlayer,
    ImagePlayer,
    VideoPlayer,
    useGame,
    useAuth,
    OvalButton,
    ButtonLink, Button, useTimer
} from "common/Essentials";
import {AdminAuth} from "common/Auth";
import {BlockContent, Content, Footer, FooterItem, GameAdmin, Header, TextContent} from "common/Admin";

import styles from "whirligig/Admin.scss";


const getStatusName = (status) => {
    switch (status) {
        case 'start':
            return "Start";
        case 'intro':
            return "Intro";
        case 'questions':
            return "Questions";
        case 'question_whirligig':
            return "Selecting question";
        case 'question_start':
            return "Asking";
        case 'question_discussion':
            return "Discussion";
        case 'answer':
            return "Answer";
        case 'right_answer':
            return "Right answer";
        case 'question_end':
            return "Question end";
        case 'end':
            return "Game over";
    }
}

const ItemQuestion = ({question, single}) => {
    const {number, is_processed, description, answer_description} = question;
    const checkbox = (is_processed)
        ? <i className="fas fa-check-square"/>
        : <i className="fas fa-square"/>

    return <div className={styles.question}>
        {single || <div>{number}: {checkbox}</div>}
        <div>Question: {description}</div>
        <div>Answer: {answer_description}</div>
    </div>
};

const ItemQuestions = ({questions}) => (
    <div className={styles.questions}>
        {questions.map((q, k) => (
            <ItemQuestion key={k} question={q} single={questions.length <= 1}/>
        ))}
    </div>
);

const Item = ({item}) => {
    let [isSelected, select] = useState(false);
    const {name, description, type, is_processed} = item;

    const checkbox = (is_processed)
        ? <i className="fas fa-check-square"/>
        : <i className="fas fa-square"/>

    return <div className={styles.item}>
        <div className={styles.short} onClick={() => select(!isSelected)}>
            <div className={styles.desc}>{name}: {description}</div>
            <div className={styles.processed}>{checkbox}</div>
        </div>
        {isSelected && <ItemQuestions questions={item.questions}/>}
    </div>;
};

const Items = ({items}) => (
    <div className={styles.list}>
        {items.map((item, key) => (
            <Item key={key} item={item}/>
        ))}
    </div>
);

const Timer = ({game}) => {
    const time = useTimer(WHIRLIGIG_API, () => {
        setTimeout(() => {
            if (game.state === "question_discussion") {
                WHIRLIGIG_API.nextState(game.state);
            }
        }, 2000);
    });
    const onPause = () => WHIRLIGIG_API.timer(!game.timer_paused);

    return <div className={styles.timer}>
        <div className={styles.time}>{time}</div>
        <Button className={styles.timerButton} onClick={onPause}>{game.timer_paused ? "Resume" : "Pause"}</Button>
    </div>
}

const ScoreControl = ({game}) => {
    const updateScore = (connoisseurs_score, viewers_score) => {
        WHIRLIGIG_API.score(connoisseurs_score, viewers_score);
    };

    return <div className={styles.scoreControl}>
        <div className={styles.control}>
            <div>Connoisseurs</div>
            <div>
                <Button
                     onClick={() => updateScore(game.connoisseurs_score - 1, game.viewers_score)}>
                    <i className="fas fa-minus"/>
                </Button>
                {game.connoisseurs_score}
                <Button
                     onClick={() => updateScore(game.connoisseurs_score + 1, game.viewers_score)}>
                    <i className="fas fa-plus"/>
                </Button>
            </div>
        </div>
        <div className={styles.control}>
            <div>Viewers</div>
            <div>
                <Button
                     onClick={() => updateScore(game.connoisseurs_score, game.viewers_score - 1)}>
                    <i className="fas fa-minus"/>
                </Button>
                {game.viewers_score}
                <Button
                     onClick={() => updateScore(game.connoisseurs_score, game.viewers_score + 1)}>
                    <i className="fas fa-plus"/>
                </Button>
            </div>
        </div>
    </div>
};

const useStateContent = (game) => {
    const {cur_item, cur_question} = game;

    if (!cur_item || !cur_question) {
        return <TextContent>{getStatusName(game.state)}</TextContent>;
    }

    return <BlockContent>
        <div>
            <div>Name: {cur_item.name}</div>
            {cur_item.description && <div>Description: {cur_item.description}</div>}
            <div>Type: {cur_item.type}</div>
        </div>
        <div className={styles.media}>
            <div>{cur_question.description}</div>
        </div>
        {(cur_question.text || cur_question.image || cur_question.audio || cur_question.video) &&
        <div className={styles.media}>
            <div>{cur_question.text && <p>{cur_question.text}</p>}</div>
            <div>{cur_question.image && <ImagePlayer controls={true} game={game} url={cur_question.image}/>}</div>
            <div>{cur_question.audio && <AudioPlayer controls={true} game={game} url={cur_question.audio}/>}</div>
            <div>{cur_question.video && <VideoPlayer controls={true} game={game} url={cur_question.video}/>}</div>
        </div>}
        <div className={styles.media}>
            <div>{cur_question.answer_description}</div>
            <div>{cur_question.answer_text && <p>{cur_question.answer_text}</p>}</div>
            <div>{cur_question.answer_image && <ImagePlayer controls={true} game={game} url={cur_question.answer_image}/>}</div>
            <div>{cur_question.answer_audio && <AudioPlayer controls={true} game={game} url={cur_question.answer_audio}/>}</div>
            <div>{cur_question.answer_video && <VideoPlayer controls={true} game={game} url={cur_question.answer_video}/>}</div>
        </div>
    </BlockContent>
};

const useControl = (game) => {
    const onGongClick = () => WHIRLIGIG_API.intercom("gong");
    const onAnswerClick = (isCorrect) => WHIRLIGIG_API.answerCorrect(isCorrect);
    const onNextClick = () => WHIRLIGIG_API.nextState(game.state);
    const onExtraTime = () => WHIRLIGIG_API.extra_time();

    const buttons = [];

    if (game.state === "question_discussion") {
        buttons.push(<Timer game={game}/>)
    } else if (game.state === "answer") {
        buttons.push(<Button onClick={onExtraTime}>+time</Button>);
    }

    buttons.push(<Button className={styles.gong} onClick={() => onGongClick()}>Gong</Button>)

    if (game.state === "right_answer") {
        buttons.push(
            <Button onClick={() => onAnswerClick(false)}>Wrong</Button>,
            <Button onClick={() => onAnswerClick(true)}>Right</Button>
        );
    } else if (game.state !== "end") {
        buttons.push(<Button onClick={onNextClick}>Next</Button>)
    }
    return buttons;
}

const WhirligigAdmin = () => {
    const game = useGame(WHIRLIGIG_API);
    const [connected, setConnected] = useAuth(WHIRLIGIG_API);
    const history = useHistory();

    const onSoundStop = () => WHIRLIGIG_API.intercom("sound_stop");
    const onLogout = () => {
        WHIRLIGIG_API.logout();
        history.push("/admin");
    };

    if (!connected) return <AdminAuth api={WHIRLIGIG_API} setConnected={setConnected}/>;
    if (!game) return <Loading/>

    return <GameAdmin>
        <Header gameName={"Whirligig"} token={game.token} stateName={getStatusName(game.state)}>
            <OvalButton onClick={onSoundStop}><i className="fas fa-volume-mute"/></OvalButton>
            <ButtonLink to={"/admin"}>Home</ButtonLink>
            <ButtonLink to={"/whirligig/view"}>View</ButtonLink>
            <Button onClick={onLogout}>Logout</Button>
        </Header>
        <Content rightPanel={[<Items items={game.items || []}/>, <ScoreControl game={game}/>]}>
            {useStateContent(game)}
        </Content>
        <Footer>
            <FooterItem className={styles.score}>{game.connoisseurs_score} : {game.viewers_score}</FooterItem>
            <FooterItem>{useControl(game)}</FooterItem>
        </Footer>
    </GameAdmin>
}

export default WhirligigAdmin;
