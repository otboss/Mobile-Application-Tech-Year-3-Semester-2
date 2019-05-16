import { Signature } from "../../Server";
const addslashes = require("../../node_modules/addslashes/addslashes.js");


export class ParticipantsRequestBody{
    public encryptedMessage:string;
    public signature:Signature;       
    public username:string;
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
        this.joinKey = addslashes(requestBody["joinKey"]);
        this.participantId = participantId;
    }
}