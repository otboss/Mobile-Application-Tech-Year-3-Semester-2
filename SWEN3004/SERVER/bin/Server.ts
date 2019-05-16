import * as fs from "fs";
import { DatabaseAdapter } from "./DatabaseAdapter";
import { Config } from "./Config";
import { NewGroupRequestBody } from "./Request_Bodies/Chat_Server/NewGroupRequestBody";
import { JoinGroupRequestBody } from "./Request_Bodies/Chat_Server/JoinGroupRequestBody";
import { IsUsernameTakenRequestBody } from "./Request_Bodies/Chat_Server/IsUsernameTakenRequestBody";
import { MessageRequestBody } from './Request_Bodies/Chat_Server/MessageRequestBody';
import { MessagesRequestBody } from './Request_Bodies/Chat_Server/MessagesRequestBody';
import { ParticipantsRequestBody } from './Request_Bodies/Chat_Server/ParticipantsRequestBody';

const config:Config = new Config();
const databaseAdapter:DatabaseAdapter = new DatabaseAdapter();

if(!fs.existsSync("./config.json")){
    fs.writeFileSync("./config.json", "ewogICAgInNlcnZlcklwIjogIjxTZXJ2ZXIgSXAgQWRkcmVzcyBIZXJlPiIsCiAgICAiYXV0b0lwRGV0ZWN0aW9uIjogdHJ1ZSwKICAgICJzaG93QWR2ZXJ0aXNtZW50cyI6IHRydWUsCiAgICAiYWRtb2RJZCI6ImNhLWFwcC1wdWItMzk0MDI1NjA5OTk0MjU0NC82MzAwOTc4MTExIiwKICAgICJlbmFibGVIVFRQUyI6IHRydWUsCiAgICAia2V5UGF0aCI6Ii4va2V5LnBlbSIsCiAgICAiY2VydFBhdGgiOiIuL2NlcnQucGVtIiwKICAgICJzYXZlRXh0ZXJuYWxTZXJ2ZXJzIjogdHJ1ZSwKICAgICJzaGEyNTZQYXNzd29yZCI6ICIwMWJhNDcxOWM4MGI2ZmU5MTFiMDkxYTdjMDUxMjRiNjRlZWVjZTk2NGUwOWMwNThlZjhmOTgwNWRhY2E1NDZiIiwKICAgICJtYXhQYXJ0aWNpcGFudHNQZXJHcm91cCI6IDEwMCwKICAgICJwb3J0IjogNjMzMywKICAgICJkYXRhYmFzZUNvbmZpZyI6ewogICAgICAgICJob3N0IjoibG9jYWxob3N0IiwKICAgICAgICAidXNlciI6InJvb3QiLAogICAgICAgICJwYXNzd29yZCI6IiIsCiAgICAgICAgImRhdGFiYXNlIjoiY2lwaGVyY2hhdCIsCiAgICAgICAgInBvcnQiOiAzMzA2CiAgICB9Cn0=", 'base64');
}

const exec = require('child_process').exec;
const execute = function (command, callback) {
    exec(command, { maxBuffer: 1024 * 250 }, function (error, stdout, stderr) {
        callback(error, stdout, stderr);
    });
};

execute("echo [$PORT, $DEBUGGING]", async function(error, stdout, stderr){
    var envVariables  = new Array();
    try{
        envVariables = JSON.parse(stdout);
        if(typeof(envVariables[1]) != "boolean")
            envVariables[1] = true;
        if(typeof(envVariables[0]) != "number")
            envVariables[0] = config.instanceServerStartingPort;
        else if(envVariables[0] == config.port)
            envVariables[0] = config.instanceServerStartingPort;
    }
    catch(err){
        envVariables = [config.instanceServerStartingPort, true];
    }  
    
    const serverPort = envVariables[0];
    const debugging = envVariables[1];
    const compression = require('compression');
    const helmet = require('helmet');
    const express = require("express");
    const bodyParser = require('body-parser');
    const sha256 = require('sha256');
    const os = require('os');
    const https = require('https');
    const bigInt = require("big-integer");
    const request = require('request');
    const elliptic = require('elliptic');
    const ec = new elliptic.ec('secp256k1');
    const readline = require('readline').createInterface({
        input: process.stdin,
        output: process.stdout
    });

    /** Fetches the servers Current IP address*/
    const getServerIp = function():Promise<string>{
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

    const generateNewCertificate = function():Promise<boolean>{
        return new Promise(function(resolve, reject){
            execute(`openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
            -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" \
            -keyout key.pem  -out cert.pem`, function(err, stdout, stderr){
                if(err)
                    resolve(false);
                else
                    resolve(true);
            });
        });
    }    
    
    const checkForCertificate = function():boolean{
        try{
            if(!fs.existsSync(config.keyPath) || !fs.existsSync(config.certPath))
                throw new Error();
        }
        catch(err){
            return false;
        }
        return true;
    }    


    new Promise(async function(resolve, reject){
        if(!checkForCertificate){
            if(os.platform() == "linux"){
                console.log("It appears HTTPS is enabled, however the key/certificate files are missing.");
                readline.question("Would you like to generate them now? (requires openssl) [Y/n] ", function(response){
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
                    readline.close();
                });
            }
            else{
                throw new Error("Unable to find key/certificate file(s)");
            }
        }

console.log(`
==========================
BOOTED A CipherChat SERVER
==========================
Selected Port: `+config.port+`
Debug Mode: true

Starting Server..
`); 
        
        console.log("CipherChat SERVER STARTED. Now Listening on port "+config.port);
        console.log("You may check the server at https://127.0.0.1:"+config.port+"/");
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
        
        const verifySignature = function(gid:number, pid:number, message:string, r:string, s:string, recoveryParam:number):Promise<SignatureVerificationResults>{
            return new Promise(function(resolve, reject){
                var badResult = function():void{
                    resolve(new SignatureVerificationResults(false, null));
                }        
                if(gid != null && pid != null){
                    const hashedMessage:string = sha256(message);
                    const signature:Signature = new Signature(r, s, recoveryParam);
                    const pubKeyRecovered = ec.recoverPubKey(bigInt(hashedMessage, 16).toString(), signature.toJSON(), signature.recoveryParam, "hex");
                    const pubKeyRecoveredObj:PublicKeyRecovered = new PublicKeyRecovered(pubKeyRecovered);
                    if(ec.verify(hashedMessage, signature, pubKeyRecoveredObj.pubKeyObject)){
                        databaseAdapter.verifyPublicKey(gid, hashedMessage, pubKeyRecoveredObj, signature).then(function(result:SignatureVerificationResults){
                            resolve(result);
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

        const router = express();
        router
        .use(helmet())
        .use(compression())
        .use(bodyParser.urlencoded({ extended: false }))
        .use(bodyParser.json());
        
        if(!fs.existsSync(config.keyPath) || !fs.existsSync(config.certPath)){
            throw new Error("Could not file certificate files..");
        }
        else{
            const credentials:SSLCertificate = new SSLCertificate(fs.readFileSync(config.keyPath, "utf8"), fs.readFileSync(config.certPath, "utf8"));
            if(!debugging){
                try{
                    router.listen(serverPort);
                }
                catch(err){
                    var rebootInteger:number = config.instanceServerStartingPort;
                    while(rebootInteger <= config.instanceServerStartingPort + config.numberOfLocalhostServers){
                        try{
                            await new Promise(function(resolve, reject){
                                request("http://127.0.0.1:"+rebootInteger, function(error, response, body){
                                    if(error){
                                        //Port Available
                                        reject();
                                    }
                                    else{
                                        rebootInteger++;
                                        resolve();
                                    }
                                });
                            });  
                        }
                        catch(err){
                            break;
                        }
                    }     
                    router.listen(rebootInteger);             
                }                
            }
            else{
                https.createServer(credentials.toJSON(), router).listen(config.port, async function () {
                });
            }

            router.get('/', function (req, res) {
                //FOR TESTING PURPOSES
                res.send('HELLO WORLD');
            }); 
            
            router.post('/newgroup', async function(req, res){
                if(Object.keys(req.body).length == 0){
                    res.send("");
                    return null;        
                }    
                const newGroupRequestBody:NewGroupRequestBody = new NewGroupRequestBody(req.body);
                try{
                    bigInt(newGroupRequestBody.publicKey);
                    bigInt(newGroupRequestBody.publicKey2);
                    if(sha256(newGroupRequestBody.passphrase) == config.sha256Password){
                        res.send(await databaseAdapter.createNewGroup(newGroupRequestBody.joinKey, newGroupRequestBody.username, newGroupRequestBody.publicKey, newGroupRequestBody.publicKey2));   
                    }
                    else{
                        res.send("0");
                    }
                }
                catch(err){
                    console.log(err);
                    res.send("-1");
                }
            });          
            
            router.post('/joingroup', async function(req, res){
                if(Object.keys(req.body).length == 0){
                    res.send("");
                    return null;        
                }    
                const groupId:number = await databaseAdapter.getGroupIdFromJoinKey(req.body.joinKey);
                const joinGroupRequestBody:JoinGroupRequestBody = new JoinGroupRequestBody(request.body, groupId);
                try{
                    if(groupId == null){
                        res.send("0");
                        return null;
                    }
                    const signatureVerification:SignatureVerificationResults = await verifySignature(joinGroupRequestBody.groupId, 1, joinGroupRequestBody.encryptedMessage, joinGroupRequestBody.signature.r, joinGroupRequestBody.signature.s, joinGroupRequestBody.signature.recoveryParam);
                    if(signatureVerification.isValid){
                        bigInt(joinGroupRequestBody.publicKey).toString();
                        bigInt(joinGroupRequestBody.publicKey2).toString();
                        res.send((await databaseAdapter.insertNewParticipant(joinGroupRequestBody.groupId, joinGroupRequestBody.username, joinGroupRequestBody.publicKey, joinGroupRequestBody.publicKey2)).toString());
                    }  
                    else{
                        res.send("-4");
                    }            
                }
                catch(err){
                    console.log(err);
                    res.send("-3");
                }  
            });       
            
            router.post('/isusernametaken', async function(req, res){
                if(Object.keys(req.body).length == 0){
                    res.send("");
                    return null;        
                }    
                const groupId:number = await databaseAdapter.getGroupIdFromJoinKey(req.body.joinKey);   
                const isUsernameTakenRequestBody:IsUsernameTakenRequestBody = new IsUsernameTakenRequestBody(req.body, groupId);
                try{
                    if(groupId == null){
                        res.send("0");
                    }
                    else{
                        const signatureVerification:SignatureVerificationResults = await verifySignature(groupId, 1, isUsernameTakenRequestBody.encryptedMessage, isUsernameTakenRequestBody.signature.r, isUsernameTakenRequestBody.signature.s, isUsernameTakenRequestBody.signature.recoveryParam);
                        if(signatureVerification.isValid){
                            if(await databaseAdapter.isUsernameTaken(groupId, isUsernameTakenRequestBody.username))
                                res.send("1");
                            else    
                                res.send("0");
                        }  
                        else{
                            res.send("1");
                        } 
                    }           
                }
                catch(err){
                    console.log(err);
                    res.send("1");
                }  
            });   
            
            router.post('/message', async function(req, res){
                if(Object.keys(req.body).length == 0){
                    res.send("");
                    return null;        
                }    
                console.log("NEW MESSAGE REQUEST");
                const groupId:number = await databaseAdapter.getGroupIdFromJoinKey(req.body.joinKey);
                const messageRequestBody:MessageRequestBody = new MessageRequestBody(request.body, groupId, null);
                const participantId:number = await databaseAdapter.getParticipantIdFromGroupId(groupId, messageRequestBody.username);
                messageRequestBody.participantId = participantId;                
                console.log("THE COMPOSITE KEYS ARE: ");
                console.log(messageRequestBody.compositeKeys);
                console.log("PARTICIPANT ID: "+participantId.toString());
                console.log("NEW MESSAGE REQUEST!");
                console.log(req.body);
                try{
                    const signatureVerification:SignatureVerificationResults = await verifySignature(messageRequestBody.groupId, participantId, messageRequestBody.encryptedMessage, messageRequestBody.signature.r, messageRequestBody.signature.s, messageRequestBody.signature.recoveryParam);
                    if(signatureVerification.isValid){
                        databaseAdapter.saveMessage(messageRequestBody.groupId, messageRequestBody.participantId, messageRequestBody.encryptedMessage, messageRequestBody.compositeKeys).then(function(messageInsertionResponse){
                            if(messageInsertionResponse == null)
                                res.send("-1");
                            else
                                res.send(messageInsertionResponse.toJSON())
                        });
                    } 
                }
                catch(err){
                    console.log(err);
                }
            }); 
            
            router.get('/messages', async function(req, res){
                if(Object.keys(req.query).length == 0){
                    res.send("");
                    return null;        
                }
                const groupId:number = await databaseAdapter.getGroupIdFromJoinKey(req.body.joinKey);
                const messagesRequestBody:MessagesRequestBody = new MessagesRequestBody(request.body, groupId, null);
                const participantId:number = await databaseAdapter.getParticipantIdFromGroupId(groupId, messagesRequestBody.username);
                messagesRequestBody.participantId = participantId; 
                try{
                    const signatureVerification:SignatureVerificationResults = await verifySignature(messagesRequestBody.groupId, participantId, messagesRequestBody.encryptedMessage, messagesRequestBody.signature.r, messagesRequestBody.signature.s, messagesRequestBody.signature.recoveryParam);
                    if(signatureVerification.isValid){
                        //Get user join timestamp. Users will only receive messages
                        //with a timestamp greater than their join timestamp.
                        databaseAdapter.getMessages(messagesRequestBody.groupId, messagesRequestBody.participantId, messagesRequestBody.offset).then(function(messages){
                            res.send(messages); 
                        }).catch(function(err){
                            res.send(err);
                        });
                    }
                    else
                        console.log("SIGNATURE INVALID");
                }
                catch(err){
                    console.log(err);
                    res.send("0")
                }
            });         
            
            router.get('/participants', async function(req, res){
                if(Object.keys(req.query).length == 0){
                    res.send("");
                    return null;        
                }
                const groupId:number = await databaseAdapter.getGroupIdFromJoinKey(req.body.joinKey);
                const participantsRequestBody:ParticipantsRequestBody = new ParticipantsRequestBody(request.body, groupId, null);
                const participantId:number = await databaseAdapter.getParticipantIdFromGroupId(groupId, participantsRequestBody.username);
                participantsRequestBody.participantId = participantId;                 
                try{
                    const signatureVerification:SignatureVerificationResults = await verifySignature(participantsRequestBody.groupId, participantId, participantsRequestBody.encryptedMessage, participantsRequestBody.signature.r, participantsRequestBody.signature.s, participantsRequestBody.signature.recoveryParam);
                    if(signatureVerification.isValid){
                        databaseAdapter.getChatParticipants(participantsRequestBody.groupId).then(function(participants){
                            res.send(participants);
                        });
                    }
                    else{
                        console.log("Invalid SIgnature received at GET /participants");
                    }
                }
                catch(err){
                    console.log(err);
                }
            });            
        }        
    });
});

export class SignatureVerificationResults{
    public isValid:boolean = false;
    public publicKey:string;
    constructor(isValid:boolean, publicKey:string){
        this.isValid = isValid;
        this.publicKey = publicKey;
    }
}

export class Signature{
    public r:string;
    public s: string;
    public recoveryParam: number;
    constructor(r:string, s:string, recoveryParam:number){
        this.r = r;
        this.s = s;
        this.recoveryParam = recoveryParam;
    }
    public toJSON():object{
        return {
            "r": this.r,
            "s": this.s,
            "recoveryParam": this.recoveryParam,
        }
    }
}

export class PublicKeyRecovered{
    public xCoord:number;
    public yCoord:number;
    public pubKeyObject:object;
    constructor(rawPoint:object){
        this.xCoord = parseInt(rawPoint["x"].toString());
        this.yCoord = parseInt(rawPoint["y"].toString());
        this.pubKeyObject = rawPoint; 
    }
    public toArray(){
        return [
            this.xCoord,
            this.yCoord
        ]
    }
}

class SSLCertificate{
    public key:string;
    public cert:string;
    constructor(key:string, cert:string){
        this.key = key;
        this.cert = cert;
    }
    public toJSON():object{
        return {
            "key": this.key,
            "cert": this.cert
        }
    }
}