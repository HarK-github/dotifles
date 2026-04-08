"use strict";
import GLib from 'gi://GLib';
import App from 'resource:///com/github/Aylur/ags/app.js'
import userOptions from './modules/.configuration/user_options.js';
import Overview from './modules/overview/main.js';

const COMPILED_STYLE_DIR = `${GLib.get_user_config_dir()}/ags/user/`

async function applyStyle() {
    App.resetCss();
    App.applyCss(`${COMPILED_STYLE_DIR}/style.css`);
    console.log('[LOG] Styles loaded')
}

applyStyle().catch(print);

Utils.monitorFile(
    `${COMPILED_STYLE_DIR}/style.css`,
    () => applyStyle().catch(print)
);

const Windows = () => [
    Overview()
];

// Win11 typical animation duration is around 300ms
const CLOSE_ANIM_TIME = 300; 

App.config({
    css: `${COMPILED_STYLE_DIR}/style.css`,
    stackTraceOnError: true,
    closeWindowDelay: {
        'sideright': CLOSE_ANIM_TIME,
        'sideleft': CLOSE_ANIM_TIME,
        'osk': CLOSE_ANIM_TIME,
        'overview': CLOSE_ANIM_TIME, // Ensure the name matches your Overview window name
    },
    windows: Windows().flat(1),
});

// Hook into the window visibility to trigger the CSS transition
// This assumes your Overview window name is 'overview'
App.connect('window-toggled', (_, name, visible) => {
    if (name === 'overview') {
        const win = App.getWindow(name);
        if (visible) {
            // Add the 'visible' class after a tiny delay to trigger the slide up
            Utils.timeout(10, () => win.get_child().class_name += " visible");
        } else {
            // Remove it to trigger slide down/fade out
            win.get_child().class_name = win.get_child().class_name.replace(" visible", "");
        }
    }
});