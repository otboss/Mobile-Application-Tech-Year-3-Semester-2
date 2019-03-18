import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  static final DatabaseManager _databaseManager = new DatabaseManager.internal();

  factory DatabaseManager() {
    return _databaseManager;
  }

  static Database db;

  final String accountTable = "accountInfo";
  final String inboxTable = "inbox";
  final String outboxTable = "outbox";
  final String connectionsTable = "connections";

  DatabaseManager.internal();

  Future<bool> saveMessage(String message) {}

  Future<String> getDatabasePath() async {
    Directory privateStorage = await getApplicationDocumentsDirectory();
    return join(privateStorage.path, 'steemitsentinels.db');
  }

  Future<Database> initDb() async {
    try {
      String path = await getDatabasePath();
      db = await openDatabase(path, version: 1);
      await db.execute("CREATE TABLE IF NOT EXISTS $accountTable(aid INTEGER PRIMARY KEY, username TEXT, ipAddress TEXT, port INTEGER, ts DATETIME DEFAULT CURRENT_TIMESTAMP)");
      await db.execute("CREATE TABLE IF NOT EXISTS $connectionsTable(usrid INTEGER PRIMARY KEY, username TEXT, network TEXT, ts DATETIME DEFAULT CURRENT_TIMESTAMP)");
      await db.execute("CREATE TABLE IF NOT EXISTS $inboxTable(inId INTEGER PRIMARY KEY, username TEXT, network TEXT, ts DATETIME DEFAULT CURRENT_TIMESTAMP)");
      await db.execute("CREATE TABLE IF NOT EXISTS $outboxTable(usrid INTEGER PRIMARY KEY, username TEXT, network TEXT, ts DATETIME DEFAULT CURRENT_TIMESTAMP)");
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

  
}
