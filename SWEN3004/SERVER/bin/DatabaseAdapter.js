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
var mysql = require("mysql");
var Config_1 = require("./Config");
var fs = require("fs");
var child_process = require("child_process");
var os = require("os");
var Server_1 = require("./Server");
var elliptic = require("elliptic");
var addslashes_1 = require("./node_modules/addslashes/addslashes");
var bigInt = require("big-integer");
var ec = new elliptic.ec('secp256k1');
var config = new Config_1.Config();
var exec = child_process.exec;
var execute = function (command, callback) {
    exec(command, { maxBuffer: 1024 * 250 }, function (error, stdout, stderr) {
        callback(error, stdout, stderr);
    });
};
var connection = mysql.createConnection({
    host: config.databaseConfig.host,
    user: config.databaseConfig.user,
    password: config.databaseConfig.password,
    database: config.databaseConfig.database,
    port: config.databaseConfig.port
});
var DatabaseAdapter = /** @class */ (function () {
    function DatabaseAdapter() {
        this.getChatParticipants = function (groupId) {
            return new Promise(function (resolve, reject) {
                var participants = {};
                connection.query("\n            SELECT *, \n            UNIX_TIMESTAMP(" + participantsTable.timestamp.columnName + ")*1000 joinedTimestamp\n            FROM " + participantsTable.tableName + " \n            WHERE " + participantsTable.groupId.columnName + " = '" + groupId + "';", function (error, results, fields) {
                    if (error)
                        console.log(error);
                    for (var x = 0; x < results.length; x++) {
                        participants[results[x]["username"]] = (new ParticipantForRecipient(results[x]["publicKey"], results[x]["publicKey2"], results[x]["joinedTimestamp"])).toJSON();
                    }
                    resolve(participants);
                });
            });
        };
        try {
            connection.connect();
        }
        catch (err) {
            console.log("Could not connect to database. Attempting fix..");
            if (os.platform() == "linux") {
                //Attempt to import sql automatically
                if (fs.existsSync("./db.sql") == false) {
                    fs.writeFileSync("./db.sql", "Q1JFQVRFIERBVEFCQVNFIGNpcGhlcmNoYXQ7ClVTRSBjaXBoZXJjaGF0OwoKQ1JFQVRFIFRBQkxFIElGIE5PVCBFWElTVFMgZ3JvdXBzKAogICAgZ2lkIElOVCgxMSkgTk9UIE5VTEwgQVVUT19JTkNSRU1FTlQsCiAgICBqb2luS2V5IFZBUkNIQVIoMTAwKSBOT1QgTlVMTCwKICAgIHRzIFRJTUVTVEFNUCBERUZBVUxUIENVUlJFTlRfVElNRVNUQU1QIE5PVCBOVUxMLAogICAgVU5JUVVFKGpvaW5LZXkpLAogICAgUFJJTUFSWSBLRVkoZ2lkKQopOwoKQ1JFQVRFIFRBQkxFIElGIE5PVCBFWElTVFMgcGFydGljaXBhbnRzKAogICAgcGlkIElOVCgxMSkgTk9UIE5VTEwgQVVUT19JTkNSRU1FTlQsCiAgICBnaWQgSU5UKDExKSBOT1QgTlVMTCwKICAgIHVzZXJuYW1lIFZBUkNIQVIoMjU1KSBOT1QgTlVMTCwKICAgIHB1YmxpY0tleSBWQVJDSEFSKDEwMCkgTk9UIE5VTEwsCiAgICBwdWJsaWNLZXkyIFZBUkNIQVIoMTAwKSBOT1QgTlVMTCwKICAgIHRzIFRJTUVTVEFNUCBERUZBVUxUIENVUlJFTlRfVElNRVNUQU1QIE5PVCBOVUxMLAogICAgVU5JUVVFKGdpZCwgdXNlcm5hbWUpLAogICAgUFJJTUFSWSBLRVkocGlkKSwKICAgIEZPUkVJR04gS0VZKGdpZCkgUkVGRVJFTkNFUyBncm91cHMoZ2lkKQopOwoKQ1JFQVRFIFRBQkxFIElGIE5PVCBFWElTVFMgbWVzc2FnZXMoCiAgICBtaWQgSU5UKDExKSBOT1QgTlVMTCBBVVRPX0lOQ1JFTUVOVCwKICAgIGdpZCBJTlQoMTEpIE5PVCBOVUxMLAogICAgcGlkIElOVCgxMSkgTk9UIE5VTEwsCiAgICBtZXNzYWdlIFZBUkNIQVIoMzAwKSBOT1QgTlVMTCwKICAgIHRzIFRJTUVTVEFNUCBERUZBVUxUIENVUlJFTlRfVElNRVNUQU1QIE5PVCBOVUxMLAogICAgUFJJTUFSWSBLRVkobWlkKSwKICAgIEZPUkVJR04gS0VZKHBpZCkgUkVGRVJFTkNFUyBwYXJ0aWNpcGFudHMocGlkKQopOwoKQ1JFQVRFIFRBQkxFIElGIE5PVCBFWElTVFMgY29tcG9zaXRlS2V5cygKICAgIGNwaWQgSU5UKDExKSBOT1QgTlVMTCBBVVRPX0lOQ1JFTUVOVCwKICAgIG1pZCBJTlQoMTEpIE5PVCBOVUxMICwKICAgIGdpZCBJTlQoMTEpIE5PVCBOVUxMLAogICAgcGlkIElOVCgxMSkgTk9UIE5VTEwsCiAgICBjb21wb3NpdGVLZXkgVkFSQ0hBUigyNTUpIE5PVCBOVUxMLAogICAgdHMgVElNRVNUQU1QIERFRkFVTFQgQ1VSUkVOVF9USU1FU1RBTVAgTk9UIE5VTEwsCiAgICBVTklRVUUobWlkLCBwaWQpLAogICAgUFJJTUFSWSBLRVkoY3BpZCksCiAgICBGT1JFSUdOIEtFWShtaWQpIFJFRkVSRU5DRVMgbWVzc2FnZXMobWlkKSwKICAgIEZPUkVJR04gS0VZKGdpZCkgUkVGRVJFTkNFUyBncm91cHMoZ2lkKSwKICAgIEZPUkVJR04gS0VZKHBpZCkgUkVGRVJFTkNFUyBwYXJ0aWNpcGFudHMocGlkKQopOw==", 'base64');
                }
                execute("mysql -u" + config.databaseConfig.user + " < db.sql", function (error, stdout, stderr) { });
                execute("mysql -u" + config.databaseConfig.user + " -p" + config.databaseConfig.database + " < db.sql", function (error, stdout, stderr) { });
            }
            try {
                connection.connect();
            }
            catch (err) {
                throw new Error("Could not connect to database. Please start your mysql server and edit the configuration accordingly.");
            }
        }
    }
    DatabaseAdapter.prototype.getGroupIdFromJoinKey = function (joinKey) {
        joinKey = addslashes_1.addslashes(joinKey);
        return new Promise(function (resolve, reject) {
            connection.query("\n            SELECT " + groupsTable.groupId.fullColumnName + " gid \n            FROM " + groupsTable.tableName.getTableName + " \n            WHERE joinKey = '" + joinKey + "';", function (error, results, fields) {
                if (results.length == 0)
                    resolve(null);
                else
                    resolve(results[0][groupsTable.groupId.columnName]);
            });
        });
    };
    DatabaseAdapter.prototype.getParticipantIdFromGroupId = function (groupId, username) {
        username = addslashes_1.addslashes(username);
        return new Promise(function (resolve, reject) {
            connection.query("\n            SELECT " + participantsTable.participantId.columnName + " \n            FROM " + participantsTable.tableName.getTableName + " \n            WHERE " + participantsTable.groupId.columnName + " = '" + groupId + "' \n            AND " + participantsTable.username.columnName + " = '" + username + "';", function (error, results, fields) {
                if (results.length == 0)
                    resolve(null);
                else
                    resolve(results[0][participantsTable.participantId.columnName]);
            });
        });
    };
    /** Verifies the origin's authenticity*/
    DatabaseAdapter.prototype.verifyPublicKey = function (groupId, hashedMessage, pubKeyRecovered, signature) {
        return new Promise(function (resolve, reject) {
            connection.query("\n            SELECT * FROM " + participantsTable.tableName + " \n            WHERE " + participantsTable.groupId.fullColumnName + " = '" + groupId + "' \n            AND " + participantsTable.publicKey2.fullColumnName + " = '" + pubKeyRecovered["x"].toString(16) + "';", function (error, results, fields) {
                if (results.length > 0)
                    resolve(new Server_1.SignatureVerificationResults(ec.verify(hashedMessage, signature.toJSON(), pubKeyRecovered.pubKeyObject), pubKeyRecovered["x"].toString(16)));
                else
                    resolve(new Server_1.SignatureVerificationResults(false, pubKeyRecovered["x"].toString(16)));
            });
        });
    };
    DatabaseAdapter.prototype.createNewGroup = function (joinKey, username, publicKey, publicKey2) {
        joinKey = addslashes_1.addslashes(joinKey);
        username = addslashes_1.addslashes(username);
        publicKey = addslashes_1.addslashes(publicKey);
        publicKey2 = addslashes_1.addslashes(publicKey2);
        return new Promise(function (resolve, reject) {
            connection.query("\n            INSERT \n            INTO " + groupsTable.tableName + " (\n                " + groupsTable.joinKey.columnName + "\n            ) \n            VALUES (\n                '" + joinKey + "'\n            );", function (error, results, fields) {
                connection.query("\n                INSERT \n                INTO " + participantsTable.tableName + " \n                (\n                    " + participantsTable.groupId.columnName + ", \n                    " + participantsTable.username.columnName + ", \n                    " + participantsTable.publicKey.columnName + ", \n                    " + participantsTable.publicKey2.columnName + "\n                ) \n                VALUES (\n                    '" + results["insertId"] + "', \n                    '" + username + "', \n                    '" + publicKey + "', \n                    '" + publicKey2 + "'\n                );", function (error, results, fields) {
                    resolve(joinKey);
                });
            });
        });
    };
    DatabaseAdapter.prototype.insertNewParticipant = function (groupId, username, publicKey, publicKey2) {
        username = addslashes_1.addslashes(username);
        publicKey = addslashes_1.addslashes(publicKey);
        publicKey2 = addslashes_1.addslashes(publicKey2);
        return new Promise(function (resolve, reject) {
            connection.query("\n            SELECT * \n            FROM " + participantsTable.tableName + " \n            WHERE " + participantsTable.groupId.columnName + " = '" + groupId + "';", function (error, results, fields) {
                if (error) {
                    console.log(error);
                    resolve(-1);
                }
                else {
                    if (results.length < config.maxParticipantsPerGroup) {
                        connection.query("\n                        SELECT * \n                        FROM " + participantsTable.tableName + " \n                        WHERE " + participantsTable.groupId.columnName + " = '" + groupId + "' \n                        AND " + participantsTable.username.columnName + " = '" + username + "';", function (error, results, fields) {
                            if (error)
                                console.log(error);
                            if (results.length > 0) {
                                //Already joined group
                                resolve(-3);
                            }
                            else {
                                connection.query("\n                                INSERT \n                                INTO " + participantsTable.tableName + " \n                                (\n                                    " + participantsTable.groupId.columnName + ", \n                                    " + participantsTable.username.columnName + ", \n                                    " + participantsTable.publicKey.columnName + ", \n                                    " + participantsTable.publicKey2.columnName + "\n                                ) \n                                VALUES (\n                                    '" + groupId + "', \n                                    '" + username + "', \n                                    '" + publicKey + "', \n                                    '" + publicKey2 + "'\n                                );", function (error, results, fields) {
                                    if (error) {
                                        console.log(error);
                                        resolve(-2);
                                    }
                                    else {
                                        resolve(1);
                                    }
                                });
                            }
                        });
                    }
                    else {
                        resolve(-1);
                    }
                }
            });
        });
    };
    DatabaseAdapter.prototype.isUsernameTaken = function (groupId, username) {
        return new Promise(function (resolve, reject) {
            connection.query("\n            SELECT * \n            FROM " + participantsTable.tableName + " \n            WHERE " + participantsTable.groupId.fullColumnName + " = '" + groupId + "' \n            AND " + participantsTable.username.fullColumnName + " = '" + username + "';", function (error, results, fields) {
                if (results.length > 0)
                    resolve(true);
                else
                    resolve(false);
            });
        });
    };
    DatabaseAdapter.prototype.saveMessage = function (groupId, participantId, encryptedMessage, compositeKeys) {
        return new Promise(function (resolve, reject) {
            connection.query("\n            INSERT \n            INTO " + messagesTable.tableName + " (\n                " + messagesTable.groupId.columnName + ", \n                " + messagesTable.participantId.columnName + ", \n                " + messagesTable.message.columnName + "\n            )\n            VALUES (\n                '" + groupId + "', \n                '" + participantId + "', \n                '" + encryptedMessage + "'\n            );", function (error, results, fields) {
                if (error)
                    resolve(null);
                else {
                    var messageInsertionId_1 = results["insertId"];
                    var messageRecipientUsernames = Object.keys(compositeKeys);
                    var _loop_1 = function () {
                        var currentRecipientUsername = messageRecipientUsernames[x];
                        try {
                            bigInt(compositeKeys[currentRecipientUsername]);
                            compositeKeys[currentRecipientUsername] = addslashes_1.addslashes(compositeKeys[currentRecipientUsername]);
                            connection.query("\n                            SELECT " + participantsTable.participantId.fullColumnName + " pid \n                            FROM " + participantsTable.tableName + "\n                            WHERE " + participantsTable.username.fullColumnName + " = '" + currentRecipientUsername + "'\n                            AND " + participantsTable.groupId.fullColumnName + " = '" + groupId + "';", function (error, results, fields) {
                                if (results.length > 0) {
                                    var currentParticipantId = results[0]["pid"];
                                    connection.query("\n                                    INSERT \n                                    INTO " + compositeKeysTable.tableName + " (\n                                        " + compositeKeysTable.messageId.columnName + ", \n                                        " + compositeKeysTable.groupId.columnName + ", \n                                        " + compositeKeysTable.participantId.columnName + ", \n                                        " + compositeKeysTable.compositeKey.columnName + "\n                                    ) \n                                    VALUES (\n                                        '" + messageInsertionId_1 + "', \n                                        '" + groupId + "', \n                                        '" + currentParticipantId + "', \n                                        '" + compositeKeys[currentRecipientUsername] + "'\n                                    );", function (error, results, fields) {
                                        if (error)
                                            console.log(error);
                                    });
                                }
                            });
                        }
                        catch (err) {
                            console.log(err);
                        }
                    };
                    for (var x = 0; x < messageRecipientUsernames.length; x++) {
                        _loop_1();
                    }
                    connection.query("\n                    SELECT *, \n                    UNIX_TIMESTAMP(" + messagesTable.timestamp.columnName + ")*1000 sentTime \n                    FROM " + messagesTable.tableName + " \n                    WHERE mid = '" + messageInsertionId_1 + "';", function (error, results, fields) {
                        if (error)
                            console.log(error);
                        console.log("THE MESSAGE RESPONSE IS: ");
                        console.log({
                            "mid": results[0]["mid"],
                            "timestamp": results[0]["sentTime"]
                        });
                        resolve(new MessageInsertionResponse(results[0]["mid"], results[0]["sentTime"]));
                    });
                }
            });
        });
    };
    DatabaseAdapter.prototype.getMessages = function (groupId, participantId, offset) {
        return new Promise(function (resolve, reject) {
            connection.query("\n            SELECT " + participantsTable.timestamp.columnName + "\n            FROM " + participantsTable.tableName + " \n            WHERE " + participantsTable.participantId.columnName + " = '" + participantId + "' \n            AND " + participantsTable.groupId.columnName + " = '" + groupId + "';", function (error, userInfo, fields) {
                var userJoinTs = userInfo[0][participantsTable.timestamp.columnName];
                //Get all message ids related to this group
                connection.query("\n                SELECT " + messagesTable.messageId.fullColumnName + " mid\n                FROM " + messagesTable.tableName + " \n                JOIN " + participantsTable.tableName + " \n                ON " + messagesTable.groupId.fullColumnName + " = " + participantsTable.groupId.fullColumnName + " \n                WHERE " + messagesTable.groupId.fullColumnName + " = '" + groupId + "' \n                AND " + messagesTable.messageId.fullColumnName + " > '" + offset + "' \n                AND " + messagesTable.timestamp.fullColumnName + " > '" + userJoinTs + "' \n                GROUP BY " + messagesTable.messageId.fullColumnName + "\n                ORDER BY " + messagesTable.timestamp.fullColumnName + " \n                DESC \n                LIMIT 20;", function (error, messageResults, fields) {
                    return __awaiter(this, void 0, void 0, function () {
                        var messages, _loop_2, x;
                        return __generator(this, function (_a) {
                            switch (_a.label) {
                                case 0:
                                    console.log("THE MESSAGE RESULTS ARE: ");
                                    console.log(messageResults);
                                    if (!error) return [3 /*break*/, 1];
                                    reject("0");
                                    return [3 /*break*/, 6];
                                case 1:
                                    messages = {};
                                    _loop_2 = function () {
                                        var messageId;
                                        return __generator(this, function (_a) {
                                            switch (_a.label) {
                                                case 0:
                                                    messageId = messageResults[x]["mid"];
                                                    //Get composite key for message
                                                    return [4 /*yield*/, new Promise(function (resolve, reject) {
                                                            connection.query("\n                                SELECT\n                                " + participantsTable.username.fullColumnName + " sender, \n                                " + messagesTable.message.fullColumnName + " encryptedMessage,\n                                " + compositeKeysTable.compositeKey.fullColumnName + " compositeKey, \n                                UNIX_TIMESTAMP(" + messagesTable.timestamp.fullColumnName + ")*1000 sentTime\n                                FROM " + messagesTable.tableName + "\n                                JOIN " + compositeKeysTable.tableName + "\n                                ON " + messagesTable.messageId.fullColumnName + " = " + compositeKeysTable.messageId.fullColumnName + "\n                                JOIN " + participantsTable.tableName + "\n                                ON " + messagesTable.participantId.fullColumnName + " = " + participantsTable.participantId.fullColumnName + "\n                                WHERE " + messagesTable.messageId.fullColumnName + " = '" + messageId + "'\n                                AND " + compositeKeysTable.participantId.fullColumnName + " = '" + participantId + "'\n                                GROUP BY " + messagesTable.messageId.fullColumnName + "\n                                ORDER BY " + messagesTable.messageId.fullColumnName + ";", function (error, results, fields) {
                                                                if (error)
                                                                    console.log(error);
                                                                if (results.length > 0) {
                                                                    messages[messageId] = (new MessageForRecipient(results[0]["sender"], results[0]["encryptedMessage"], results[0]["compositeKey"], results[0]["sentTime"])).toJSON();
                                                                }
                                                                resolve();
                                                            });
                                                        })];
                                                case 1:
                                                    //Get composite key for message
                                                    _a.sent();
                                                    return [2 /*return*/];
                                            }
                                        });
                                    };
                                    x = 0;
                                    _a.label = 2;
                                case 2:
                                    if (!(x < messageResults.length)) return [3 /*break*/, 5];
                                    return [5 /*yield**/, _loop_2()];
                                case 3:
                                    _a.sent();
                                    _a.label = 4;
                                case 4:
                                    x++;
                                    return [3 /*break*/, 2];
                                case 5:
                                    resolve(messages);
                                    _a.label = 6;
                                case 6: return [2 /*return*/];
                            }
                        });
                    });
                });
            });
        });
    };
    return DatabaseAdapter;
}());
exports.DatabaseAdapter = DatabaseAdapter;
;
var GroupsTable = /** @class */ (function () {
    function GroupsTable() {
        this.tableName = new TableName("groups");
        this.groupId = new TableColumn(this.tableName.getTableName(), "gid", columnTypes.integer, true);
        this.joinKey = new TableColumn(this.tableName.getTableName(), "joinKey", columnTypes.varchar, false);
        this.timestamp = new TableColumn(this.tableName.getTableName(), "ts", columnTypes.timestamp, false);
    }
    return GroupsTable;
}());
var ParticipantsTable = /** @class */ (function () {
    function ParticipantsTable() {
        this.tableName = new TableName("participants");
        this.participantId = new TableColumn(this.tableName.getTableName(), "pid", columnTypes.integer, true);
        this.groupId = new TableColumn(this.tableName.getTableName(), "gid", columnTypes.integer, false);
        this.username = new TableColumn(this.tableName.getTableName(), "username", columnTypes.varchar, false);
        this.publicKey = new TableColumn(this.tableName.getTableName(), "publicKey", columnTypes.varchar, false);
        this.publicKey2 = new TableColumn(this.tableName.getTableName(), "publicKey2", columnTypes.varchar, false);
        this.timestamp = new TableColumn(this.tableName.getTableName(), "ts", columnTypes.timestamp, false);
    }
    return ParticipantsTable;
}());
var MessagesTable = /** @class */ (function () {
    function MessagesTable() {
        this.tableName = new TableName("participants");
        this.messageId = new TableColumn(this.tableName.getTableName(), "mid", columnTypes.integer, true);
        this.groupId = new TableColumn(this.tableName.getTableName(), "gid", columnTypes.integer, false);
        this.participantId = new TableColumn(this.tableName.getTableName(), "pid", columnTypes.integer, false);
        this.message = new TableColumn(this.tableName.getTableName(), "message", columnTypes.varchar, false);
        this.timestamp = new TableColumn(this.tableName.getTableName(), "ts", columnTypes.timestamp, false);
    }
    return MessagesTable;
}());
var CompositeKeysTable = /** @class */ (function () {
    function CompositeKeysTable() {
        this.tableName = new TableName("compositeKeys");
        this.compositeKeyId = new TableColumn(this.tableName.getTableName(), "cpid", columnTypes.integer, true);
        this.messageId = new TableColumn(this.tableName.getTableName(), "mid", columnTypes.integer, false);
        this.groupId = new TableColumn(this.tableName.getTableName(), "gid", columnTypes.integer, false);
        this.participantId = new TableColumn(this.tableName.getTableName(), "pid", columnTypes.integer, false);
        this.compositeKey = new TableColumn(this.tableName.getTableName(), "compositeKey", columnTypes.varchar, false);
        this.timestamp = new TableColumn(this.tableName.getTableName(), "ts", columnTypes.timestamp, false);
    }
    return CompositeKeysTable;
}());
var TableName = /** @class */ (function () {
    function TableName(tableName) {
        this.getTableName = function () {
            return this.tableName;
        };
        this.tableName = tableName;
    }
    return TableName;
}());
var columnTypes;
(function (columnTypes) {
    columnTypes[columnTypes["integer"] = 0] = "integer";
    columnTypes[columnTypes["varchar"] = 1] = "varchar";
    columnTypes[columnTypes["text"] = 2] = "text";
    columnTypes[columnTypes["float"] = 3] = "float";
    columnTypes[columnTypes["timestamp"] = 4] = "timestamp";
})(columnTypes || (columnTypes = {}));
var TableColumn = /** @class */ (function () {
    function TableColumn(tableName, columnName, type, isPrimary) {
        this.tableName = tableName;
        this.columnName = columnName;
        this.fullColumnName = tableName + "." + columnName;
        this.isPrimary = isPrimary;
        this.type = type;
    }
    return TableColumn;
}());
var groupsTable = new GroupsTable();
var participantsTable = new ParticipantsTable();
var messagesTable = new MessagesTable();
var compositeKeysTable = new CompositeKeysTable();
var MessageInsertionResponse = /** @class */ (function () {
    function MessageInsertionResponse(messageId, timestamp) {
        this.messageId = messageId;
        this.timestamp = timestamp;
    }
    MessageInsertionResponse.prototype.toJSON = function () {
        return {
            "mid": this.messageId,
            "timestamp": this.timestamp
        };
    };
    return MessageInsertionResponse;
}());
var MessageForRecipient = /** @class */ (function () {
    function MessageForRecipient(sender, encryptedMessage, compositeKey, timestamp) {
        this.sender = sender;
        this.encryptedMessage = encryptedMessage;
        this.compositeKey = compositeKey;
        this.timestamp = timestamp;
    }
    MessageForRecipient.prototype.toJSON = function () {
        return {
            "sender": this.sender,
            "encryptedMessage": this.encryptedMessage,
            "compositeKey": this.compositeKey,
            "ts": this.timestamp.toString()
        };
    };
    return MessageForRecipient;
}());
var ParticipantForRecipient = /** @class */ (function () {
    function ParticipantForRecipient(publicKey, publicKey2, joined) {
        this.publicKey = publicKey;
        this.publicKey2 = publicKey2;
        this.joined = joined;
    }
    ParticipantForRecipient.prototype.toJSON = function () {
        return {
            "publicKey": this.publicKey,
            "publicKey2": this.publicKey2,
            "joined": this.joined.toString()
        };
    };
    return ParticipantForRecipient;
}());
