import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cipherchat/screens/chat.dart';
import 'package:cipherchat/screens/start.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import './secp256k1.dart';
import './database.dart';
import './screens/home.dart';
import 'package:toast/toast.dart';

void main() => runApp(MyApp());

Dio dio = Dio(Options(connectTimeout: 5000, receiveTimeout: 5000));
final flutterWebviewPlugin = FlutterWebviewPlugin();
final DatabaseManager databaseManager = DatabaseManager();
final Secp256k1 secp256k1EllipticCurve = Secp256k1();

//Color themeColor = Color.fromRGBO(35, 55, 74, 1);
Color themeColor = Color.fromRGBO(42, 66, 89, 1);
//Color themeColor = Color.fromRGBO(162, 162, 162, 1);
Color materialGreen = Colors.teal[400];
Color appBarTextColor = Colors.white;
Color cardColor = Colors.white;
Color sentMessageWidgetColor = Color.fromRGBO(48, 76, 102, 1);
Color receivedMessageWidgetColor = Colors.grey[350];
List<Color> receivedMessageUserIndicatorColor = [
  materialGreen,
  Colors.pink,
  Colors.lightGreen,
  Colors.orange,
  Colors.purple,
  Colors.redAccent,
  Colors.yellow[600],
  Colors.brown,
  Colors.indigo
];
Map serverEntrypoints = {
  "/": "get",
  "/ads": "get",
  "/newgroup": "post",
  "/joingroup": "post",
  "/message": "post",
  "/messages": "get",
  "/anynewmessages": "get",
  "/participants": "get",
  "/isusernametaken": "post"
};

final int limitPerChatsFetchFromDatabase = 20;
final int limitPerMessagesFetchFromDatabase = 20;
final int publicServersPerRequest = 10;

int currentGroupId = 0;
String currentServer = "";
int currentPort = 0;
BigInt currentPrivateKey = BigInt.parse("1");
Map currentPublicKey = {};
bool newGroupConnection = true;
JoinKey globalGroupJoinKey;

Future<bool> toastMessageBottomShort(String message, BuildContext context) async {
  Toast.show(message, context, duration: 4, gravity: Toast.BOTTOM);
  return true;
}

Future<bool> isConnected() async {
  try {
    await dio.get("http://example.com/");
    return true;
  } catch (err) {
    return false;
  }
}

Image base64ToImageConverter(String base64String) {
  Uint8List bytes = base64.decode(base64String);
  return Image.memory(Uint8List.fromList(bytes));
}

Future<bool> launchUrlInWebview(String url, bool hidden) async {
  try {
    await flutterWebviewPlugin.launch(url, hidden: hidden);
  } catch (err) {
    await flutterWebviewPlugin.close();
    await flutterWebviewPlugin.launch(url, hidden: hidden);
  }
  return true;
}

Future<bool> showCustomProcessDialog(String text, BuildContext context, {bool dissmissable, TextAlign alignment}) async {
  if (dissmissable == null) 
    dissmissable = false;
  if (alignment == null) 
    alignment = TextAlign.left;
  Widget customDialog = AlertDialog(
    title: Text(
      text,
      textAlign: alignment,
    ),
    content: SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Column(
          children: <Widget>[
            CircularProgressIndicator(
              backgroundColor: themeColor,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    ),
    actions: <Widget>[],
  );
  showDialog(context: context, child: customDialog, barrierDismissible: dissmissable);
  return true;
}

Future<void> showAlert(String title, String body, BuildContext context) {
  Widget alert = AlertDialog(
    title: Text(title),
    content: SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: ListBody(
          children: <Widget>[
            Text(body),
          ],
        ),
      ),
    ),
    actions: <Widget>[
      FlatButton(
        child: Text("OK", style: TextStyle(color: materialGreen)),
        onPressed: () {
          Navigator.pop(context);
        },
      )
    ],
  );
  showDialog(context: context, child: alert, barrierDismissible: true);
}


Future<bool> checkServerRoutes(String ip, int port) async{
  try{
    List entrypoints = serverEntrypoints.keys.toList();
    for(var x = 0; x < entrypoints.length; x++){
      switch(serverEntrypoints[entrypoints[x]]){
        case "get":
          await dio.get("https://"+ip+":"+port.toString()+entrypoints[x]);
          break;
        case "post":
          await dio.post("https://"+ip+":"+port.toString()+entrypoints[x]);
          break;
        case "put":
          await dio.put("https://"+ip+":"+port.toString()+entrypoints[x]);
          break;
        case "delete":
          await dio.delete("https://"+ip+":"+port.toString()+entrypoints[x]);
          break;
      }
    }    
  }
  catch(err){
    return false;
  }
  return true;
}

Future<void> showPrompt(String title, BuildContext context,
    TextEditingController controller, Future<dynamic> callback()) {
  Widget alert = AlertDialog(
      title: Text(
        title,
      ),
      content: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: ListBody(
            children: <Widget>[
              Theme(
                data: ThemeData(cursorColor: materialGreen),
                child: TextField(
                  obscureText: false,
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: materialGreen),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: materialGreen, width: 2.0),
                      ),
                      //labelText: "(eg.) https://steemit.com/blog/@username/blog-title",
                      border: new UnderlineInputBorder(
                          borderSide: new BorderSide(color: Colors.red)),
                      labelStyle: Theme.of(context)
                          .textTheme
                          .caption
                          .copyWith(color: materialGreen, fontSize: 16),
                      errorText: null),
                  style: TextStyle(color: materialGreen, fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("OK", style: TextStyle(color: materialGreen)),
          onPressed: () {
            Navigator.pop(context);
            //START NEW SEARCH
            callback();
          },
        )
      ],);
  showDialog(context: context, barrierDismissible: true, child: alert);
  Completer<Null> completer = Completer();
  completer.complete();
  return completer.future;
}



Widget loadingIndicator ({color: Colors}){
  if(color == null)
    color = Colors.blue;
  return Center(
    child: new ListView(
      shrinkWrap: true,
        padding: const EdgeInsets.all(20.0),
        children: [
          SingleChildScrollView(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(0, 5, 0, 60),
              child: Column(
                children: <Widget>[
                  CircularProgressIndicator(
                    backgroundColor: themeColor,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ],
              ),
            ),
          )                    
        ]
    ),
  );
}



///Selects a public CipherChat Server from the first issue
///page on CipherChat's GitHub
Future<Map> selectRandomServerFromGithub() async{
  try{
    await launchUrlInWebview("https://github.com/CipherChat/CipherChat/issues?page=1&utf8=✓&q=is%3Aopen+is%3Aissue+Public+Server+Submission+", true);
    String serverInfo = await flutterWebviewPlugin.evalJavascript(r"""
      const getRandomInt = function(min, max) {
          min = Math.ceil(min);
          max = Math.floor(max);
          return Math.floor(Math.random() * (max - min + 1)) + min;
      }
      var numberOfIssues = $(".h4").length;
      if(numberOfIssues > 0){
        getServerInfo = async function(){     
          var tries = 0;
          while(true){
            var selectedServer = getRandomInt(0, numberOfIssues);
            var link = $($(".h4")[selectedServer]).attr("data-hovercard-url"); 
            var serverInfo = await new Promise(function(resolve, reject){
              $.ajax({
                "url": link,
                success: function(response){
                  try{
                    response = JSON.parse($($("p", $.parseHTML(response))[0]).html());
                    if(response["ip"] != null && response["port"] != null)
                      resolve(response);
                    else
                      resolve(null);
                  }
                  catch(err){
                    resolve(null);
                  }
                }
              });
            });
            if(serverInfo != null)
              break;
            tries++;
            console.log(tries);
            if(tries >= 50)
              break;
          }   
          if(tries >= 50)
            reject();       
          else
            return serverInfo;
        }
        getServerInfo().then(function(serverInfo){
          serverInfo;
        }).catch(function(err){
          null;
        });
      }
      else{
        null;
      }
    """);
    await flutterWebviewPlugin.close();
    if(serverInfo == "null")
      return null;
    else
      return json.decode(serverInfo);    
  }
  catch(err){
    //connection error
  }
  return null;
}

Future<Map> getServerInfo(String ip) async{
  Map result = {};
  try{
    Response response = await dio.get("https://extreme-ip-lookup.com/json/"+ip);
    result = json.decode(json.encode(response.data));
    if(result["org"] == "Private IP Address LAN"){
      Response publicIpAddress = await dio.get("https://ipecho.net/plain");
      response = await dio.get("https://extreme-ip-lookup.com/json/"+publicIpAddress.data);
      result = json.decode(json.encode(response.data));      
    }
  }
  catch(err){

  }
  return result;
}


Future<bool> isUsernameTakenForServer(String ip, int port, String username, String joinKey, String encryptedMessage, Map signature) async{
  try{
    String currentServerUrl = "https://" + ip + ":" + port.toString() + "/";
    Response response = await dio.post(currentServerUrl+"isusernametaken", data:{
      "encryptedMessage": encryptedMessage,
      "signature": json.encode(signature),
      "username": username,
      "joinKey": joinKey,
    });  
    if(response.data == "1")
      return true;
  }
  catch(err){
    print(err);
  }
  return false;   
}       

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CipherChat',
      theme: ThemeData(
        dividerColor: Colors.transparent,
        primaryColor: themeColor,
      ),
      home: Home(),
      routes: {
        "/home": (BuildContext context) => Home(),
        "/start": (BuildContext context) => Start(),
        "/chat": (BuildContext context) => Chat(),
      },
    );
  }
}


class JoinKey{
  String ip, encryptedMessage, joinKey, username;
  int port;
  Map signature;
  BigInt publicKey, publicKey2;
  JoinKey(String ip, int port, String encryptedMessage, Map signature, String joinKey, BigInt publicKey, BigInt publicKey2, String username){
    this.ip = ip;
    this.port = port;
    this.encryptedMessage = encryptedMessage;
    this.signature = signature;
    this.joinKey = joinKey;
    this.publicKey = publicKey;
    this.publicKey2 = publicKey2;
    this.username = username;
  }
  toJSON(){
    return {
      "ip": ip,
      "port": port,
      "signature": signature,
      "encryptedMessage": encryptedMessage,
      "joinKey": joinKey,
      "username": username,
      "publicKey": publicKey,
      "publicKey2": publicKey2,
    };
  }
}