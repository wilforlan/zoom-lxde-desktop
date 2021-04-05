"use strict";
const SegfaultHandler = require('segfault-handler');
const { spawn } = require('child_process');
const isLinux = process.platform === 'linux';
const { keyboard, Key, mouse, left, right, up, down, screen, straightTo, centerOf } = require("@nut-tree/nut-js");
const sleep = require('sleep-promise');

SegfaultHandler.registerHandler("crash.log");


screen.config.confidence = 0.8

const demo_code = "7261429696"
const demo_pwd = "MVAwZXpWa3h2amRRRlVyRFUxc3hxdz09"
const demo_name = "Williams Notetaker"

const openZoom = async (link) => {
    const child = spawn(`${isLinux ? 'xdg-' : '' }open`, [link]);

    child.stdout.on('data', (data) => {
      console.log(`stdout:\n${data}`);
    });
    
    child.stderr.on('data', (data) => {
      console.error(`stderr: ${data}`);
    });
    
    child.on('error', (error) => {
      console.error(`error: ${error.message}`);
    });
    
    child.on('close', (code) => {
      console.log(`child process exited with code ${code}`);
    });
};

const clickButton = (id, ts = 10000, log = true) => {
    return new Promise(( resolve, reject) => {
        mouse.move(straightTo(centerOf(screen.waitFor(`assets/buttons/${id}.png`, ts)))).then(m => {
            if (log) console.log(`moved mouse to ${id}`)
            mouse.leftClick().then(_ => {
                if (log) console.log(`clicked ${id}`)
                return resolve();
            })
        }).catch(e => {
            if (log) console.log(`button ${id} not found after ${ts}ms`);
            reject(e);
        });
    });
};

(async () => {
    const link = "zoommtg://zoom.us/join?action=join&confno=" + demo_code + "&pwd=" + demo_pwd + "&uname=" + demo_name + "&zc=0"
    await openZoom(link);

    console.log("starting async watcher functions. link:", link);
    
    const demoRecorder = () => {
        console.log("Demo recorder call and init!. will log blob every 5sec");
        setInterval(() => {
            console.log("[t-blob] 0x00000000");
        }, 5000);
    };

    // demoRecorder();
    console.log("sleeping for 10sec for processes to boot up")
    await sleep(10000);
    console.log("exit sleep")

    mouse.leftClick().then(_ => {
        console.log(`leftClicked...`)
    })
    
    screen.waitFor("assets/texts/waiting-to-start.png", 60000).then(region => {
        console.log({ name: "waiting-to-start", region })
    }).catch(e => console.log(`waiting-to-start not found`));
    

    // screen.waitFor("assets/texts/waiting-to-join-room.png", 60000).then(region => {
    //     console.log({ name: "waiting-to-join-room", region })
    // }).catch(e => console.log(`waiting-to-join-room not found`));

    // screen.waitFor("assets/texts/invalid-meeting-id.png", 60000).then(region => {
    //     console.log({ name: "invalid-meeting-id", region })
    // }).catch(e => console.log(`invalid-meeting-id not found`));

    // screen.waitFor("assets/texts/invalid-meeting-id-opt-2.png", 60000).then(region => {
    //     console.log({ name: "invalid-meeting-id-opt-2", region })
    // }).catch(e => console.log(`invalid-meeting-id-opt-2 not found`));

    // screen.waitFor("assets/texts/previously-removed.png", 60000).then(region => {
    //     console.log({ name: "previously-removed", region })
    // }).catch(e => console.log(`previously-removed not found`));

    // clickButton("join-with-computer-audio", 120000).then(m => {
    //    demoRecorder();
    // }).catch(e => console.log(`join-with-computer-audio not found`));

    // clickButton("mute", 120000).then(m => {
    //     // console.log("moved mouse")
    // }).catch(e => console.log(`mute not found`));

    // setInterval(function() {
    //     console.log("timer that keeps nodejs processing running");
    // }, 1000 * 60 * 60);

})();