"use strict";
exports.__esModule = true;
var sha256 = require("sha256");
var addslashes = require("../../node_modules/addslashes/addslashes.js");
var NewGroupRequestBody = /** @class */ (function () {
    function NewGroupRequestBody(requestBody) {
        /** Creates a key which is used to add other persons to a chat*/
        this.makeJoinKey = function (length) {
            var text = "";
            var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            for (var i = 0; i < length; i++)
                text += possible.charAt(Math.floor(Math.random() * possible.length));
            return text;
        };
        this.username = addslashes(requestBody["username"]);
        this.publicKey = addslashes(requestBody["publicKey"]);
        this.publicKey2 = addslashes(requestBody["publicKey2"]);
        this.passphrase = addslashes(requestBody["passphrase"]);
        this.joinKey = sha256(this.makeJoinKey(1000) + (new Date().getTime().toString()));
    }
    return NewGroupRequestBody;
}());
exports.NewGroupRequestBody = NewGroupRequestBody;
