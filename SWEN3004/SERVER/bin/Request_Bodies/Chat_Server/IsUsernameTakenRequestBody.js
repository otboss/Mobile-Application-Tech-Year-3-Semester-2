"use strict";
exports.__esModule = true;
var Server_1 = require("../../Server");
var addslashes = require("../../node_modules/addslashes/addslashes.js");
var IsUsernameTakenRequestBody = /** @class */ (function () {
    function IsUsernameTakenRequestBody(requestBody, groupId) {
        this.encryptedMessage = addslashes(requestBody["encryptedMessage"]);
        this.username = addslashes(requestBody["username"]);
        this.publicKey = addslashes(requestBody["publicKey"]);
        this.joinKey = addslashes(requestBody["joinKey"]);
        this.groupId = groupId;
        var signature = JSON.parse(requestBody["signature"]);
        signature["r"] = addslashes(signature["r"]);
        signature["s"] = addslashes(signature["s"]);
        signature["recoveryParam"] = addslashes(signature["recoveryParam"]);
        this.signature = new Server_1.Signature(signature["r"], signature["s"], signature["recoveryParam"]);
    }
    return IsUsernameTakenRequestBody;
}());
exports.IsUsernameTakenRequestBody = IsUsernameTakenRequestBody;
