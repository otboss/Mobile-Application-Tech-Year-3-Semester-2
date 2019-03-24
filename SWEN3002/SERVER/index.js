//MODULES
const express = require("express");
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const bodyParser = require('body-parser');
const md5 = require('md5');
const fs = require('fs');
const config = JSON.parse(fs.readFileSync("./config.json",{encoding: "utf8"}));

//BOOT MESSAGE
console.log(`
==========================
BOOTED A CipherChat SERVER
==========================
Selected Port: `+config.port+`
Max Connections: `+config.maxClients+`
Admob ID: `+config.admobId+`

Starting Server..
`);

const execute = function (command, callback) {
    exec(command, { maxBuffer: 1024 * 250 }, function (error, stdout, stderr) {
        callback(error, stdout, stderr);
    });
};

/** Escapes slashes, Useful if mysql is being implemented*/
const addslashes = function (string) {
    string = String(string);
    return string.replace(/\\/g, '\\\\').
        replace(/\u0008/g, '\\b').
        replace(/\t/g, '\\t').
        replace(/\n/g, '\\n').
        replace(/\f/g, '\\f').
        replace(/\r/g, '\\r').
        replace(/'/g, '\\\'').
        replace(/"/g, '\\"');
}

/** Returns a new Message Object*/
const newMessage = function(senderIP, username, message, recipients, timestamp, checksum){
    return {
        "sender": senderIP,
        "username": username,
        "message": message,
        "ts": timestamp,
        "checksum": checksum,
        "recipients": JSON.stringify(recipients)
    }
}

/** JSON of the participants currently connected to the server.*/
var participants = {};

/** Messages of the Current Chat*/
var messages = {};

//INACTIVE PARTICIPANTS KICKER
setInterval(function(){
    for(ip in participants){
        if(new Date().getTime() - participants[ip]["ts"] >= 300000)
            delete participants[ip];
    }
    if(Object.keys(participants) == 0){
        messages = {};
    }
}, 10000);

/** Server Router*/
const router = express();
//HELMET PROTECTION MIDDLEWARE
router.use(helmet());
//LIMIT REQUESTS FROM IP ADDRESS, PREVENTS SPAM
router.use(
    rateLimit({
        windowMs: 15 * 60 * 1000,
        max: 1500,
        message: "please try again later"
    })
);

//REQUEST BODY PARSER
router.use(bodyParser.urlencoded({ extended: false }));
router.use(bodyParser.json());

router.listen(config.port, function () {
    console.log("CipherChat SERVER STARTED. Now Listening on port "+config.port);
});


router.get('/', function (req, res) {
    //FOR TESTING PURPOSES
    res.send("HELLO WORLD");
});

router.post('/connect', function (req, res) {
    const ip = req.connection.remoteAddress;
    const username = req.body.username;
    const publicKey = req.body.publicKey;
    var profilePic = req.body.profilePic;
    var users = {};
    if(profilePic == null)
        profilePic = "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KUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJDyP1UGRFJDdnk2AAAAAElFTkSuQmCC";
    if(Object.keys(participants).length < config.maxClients && participants[ip] == null){
        var usernameTaken = false;
        for(var ipAddresses in participants){
            if(participants[ipAddresses]["username"] == username){
                usernameTaken = true;
                break;
            }
        }
        if(!usernameTaken && username != null){
            participants[ip] = {
                "username": username,
                "profilePic": profilePic,
                "publicKey": publicKey,
                "ts": new Date().getTime()
            };
        }
    }
    //Refresh Connection
    if(participants[ip] != null){
        participants[ip]["ts"] = new Date().getTime();
    }
    for(var ipAddresses in participants){
        users[participants[ipAddresses]["username"]] = participants[ipAddresses];
    }
    res.send(JSON.stringify({
        "participants": users,
        "admobId": config.admobId,
        "customAds": config.customAds
    }));
});

router.get('/getmessages', function(req, res){
    const ip = req.connection.remoteAddress;
    const username = req.query.username;
    const oldMessages = req.query.oldMessages;
    var newMessages = [];
    for(var checksum in messages){
        if(oldMessages[checksum] == null){
            if(messages[checksum]["recipients"][username] != null && participants[ip]["username"] == username)
                newMessages.push(messages[checksum]);
        }
    }
    res.send(JSON.stringify(newMessages));
});

router.get('/getchatparticipants', function(req, res){
    const ip = req.connection.remoteAddress;
    const username = req.query.username;
    const publicKey = req.query.publicKey;
    var users = {};
    if(participants[ip] != null){
        if(participants[ip]["username"] == username){
            participants[ip]["publicKey"] = publicKey;
            for(var ipAddresses in participants){
                users[participants[ipAddresses]["username"]] = participants[ipAddresses];
            }
            res.send(JSON.stringify(users));   
        }
    }
    else
        res.send("{}");
});

router.get('/anynewmessages', function(req, res){
    const oldMessages = req.query.oldMessages;
    if(Object.keys(messages).length > Object.keys(oldMessages).length){
        res.send("true")
    }
    else{
        res.send("false");
    }
});

router.post('/message', function (req, res) {
    try{
        const senderIP = req.connection.remoteAddress;
        if(participants[senderIP] == null)
            throw new Error("message send from non-participant.\n IP: "+senderIP);
        /**JSON Object */
        const recipients = req.body.recipients;
        const username = req.body.username;
        const message = req.body.message;
        const ts = new Date().getTime();
        const checksum = md5(senderIP+username+message+JSON.stringify(recipients)+ts);
        messages[checksum] = newMessage(senderIP, username, message, recipients, ts, checksum);
        participants[senderIP]["ts"] = new Date().getTime();
        res.send("true");
    }
    catch(err){
        console.log("\nERROR LOG:")
        console.log(err);
        res.send("false");
    }
});

router.delete('/recall', function (req, res) {
    try{
        const sender = req.connection.remoteAddress;
        const messageChecksum = req.body.messageChecksum;
        const username = req.body.username;
        if(messages[messageChecksum]["sender"] == sender && messages[messageChecksum]["username"] == username){
            messages[x]["message"] = messages[x]["username"]+" has recalled this message";
        }
        res.send("true");
    }
    catch(err){
        console.log("\nERROR LOG:")
        console.log(err);
    }
});


router.delete('/disconnect', function(req, res){
    const ip = req.connection.remoteAddress;
    const username = req.body.username;
    if(participants[ip]["username"] == username)
        delete participants[ip];
    res.send("true")
});





