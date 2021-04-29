import React from "react";
import {Toast} from "common/Essentials";
import styles from "common/Client.scss";

const ExitButton = ({onClick}) => (
    <a className={styles.exit} onClick={() => {
        if(confirm("Are you sure want to exit?")){
            onClick();
        } else {
            e.preventDefault();
        }
    }}><i className="fas fa-times-circle"/></a>
)

const Header = ({children}) => (
    <div className={styles.header}>
        {children}
    </div>
);

const TextContent = ({children}) => (
    <div className={styles.text}>{children}</div>
)

const FormContent = ({children}) => (
    <div className={styles.form}>
        {children}
    </div>
)

const BigButtonContent = ({active, onClick, children}) => (
    <div className={css(styles.bigButton, active && styles.active)} onClick={onClick} onTouchStart={onClick}>
        {children}
    </div>
)

const Content = ({children}) => (
    <div className={styles.content}>
        {children}
    </div>
)

const GameClient = ({children}) => (
    <div className={styles.client}>
        {children}
        <Toast/>
    </div>
);

export {
    ExitButton,
    Header,
    TextContent,
    FormContent,
    BigButtonContent,
    Content,
    GameClient,
};
