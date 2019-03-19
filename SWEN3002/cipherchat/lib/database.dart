import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
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
  final String inboxTable = "inbox";
  final String outboxTable = "outbox";
  ///Columns Are: mid, username, ip, msg, inbound, ts
  final String messagesTable = "messages";
  final String connectionsTable = "groups";
  final String defaultProfilePicBase64 = "";

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
      await db.execute("CREATE TABLE IF NOT EXISTS $messagesTable(mid INTEGER PRIMARY KEY, username TEXT, ip TEXT, msg TEXT, inbound INTEGER(1) DEFAULT 0, ts DATETIME DEFAULT CURRENT_TIMESTAMP");
      //await db.execute("CREATE TABLE IF NOT EXISTS $inboxTable(inId INTEGER PRIMARY KEY, username TEXT, ip TEXT, msg TEXT, ts DATETIME DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(aid) REFERENCES ($accountTable.aid))");
      //await db.execute("CREATE TABLE IF NOT EXISTS $outboxTable(usrid INTEGER PRIMARY KEY, username TEXT, ip TEXT, msg TEXT, ts DATETIME DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(aid) REFERENCES ($accountTable.aid))");
      await rootBundle
        .loadString(defaultProfilePicFile)
        .then((fileContents) async{
          await db.rawInsert("INSERT INTO $accountTable (username, profilePic) VALUES ('Anonymous', '$fileContents')");
        });
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

  Future<Map> getCurrentUserInfo() async{
    Map info = {
      "username":"",
      "profilePic": ""
    };
    var client = await getDatabase();
    try{
      List query = await client.rawQuery("SELECT * FROM $accountTable");
      info["username"] = query[0]["username"];
      String base64Image = query[0]["profilePic"];
      Uint8List bytes = base64.decode(base64Image);
      info["profilePic"] = Image.memory(Uint8List.fromList(bytes));
    }
    catch(err){
      print(err);
    }
    return info;
  }
  

  Future<List> getMessages(String ipAddress, String username, bool isGroup, List<String> negatePostsArray, bool loadMore) async{
    var client = await getDatabase();
    
    List results = [];
    try{
      if(!isGroup){
        if(loadMore){
          String negation = listToSqlArray(negatePostsArray);
          results = await client.rawQuery("SELECT * FROM $messagesTable WHERE ip = '$ipAddress' AND username = '$username' WHERE mid NOT IN $negation ORDER BY ts DESC LIMIT "+negatePostsArray.length.toString());
          results = List.from(results)..addAll(
            await client.rawQuery("SELECT * FROM $messagesTable WHERE ip = '$ipAddress' AND username = '$username' WHERE mid NOT IN $negation ORDER BY ts DESC LIMIT 20")
          );
        }
        else{
          results = await client.rawQuery("SELECT * FROM $messagesTable WHERE ip = '$ipAddress' AND username = '$username' ORDER BY ts DESC LIMIT 20");
        }
      }
    }
    catch(err){
      print(err);
    } 
    return results;
  }



  Future<bool> saveMessage(String message) async{
    var client = await getDatabase();
    try{
      await client.rawInsert("INSERT INTO $messagesTable (username, ip, msg, inbound) VALUES ('$peerUsername', '$peerIpAddress', '$message', '0')");
    }
    catch(err){
      print(err);
      return false;
    }
    return true;    
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
