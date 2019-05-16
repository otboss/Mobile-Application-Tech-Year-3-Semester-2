"use strict";
exports.__esModule = true;
var Server_1 = require("../../Server");
var addslashes = require("../../node_modules/addslashes/addslashes.js");
var ParticipantsRequestBody = /** @class */ (function () {
    function ParticipantsRequestBody(requestBody, groupId, participantId) {
        this.encryptedMessage = addslashes(requestBody["encryptedMessage"]);
        this.groupId = groupId;
        var signature = JSON.parse(requestBody["signature"]);
        signature["r"] = addslashes(signature["r"]);
        signature["s"] = addslashes(signature["s"]);
        signature["recoveryParam"] = addslashes(signature["recoveryParam"]);
        this.signature = new Server_1.Signature(signature["r"], signature["s"], signature["recoveryParam"]);
        this.username = addslashes(requestBody["username"]);
        this.joinKey = addslashes(requestBody["joinKey"]);
        this.participantId = participantId;
    }
    return ParticipantsRequestBody;
}());
exports.ParticipantsRequestBody = ParticipantsRequestBody;
