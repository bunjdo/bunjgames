import React from "react";
import {useHistory} from "react-router-dom";

import {Loading, useAuth, useGame} from "common/Essentials";
import {PlayerAuth} from "common/Auth";
import {GameClient, Content, Header, ExitButton, TextContent, BigButtonContent} from "common/Client";


const useStateContent = (game) => {
    const buttonActive = !game.answerer;

    const onButton = () => buttonActive && FEUD_API.button_click(FEUD_API.playerId);

    switch (game.state) {
        case "button":
            return <BigButtonContent active={buttonActive} onClick={onButton} />
        case "end":
            return <TextContent>Game over</TextContent>;
        default:
            return <TextContent>Friends Feud</TextContent>
    }
};

const FeudClient = () => {
    const game = useGame(FEUD_API);
    const [connected, setConnected] = useAuth(FEUD_API);
    const history = useHistory();

    if (!connected) return <PlayerAuth api={FEUD_API} setConnected={setConnected}/>;
    if (!game) return <Loading/>;

    const onLogout = () => {
        FEUD_API.logout();
        history.push("/");
    };

    return <GameClient>
        <Header><ExitButton onClick={onLogout}/></Header>
        <Content>{useStateContent(game)}</Content>
    </GameClient>
}

export default FeudClient;
