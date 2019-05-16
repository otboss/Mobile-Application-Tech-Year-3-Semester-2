import { Signature } from "../../Server";
const addslashes = require("../../node_modules/addslashes/addslashes.js");


export class JoinGroupRequestBody{
    public encryptedMessage:string;
    public signature:Signature;       
    public username:string;
    public publicKey:string;
    public publicKey2:string;
    public joinKey:string;
    public groupId:number;
    constructor(requestBody:object, groupId:number){
        this.encryptedMessage = addslashes(requestBody["encryptedMessage"]);
        const signature = JSON.parse(requestBody["signature"]);
        signature["r"] = addslashes(signature["r"]);
        signature["s"] = addslashes(signature["s"]);    
        signature["recoveryParam"] = addslashes(signature["recoveryParam"]);            
        this.signature = new Signature(signature["r"], signature["s"], signature["recoveryParam"]);
        this.username = addslashes(requestBody["username"]);
        this.publicKey = addslashes(requestBody["publicKey"]);
        this.publicKey2 = addslashes(requestBody["publicKey2"]);
        this.joinKey = addslashes(requestBody["joinKey"]);
        this.groupId = groupId;
    }
}