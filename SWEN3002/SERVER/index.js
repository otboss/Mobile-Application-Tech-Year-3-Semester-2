//MODULES
const express = require("express");
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const bodyParser = require('body-parser');
const md5 = require('md5');
const sha256 = require('sha256');
const fs = require('fs');
const bigInt = require("big-integer");
const request = require('request');
const elliptic = require('elliptic');
const ec = new elliptic.ec('secp256k1');
const config = JSON.parse(fs.readFileSync("./config.json",{encoding: "utf8"}));
var mysql      = require('mysql');
var connection = mysql.createConnection({
  host     : config.databaseConfig.host,
  user     : config.databaseConfig.user,
  password : config.databaseConfig.password,
  database : config.databaseConfig.database,
  port     : config.databaseConfig.port
});
connection.connect();

//BOOT MESSAGE
console.log(`
==========================
BOOTED A CipherChat SERVER
==========================
Selected Port: `+config.port+`
Max Connections: `+config.maxConnections+`
Admob ID: `+config.admodId+`

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

/** Creates a key which is used to add other persons to a chat*/
const makeJoinKey = function(length) {
    var text = "";
    var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    for (var i = 0; i < length; i++)
        text += possible.charAt(Math.floor(Math.random() * possible.length));
    return text;
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

/** Fetches the servers Current IP address*/
const getServerIp = function(){
    return new Promise(function(resolve, reject){
        if(!config.autoIpDetection){
            resolve(config.senderIP+":"+config.port);
        }
        else{
            request("http://ipecho.net/plain", {timeout: 5000}, function(error, response, body){
                if(body == undefined)
                    throw new Error("Could not fetch your public IP Address. Are you connected?");
                resolve(body+":"+config.port);
            });
        }
    });
}

const getGroupIdFromJoinKey = function(joinKey){
    return new Promise(function(resolve, reject){
        connection.query("SELECT gid FROM group WHERE joinKey = '"+joinKey+"';", function(error, results, fields){
            if(results.length == 0)
                resolve(null)
            else    
                resolve(results[0]["gid"]);
        });      
    });
}

const getParticipantIdFromGroupId = function(groupId, participantKey){
    return new Promise(function(resolve, reject){
        connection.query("SELECT pid FROM participants WHERE gid = '"+groupId+"' AND participantKey = '"+participantKey+"';", function(error, results, fields){
            if(results.length == 0)
                resolve(null)
            else    
                resolve(results[0]["pid"]);
        });      
    });
}

const jsArrayToSqlArray = function(lst){
    sqlArr = "(";
    if(lst.length == 0){
        lst = [];
        sqlArr = "('')";
    }
    else{
        for(var x = 0; x < lst.length; x++){
        if(x != lst.length - 1)
            sqlArr += "'"+lst[x]+"',";
        else
            sqlArr += "'"+lst[x]+"'";
        }
        sqlArr += ")";
    }
    return sqlArr;
}


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

router.post('/newgroup', async function(req, res){
    const username = addslashes(req.body.username);
    const publicKey = addslashes(req.body.publicKey);
    const joinKey = sha256(makeJoinKey(1000)+(new Date().getTime().toString()))+await getServerIp();
    const participantKey = sha256(makeJoinKey(1000)+(new Date().getTime().toString()));
    if(sha256(passphrase) == config.sha256Password){
        connection.query("INSERT INTO groups (joinKey, name) VALUES ('"+joinKey+"', 'Chatroom');", function(error, results, fields){
            connection.query("INSERT INTO participants (gid, username, publicKey, participantKey) VALUES ('"+results["insertId"]+"', '"+username+"', '"+publicKey+"', '"+participantKey+"');", function(error, results, fields){
                res.send(JSON.stringify({
                    "joinKey": joinKey,
                    "participantKey": participantKey
                }));
            });
        });
    }
    else{
        res.send("false");
    }
});

router.post('/joingroup', async function(req, res){
    const username = addslashes(req.body.username);
    const publicKey = addslashes(req.body.publicKey);
    const joinKey = addslashes(req.body.joinKey);
    const groupId = await getGroupIdFromJoinKey(joinKey);
    const participantKey = sha256(makeJoinKey(1000)+(new Date().getTime().toString()));
    if(groupId == null)
        res.send("0");
    else{
        //Valid Join Key
        const groupId = results[0]["gid"];
        connection.query("SELECT * FROM participants WHERE gid = '"+groupId+"';", function(error, results, fields){
            if(results.length < config.maxParticipantsPerGroup){
                connection.query("INSERT INTO participants (gid, username, publicKey) VALUES ('"+groupId+"', '"+username+"', '"+publicKey+"');", function(error, results, fields){
                    if(error)
                        res.send("-2");
                    else
                        res.send(participantKey);
                });
            }
            else{
                res.send("-1");
            }
        });          
    }
});

router.put('/setgroupname', function(req, res){
    const joinKey = addslashes(req.body.joinKey);
    const participantKey = addslashes(req.body.participantKey);
    const groupId = await getGroupIdFromJoinKey(joinKey);
    const participantId = await getParticipantIdFromGroupId(groupId, participantKey);
    if(groupId != null && participantId != null){
        connection.query("UPDATE groups SET name = '"+groupName+"' WHERE gid = '"+groupId+"';", function(error, results, fields){
            if(error)
                res.send("0");
            else    
                res.send("1");
        });
    }

});

router.get('/getgroupname', function(req, res){
    const joinKey = addslashes(req.body.joinKey);
    const participantKey = addslashes(req.body.participantKey);
    const groupId = await getGroupIdFromJoinKey(joinKey);
    const participantId = await getParticipantIdFromGroupId(groupId, participantKey);
    if(groupId != null && participantId != null){
        connection.query("SELECT * FROM participants WHERE gid = '"+groupId+"'", async function(error, results, fields){
            if(results.length == 1){
                res.send(await getServerIp());
            }
            if(results.length == 2){
                connection.query("SELECT username FROM participants WHERE pid != '"+participantId+"';", function(error, results, fields){
                    res.send(results[0]["username"]);
                });
            }
            else{
                connection.query("SELECT name FROM groups WHERE gid = '"+groupId+"';", function(error, results, fields){
                    res.send(results[0]["name"]);
                });
            }
        });
    }
});

router.post('/message', async function(req, res){
    const encryptedMessage = addslashes(req.body.encryptedMessage);
    const joinKey = addslashes(req.body.joinKey);
    const participantKey = addslashes(req.body.participantKey);
    const groupId = await getGroupIdFromJoinKey(joinKey);
    const participantId = await getParticipantIdFromGroupId(groupId, participantKey);
    if(groupId != null && participantId != null){
        connection.query("INSERT INTO messages (pid, message) VALUES ('"+participantId+"', '"+encryptedMessage+"');", function(error, results, fields){
            if(error)
                res.send("false");
            else
                res.send("true");
        });
    }
});

router.get('/messages', async function(req, res){
    const joinKey = addslashes(req.body.joinKey);
    const participantKey = addslashes(req.body.participantKey);  
    const groupId = await getGroupIdFromJoinKey(joinKey);
    const participantId = await getParticipantIdFromGroupId(groupId, participantKey);  
    var offset = JSON.parse(addslashes(req.body.offset));
    try{
        if(groupId != null && participantId != null){
            offset = jsArrayToSqlArray(offset);
            connection.query("SELECT ts FROM participants WHERE pid = '"+participantId+"' AND gid = '"+groupId+"';", function(error, results, fields){
                const userJoinTs = results[0]["ts"];
                connection.query("SELECT * FROM messages JOIN participants ON messages.pid = participants.pid WHERE participants.gid = '"+groupId+"' AND messages.mid NOT IN "+offset+" AND messages.ts > '"+userJoinTs+"' GROUP BY recipients.rid ORDER BY messages.ts DESC LIMIT 20;", function(error, results, fields){
                    if(error)
                        res.send("0");
                    else{
                        var messages = {};
                        for(var x = 0; x < results.length; x++){
                            if(messages[mid] == null){
                                messages[mid] = {
                                    "message": results[x]["message"],
                                    "ts": new Date().getTime(results[x]["ts"])
                                }
                            }
                            messages[mid]["recipients"][results[x]["username"]] = results[x]["publicKey"];
                        }
                        res.send(messages);
                    }            
                }); 
            });
        }       
    }
    catch(err){
        res.send("0")
    }
});

router.get('/anynewmessages', async function(req, res){
    const joinKey = addslashes(req.body.joinKey);
    const participantKey = addslashes(req.body.participantKey);  
    const groupId = await getGroupIdFromJoinKey(joinKey);
    const participantId = await getParticipantIdFromGroupId(groupId, participantKey);  
    var offset = JSON.parse(addslashes(req.body.offset));
    try{
        if(groupId != null && participantId != null){
            offset = jsArrayToSqlArray(offset);
            connection.query("SELECT ts FROM participants WHERE pid = '"+participantId+"' AND gid = '"+groupId+"';", function(error, results, fields){
                const userJoinTs = results[0]["ts"];
                connection.query("SELECT * FROM messages JOIN participants ON messages.pid = participants.pid WHERE participants.gid = '"+groupId+"' AND messages.mid NOT IN "+offset+" AND messages.ts > '"+userJoinTs+"' GROUP BY recipients.rid ORDER BY messages.ts DESC LIMIT 20;", function(error, results, fields){
                    if(results.length > 0)
                        res.send("true");
                    else
                        res.send("false");            
                }); 
            });
        }       
    }
    catch(err){
        res.send("false")
    }
});

router.get('/participants', async function(req, res){
    const joinKey = addslashes(req.body.joinKey);
    const participantKey = addslashes(req.body.participantKey);
    const groupId = await getGroupIdFromJoinKey(joinKey);
    const participantId = await getParticipantIdFromGroupId(groupId, participantKey);
    if(groupId != null && participantId != null){
        var participants = {};
        connection.query("SELECT * FROM participants WHERE gid = '"+groupId+"';", function(error, results, fields){
            for(var x = 0; x < results.length; x++){
                participants[results[x]["username"]] = {
                    "publicKey": results[x]["publicKey"],
                    "joined": results[x]["ts"]
                };
            }
            res.send(participants);
        });     
    }
});
