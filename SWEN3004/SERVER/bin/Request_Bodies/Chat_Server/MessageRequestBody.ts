import { Signature } from "../../Server";
const sha256 = require("sha256");
const addslashes = require("../../node_modules/addslashes/addslashes.js");

export class MessageRequestBody{
    public encryptedMessage:string;
    public signature:Signature;       
    public username:string;
    public publicKey:string;
    public compositeKeys:object;
    public joinKey:string;
    public groupId:number;
    public participantId:number;
    constructor(requestBody:object, groupId:number, participantId:number){
        this.encryptedMessage = addslashes(requestBody["encryptedMessage"]);
        this.groupId = groupId;
        const signature = JSON.parse(requestBody["signature"]);
        signature["r"] = addslashes(signature["r"]);
        signature["s"] = addslashes(signature["s"]);    
        signature["recoveryParam"] = addslashes(signature["recoveryParam"]);        
        this.signature = new Signature(signature["r"], signature["s"], signature["recoveryParam"]);
        this.username = addslashes(requestBody["username"]);
        this.publicKey = addslashes(requestBody["publicKey"]);
        this.compositeKeys = JSON.parse(requestBody["compositeKeys"]);
        this.joinKey = addslashes(requestBody["joinKey"]);
        this.participantId = participantId;
        const compositeKeyContents = Object.keys(this.compositeKeys);
        for(var x = 0; x < compositeKeyContents.length; x++){
            this.compositeKeys[compositeKeyContents[x]] = addslashes(this.compositeKeys[compositeKeyContents[x]]);
        }
    }
}