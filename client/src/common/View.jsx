import React from "react";
import QRCode from "qrcode.react";
import styles from "common/View.scss";
import {Toast} from "common/Essentials";

const ExitButton = ({onClick}) => (
    <a className={styles.exit} onClick={() => {
        if(confirm("Are you sure want to exit?")){
            onClick();
        } else {
            e.preventDefault();
        }
    }}><i className="fas fa-times-circle"/></a>
)

const TextContent = ({className, children}) => (
    <div className={css(styles.text, className)}>
        <p>{children}</p>
    </div>
);

const QRCodeContent = ({className, children, value}) => (
    <div className={css(styles.text, className)}>
        <p>{children}</p>
        <QRCode className={styles.qr} size={2000} includeMargin={true} bgColor={'#fff'} value={value} />
    </div>
);

const BlockContent = ({children}) => (
    <div className={styles.block}>
        {children}
    </div>
);

const Content = ({children}) => (
    <div className={styles.content}>
        {children}
    </div>
);

const GameView = ({children}) => (
    <div className={styles.view}>
        {children}
        <Toast/>
    </div>
);

export {
    ExitButton,
    TextContent,
    QRCodeContent,
    BlockContent,
    Content,
    GameView,
}
