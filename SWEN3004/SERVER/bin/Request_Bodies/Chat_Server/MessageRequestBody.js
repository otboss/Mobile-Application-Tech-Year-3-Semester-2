"use strict";
exports.__esModule = true;
var Server_1 = require("../../Server");
var sha256 = require("sha256");
var addslashes = require("../../node_modules/addslashes/addslashes.js");
var MessageRequestBody = /** @class */ (function () {
    function MessageRequestBody(requestBody, groupId, participantId) {
        this.encryptedMessage = addslashes(requestBody["encryptedMessage"]);
        this.groupId = groupId;
        var signature = JSON.parse(requestBody["signature"]);
        signature["r"] = addslashes(signature["r"]);
        signature["s"] = addslashes(signature["s"]);
        signature["recoveryParam"] = addslashes(signature["recoveryParam"]);
        this.signature = new Server_1.Signature(signature["r"], signature["s"], signature["recoveryParam"]);
        this.username = addslashes(requestBody["username"]);
        this.publicKey = addslashes(requestBody["publicKey"]);
        this.compositeKeys = JSON.parse(requestBody["compositeKeys"]);
        this.joinKey = addslashes(requestBody["joinKey"]);
        this.participantId = participantId;
        var compositeKeyContents = Object.keys(this.compositeKeys);
        for (var x = 0; x < compositeKeyContents.length; x++) {
            this.compositeKeys[compositeKeyContents[x]] = addslashes(this.compositeKeys[compositeKeyContents[x]]);
        }
    }
    return MessageRequestBody;
}());
exports.MessageRequestBody = MessageRequestBody;
