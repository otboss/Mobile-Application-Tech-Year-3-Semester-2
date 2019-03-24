import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import './main.dart';

class DatabaseManager {
  static final DatabaseManager _databaseManager = new DatabaseManager.internal();

  factory DatabaseManager() {
    return _databaseManager;
  }

  static Database db;
  ///Columns Are: aid, username, profilePic, ts
  final String accountTable = "accountInfo";
  
  ///Columns Are: conId, ip, ts
  final String connectionsTable = "connections";
  ///Columns Are: mid, conId, checksum, username, profilePic, msg, symmetricKey, privateKey, inbound, ts
  final String messagesTable = "messages";  
  
  final String inboxTable = "inbox";
  final String outboxTable = "outbox";

  final String defaultProfilePicBase64 = "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KUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJAiJAEASBGSAACkCEkAAFKEJAAAKUISAIAUIQkAQIqQBAAgRUgCAJDyP1UGRFJDdnk2AAAAAElFTkSuQmCC";

  DatabaseManager.internal();

  Future<String> getDatabasePath() async {
    Directory privateStorage = await getApplicationDocumentsDirectory();
    return join(privateStorage.path, 'steemitsentinels.db');
  }

  Future<Database> initDb() async {
    try {
      String path = await getDatabasePath();
      db = await openDatabase(path, version: 1);
      await db.execute("CREATE TABLE IF NOT EXISTS $accountTable(aid INTEGER PRIMARY KEY, username TEXT, profilePic TEXT, ts DATETIME DEFAULT CURRENT_TIMESTAMP)");
      await db.execute("CREATE TABLE IF NOT EXISTS $connectionsTable(conid INTEGER PRIMARY KEY, ip TEXT, ts DATETIME DEFAULT CURRENT_TIMESTAMP)");
      await db.execute("CREATE TABLE IF NOT EXISTS $messagesTable(mid INTEGER PRIMARY KEY, conid INTEGER, checksum TEXT, username TEXT, profilePic TEXT, msg TEXT, symmetricKey TEXT, privateKey TEXT, inbound INTEGER(1) DEFAULT 0, ts DATETIME DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(conid) REFERENCES ($connectionsTable))");      
      //await db.execute("CREATE TABLE IF NOT EXISTS $chatsTable(cid INTEGER PRIMARY KEY, username TEXT, profilePic TEXT, ts DATETIME DEFAULT CURRENT_TIMESTAMP)");
      //await db.execute("CREATE TABLE IF NOT EXISTS $inboxTable(inId INTEGER PRIMARY KEY, username TEXT, ip TEXT, msg TEXT, ts DATETIME DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(aid) REFERENCES ($accountTable.aid))");
      //await db.execute("CREATE TABLE IF NOT EXISTS $outboxTable(usrid INTEGER PRIMARY KEY, username TEXT, ip TEXT, msg TEXT, ts DATETIME DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(aid) REFERENCES ($accountTable.aid))");
      /*await rootBundle
        .loadString(defaultProfilePicFile)
        .then((fileContents) async{
          await db.rawInsert("INSERT INTO $accountTable (username, profilePic) VALUES ('Anonymous', '$fileContents')");
        });*/
      print("Database Created Successfully");
      return db;
    } catch (err) {
      print(err);
      return db;
    }
  }

  Future<Database> getDatabase() async {
    if (db != null) return db;
    await initDb();
    return db;
  }

  Future<int> getCurrentConnection() async{
    var client = await getDatabase();
    try{
      List query = await client.rawQuery("SELECT MAX(conId) FROM $connectionsTable");
      return query[0]["conId"];
    }
    catch(err){
      print(err);
      return null;
    }
  }

  Future<Map> getCurrentUserInfo() async{
    Map info = {
      "username":"",
      "profilePic": ""
    };
    List query;
    var client = await getDatabase();
    try{
      query = await client.rawQuery("SELECT * FROM $accountTable");
      if(query.length == 0){
        await db.rawInsert("INSERT INTO $accountTable (username, profilePic) VALUES ('Anonymous', '$defaultProfilePicBase64')");
      }
      query = await client.rawQuery("SELECT * FROM $accountTable");
      info["username"] = query[0]["username"];
      info["profilePic"] = query[0]["profilePic"];
    }
    catch(err){
      print(err);
    }
    return info;
  }


  Future<bool> saveMessage(String message, String checksum, String sender, String symmetricKey, String privateKey, String profilePic, int inbound) async{
    var client = await getDatabase();
    try{
      int currentConnection = await getCurrentConnection();
      List previousMessages = await client.rawQuery("SELECT checksum FROM $messagesTable WHERE conId = $currentConnection");
      for(var x = 0; x < previousMessages.length; x++){
        if(checksum == previousMessages[x]["checksum"]){
          //Message Already Saved
          return true;
        }
      }
      await client.rawInsert("INSERT INTO $messagesTable (conId, checksum, username, profilePic, msg, symmetricKey, privateKey, inbound) VALUES ('$currentConnection', '$checksum', '$profilePic', '$sender', '$message', '$symmetricKey', '$privateKey', '$inbound')");
      /*List query = await client.rawQuery("SELECT MAX(mid) FROM $messagesTable WHERE username = '$username' AND conId = '$currentConnection'");
      int newInsertionId = query[0]["mid"];
      loadedMessagesIds[newInsertionId] = true;*/
    }
    catch(err){
      print(err);
      return false;
    }
    return true;    
  }

  ///Returns A list of the past conversation and the last message
  ///of each conversation
  Future<List> getPreviousConversations(String ipAddress) async{
    var client = await getDatabase();
    try{
      return await client.rawQuery("SELECT * FROM $connectionsTable JOIN $messagesTable ON $connectionsTable.conId = $messagesTable.conId WHERE $connectionsTable.ip = '$ipAddress' GROUP BY $connectionsTable.conId HAVING MAX($messagesTable.mid)");
    }
    catch(err){
      print(err);
    }
    return [];
  }

  /*
  Future<bool> isPreviousChat() async{
    var client = await getDatabase();
    try{
      List previousChat = await client.rawQuery("SELECT * FROM $chatsTable WHERE username = '$peerUsername'");
      if(previousChat.length == 0)
        return false;
    }
    catch(err){
      print(err);
      return false;
    }
    return true;
  }*/

  Future<bool> updateUsername(String newUsername) async{
    var client = await getDatabase();
    try{
      await client.rawUpdate("UPDATE $accountTable SET username = '$newUsername'");
    }
    catch(err){
      print(err);
      return false;
    }
    return true;      
  }

  Future<bool> updateProfilePicture(String base64profilePic) async{
    var client = await getDatabase();
    try{
      await client.rawUpdate("UPDATE $accountTable SET profilePic = '$base64profilePic'");
    }
    catch(err){
      print(err);
      return false;
    }
    return true;     
  }


  ///Gets the messages for a specific ip address and username from the database
  Future<List> getMessages(String ipAddress, bool isGroup, List negatePostsArray, bool loadMore) async{
    var client = await getDatabase();
    List results = [];
    try{
      if(!isGroup){
        if(loadMore){
          String negation = listToSqlArray(negatePostsArray);
          results = await client.rawQuery("SELECT * FROM $messagesTable WHERE ip = '$ipAddress' ORDER BY ts DESC LIMIT "+negatePostsArray.length.toString());
          results = List.from(results)..addAll(
            await client.rawQuery("SELECT * FROM $messagesTable WHERE ip = '$ipAddress' WHERE mid NOT IN $negation ORDER BY ts DESC LIMIT $limitPerMessagesFetchFromDatabase")
          );
        }
        else{
          results = await client.rawQuery("SELECT * FROM $messagesTable WHERE ip = '$ipAddress' ORDER BY ts DESC LIMIT $limitPerMessagesFetchFromDatabase");
        }
      }
    }
    catch(err){
      print(err);
    } 
    return results;
  }

  String listToSqlArray(List lst){
    String sqlArr = "(";
    if(lst.length == 0){
      lst = [];
      sqlArr = "('')";
    }
    else{
      for(var x = 0; x < lst.length; x++){
        if(x != lst.length - 1)
          sqlArr += "'"+lst[x]+"',";
        else
          sqlArr += "'"+lst[x]+"'";
      }
      sqlArr += ")";
    }
    return sqlArr;
  }

  
}
