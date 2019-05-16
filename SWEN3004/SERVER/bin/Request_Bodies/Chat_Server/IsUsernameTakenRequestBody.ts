import { Signature } from "../../Server";
const addslashes = require("../../node_modules/addslashes/addslashes.js");

export class IsUsernameTakenRequestBody{
    public encryptedMessage:string;
    public signature:Signature;       
    public username:string;
    public publicKey:string;
    public joinKey:string;
    public groupId:number;
    constructor(requestBody:object, groupId:number){
        this.encryptedMessage = addslashes(requestBody["encryptedMessage"]);
        this.username = addslashes(requestBody["username"]);
        this.publicKey = addslashes(requestBody["publicKey"]);
        this.joinKey = addslashes(requestBody["joinKey"]);        
        this.groupId = groupId;
        const signature = JSON.parse(requestBody["signature"]);
        signature["r"] = addslashes(signature["r"]);
        signature["s"] = addslashes(signature["s"]);    
        signature["recoveryParam"] = addslashes(signature["recoveryParam"]);            
        this.signature = new Signature(signature["r"], signature["s"], signature["recoveryParam"]);
    }    
}