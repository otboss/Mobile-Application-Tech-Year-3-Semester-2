const sha256 = require("sha256");
const addslashes = require("../../node_modules/addslashes/addslashes.js");


export class NewGroupRequestBody{
    public username:string;
    public publicKey:string;
    public publicKey2:string;
    public passphrase:string;
    public joinKey:string;

    /** Creates a key which is used to add other persons to a chat*/
    private makeJoinKey = function(length):string {
        var text = "";
        var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        for (var i = 0; i < length; i++)
            text += possible.charAt(Math.floor(Math.random() * possible.length));
        return text;
    }

    constructor(requestBody:object){
        this.username = addslashes(requestBody["username"]);
        this.publicKey = addslashes(requestBody["publicKey"]);
        this.publicKey2 = addslashes(requestBody["publicKey2"]);
        this.passphrase = addslashes(requestBody["passphrase"]);
        this.joinKey = sha256(this.makeJoinKey(1000)+(new Date().getTime().toString()));
    }
}