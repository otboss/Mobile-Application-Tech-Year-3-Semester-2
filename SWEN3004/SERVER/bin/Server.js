"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
exports.__esModule = true;
var fs = require("fs");
var DatabaseAdapter_1 = require("./DatabaseAdapter");
var Config_1 = require("./Config");
var NewGroupRequestBody_1 = require("./Request_Bodies/Chat_Server/NewGroupRequestBody");
var JoinGroupRequestBody_1 = require("./Request_Bodies/Chat_Server/JoinGroupRequestBody");
var IsUsernameTakenRequestBody_1 = require("./Request_Bodies/Chat_Server/IsUsernameTakenRequestBody");
var MessageRequestBody_1 = require("./Request_Bodies/Chat_Server/MessageRequestBody");
var MessagesRequestBody_1 = require("./Request_Bodies/Chat_Server/MessagesRequestBody");
var ParticipantsRequestBody_1 = require("./Request_Bodies/Chat_Server/ParticipantsRequestBody");
var config = new Config_1.Config();
var databaseAdapter = new DatabaseAdapter_1.DatabaseAdapter();
if (!fs.existsSync("./config.json")) {
    fs.writeFileSync("./config.json", "ewogICAgInNlcnZlcklwIjogIjxTZXJ2ZXIgSXAgQWRkcmVzcyBIZXJlPiIsCiAgICAiYXV0b0lwRGV0ZWN0aW9uIjogdHJ1ZSwKICAgICJzaG93QWR2ZXJ0aXNtZW50cyI6IHRydWUsCiAgICAiYWRtb2RJZCI6ImNhLWFwcC1wdWItMzk0MDI1NjA5OTk0MjU0NC82MzAwOTc4MTExIiwKICAgICJlbmFibGVIVFRQUyI6IHRydWUsCiAgICAia2V5UGF0aCI6Ii4va2V5LnBlbSIsCiAgICAiY2VydFBhdGgiOiIuL2NlcnQucGVtIiwKICAgICJzYXZlRXh0ZXJuYWxTZXJ2ZXJzIjogdHJ1ZSwKICAgICJzaGEyNTZQYXNzd29yZCI6ICIwMWJhNDcxOWM4MGI2ZmU5MTFiMDkxYTdjMDUxMjRiNjRlZWVjZTk2NGUwOWMwNThlZjhmOTgwNWRhY2E1NDZiIiwKICAgICJtYXhQYXJ0aWNpcGFudHNQZXJHcm91cCI6IDEwMCwKICAgICJwb3J0IjogNjMzMywKICAgICJkYXRhYmFzZUNvbmZpZyI6ewogICAgICAgICJob3N0IjoibG9jYWxob3N0IiwKICAgICAgICAidXNlciI6InJvb3QiLAogICAgICAgICJwYXNzd29yZCI6IiIsCiAgICAgICAgImRhdGFiYXNlIjoiY2lwaGVyY2hhdCIsCiAgICAgICAgInBvcnQiOiAzMzA2CiAgICB9Cn0=", 'base64');
}
var exec = require('child_process').exec;
var execute = function (command, callback) {
    exec(command, { maxBuffer: 1024 * 250 }, function (error, stdout, stderr) {
        callback(error, stdout, stderr);
    });
};
execute("echo [$PORT, $DEBUGGING]", function (error, stdout, stderr) {
    return __awaiter(this, void 0, void 0, function () {
        var envVariables, serverPort, debugging, compression, helmet, express, bodyParser, sha256, os, https, bigInt, request, elliptic, ec, readline, getServerIp, generateNewCertificate, checkForCertificate;
        return __generator(this, function (_a) {
            envVariables = new Array();
            try {
                envVariables = JSON.parse(stdout);
                if (typeof (envVariables[1]) != "boolean")
                    envVariables[1] = true;
                if (typeof (envVariables[0]) != "number")
                    envVariables[0] = config.instanceServerStartingPort;
                else if (envVariables[0] == config.port)
                    envVariables[0] = config.instanceServerStartingPort;
            }
            catch (err) {
                envVariables = [config.instanceServerStartingPort, true];
            }
            serverPort = envVariables[0];
            debugging = envVariables[1];
            compression = require('compression');
            helmet = require('helmet');
            express = require("express");
            bodyParser = require('body-parser');
            sha256 = require('sha256');
            os = require('os');
            https = require('https');
            bigInt = require("big-integer");
            request = require('request');
            elliptic = require('elliptic');
            ec = new elliptic.ec('secp256k1');
            readline = require('readline').createInterface({
                input: process.stdin,
                output: process.stdout
            });
            getServerIp = function () {
                return new Promise(function (resolve, reject) {
                    if (!config.autoIpDetection) {
                        resolve(config.serverIp + ":" + config.port);
                    }
                    else {
                        request("http://ipecho.net/plain", { timeout: 5000 }, function (error, response, body) {
                            if (body == undefined)
                                reject("Could not fetch your public IP Address. Are you connected?");
                            resolve(body + ":" + config.port);
                        });
                    }
                });
            };
            generateNewCertificate = function () {
                return new Promise(function (resolve, reject) {
                    execute("openssl req -new -newkey rsa:4096 -days 365 -nodes -x509             -subj \"/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com\"             -keyout key.pem  -out cert.pem", function (err, stdout, stderr) {
                        if (err)
                            resolve(false);
                        else
                            resolve(true);
                    });
                });
            };
            checkForCertificate = function () {
                try {
                    if (!fs.existsSync(config.keyPath) || !fs.existsSync(config.certPath))
                        throw new Error();
                }
                catch (err) {
                    return false;
                }
                return true;
            };
            new Promise(function (resolve, reject) {
                return __awaiter(this, void 0, void 0, function () {
                    var ip, err_1, verifySignature, router, credentials, err_2, rebootInteger, err_3;
                    return __generator(this, function (_a) {
                        switch (_a.label) {
                            case 0:
                                if (!checkForCertificate) {
                                    if (os.platform() == "linux") {
                                        console.log("It appears HTTPS is enabled, however the key/certificate files are missing.");
                                        readline.question("Would you like to generate them now? (requires openssl) [Y/n] ", function (response) {
                                            if (response != "n" && response != "N") {
                                                console.log("\nGenerating 4096 bit Certificate..");
                                                generateNewCertificate().then(function () {
                                                    console.log("Done!\n");
                                                    resolve();
                                                });
                                            }
                                            else {
                                                console.log("\n\nExiting..\n");
                                                throw new Error();
                                            }
                                            readline.close();
                                        });
                                    }
                                    else {
                                        throw new Error("Unable to find key/certificate file(s)");
                                    }
                                }
                                console.log("\n==========================\nBOOTED A CipherChat SERVER\n==========================\nSelected Port: " + config.port + "\nDebug Mode: true\n\nStarting Server..\n");
                                console.log("CipherChat SERVER STARTED. Now Listening on port " + config.port);
                                console.log("You may check the server at https://127.0.0.1:" + config.port + "/");
                                ip = "<Your Public IP Address>";
                                _a.label = 1;
                            case 1:
                                _a.trys.push([1, 3, , 4]);
                                return [4 /*yield*/, getServerIp()];
                            case 2:
                                ip = _a.sent();
                                ip = ip.split(":")[0];
                                return [3 /*break*/, 4];
                            case 3:
                                err_1 = _a.sent();
                                return [3 /*break*/, 4];
                            case 4:
                                console.log("\nThis server may be submitted at:\n'https://github.com/CipherChat/CipherChat/issues/new'\nwith the title 'Public Server Submission' and the comment of: \n\n{\n    \"ip\": \"" + ip + "\",\n    \"port\": \"" + config.port + "\"\n}\n");
                                console.log("=========================================================");
                                console.log("| Remember to forward port " + config.port + " in your router settings |");
                                console.log("| for global access this server.                        |");
                                console.log("=========================================================");
                                console.log("");
                                verifySignature = function (gid, pid, message, r, s, recoveryParam) {
                                    return new Promise(function (resolve, reject) {
                                        var badResult = function () {
                                            resolve(new SignatureVerificationResults(false, null));
                                        };
                                        if (gid != null && pid != null) {
                                            var hashedMessage = sha256(message);
                                            var signature = new Signature(r, s, recoveryParam);
                                            var pubKeyRecovered = ec.recoverPubKey(bigInt(hashedMessage, 16).toString(), signature.toJSON(), signature.recoveryParam, "hex");
                                            var pubKeyRecoveredObj = new PublicKeyRecovered(pubKeyRecovered);
                                            if (ec.verify(hashedMessage, signature, pubKeyRecoveredObj.pubKeyObject)) {
                                                databaseAdapter.verifyPublicKey(gid, hashedMessage, pubKeyRecoveredObj, signature).then(function (result) {
                                                    resolve(result);
                                                });
                                            }
                                            else {
                                                badResult();
                                            }
                                        }
                                        else {
                                            badResult();
                                        }
                                    });
                                };
                                router = express();
                                router
                                    .use(helmet())
                                    .use(compression())
                                    .use(bodyParser.urlencoded({ extended: false }))
                                    .use(bodyParser.json());
                                if (!(!fs.existsSync(config.keyPath) || !fs.existsSync(config.certPath))) return [3 /*break*/, 5];
                                throw new Error("Could not file certificate files..");
                            case 5:
                                credentials = new SSLCertificate(fs.readFileSync(config.keyPath, "utf8"), fs.readFileSync(config.certPath, "utf8"));
                                if (!!debugging) return [3 /*break*/, 15];
                                _a.label = 6;
                            case 6:
                                _a.trys.push([6, 7, , 14]);
                                router.listen(serverPort);
                                return [3 /*break*/, 14];
                            case 7:
                                err_2 = _a.sent();
                                rebootInteger = config.instanceServerStartingPort;
                                _a.label = 8;
                            case 8:
                                if (!(rebootInteger <= config.instanceServerStartingPort + config.numberOfLocalhostServers)) return [3 /*break*/, 13];
                                _a.label = 9;
                            case 9:
                                _a.trys.push([9, 11, , 12]);
                                return [4 /*yield*/, new Promise(function (resolve, reject) {
                                        request("http://127.0.0.1:" + rebootInteger, function (error, response, body) {
                                            if (error) {
                                                //Port Available
                                                reject();
                                            }
                                            else {
                                                rebootInteger++;
                                                resolve();
                                            }
                                        });
                                    })];
                            case 10:
                                _a.sent();
                                return [3 /*break*/, 12];
                            case 11:
                                err_3 = _a.sent();
                                return [3 /*break*/, 13];
                            case 12: return [3 /*break*/, 8];
                            case 13:
                                router.listen(rebootInteger);
                                return [3 /*break*/, 14];
                            case 14: return [3 /*break*/, 16];
                            case 15:
                                https.createServer(credentials.toJSON(), router).listen(config.port, function () {
                                    return __awaiter(this, void 0, void 0, function () {
                                        return __generator(this, function (_a) {
                                            return [2 /*return*/];
                                        });
                                    });
                                });
                                _a.label = 16;
                            case 16:
                                router.get('/', function (req, res) {
                                    //FOR TESTING PURPOSES
                                    res.send('HELLO WORLD');
                                });
                                router.post('/newgroup', function (req, res) {
                                    return __awaiter(this, void 0, void 0, function () {
                                        var newGroupRequestBody, _a, _b, err_4;
                                        return __generator(this, function (_c) {
                                            switch (_c.label) {
                                                case 0:
                                                    if (Object.keys(req.body).length == 0) {
                                                        res.send("");
                                                        return [2 /*return*/, null];
                                                    }
                                                    newGroupRequestBody = new NewGroupRequestBody_1.NewGroupRequestBody(req.body);
                                                    _c.label = 1;
                                                case 1:
                                                    _c.trys.push([1, 5, , 6]);
                                                    bigInt(newGroupRequestBody.publicKey);
                                                    bigInt(newGroupRequestBody.publicKey2);
                                                    if (!(sha256(newGroupRequestBody.passphrase) == config.sha256Password)) return [3 /*break*/, 3];
                                                    _b = (_a = res).send;
                                                    return [4 /*yield*/, databaseAdapter.createNewGroup(newGroupRequestBody.joinKey, newGroupRequestBody.username, newGroupRequestBody.publicKey, newGroupRequestBody.publicKey2)];
                                                case 2:
                                                    _b.apply(_a, [_c.sent()]);
                                                    return [3 /*break*/, 4];
                                                case 3:
                                                    res.send("0");
                                                    _c.label = 4;
                                                case 4: return [3 /*break*/, 6];
                                                case 5:
                                                    err_4 = _c.sent();
                                                    console.log(err_4);
                                                    res.send("-1");
                                                    return [3 /*break*/, 6];
                                                case 6: return [2 /*return*/];
                                            }
                                        });
                                    });
                                });
                                router.post('/joingroup', function (req, res) {
                                    return __awaiter(this, void 0, void 0, function () {
                                        var groupId, joinGroupRequestBody, signatureVerification, _a, _b, err_5;
                                        return __generator(this, function (_c) {
                                            switch (_c.label) {
                                                case 0:
                                                    if (Object.keys(req.body).length == 0) {
                                                        res.send("");
                                                        return [2 /*return*/, null];
                                                    }
                                                    return [4 /*yield*/, databaseAdapter.getGroupIdFromJoinKey(req.body.joinKey)];
                                                case 1:
                                                    groupId = _c.sent();
                                                    joinGroupRequestBody = new JoinGroupRequestBody_1.JoinGroupRequestBody(request.body, groupId);
                                                    _c.label = 2;
                                                case 2:
                                                    _c.trys.push([2, 7, , 8]);
                                                    if (groupId == null) {
                                                        res.send("0");
                                                        return [2 /*return*/, null];
                                                    }
                                                    return [4 /*yield*/, verifySignature(joinGroupRequestBody.groupId, 1, joinGroupRequestBody.encryptedMessage, joinGroupRequestBody.signature.r, joinGroupRequestBody.signature.s, joinGroupRequestBody.signature.recoveryParam)];
                                                case 3:
                                                    signatureVerification = _c.sent();
                                                    if (!signatureVerification.isValid) return [3 /*break*/, 5];
                                                    bigInt(joinGroupRequestBody.publicKey).toString();
                                                    bigInt(joinGroupRequestBody.publicKey2).toString();
                                                    _b = (_a = res).send;
                                                    return [4 /*yield*/, databaseAdapter.insertNewParticipant(joinGroupRequestBody.groupId, joinGroupRequestBody.username, joinGroupRequestBody.publicKey, joinGroupRequestBody.publicKey2)];
                                                case 4:
                                                    _b.apply(_a, [(_c.sent()).toString()]);
                                                    return [3 /*break*/, 6];
                                                case 5:
                                                    res.send("-4");
                                                    _c.label = 6;
                                                case 6: return [3 /*break*/, 8];
                                                case 7:
                                                    err_5 = _c.sent();
                                                    console.log(err_5);
                                                    res.send("-3");
                                                    return [3 /*break*/, 8];
                                                case 8: return [2 /*return*/];
                                            }
                                        });
                                    });
                                });
                                router.post('/isusernametaken', function (req, res) {
                                    return __awaiter(this, void 0, void 0, function () {
                                        var groupId, isUsernameTakenRequestBody, signatureVerification, err_6;
                                        return __generator(this, function (_a) {
                                            switch (_a.label) {
                                                case 0:
                                                    if (Object.keys(req.body).length == 0) {
                                                        res.send("");
                                                        return [2 /*return*/, null];
                                                    }
                                                    return [4 /*yield*/, databaseAdapter.getGroupIdFromJoinKey(req.body.joinKey)];
                                                case 1:
                                                    groupId = _a.sent();
                                                    isUsernameTakenRequestBody = new IsUsernameTakenRequestBody_1.IsUsernameTakenRequestBody(req.body, groupId);
                                                    _a.label = 2;
                                                case 2:
                                                    _a.trys.push([2, 8, , 9]);
                                                    if (!(groupId == null)) return [3 /*break*/, 3];
                                                    res.send("0");
                                                    return [3 /*break*/, 7];
                                                case 3: return [4 /*yield*/, verifySignature(groupId, 1, isUsernameTakenRequestBody.encryptedMessage, isUsernameTakenRequestBody.signature.r, isUsernameTakenRequestBody.signature.s, isUsernameTakenRequestBody.signature.recoveryParam)];
                                                case 4:
                                                    signatureVerification = _a.sent();
                                                    if (!signatureVerification.isValid) return [3 /*break*/, 6];
                                                    return [4 /*yield*/, databaseAdapter.isUsernameTaken(groupId, isUsernameTakenRequestBody.username)];
                                                case 5:
                                                    if (_a.sent())
                                                        res.send("1");
                                                    else
                                                        res.send("0");
                                                    return [3 /*break*/, 7];
                                                case 6:
                                                    res.send("1");
                                                    _a.label = 7;
                                                case 7: return [3 /*break*/, 9];
                                                case 8:
                                                    err_6 = _a.sent();
                                                    console.log(err_6);
                                                    res.send("1");
                                                    return [3 /*break*/, 9];
                                                case 9: return [2 /*return*/];
                                            }
                                        });
                                    });
                                });
                                router.post('/message', function (req, res) {
                                    return __awaiter(this, void 0, void 0, function () {
                                        var groupId, messageRequestBody, participantId, signatureVerification, err_7;
                                        return __generator(this, function (_a) {
                                            switch (_a.label) {
                                                case 0:
                                                    if (Object.keys(req.body).length == 0) {
                                                        res.send("");
                                                        return [2 /*return*/, null];
                                                    }
                                                    console.log("NEW MESSAGE REQUEST");
                                                    return [4 /*yield*/, databaseAdapter.getGroupIdFromJoinKey(req.body.joinKey)];
                                                case 1:
                                                    groupId = _a.sent();
                                                    messageRequestBody = new MessageRequestBody_1.MessageRequestBody(request.body, groupId, null);
                                                    return [4 /*yield*/, databaseAdapter.getParticipantIdFromGroupId(groupId, messageRequestBody.username)];
                                                case 2:
                                                    participantId = _a.sent();
                                                    messageRequestBody.participantId = participantId;
                                                    console.log("THE COMPOSITE KEYS ARE: ");
                                                    console.log(messageRequestBody.compositeKeys);
                                                    console.log("PARTICIPANT ID: " + participantId.toString());
                                                    console.log("NEW MESSAGE REQUEST!");
                                                    console.log(req.body);
                                                    _a.label = 3;
                                                case 3:
                                                    _a.trys.push([3, 5, , 6]);
                                                    return [4 /*yield*/, verifySignature(messageRequestBody.groupId, participantId, messageRequestBody.encryptedMessage, messageRequestBody.signature.r, messageRequestBody.signature.s, messageRequestBody.signature.recoveryParam)];
                                                case 4:
                                                    signatureVerification = _a.sent();
                                                    if (signatureVerification.isValid) {
                                                        databaseAdapter.saveMessage(messageRequestBody.groupId, messageRequestBody.participantId, messageRequestBody.encryptedMessage, messageRequestBody.compositeKeys).then(function (messageInsertionResponse) {
                                                            if (messageInsertionResponse == null)
                                                                res.send("-1");
                                                            else
                                                                res.send(messageInsertionResponse.toJSON());
                                                        });
                                                    }
                                                    return [3 /*break*/, 6];
                                                case 5:
                                                    err_7 = _a.sent();
                                                    console.log(err_7);
                                                    return [3 /*break*/, 6];
                                                case 6: return [2 /*return*/];
                                            }
                                        });
                                    });
                                });
                                router.get('/messages', function (req, res) {
                                    return __awaiter(this, void 0, void 0, function () {
                                        var groupId, messagesRequestBody, participantId, signatureVerification, err_8;
                                        return __generator(this, function (_a) {
                                            switch (_a.label) {
                                                case 0:
                                                    if (Object.keys(req.query).length == 0) {
                                                        res.send("");
                                                        return [2 /*return*/, null];
                                                    }
                                                    return [4 /*yield*/, databaseAdapter.getGroupIdFromJoinKey(req.body.joinKey)];
                                                case 1:
                                                    groupId = _a.sent();
                                                    messagesRequestBody = new MessagesRequestBody_1.MessagesRequestBody(request.body, groupId, null);
                                                    return [4 /*yield*/, databaseAdapter.getParticipantIdFromGroupId(groupId, messagesRequestBody.username)];
                                                case 2:
                                                    participantId = _a.sent();
                                                    messagesRequestBody.participantId = participantId;
                                                    _a.label = 3;
                                                case 3:
                                                    _a.trys.push([3, 5, , 6]);
                                                    return [4 /*yield*/, verifySignature(messagesRequestBody.groupId, participantId, messagesRequestBody.encryptedMessage, messagesRequestBody.signature.r, messagesRequestBody.signature.s, messagesRequestBody.signature.recoveryParam)];
                                                case 4:
                                                    signatureVerification = _a.sent();
                                                    if (signatureVerification.isValid) {
                                                        //Get user join timestamp. Users will only receive messages
                                                        //with a timestamp greater than their join timestamp.
                                                        databaseAdapter.getMessages(messagesRequestBody.groupId, messagesRequestBody.participantId, messagesRequestBody.offset).then(function (messages) {
                                                            res.send(messages);
                                                        })["catch"](function (err) {
                                                            res.send(err);
                                                        });
                                                    }
                                                    else
                                                        console.log("SIGNATURE INVALID");
                                                    return [3 /*break*/, 6];
                                                case 5:
                                                    err_8 = _a.sent();
                                                    console.log(err_8);
                                                    res.send("0");
                                                    return [3 /*break*/, 6];
                                                case 6: return [2 /*return*/];
                                            }
                                        });
                                    });
                                });
                                router.get('/participants', function (req, res) {
                                    return __awaiter(this, void 0, void 0, function () {
                                        var groupId, participantsRequestBody, participantId, signatureVerification, err_9;
                                        return __generator(this, function (_a) {
                                            switch (_a.label) {
                                                case 0:
                                                    if (Object.keys(req.query).length == 0) {
                                                        res.send("");
                                                        return [2 /*return*/, null];
                                                    }
                                                    return [4 /*yield*/, databaseAdapter.getGroupIdFromJoinKey(req.body.joinKey)];
                                                case 1:
                                                    groupId = _a.sent();
                                                    participantsRequestBody = new ParticipantsRequestBody_1.ParticipantsRequestBody(request.body, groupId, null);
                                                    return [4 /*yield*/, databaseAdapter.getParticipantIdFromGroupId(groupId, participantsRequestBody.username)];
                                                case 2:
                                                    participantId = _a.sent();
                                                    participantsRequestBody.participantId = participantId;
                                                    _a.label = 3;
                                                case 3:
                                                    _a.trys.push([3, 5, , 6]);
                                                    return [4 /*yield*/, verifySignature(participantsRequestBody.groupId, participantId, participantsRequestBody.encryptedMessage, participantsRequestBody.signature.r, participantsRequestBody.signature.s, participantsRequestBody.signature.recoveryParam)];
                                                case 4:
                                                    signatureVerification = _a.sent();
                                                    if (signatureVerification.isValid) {
                                                        databaseAdapter.getChatParticipants(participantsRequestBody.groupId).then(function (participants) {
                                                            res.send(participants);
                                                        });
                                                    }
                                                    else {
                                                        console.log("Invalid SIgnature received at GET /participants");
                                                    }
                                                    return [3 /*break*/, 6];
                                                case 5:
                                                    err_9 = _a.sent();
                                                    console.log(err_9);
                                                    return [3 /*break*/, 6];
                                                case 6: return [2 /*return*/];
                                            }
                                        });
                                    });
                                });
                                _a.label = 17;
                            case 17: return [2 /*return*/];
                        }
                    });
                });
            });
            return [2 /*return*/];
        });
    });
});
var SignatureVerificationResults = /** @class */ (function () {
    function SignatureVerificationResults(isValid, publicKey) {
        this.isValid = false;
        this.isValid = isValid;
        this.publicKey = publicKey;
    }
    return SignatureVerificationResults;
}());
exports.SignatureVerificationResults = SignatureVerificationResults;
var Signature = /** @class */ (function () {
    function Signature(r, s, recoveryParam) {
        this.r = r;
        this.s = s;
        this.recoveryParam = recoveryParam;
    }
    Signature.prototype.toJSON = function () {
        return {
            "r": this.r,
            "s": this.s,
            "recoveryParam": this.recoveryParam
        };
    };
    return Signature;
}());
exports.Signature = Signature;
var PublicKeyRecovered = /** @class */ (function () {
    function PublicKeyRecovered(rawPoint) {
        this.xCoord = parseInt(rawPoint["x"].toString());
        this.yCoord = parseInt(rawPoint["y"].toString());
        this.pubKeyObject = rawPoint;
    }
    PublicKeyRecovered.prototype.toArray = function () {
        return [
            this.xCoord,
            this.yCoord
        ];
    };
    return PublicKeyRecovered;
}());
exports.PublicKeyRecovered = PublicKeyRecovered;
var SSLCertificate = /** @class */ (function () {
    function SSLCertificate(key, cert) {
        this.key = key;
        this.cert = cert;
    }
    SSLCertificate.prototype.toJSON = function () {
        return {
            "key": this.key,
            "cert": this.cert
        };
    };
    return SSLCertificate;
}());
