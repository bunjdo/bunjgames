import React from "react";
import ReactDOM from "react-dom";
import {Howler} from 'howler';
import styles from './App.scss';
import { BrowserRouter, withRouter } from 'react-router-dom'
import { Switch, Route } from "react-router";
import {MainPage, AdminPage, AboutPage} from "info/InfoPage";
import WhirligigAdmin from "./whirligig/Admin.jsx";
import WhirligigView from "./whirligig/View.jsx";
import WhirligigApi from "./whirligig/WhirligigApi.js";
import JeopardyApi from "./jeopardy/JeopardyApi.js";
import WeakestApi from "./weakest/WeakestApi.js";
import FeudApi from "./feud/FeudApi.js";
import JeopardyAdmin from "./jeopardy/Admin.jsx";
import JeopardyView from "./jeopardy/View.jsx";
import JeopardyClient from "./jeopardy/Client.jsx";
import WeakestAdmin from "./weakest/Admin.jsx";
import WeakestView from "./weakest/View.jsx";
import WeakestClient from "./weakest/Client.jsx";
import FeudAdmin from "./feud/Admin.jsx";
import FeudView from "./feud/View.jsx";
import FeudClient from "./feud/Client.jsx";

require("./Polyfils.js");

window.BunjGamesConfig = {
    MEDIA: MEDIA_ENDPOINT,

    COMMON_API_ENDPOINT: API_ENDPOINT + "common/",

    WHIRLIGIG_API_ENDPOINT: API_ENDPOINT + "whirligig/",
    WHIRLIGIG_WS_ENDPOINT: WS_ENDPOINT + "whirligig/",

    JEOPARDY_API_ENDPOINT: API_ENDPOINT + "jeopardy/",
    JEOPARDY_WS_ENDPOINT: WS_ENDPOINT + "jeopardy/",

    WEAKEST_API_ENDPOINT: API_ENDPOINT + "weakest/",
    WEAKEST_WS_ENDPOINT: WS_ENDPOINT + "weakest/",

    FEUD_API_ENDPOINT: API_ENDPOINT + "feud/",
    FEUD_WS_ENDPOINT: WS_ENDPOINT + "feud/",
};

window.WHIRLIGIG_API = new WhirligigApi(BunjGamesConfig.WHIRLIGIG_API_ENDPOINT, BunjGamesConfig.WHIRLIGIG_WS_ENDPOINT);
window.JEOPARDY_API = new JeopardyApi(BunjGamesConfig.JEOPARDY_API_ENDPOINT, BunjGamesConfig.JEOPARDY_WS_ENDPOINT);
window.WEAKEST_API = new WeakestApi(BunjGamesConfig.WEAKEST_API_ENDPOINT, BunjGamesConfig.WEAKEST_WS_ENDPOINT);
window.FEUD_API = new FeudApi(BunjGamesConfig.FEUD_API_ENDPOINT, BunjGamesConfig.FEUD_WS_ENDPOINT);

Howler.volume(0.5);

const App = () => {
    return <BrowserRouter>
        <Switch>
            <Route exact path="/" component={MainPage}/>
            <Route exact path="/admin" component={AdminPage}/>
            <Route exact path="/about" component={AboutPage}/>

            <Route exact path="/whirligig/admin" component={WhirligigAdmin}/>
            <Route exact path="/whirligig/view" component={WhirligigView}/>

            <Route exact path="/jeopardy/admin" component={JeopardyAdmin}/>
            <Route exact path="/jeopardy/view" component={JeopardyView}/>
            <Route exact path="/jeopardy/client" component={JeopardyClient}/>

            <Route exact path="/weakest/admin" component={WeakestAdmin}/>
            <Route exact path="/weakest/view" component={WeakestView}/>
            <Route exact path="/weakest/client" component={WeakestClient}/>

            <Route exact path="/feud/admin" component={FeudAdmin}/>
            <Route exact path="/feud/view" component={FeudView}/>
            <Route exact path="/feud/client" component={FeudClient}/>
        </Switch>
    </BrowserRouter>
};

ReactDOM.render(<App />, document.getElementById("root"));
