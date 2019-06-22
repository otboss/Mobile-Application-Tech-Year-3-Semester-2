import * as mysql from "mysql";
import { Config } from "./Config";
import * as fs from "fs";
import * as child_process from 'child_process';
import * as os from 'os';
import { Signature, SignatureVerificationResults, PublicKeyRecovered } from './Server';
import * as elliptic from 'elliptic';
import { addslashes } from "./node_modules/addslashes/addslashes";
import * as bigInt from "big-integer";
import { runInThisContext } from "vm";
const ec = new elliptic.ec('secp256k1');

const config:Config = new Config();

const exec = child_process.exec;

const execute = function (command, callback) {
    exec(command, { maxBuffer: 1024 * 250 }, function (error, stdout, stderr) {
        callback(error, stdout, stderr);
    });
};

const connection:any = mysql.createConnection({
    host     : config.databaseConfig.host,
    user     : config.databaseConfig.user,
    password : config.databaseConfig.password,
    database : config.databaseConfig.database,
    port     : config.databaseConfig.port
});

export class DatabaseAdapter{

    constructor(){
        try{
            connection.connect();
        }
        catch(err){
            console.log("Could not connect to database. Attempting fix..");
            if(os.platform() == "linux"){
                //Attempt to import sql automatically
                if(fs.existsSync("./db.sql") == false){
                    fs.writeFileSync("./db.sql", "Q1JFQVRFIERBVEFCQVNFIGNpcGhlcmNoYXQ7ClVTRSBjaXBoZXJjaGF0OwoKQ1JFQVRFIFRBQkxFIElGIE5PVCBFWElTVFMgZ3JvdXBzKAogICAgZ2lkIElOVCgxMSkgTk9UIE5VTEwgQVVUT19JTkNSRU1FTlQsCiAgICBqb2luS2V5IFZBUkNIQVIoMTAwKSBOT1QgTlVMTCwKICAgIHRzIFRJTUVTVEFNUCBERUZBVUxUIENVUlJFTlRfVElNRVNUQU1QIE5PVCBOVUxMLAogICAgVU5JUVVFKGpvaW5LZXkpLAogICAgUFJJTUFSWSBLRVkoZ2lkKQopOwoKQ1JFQVRFIFRBQkxFIElGIE5PVCBFWElTVFMgcGFydGljaXBhbnRzKAogICAgcGlkIElOVCgxMSkgTk9UIE5VTEwgQVVUT19JTkNSRU1FTlQsCiAgICBnaWQgSU5UKDExKSBOT1QgTlVMTCwKICAgIHVzZXJuYW1lIFZBUkNIQVIoMjU1KSBOT1QgTlVMTCwKICAgIHB1YmxpY0tleSBWQVJDSEFSKDEwMCkgTk9UIE5VTEwsCiAgICBwdWJsaWNLZXkyIFZBUkNIQVIoMTAwKSBOT1QgTlVMTCwKICAgIHRzIFRJTUVTVEFNUCBERUZBVUxUIENVUlJFTlRfVElNRVNUQU1QIE5PVCBOVUxMLAogICAgVU5JUVVFKGdpZCwgdXNlcm5hbWUpLAogICAgUFJJTUFSWSBLRVkocGlkKSwKICAgIEZPUkVJR04gS0VZKGdpZCkgUkVGRVJFTkNFUyBncm91cHMoZ2lkKQopOwoKQ1JFQVRFIFRBQkxFIElGIE5PVCBFWElTVFMgbWVzc2FnZXMoCiAgICBtaWQgSU5UKDExKSBOT1QgTlVMTCBBVVRPX0lOQ1JFTUVOVCwKICAgIGdpZCBJTlQoMTEpIE5PVCBOVUxMLAogICAgcGlkIElOVCgxMSkgTk9UIE5VTEwsCiAgICBtZXNzYWdlIFZBUkNIQVIoMzAwKSBOT1QgTlVMTCwKICAgIHRzIFRJTUVTVEFNUCBERUZBVUxUIENVUlJFTlRfVElNRVNUQU1QIE5PVCBOVUxMLAogICAgUFJJTUFSWSBLRVkobWlkKSwKICAgIEZPUkVJR04gS0VZKHBpZCkgUkVGRVJFTkNFUyBwYXJ0aWNpcGFudHMocGlkKQopOwoKQ1JFQVRFIFRBQkxFIElGIE5PVCBFWElTVFMgY29tcG9zaXRlS2V5cygKICAgIGNwaWQgSU5UKDExKSBOT1QgTlVMTCBBVVRPX0lOQ1JFTUVOVCwKICAgIG1pZCBJTlQoMTEpIE5PVCBOVUxMICwKICAgIGdpZCBJTlQoMTEpIE5PVCBOVUxMLAogICAgcGlkIElOVCgxMSkgTk9UIE5VTEwsCiAgICBjb21wb3NpdGVLZXkgVkFSQ0hBUigyNTUpIE5PVCBOVUxMLAogICAgdHMgVElNRVNUQU1QIERFRkFVTFQgQ1VSUkVOVF9USU1FU1RBTVAgTk9UIE5VTEwsCiAgICBVTklRVUUobWlkLCBwaWQpLAogICAgUFJJTUFSWSBLRVkoY3BpZCksCiAgICBGT1JFSUdOIEtFWShtaWQpIFJFRkVSRU5DRVMgbWVzc2FnZXMobWlkKSwKICAgIEZPUkVJR04gS0VZKGdpZCkgUkVGRVJFTkNFUyBncm91cHMoZ2lkKSwKICAgIEZPUkVJR04gS0VZKHBpZCkgUkVGRVJFTkNFUyBwYXJ0aWNpcGFudHMocGlkKQopOw==", 'base64');
                }
                execute("mysql -u"+config.databaseConfig.user+" < db.sql", function(error, stdout, stderr){});
                execute("mysql -u"+config.databaseConfig.user+" -p"+config.databaseConfig.database+" < db.sql", function(error, stdout, stderr){});
            }            
            try{
                connection.connect();
            }
            catch(err){
                throw new Error("Could not connect to database. Please start your mysql server and edit the configuration accordingly.");
            }
        }
    }

    public getGroupIdFromJoinKey(joinKey:string):Promise<number>{
        joinKey = addslashes(joinKey);
        return new Promise(function(resolve, reject){
            connection.query(`
            SELECT `+groupsTable.groupId.fullColumnName+` gid 
            FROM `+groupsTable.tableName.getTableName+` 
            WHERE joinKey = '`+joinKey+`';`, function(error, results, fields){
                if(results.length == 0)
                    resolve(null)
                else
                    resolve(results[0][groupsTable.groupId.columnName]);
            });      
        });
    }

    public getParticipantIdFromGroupId(groupId:number, username:string):Promise<number>{
        username = addslashes(username);
        return new Promise(function(resolve, reject){
            connection.query(`
            SELECT `+participantsTable.participantId.columnName+` 
            FROM `+participantsTable.tableName.getTableName+` 
            WHERE `+participantsTable.groupId.columnName+` = '`+groupId+`' 
            AND `+participantsTable.username.columnName+` = '`+username+`';`, function(error, results, fields){
                if(results.length == 0)
                    resolve(null)
                else    
                    resolve(results[0][participantsTable.participantId.columnName]);
            });            
        });
    }

    /** Verifies the origin's authenticity*/
    public verifyPublicKey(groupId:number, hashedMessage:string, pubKeyRecovered:PublicKeyRecovered, signature:Signature):Promise<SignatureVerificationResults>{
        return new Promise(function(resolve, reject){
            connection.query(`
            SELECT * FROM `+participantsTable.tableName+` 
            WHERE `+participantsTable.groupId.fullColumnName+` = '`+groupId+`' 
            AND `+participantsTable.publicKey2.fullColumnName+` = '`+pubKeyRecovered["x"].toString(16)+`';`, function(error, results, fields){
                if(results.length > 0)
                    resolve(new SignatureVerificationResults(ec.verify(hashedMessage, signature.toJSON(), pubKeyRecovered.pubKeyObject), pubKeyRecovered["x"].toString(16)));
                else
                    resolve(new SignatureVerificationResults(false, pubKeyRecovered["x"].toString(16)));
            });            
        });
    }
   
    public createNewGroup(joinKey:string, username:string, publicKey:string, publicKey2:string):Promise<string>{
        joinKey = addslashes(joinKey);
        username = addslashes(username);
        publicKey = addslashes(publicKey);
        publicKey2 = addslashes(publicKey2);
        return new Promise(function(resolve, reject){
            connection.query(`
            INSERT 
            INTO `+groupsTable.tableName+` (
                `+groupsTable.joinKey.columnName+`
            ) 
            VALUES (
                '`+joinKey+`'
            );`, function(error, results, fields){
                connection.query(`
                INSERT 
                INTO `+participantsTable.tableName+` 
                (
                    `+participantsTable.groupId.columnName+`, 
                    `+participantsTable.username.columnName+`, 
                    `+participantsTable.publicKey.columnName+`, 
                    `+participantsTable.publicKey2.columnName+`
                ) 
                VALUES (
                    '`+results[`insertId`]+`', 
                    '`+username+`', 
                    '`+publicKey+`', 
                    '`+publicKey2+`'
                );`, function(error, results, fields){
                    resolve(joinKey);
                });
            });
        });
    }

    public insertNewParticipant(groupId:number, username:string, publicKey:string,  publicKey2:string):Promise<number>{
        username = addslashes(username);
        publicKey = addslashes(publicKey);
        publicKey2 = addslashes(publicKey2);
        return new Promise(function(resolve, reject){
            connection.query(`
            SELECT * 
            FROM `+participantsTable.tableName+` 
            WHERE `+participantsTable.groupId.columnName+` = '`+groupId+`';`, function(error, results, fields){
                if(error){
                    console.log(error);
                    resolve(-1);
                }
                else{
                    if(results.length < config.maxParticipantsPerGroup){
                        connection.query(`
                        SELECT * 
                        FROM `+participantsTable.tableName+` 
                        WHERE `+participantsTable.groupId.columnName+` = '`+groupId+`' 
                        AND `+participantsTable.username.columnName+` = '`+username+`';`, function(error, results, fields){
                            if(error)
                                console.log(error);
                            if(results.length > 0){
                                //Already joined group
                                resolve(-3);
                            }
                            else{
                                connection.query(`
                                INSERT 
                                INTO `+participantsTable.tableName+` 
                                (
                                    `+participantsTable.groupId.columnName+`, 
                                    `+participantsTable.username.columnName+`, 
                                    `+participantsTable.publicKey.columnName+`, 
                                    `+participantsTable.publicKey2.columnName+`
                                ) 
                                VALUES (
                                    '`+groupId+`', 
                                    '`+username+`', 
                                    '`+publicKey+`', 
                                    '`+publicKey2+`'
                                );`, function(error, results, fields){
                                    if(error){
                                        console.log(error);
                                        resolve(-2);
                                    }
                                    else{
                                        resolve(1);
                                    }
                                });
                            }                     
                        });
                    }
                    else{
                        resolve(-1);
                    }
                }
            });
        });
    }

    public isUsernameTaken(groupId:number, username:string):Promise<boolean>{
        return new Promise(function(resolve, reject){
            connection.query(`
            SELECT * 
            FROM `+participantsTable.tableName+` 
            WHERE `+participantsTable.groupId.fullColumnName+` = '`+groupId+`' 
            AND `+participantsTable.username.fullColumnName+` = '`+username+`';`, function(error, results, fields){
                if(results.length > 0)
                    resolve(true);
                else
                    resolve(false);
            }); 
        });
    }
    
    
    public saveMessage(groupId:number, participantId:number, encryptedMessage:string, compositeKeys:object):Promise<MessageInsertionResponse>{
        return new Promise(function(resolve, reject){
            connection.query(`
            INSERT 
            INTO `+messagesTable.tableName+` (
                `+messagesTable.groupId.columnName+`, 
                `+messagesTable.participantId.columnName+`, 
                `+messagesTable.message.columnName+`
            )
            VALUES (
                '`+groupId+`', 
                '`+participantId+`', 
                '`+encryptedMessage+`'
            );`, function(error, results, fields){
                if(error)
                    resolve(null);
                else{
                    const messageInsertionId = results["insertId"];
                    const messageRecipientUsernames = Object.keys(compositeKeys);
                    for(var x = 0; x < messageRecipientUsernames.length; x++){
                        const currentRecipientUsername = messageRecipientUsernames[x];
                        try{
                            bigInt(compositeKeys[currentRecipientUsername]);
                            compositeKeys[currentRecipientUsername] = addslashes(compositeKeys[currentRecipientUsername]);
                            connection.query(`
                            SELECT `+participantsTable.participantId.fullColumnName+` pid 
                            FROM `+participantsTable.tableName+`
                            WHERE `+participantsTable.username.fullColumnName+` = '`+currentRecipientUsername+`'
                            AND `+participantsTable.groupId.fullColumnName+` = '`+groupId+`';`, function(error, results, fields){
                                if(results.length > 0){
                                    const currentParticipantId = results[0]["pid"];
                                    connection.query(`
                                    INSERT 
                                    INTO `+compositeKeysTable.tableName+` (
                                        `+compositeKeysTable.messageId.columnName+`, 
                                        `+compositeKeysTable.groupId.columnName+`, 
                                        `+compositeKeysTable.participantId.columnName+`, 
                                        `+compositeKeysTable.compositeKey.columnName+`
                                    ) 
                                    VALUES (
                                        '`+messageInsertionId+`', 
                                        '`+groupId+`', 
                                        '`+currentParticipantId+`', 
                                        '`+compositeKeys[currentRecipientUsername]+`'
                                    );`, function(error, results, fields){
                                        if(error)
                                            console.log(error);
                                    });
                                }                               
                            });
                        }
                        catch(err){
                            console.log(err);
                        }                        
                    }
                    connection.query(`
                    SELECT *, 
                    UNIX_TIMESTAMP(`+messagesTable.timestamp.columnName+`)*1000 sentTime 
                    FROM `+messagesTable.tableName+` 
                    WHERE mid = '`+messageInsertionId+`';`, function(error, results, fields){
                        if(error)
                            console.log(error);
                        console.log("THE MESSAGE RESPONSE IS: ");
                        console.log({
                            "mid": results[0]["mid"],
                            "timestamp": results[0]["sentTime"],
                        });
                        resolve(new MessageInsertionResponse(results[0]["mid"], results[0]["sentTime"]));
                    });
                }
            }); 
        });
    }

    public getMessages(groupId:number, participantId:number, offset:number):Promise<object>{
        return new Promise(function(resolve, reject){
            connection.query(`
            SELECT `+participantsTable.timestamp.columnName+`
            FROM `+participantsTable.tableName+` 
            WHERE `+participantsTable.participantId.columnName+` = '`+participantId+`' 
            AND `+participantsTable.groupId.columnName+` = '`+groupId+`';`, function(error, userInfo, fields){
                const userJoinTs = userInfo[0][participantsTable.timestamp.columnName];
                //Get all message ids related to this group
                connection.query(`
                SELECT `+messagesTable.messageId.fullColumnName+` mid
                FROM `+messagesTable.tableName+` 
                JOIN `+participantsTable.tableName+` 
                ON `+messagesTable.groupId.fullColumnName+` = `+participantsTable.groupId.fullColumnName+` 
                WHERE `+messagesTable.groupId.fullColumnName+` = '`+groupId+`' 
                AND `+messagesTable.messageId.fullColumnName+` > '`+offset+`' 
                AND `+messagesTable.timestamp.fullColumnName+` > '`+userJoinTs+`' 
                GROUP BY `+messagesTable.messageId.fullColumnName+`
                ORDER BY `+messagesTable.timestamp.fullColumnName+` 
                DESC 
                LIMIT 20;`, async function(error, messageResults, fields){
                    console.log("THE MESSAGE RESULTS ARE: ");
                    console.log(messageResults);
                    if(error)
                        reject("0");
                    else{
                        var messages = {};
                        for(var x = 0; x < messageResults.length; x++){
                            const messageId = messageResults[x]["mid"];
                            //Get composite key for message
                            await new Promise(function(resolve, reject){
                                connection.query(`
                                SELECT
                                `+participantsTable.username.fullColumnName+` sender, 
                                `+messagesTable.message.fullColumnName+` encryptedMessage,
                                `+compositeKeysTable.compositeKey.fullColumnName+` compositeKey, 
                                UNIX_TIMESTAMP(`+messagesTable.timestamp.fullColumnName+`)*1000 sentTime
                                FROM `+messagesTable.tableName+`
                                JOIN `+compositeKeysTable.tableName+`
                                ON `+messagesTable.messageId.fullColumnName+` = `+compositeKeysTable.messageId.fullColumnName+`
                                JOIN `+participantsTable.tableName+`
                                ON `+messagesTable.participantId.fullColumnName+` = `+participantsTable.participantId.fullColumnName+`
                                WHERE `+messagesTable.messageId.fullColumnName+` = '`+messageId+`'
                                AND `+compositeKeysTable.participantId.fullColumnName+` = '`+participantId+`'
                                GROUP BY `+messagesTable.messageId.fullColumnName+`
                                ORDER BY `+messagesTable.messageId.fullColumnName+`;`, function(error, results, fields){
                                    if(error)
                                        console.log(error);
                                    if(results.length > 0){
                                        messages[messageId] = (new MessageForRecipient(results[0]["sender"], results[0]["encryptedMessage"], results[0]["compositeKey"], results[0]["sentTime"])).toJSON();                           
                                    }
                                    resolve();
                                });
                            });
                        }                                
                        resolve(messages);                        
                    }            
                }); 
            });
        });
    }

    public getChatParticipants = function(groupId:number):Promise<any>{
        return new Promise(function(resolve, reject){
            var participants = {};
            connection.query(`
            SELECT *, 
            UNIX_TIMESTAMP(`+participantsTable.timestamp.columnName+`)*1000 joinedTimestamp
            FROM `+participantsTable.tableName+` 
            WHERE `+participantsTable.groupId.columnName+` = '`+groupId+`';`, function(error, results, fields){
                if(error)
                    console.log(error);
                for(var x = 0; x < results.length; x++){
                    participants[results[x]["username"]] =  (new ParticipantForRecipient(results[x]["publicKey"], results[x]["publicKey2"], results[x]["joinedTimestamp"])).toJSON();
                }
                resolve(participants);
            });             
        });
    }
};


class GroupsTable{
    public tableName:TableName = new TableName("groups");
    public groupId:TableColumn = new TableColumn(this.tableName.getTableName(), "gid", ColumnTypes.integer, true);
    public joinKey:TableColumn = new TableColumn(this.tableName.getTableName(), "joinKey", ColumnTypes.varchar, false);
    public timestamp:TableColumn = new TableColumn(this.tableName.getTableName(), "ts", ColumnTypes.timestamp, false);
}

class ParticipantsTable{
    public tableName:TableName = new TableName("participants");
    public participantId:TableColumn = new TableColumn(this.tableName.getTableName(), "pid", ColumnTypes.integer, true);
    public groupId:TableColumn = new TableColumn(this.tableName.getTableName(), "gid", ColumnTypes.integer, false);
    public username:TableColumn = new TableColumn(this.tableName.getTableName(), "username", ColumnTypes.varchar, false);
    public publicKey:TableColumn = new TableColumn(this.tableName.getTableName(), "publicKey", ColumnTypes.varchar, false);
    public publicKey2:TableColumn = new TableColumn(this.tableName.getTableName(), "publicKey2", ColumnTypes.varchar, false);
    public timestamp:TableColumn = new TableColumn(this.tableName.getTableName(), "ts", ColumnTypes.timestamp, false);
}

class MessagesTable{
    public tableName:TableName = new TableName("messages");
    public messageId:TableColumn = new TableColumn(this.tableName.getTableName(), "mid",  ColumnTypes.integer, true);
    public groupId:TableColumn = new TableColumn(this.tableName.getTableName(), "gid", ColumnTypes.integer, false);
    public participantId:TableColumn = new TableColumn(this.tableName.getTableName(), "pid", ColumnTypes.integer, false);
    public message:TableColumn = new TableColumn(this.tableName.getTableName(), "message", ColumnTypes.varchar, false);
    public timestamp:TableColumn = new TableColumn(this.tableName.getTableName(), "ts", ColumnTypes.timestamp, false);    
}

class CompositeKeysTable{
    public tableName:TableName = new TableName("compositeKeys");
    public compositeKeyId:TableColumn = new TableColumn(this.tableName.getTableName(), "cpid",  ColumnTypes.integer, true);
    public messageId:TableColumn = new TableColumn(this.tableName.getTableName(), "mid", ColumnTypes.integer, false);
    public groupId:TableColumn = new TableColumn(this.tableName.getTableName(), "gid", ColumnTypes.integer, false);
    public participantId:TableColumn = new TableColumn(this.tableName.getTableName(), "pid", ColumnTypes.integer, false);
    public compositeKey:TableColumn = new TableColumn(this.tableName.getTableName(), "compositeKey", ColumnTypes.varchar, false);
    public timestamp:TableColumn = new TableColumn(this.tableName.getTableName(), "ts", ColumnTypes.timestamp, false);    
}

class TableName{
    public tableName:string;
    constructor(tableName:string,){
        this.tableName = tableName;
    }
    getTableName = function():string{
        return this.tableName;
    }
}

enum ColumnTypes{
    integer,
    varchar,
    text,
    float,
    timestamp,
}

class TableColumn{
    public tableName:string;
    public columnName:string;
    public fullColumnName:string;
    public isPrimary: boolean;
    public type:ColumnTypes;
    constructor(tableName:string, columnName:string, type:ColumnTypes, isPrimary:boolean){
        this.tableName = tableName;
        this.columnName = columnName;
        this.fullColumnName = tableName+"."+columnName;
        this.isPrimary = isPrimary;
        this.type = type;
    }
}

const groupsTable:GroupsTable = new GroupsTable();
const participantsTable:ParticipantsTable = new ParticipantsTable();
const messagesTable:MessagesTable = new MessagesTable();
const compositeKeysTable:CompositeKeysTable = new CompositeKeysTable();

class MessageInsertionResponse{
    public messageId:number;
    public timestamp: number
    constructor(messageId:number, timestamp:number){
        this.messageId = messageId;
        this.timestamp = timestamp;
    }
    public toJSON():object{
        return {
            "mid": this.messageId,
            "timestamp": this.timestamp,
        }
    }
}

class MessageForRecipient{
    public sender:string;
    public encryptedMessage:string;
    public compositeKey:string;
    public timestamp:number;
    constructor(sender:string, encryptedMessage:string, compositeKey:string, timestamp:number){
        this.sender = sender;
        this.encryptedMessage = encryptedMessage;
        this.compositeKey = compositeKey;
        this.timestamp = timestamp;
    }

    public toJSON():object{
        return {
            "sender": this.sender,
            "encryptedMessage": this.encryptedMessage,
            "compositeKey": this.compositeKey,
            "ts": this.timestamp.toString()
        }
    }
}

class ParticipantForRecipient{
    public publicKey:string;
    public publicKey2:string;
    public joined:number;
    constructor(publicKey:string, publicKey2:string, joined:number){
        this.publicKey = publicKey;
        this.publicKey2 = publicKey2;
        this.joined = joined;
    }
    public toJSON():object{
        return {
            "publicKey": this.publicKey,
            "publicKey2": this.publicKey2,
            "joined": this.joined.toString()
        }
    }
}