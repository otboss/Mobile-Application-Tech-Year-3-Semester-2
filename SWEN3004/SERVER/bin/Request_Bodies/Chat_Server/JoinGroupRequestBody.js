"use strict";
exports.__esModule = true;
var Server_1 = require("../../Server");
var addslashes = require("../../node_modules/addslashes/addslashes.js");
var JoinGroupRequestBody = /** @class */ (function () {
    function JoinGroupRequestBody(requestBody, groupId) {
        this.encryptedMessage = addslashes(requestBody["encryptedMessage"]);
        var signature = JSON.parse(requestBody["signature"]);
        signature["r"] = addslashes(signature["r"]);
        signature["s"] = addslashes(signature["s"]);
        signature["recoveryParam"] = addslashes(signature["recoveryParam"]);
        this.signature = new Server_1.Signature(signature["r"], signature["s"], signature["recoveryParam"]);
        this.username = addslashes(requestBody["username"]);
        this.publicKey = addslashes(requestBody["publicKey"]);
        this.publicKey2 = addslashes(requestBody["publicKey2"]);
        this.joinKey = addslashes(requestBody["joinKey"]);
        this.groupId = groupId;
    }
    return JoinGroupRequestBody;
}());
exports.JoinGroupRequestBody = JoinGroupRequestBody;
