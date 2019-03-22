/*

*/


//SERVER CONFIGUTATIONS
const admobId = "ENTER YOUR ADMOB ID HERE"
const maxClients = 2; //EDIT THIS LINE TO SET THE MAX NUMBER OF CLIENTS

//NODE MODULES
const express = require("express");
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const bodyParser = require('body-parser');


const execute = function (command, callback) {
    exec(command, { maxBuffer: 1024 * 250 }, function (error, stdout, stderr) {
        callback(error, stdout, stderr);
    });
};

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


const router = express();

//HELMET PROTECTION MIDDLEWARE
router.use(helmet());

//REQUEST LIMITER

//LIMITS REQUESTS FROM IP ADDRESS
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

router.listen(6333, function () {
    console.log("HTTP redirect to HTTPS Server Started..");
});


router.get('/', function (req, res) {
    //FOR TESTING PURPOSES
    res.send("HELLO WORLD");
});

router.get('/connect', function (req, res) {

    res.send("HELLO WORLD");
});

router.get('/message', function (req, res) {
    
    res.send("true");
});





