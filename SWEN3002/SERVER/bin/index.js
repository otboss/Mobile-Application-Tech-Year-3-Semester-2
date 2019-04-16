//MODULES
const express = require("express");
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const bodyParser = require('body-parser');
const sha256 = require('sha256');
const fs = require('fs');
const os = require('os');
const exec = require('child_process').exec;
const https = require('https');
const bigInt = require("big-integer");
const request = require('request');
const elliptic = require('elliptic');
const ec = new elliptic.ec('secp256k1');
const readline = require('readline').createInterface({
    input: process.stdin,
    output: process.stdout
});
if(fs.existsSync("./config.json") == false){
    fs.writeFileSync("./config.json", "ewogICAgInNlcnZlcklwIjogIjxTZXJ2ZXIgSXAgQWRkcmVzcyBIZXJlPiIsCiAgICAiYXV0b0lwRGV0ZWN0aW9uIjogdHJ1ZSwKICAgICJzaG93QWR2ZXJ0aXNtZW50cyI6IHRydWUsCiAgICAiYWRtb2RJZCI6ImNhLWFwcC1wdWItMzk0MDI1NjA5OTk0MjU0NC82MzAwOTc4MTExIiwKICAgICJlbmFibGVIVFRQUyI6IHRydWUsCiAgICAia2V5UGF0aCI6Ii4va2V5LnBlbSIsCiAgICAiY2VydFBhdGgiOiIuL2NlcnQucGVtIiwKICAgICJzYXZlRXh0ZXJuYWxTZXJ2ZXJzIjogdHJ1ZSwKICAgICJzaGEyNTZQYXNzd29yZCI6ICIwMWJhNDcxOWM4MGI2ZmU5MTFiMDkxYTdjMDUxMjRiNjRlZWVjZTk2NGUwOWMwNThlZjhmOTgwNWRhY2E1NDZiIiwKICAgICJtYXhQYXJ0aWNpcGFudHNQZXJHcm91cCI6IDEwMCwKICAgICJwb3J0IjogNjMzMywKICAgICJkYXRhYmFzZUNvbmZpZyI6ewogICAgICAgICJob3N0IjoibG9jYWxob3N0IiwKICAgICAgICAidXNlciI6InJvb3QiLAogICAgICAgICJwYXNzd29yZCI6IiIsCiAgICAgICAgImRhdGFiYXNlIjoiY2lwaGVyY2hhdCIsCiAgICAgICAgInBvcnQiOiAzMzA2CiAgICB9Cn0=", 'base64');
}
const config = JSON.parse(fs.readFileSync("./config.json",{encoding: "utf8"}));
var mysql      = require('mysql');
var connection = mysql.createConnection({
  host     : config.databaseConfig.host,
  user     : config.databaseConfig.user,
  password : config.databaseConfig.password,
  database : config.databaseConfig.database,
  port     : config.databaseConfig.port
});
const execute = function (command, callback) {
    exec(command, { maxBuffer: 1024 * 250 }, function (error, stdout, stderr) {
        callback(error, stdout, stderr);
    });
};
/** Column Definitions
 * (groupsTable => gid, name, joinKey, ts)
 * (participantsTable => pid, gid, username, publicKey, publicKey2, ts)
 * (messagesTable => mid, gid, pid, messages, compositeKey, ts)
 * (expiredSignaturesTable => exsid, gid, r, s, ts)
 * (serversTable => sid, ip, port, page, ts)
*/
const databaseTables = {
    "groupsTable": "groups",
    "participantsTable": "participants",
    "messagesTable": "messages",
    "expiredSignaturesTable": "expiredSignatures",
    "serversTable": "servers"
};

try{
    connection.connect();
    if(os.platform() == "linux"){
        //Attempt to import sql automatically
        if(fs.existsSync("./db.sql") == false){
            fs.writeFileSync("./db.sql", "Q1JFQVRFIERBVEFCQVNFIGNpcGhlcmNoYXQ7ClVTRSBjaXBoZXJjaGF0OwoKQ1JFQVRFIFRBQkxFIElGIE5PVCBFWElTVFMgZ3JvdXBzKAogICAgZ2lkIElOVCgxMSkgTk9UIE5VTEwgQVVUT19JTkNSRU1FTlQsCiAgICBuYW1lIFZBUkNIQVIoNTApLAogICAgam9pbktleSBWQVJDSEFSKDEwMCkgTk9UIE5VTEwsCiAgICB0cyBUSU1FU1RBTVAgREVGQVVMVCBDVVJSRU5UX1RJTUVTVEFNUCBOT1QgTlVMTCwKICAgIFVOSVFVRShqb2luS2V5KSwKICAgIFBSSU1BUlkgS0VZKGdpZCkKKTsKCkNSRUFURSBUQUJMRSBJRiBOT1QgRVhJU1RTIHBhcnRpY2lwYW50cygKICAgIHBpZCBJTlQoMTEpIE5PVCBOVUxMIEFVVE9fSU5DUkVNRU5ULAogICAgZ2lkIElOVCgxMSkgTk9UIE5VTEwsCiAgICB1c2VybmFtZSBWQVJDSEFSKDI1NSkgTk9UIE5VTEwsCiAgICBwdWJsaWNLZXkgVkFSQ0hBUigxMDApIE5PVCBOVUxMLAogICAgcHVibGljS2V5MiBWQVJDSEFSKDEwMCkgTk9UIE5VTEwsCiAgICB0cyBUSU1FU1RBTVAgREVGQVVMVCBDVVJSRU5UX1RJTUVTVEFNUCBOT1QgTlVMTCwKICAgIFVOSVFVRShnaWQsIHVzZXJuYW1lKSwKICAgIFBSSU1BUlkgS0VZKHBpZCksCiAgICBGT1JFSUdOIEtFWShnaWQpIFJFRkVSRU5DRVMgZ3JvdXBzKGdpZCkKKTsKCkNSRUFURSBUQUJMRSBJRiBOT1QgRVhJU1RTIG1lc3NhZ2VzKAogICAgbWlkIElOVCgxMSkgTk9UIE5VTEwgQVVUT19JTkNSRU1FTlQsCiAgICBnaWQgSU5UKDExKSBOT1QgTlVMTCwKICAgIHBpZCBJTlQoMTEpIE5PVCBOVUxMLAogICAgbWVzc2FnZSBURVhUIE5PVCBOVUxMLAogICAgY29tcG9zaXRlS2V5IFZBUkNIQVIoMjU1KSBOT1QgTlVMTCwKICAgIHRzIFRJTUVTVEFNUCBERUZBVUxUIENVUlJFTlRfVElNRVNUQU1QIE5PVCBOVUxMLAogICAgUFJJTUFSWSBLRVkobWlkKSwKICAgIEZPUkVJR04gS0VZKHBpZCkgUkVGRVJFTkNFUyBwYXJ0aWNpcGFudHMocGlkKQopOwoKQ1JFQVRFIFRBQkxFIElGIE5PVCBFWElTVFMgZXhwaXJlZFNpZ25hdHVyZXMoCiAgICBleHNpZCBJTlQoMTEpIE5PVCBOVUxMIEFVVE9fSU5DUkVNRU5ULAogICAgZ2lkIElOVCgxMSkgTk9UIE5VTEwsCiAgICByIFZBUkNIQVIoMTAwKSwKICAgIHMgVkFSQ0hBUigxMDApLAogICAgdHMgVElNRVNUQU1QIERFRkFVTFQgQ1VSUkVOVF9USU1FU1RBTVAgTk9UIE5VTEwsCiAgICBVTklRVUUoZ2lkLCByLCBzKSwKICAgIFBSSU1BUlkgS0VZKGV4c2lkKSwKICAgIEZPUkVJR04gS0VZKGdpZCkgUkVGRVJFTkNFUyBncm91cHMoZ2lkKSAKKTsKCkNSRUFURSBUQUJMRSBJRiBOT1QgRVhJU1RTIHNlcnZlcnMoCiAgICBzaWQgSU5UKDExKSBOT1QgTlVMTCBBVVRPX0lOQ1JFTUVOVCwKICAgIGlwIFZBUkNIQVIoNTApIE5PVCBOVUxMLAogICAgcG9ydCBJTlQoMTEpLAogICAgcGFnZSBJTlQoMTEpLAogICAgdHMgVElNRVNUQU1QIERFRkFVTFQgQ1VSUkVOVF9USU1FU1RBTVAgTk9UIE5VTEwsCiAgICBVTklRVUUoaXAsIHBvcnQpLAogICAgUFJJTUFSWSBLRVkoc2lkKQopOw==", 'base64');
        }
        execute("mysql -u"+config.databaseConfig.user+" < db.sql", function(error, stdout, stderr){});
        execute("mysql -u"+config.databaseConfig.user+" -p"+config.databaseConfig.database+" < db.sql", function(error, stdout, stderr){});
    }
}
catch(err){
    throw new Error("Could not connect to database. Please start your mysql server and configure your server accordingly.");
}


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

/** Fetches the servers Current IP address*/
const getServerIp = function(){
    return new Promise(function(resolve, reject){
        if(!config.autoIpDetection){
            resolve(config.serverIp+":"+config.port);
        }
        else{
            request("http://ipecho.net/plain", {timeout: 5000}, function(error, response, body){
                if(body == undefined)
                    reject("Could not fetch your public IP Address. Are you connected?");
                resolve(body+":"+config.port);
            });
        }
    });
}

const generateNewCertificate = function(){
    return new Promise(function(resolve, reject){
        execute(`openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
        -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" \
        -keyout key.pem  -out cert.pem`, function(err, stdout, stderr){
            resolve(true);
        });
    });
}

const getGroupIdFromJoinKey = function(joinKey){
    return new Promise(function(resolve, reject){
        connection.query("SELECT gid FROM "+databaseTables.groupsTable+" WHERE joinKey = '"+joinKey+"';", function(error, results, fields){
            if(results.length == 0)
                resolve(null)
            else    
                resolve(results[0]["gid"]);
        });      
    });
}

const getParticipantIdFromGroupId = function(groupId, username){
    return new Promise(function(resolve, reject){
        connection.query("SELECT pid FROM "+databaseTables.participantsTable+" WHERE gid = '"+groupId+"' AND username = '"+username+"';", function(error, results, fields){
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

/** Verifies the origin's authenticity*/
const verifySignature = function(gid, pid, message, r, s){
    return new Promise(function(resolve, reject){
        var badResult = function(){
            resolve({
                "isValid": false,
                "publicKey": null
            });
        }
        if(gid != null && pid != null){
            const hashedMessage = sha256(message);
            var signature = ec.sign("", ec.genKeyPair(), "hex", {canonical: true});
            signature["r"] = r;
            signature["s"] = s;
            const pubKeyRecovered = ec.recoverPubKey(bigInt(hashedMessage, 16), signature, signature.recoveryParam, "hex");
            if(ec.verify(hashedMessage, signature, pubKeyRecovered)){
                connection.query("SELECT * FROM "+databaseTables.expiredSignaturesTable+" WHERE gid = '"+gid+"' AND r = '"+r+"' AND s = '"+r+"';", function(error, results, fields){
                    if(results.length == 0){
                        connection.query("INSERT INTO "+databaseTables.expiredSignaturesTable+" (gid, r, s) VALUES ('"+gid+"', '"+r+"', '"+s+"');", function(error, results, fields){
                            connection.query("SELECT * FROM "+databaseTables.participantsTable+" WHERE gid = '"+gid+"' AND publicKey2 = '"+pubKeyRecovered["x"].toString()+"';", function(error, results, fields){
                                if(results.length > 0){
                                    resolve({
                                        "isValid": ec.verify(hashedMessage, signature, pubKeyRecovered),
                                        "publicKey": pubKeyRecovered["x"].toString()
                                    });
                                }
                                else{
                                    badResult();
                                }
                            });
                        });
                    }
                    else{
                        badResult();
                    }
                });
            }
            else{
                badResult();
            }
        }
        else{
            badResult();
        }
    });
}

const getCurrentGithubServersPage = async function(){

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
        message: "try again later."
    })
);

//REQUEST BODY PARSER
router.use(bodyParser.urlencoded({ extended: false }));
router.use(bodyParser.json());


//BOOT MESSAGE
console.log(`
==========================
BOOTED A CipherChat SERVER
==========================
Selected Port: `+config.port+`
HTTPS: `+config.enableHTTPS+`
Admob ID: `+config.admodId+`
Debug Mode: true

Starting Server..
`);

new Promise(function(resolve, reject){
    if(config.enableHTTPS){
        const checkForCertificate = async function(){
            return new Promise(function(resolve, reject){
                try{
                    if(!fs.existsSync(config.keyPath) || !fs.existsSync(config.certPath))
                        throw new Error();
                    else
                        resolve();
                }
                catch(err){
                    if(os.platform == "linux"){
                        console.log("It appears HTTPS is enabled, however the key/certificate files are missing.");
                        readline.question("Would you like to generate them now? (requires openssl) [Y/n] ", function(response){
                            readline.close();
                            if(response != "n" && response != "N"){
                                console.log("\nGenerating 4096 bit Certificate..");
                                generateNewCertificate().then(function(){
                                    console.log("Done!\n");
                                    resolve();
                                });
                            }
                            else{
                                console.log("\n\nExiting..\n");
                                throw new Error();
                            }
                        });
                    }
                    else{
                        throw new Error("Unable to find key/certificate file(s)");
                    }
                }
            });
        }
        checkForCertificate().then(function(data){
            const credentials = {
                key: fs.readFileSync(config.keyPath, "utf8"),
                cert: fs.readFileSync(config.certPath, "utf8")
            }    
            https.createServer(credentials, router).listen(config.port, async function () {
                resolve();
            });
        });
    }
    else{
        router.listen(config.port, async function () {
            resolve();
        });
    }
}).then(async function(){
    console.log("CipherChat SERVER STARTED. Now Listening on port "+config.port);
    var ip = "<Your Public IP Address>";
    try{
        ip = await getServerIp();
        ip = ip.split(":")[0];
    }
    catch(err){
        //Connection Error
    }
    console.log(`\nThis server may be submitted at:
'https://github.com/CipherChat/CipherChat/issues/new'
with the title 'Public Server Submission' and the comment of: 

{
    "ip": "`+ip+`",
    "port": "`+config.port+`"
}
`);
    console.log("=========================================================")
    console.log("| Remember to forward port "+config.port+" in your router settings |");
    console.log("| for global access this server.                        |")    
    console.log("=========================================================")
    console.log("");
});


///////////////
//SERVER ROUTES
///////////////

router.get('/', function (req, res) {
    //FOR TESTING PURPOSES
    res.send('HELLO WORLD');
});

router.get('/ads', function(req, res){
    res.send(config.admodId);
});

router.post('/newgroup', async function(req, res){
    if(Object.keys(req.body).length == 0){
        res.send("");
        return null;        
    }    
    const username = addslashes(req.body.username);
    const publicKey = addslashes(req.body.publicKey);
    const publicKey2 = addslashes(req.body.publicKey2);
    const passphrase = addslashes(req.body.passphrase);
    const joinKey = sha256(makeJoinKey(1000)+(new Date().getTime().toString()));
    const hashedJoinKey = sha256(joinKey); 
    console.log(req.body);
    console.log("THE PASSPHRASE SEND BY THE CLIENT IS: ");
    console.log(sha256(passphrase));
    console.log("THE PASSPHRASE OF THE SERVER IS: ");
    console.log(config.sha256Password);
    try{
        bigInt(publicKey).toString();
        if(sha256(passphrase) == config.sha256Password){
            connection.query("INSERT INTO "+databaseTables.groupsTable+" (joinKey, name) VALUES ('"+hashedJoinKey+"', 'Chatroom');", function(error, results, fields){
                console.log("GROUP INSERT ID IS: ");
                console.log(results["insertId"]);
                connection.query("INSERT INTO "+databaseTables.participantsTable+" (gid, username, publicKey, publicKey2) VALUES ('"+results["insertId"]+"', '"+username+"', '"+publicKey+"', '"+publicKey2+"');", function(error, results, fields){
                    res.send(joinKey);
                });
            });            
        }
        else{
            console.log("INCORRECT PASSPHRASE");
            res.send("0");
        }
    }
    catch(err){
        res.send("-1");
    }
});

router.post('/joingroup', async function(req, res){
    if(Object.keys(req.body).length == 0){
        res.send("");
        return null;        
    }    
    const encryptedMessage = addslashes(req.query.joinKey);
    const signature = addslashes(req.body.signature);       
    const username = addslashes(req.body.username);
    const publicKey = addslashes(req.body.publicKey);
    const publicKey2 = addslashes(req.body.publicKey2);
    const joinKey = addslashes(req.body.joinKey);
    const groupId = await getGroupIdFromJoinKey(sha256(joinKey));
    try{
        if(groupId == null)
            res.send("0");
        const sig = JSON.parse(signature);
        const signatureVerification = await verifySignature(groupId, true, encryptedMessage, sig["r"], sig["s"]);
        if(signatureVerification["isValid"]){
            bigInt(publicKey).toString();
            bigInt(publicKey2).toString();
            const groupId = results[0]["gid"];
            connection.query("SELECT * FROM "+databaseTables.participantsTable+" WHERE gid = '"+groupId+"';", function(error, results, fields){
                if(results.length < config.maxParticipantsPerGroup){
                    connection.query("SELECT * FROM "+databaseTables.participantsTable+" WHERE username = '"+username+"';", function(error, resuilts, fields){
                        if(results.length > 0){
                            //Already joined group
                            res.send("-3")
                        }
                        else{
                            connection.query("INSERT INTO "+databaseTables.participantsTable+" (gid, username, publicKey, publicKey2) VALUES ('"+groupId+"', '"+username+"', '"+publicKey+"', '"+publicKey2+"');", function(error, results, fields){
                                if(error)
                                    res.send("-2");
                                else
                                    res.send("1");
                            });
                        }                     
                    });

                }
                else{
                    res.send("-1");
                }
            });   
        }              
    }
    catch(err){
        console.log(err);
        res.send("-3");
    }  
});

router.put('/setgroupname', async function(req, res){
    if(Object.keys(req.body).length == 0){
        res.send("");
        return null;        
    }    
    const encryptedMessage = addslashes(req.query.joinKey);
    const signature = addslashes(req.body.signature);       
    const joinKey = addslashes(req.body.joinKey);
    const groupId = await getGroupIdFromJoinKey(sha256(joinKey)); 
    try{
        const sig = JSON.parse(signature);
        const signatureVerification = await verifySignature(groupId, participantId, encryptedMessage, sig["r"], sig["s"]);
        if(signatureVerification["isValid"]){
            connection.query("UPDATE "+databaseTables.groupsTable+" SET name = '"+groupName+"' WHERE gid = '"+groupId+"';", function(error, results, fields){
                if(error)
                    res.send("0");
                else    
                    res.send("1");
            });
        }
    }
    catch(err){
        console.log(err);
        res.send("0");
    }
});

router.get('/getgroupname', async function(req, res){
    if(Object.keys(req.body).length == 0){
        res.send("");
        return null;        
    }    
    const encryptedMessage = addslashes(req.query.encryptedMessage);
    const signature = addslashes(req.body.signature);      
    const joinKey = addslashes(req.body.joinKey);    
    const username = addslashes(req.body.username);
    const groupId = await getGroupIdFromJoinKey(sha256(joinKey));
    const participantId = await getParticipantIdFromGroupId(groupId, username);
    try{
        const sig = JSON.parse(signature);
        const signatureVerification = await verifySignature(groupId, participantId, encryptedMessage, sig["r"], sig["s"]);
        if(signatureVerification["isValid"]){
            connection.query("SELECT * FROM "+databaseTables.participantsTable+" WHERE gid = '"+groupId+"'", async function(error, results, fields){
                if(results.length == 1){
                    res.send(await getServerIp());
                }
                if(results.length == 2){
                    connection.query("SELECT username FROM "+databaseTables.participantsTable+" WHERE pid != '"+participantId+"';", function(error, results, fields){
                        res.send(results[0]["username"]);
                    });
                }
                else{
                    connection.query("SELECT name FROM "+databaseTables.groupsTable+" WHERE gid = '"+groupId+"';", function(error, results, fields){
                        res.send(results[0]["name"]);
                    });
                }
            });
        }
    }
    catch(err){
        console.log(err);
    }
});

router.post('/message', async function(req, res){
    if(Object.keys(req.body).length == 0){
        res.send("");
        return null;        
    }    
    const encryptedMessage = addslashes(req.body.encryptedMessage);
    const signature = addslashes(req.body.signature);
    const joinKey = addslashes(req.body.joinKey);
    const username = addslashes(req.body.username);
    const compositeKey = addslashes(req.body.compositeKey); 
    const groupId = await getGroupIdFromJoinKey(sha256(joinKey));
    const participantId = await getParticipantIdFromGroupId(groupId, username);
    try{
        const sig = JSON.parse(signature);
        const signatureVerification = await verifySignature(groupId, participantId, encryptedMessage, sig["r"], sig["s"]);
        if(signatureVerification["isValid"]){
            connection.query("INSERT INTO "+databaseTables.messagesTable+" (pid, message, compositeKey) VALUES ('"+participantId+"', '"+encryptedMessage+"', '"+compositeKey+"');", function(error, results, fields){
                if(error)
                    res.send("false");
                else
                    res.send("true");
            }); 
        } 
    }
    catch(err){
        console.log(err);
    }
});

router.get('/messages', async function(req, res){
    if(Object.keys(req.body).length == 0){
        res.send("");
        return null;        
    }    
    const encryptedMessage = addslashes(req.query.joinKey);
    const signature = addslashes(req.body.signature);
    const joinKey = addslashes(req.query.joinKey);
    const username = addslashes(req.query.username);      
    var offset = JSON.parse(addslashes(req.query.offset));
    const groupId = await getGroupIdFromJoinKey(sha256(joinKey));
    const participantId = await getParticipantIdFromGroupId(groupId, username);  
    try{
        const sig = JSON.parse(signature);
        const signatureVerification = await verifySignature(groupId, participantId, encryptedMessage, sig["r"], sig["s"]);  
        if(signatureVerification["isValid"]){
            connection.query("SELECT ts FROM "+databaseTables.participantsTable+" WHERE pid = '"+participantId+"' AND gid = '"+groupId+"';", function(error, results, fields){
                const userJoinTs = results[0]["ts"];
                connection.query("SELECT * FROM "+databaseTables.messagesTable+" JOIN "+databaseTables.participantsTable+" ON "+databaseTables.messagesTable+".gid = "+databaseTables.participantsTable+".gid WHERE "+databaseTables.messagesTable+".gid = '"+groupId+"' AND "+databaseTables.messagesTable+".mid > '"+offset+"' AND "+databaseTables.messagesTable+".ts > '"+userJoinTs+"' ORDER BY "+databaseTables.messagesTable+".ts DESC LIMIT 20;", function(error, results, fields){
                    if(error)
                        res.send("0");
                    else{
                        var messages = {};
                        for(var x = 0; x < results.length; x++){
                            connection.query("SELECT pid, username, UNIX_TIMESTAMP(ts)*1000 time FROM "+databaseTables.messagesTable+" JOIN "+databaseTables.participantsTable+" ON "+databaseTables.messagesTable+".pid = "+databaseTables.participantsTable+".pid WHERE "+databaseTables.messagesTable+".mid = '"+results[x]["mid"]+"';", function(error, senderInfo, fields){
                                messages[results[x]["mid"]] = {
                                    "sender": senderInfo[0]["username"],
                                    "message": results[x]["message"],
                                    "compositeKey": results[x]["compositeKey"],
                                    "ts": results[x]["time"]
                                }
                            });
                        }
                        res.send(messages);
                    }            
                }); 
            });
        }   
    }
    catch(err){
        console.log(err);
        res.send("0")
    }
});

router.get('/anynewmessages', async function(req, res){
    if(Object.keys(req.body).length == 0){
        res.send("");
        return null;        
    }    
    const encryptedMessage = addslashes(req.query.joinKey);
    const signature = addslashes(req.body.signature);
    const joinKey = addslashes(req.query.joinKey);
    const username = addslashes(req.query.username);  
    var offset = JSON.parse(addslashes(req.query.offset));
    const groupId = await getGroupIdFromJoinKey(sha256(joinKey));
    const participantId = await getParticipantIdFromGroupId(groupId, username);  
    try{
        const sig = JSON.parse(signature);
        const signatureVerification = await verifySignature(groupId, participantId, encryptedMessage, sig["r"], sig["s"]);  
        if(signatureVerification["isValid"]){
            offset = jsArrayToSqlArray(offset);
            connection.query("SELECT ts FROM "+databaseTables.participantsTable+" WHERE pid = '"+participantId+"' AND gid = '"+groupId+"';", function(error, results, fields){
                const userJoinTs = results[0]["ts"];
                connection.query("SELECT * FROM "+databaseTables.messagesTable+" JOIN "+databaseTables.participantsTable+" ON "+databaseTables.messagesTable+".gid = "+databaseTables.participantsTable+".gid WHERE "+databaseTables.messagesTable+".gid = '"+groupId+"' AND "+databaseTables.messagesTable+".mid > "+offset+" AND "+databaseTables.messagesTable+".ts > '"+userJoinTs+"' ORDER BY "+databaseTables.messagesTable+".ts DESC LIMIT 20;", function(error, results, fields){
                    if(error)
                        res.send("0");
                    else{
                        if(results.length > 0)
                            res.send("true");
                        else
                            res.send("false");
                    }            
                }); 
            });
        }   
    }
    catch(err){
        console.log(err);
        res.send("false")
    }
});

router.get('/participants', async function(req, res){
    if(Object.keys(req.body).length == 0){
        res.send("");
        return null;        
    }    
    const encryptedMessage = addslashes(req.query.joinKey);
    const signature = addslashes(req.body.signature);    
    const joinKey = addslashes(req.query.joinKey);
    const username = addslashes(req.query.username);
    const groupId = await getGroupIdFromJoinKey(sha256(joinKey));
    const participantId = await getParticipantIdFromGroupId(groupId, username);
    try{
        const sig = JSON.parse(signature);
        const signatureVerification = await verifySignature(groupId, participantId, encryptedMessage, sig["r"], sig["s"]);  
        if(signatureVerification["isValid"]){
            var participants = {};
            connection.query("SELECT * FROM "+databaseTables.participantsTable+" WHERE gid = '"+groupId+"';", function(error, results, fields){
                for(var x = 0; x < results.length; x++){
                    participants[results[x]["username"]] = {
                        "publicKey": results[x]["publicKey"],
                        "publicKey2": results[x]["publicKey2"],
                        "joined": results[x]["ts"]
                    };
                }
                res.send(participants);
            });  
        }
    }
    catch(err){
        console.log(err);
    }
});

router.get('/servers', async function(req, res){
    var offset = addslashes(req.query.offset);
    try{
        parseInt(addslashes(offset));
        if(offset < 0){
            offset = 0;
        }
    }
    catch(err){
        offset = 0;
    }
    connection.query("SELECT ip, port, page FROM "+databaseTables.serversTable+" WHERE sid > '"+offset+"' ORDER BY sid LIMIT 100;", function(error, results, fields){
        res.send(results);
    });
});
