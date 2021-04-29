import React from "react";
import { Link } from "react-router-dom";
import styles from "info/InfoPage.scss";

const MainPage = () => {
    return <div className={styles.body}>
        <div className={styles.header}>
            <div className={styles.title}>Bunjgames</div>
            <div className={css(styles.textRight, styles.title)}><Link to={'/admin'}>Admin panel</Link></div>
        </div>
        <div className={styles.category}>
            <div className={styles.subtitle}>Whirligig</div>
            <div>Throughout the game, a team of six (recommended) experts attempts to answer questions sent in by viewers.
                For each question, the time limit is one minute. The questions require a combination of skills such as logical thinking,
                intuition, insight, etc. to find the correct answer.
                The team of experts earns points if they manage to get the correct answer.</div>
        </div>
        <div className={styles.category}>
            <div className={styles.subtitle}><Link to={'/jeopardy/client'}>Jeopardy</Link></div>
            <div>Three (recommended) contestants each take their place behind a lectern.
                The contestants compete in a quiz game comprising two or three rounds and Final round.
                The material for the clues covers a wide variety of topics.
                Category titles often feature puns, wordplay, or shared themes, and the host regularly reminds
                contestants of topics or place emphasis on category themes before the start of the round.</div>
        </div>
        <div className={styles.category}>
            <div className={styles.subtitle}><Link to={'/weakest/client'}>The Weakest</Link></div>
            <div>The format features 3-7 (recommended) contestants, who take turns answering general knowledge questions.
                The objective of every round is to create a chain of nine correct answers in a row and earn an increasing
                amount of money within a time limit.
                One wrong answer breaks the chain and loses any money earned within that particular chain.
                However, before their question is asked (but after their name is called), a contestant can choose
                to bank the current amount of money earned in any chain to make it safe, after which the chain starts afresh.
                A contestant's decision not to bank, in anticipation being able to correctly answer the upcoming question
                allows the money to grow, as each successive correct answer earns proportionally more money.</div>
        </div>
        <div className={styles.category}>
            <div className={styles.subtitle}><Link to={'/feud/client'}>Friends Feud</Link></div>
            <div>The team with control of the question then tries to win the round by guessing all of the remaining concealed answers,
                with each member giving one answer in sequence. Giving an answer not on the board, or failing to respond within the allotted time,
                earns one strike. If the team earns three strikes, their opponents are given one chance to "steal" the points for the round
                by guessing any remaining concealed answer; failing to do so awards the points back to the family that originally had control.
                If the opponents are given the opportunity to "steal" the points, then only their team's captain is required to answer the question.
                Any remaining concealed answers on the board that were not guessed are then revealed.</div>
        </div>
    </div>
}

const AdminPage = () => {
    return <div className={styles.body}>
        <div className={styles.header}>
            <div className={styles.title}>Bunjgames</div>
            <div className={css(styles.textRight, styles.title)}><Link to={'/'}>Home</Link></div>
        </div>
        <div className={styles.category}>
            <div className={styles.subtitle}>Whirligig:</div>
            <div><Link to={'/whirligig/admin'}>Admin panel</Link></div>
            <div><Link to={'/whirligig/view'}>View</Link></div>
        </div>
        <div className={styles.category}>
            <div className={styles.subtitle}>Jeopardy:</div>
            <div><Link to={'/jeopardy/admin'}>Admin panel</Link></div>
            <div><Link to={'/jeopardy/view'}>View</Link></div>
        </div>
        <div className={styles.category}>
            <div className={styles.subtitle}>The Weakest:</div>
            <div><Link to={'/weakest/admin'}>Admin panel</Link></div>
            <div><Link to={'/weakest/view'}>View</Link></div>
        </div>
        <div className={styles.category}>
            <div className={styles.subtitle}>Friends Feud:</div>
            <div><Link to={'/feud/admin'}>Admin panel</Link></div>
            <div><Link to={'/feud/view'}>View</Link></div>
        </div>
    </div>
}

export {
    MainPage,
    AdminPage
}
