import 'dart:convert';
import 'dart:io';
import 'package:cipherchat/screens/chat.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../custom_expansion_tile.dart' as custom;
import '../main.dart';

class Start extends StatefulWidget {
  StartState createState() => StartState();
}

class StartState extends State<Start> {


  TextEditingController ipFieldController = TextEditingController();
  TextEditingController portFieldController = TextEditingController();
  TextEditingController joinKeyFieldController = TextEditingController();

  bool ascendingSort = true;
  Widget previousServerFetch = Container();


  @override
  Widget build(BuildContext context) {
    dio.onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
    };
    
    portFieldController.text = "6333";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: appBarTextColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Create New Chat",
          style: TextStyle(
            color: appBarTextColor,
          ),
        ),
      ),
      body: Center(
        child: new ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20.0),
          children: [
            Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 0, 5),
                  child: Opacity(
                    child: Icon(Icons.chat, size: 70, color: themeColor,),
                    opacity: 0.9,
                  )
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 0, 20),
                  alignment: Alignment.center,
                  child: Text(
                    "Connect to Secure CipherChat Server",
                    style: TextStyle(
                      color: themeColor,
                    ), 
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 300),
                  child: Theme(
                    data: ThemeData(
                      cursorColor: Colors.black87,
                    ),
                    child: TextField(
                      obscureText: false,
                      controller: ipFieldController,
                      autofocus: false,
                      decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black87),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black87, width: 1.0),
                        ),
                        labelText: "IP Address",
                        border: new UnderlineInputBorder(
                            borderSide: new BorderSide(color: Colors.red),),
                        labelStyle:
                            Theme.of(context).textTheme.caption.copyWith(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                        errorText: null,
                      ),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      onEditingComplete: () {
                        //UPDATE USERNAME
                      },
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 300),
                  child: Theme(
                    data: ThemeData(
                      cursorColor: Colors.black87,
                    ),
                    child: TextField(
                      obscureText: false,
                      controller: portFieldController,
                      autofocus: false,
                      decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black87),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black87, width: 1.0),
                        ),
                        labelText: "Port",
                        border: new UnderlineInputBorder(
                            borderSide: new BorderSide(color: Colors.red)),
                        labelStyle:
                            Theme.of(context).textTheme.caption.copyWith(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                        errorText: null,
                      ),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      onEditingComplete: () {
                        //UPDATE USERNAME
                      },
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 300,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: double.infinity,
                    ),
                    child: RaisedButton(
                      color: materialGreen,
                      child: Text(
                        "Connect",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async{
                        if(ipFieldController.text.length < 4){
                          toastMessageBottomShort("Invalid IP Provided", context);
                        }
                        else if(portFieldController.text.length < 3){
                          toastMessageBottomShort("Invalid Port Provided", context);
                        }
                        else{
                          try{
                            int port = int.parse(portFieldController.text);
                            try{
                              showCustomProcessDialog("Preparing", context);
                              assert(await checkServerRoutes(ipFieldController.text, port), "required server route missing");
                              currentServer = ipFieldController.text;
                              currentPort = port;
                              currentPrivateKey = await secp256k1EllipticCurve.generatePrivateKey();
                              currentPublicKey = await secp256k1EllipticCurve.generatePublicKey(currentPrivateKey.toString());
                              newGroupConnection = true;
                              Navigator.pop(context);
                              await Future.delayed(Duration(seconds: 2));
                              Navigator.pushNamed(context, '/chat');
                            }
                            catch(err){
                              Navigator.pop(context);
                              print(err);
                              toastMessageBottomShort("Error while Connecting", context);
                            }                            
                          }
                          catch(err){
                            toastMessageBottomShort("Invalid Port Provided", context);
                          }
                        }
                      },
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 3, 0, 3),
                  child: Text(
                    "Or",
                    style: TextStyle(
                      color: materialGreen,
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 300,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: double.infinity,
                    ),
                    child: RaisedButton(
                      color: materialGreen,
                      child: Text(
                        "Auto Select",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async{
                        if(await isConnected() == false){
                          toastMessageBottomShort("Connection Error", context);
                        }
                        else{
                          showCustomProcessDialog("Finding Server..", context);
                          Map server = await databaseManager.selectRandomPreviousServer();
                          if(server == null){
                            server = await selectRandomServerFromGithub();
                          }
                          else{
                            if(secp256k1EllipticCurve.generateRandomInteger(0, 100) < 50)
                              server = await databaseManager.selectRandomPreviousServer();
                            else
                              server = await selectRandomServerFromGithub();
                          }
                          currentServer = server["ip"];
                          currentPort = server["port"];
                          newGroupConnection = true;
                          Navigator.pop(context);
                          await Future.delayed(Duration(seconds: 1));
                          Navigator.pushNamed(context, '/chat');
                        }
                      },
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                ),                
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 310,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: double.infinity,
                    ),
                    child: Divider(
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 9),
                ),         
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 300,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: double.infinity,
                    ),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: materialGreen)
                      ),
                      child: FlatButton(
                        splashColor: Colors.transparent,
                        child: Text(
                          "Join Chat",
                          style: TextStyle(
                            color: materialGreen,
                          ),
                        ),
                        onPressed: () {
                          showPrompt("Enter Join Key", context, joinKeyFieldController, () async{
                            try{
                              await showCustomProcessDialog("Please Wait", context);
                              String rawJoinKey = utf8.decode(base64.decode(joinKeyFieldController.text));
                              Map fullJoinKey = json.decode(rawJoinKey);
                              BigInt privateKey = await secp256k1EllipticCurve.generatePrivateKey();
                              currentPrivateKey = privateKey;
                              Map publicKey  = await secp256k1EllipticCurve.generatePublicKey(privateKey.toString());
                              String username = await databaseManager.getUsername();
                              Map signature = {
                                "r": (fullJoinKey["signature"]["r"]).toString(),
                                "s": (fullJoinKey["signature"]["s"]).toString(),
                                "recoveryParam": (fullJoinKey["signature"]["recoveryParam"]).toString(),
                              };
                              globalGroupJoinKey = JoinKey(fullJoinKey["ip"].toString(), int.parse(fullJoinKey["port"].toString()), fullJoinKey["encryptedMessage"].toString(), signature, fullJoinKey["joinKey"].toString(), BigInt.parse(publicKey["x2"].toString()), BigInt.parse(publicKey["x"].toString()), username.toString());
                              assert(await checkServerRoutes(globalGroupJoinKey.ip, globalGroupJoinKey.port), "Invalid Server Credentials");
                              int dbSaved = await databaseManager.isGroupSaved(globalGroupJoinKey.joinKey);
                              if(dbSaved > -1){
                                currentGroupId = dbSaved;
                                currentPrivateKey = await databaseManager.getPrivateKey(currentGroupId);
                                String pastUsername = await databaseManager.getPastUsername(currentGroupId);
                                await databaseManager.updateUsername(pastUsername);
                              }
                              else{
                                if(await isUsernameTakenForServer(globalGroupJoinKey.ip, globalGroupJoinKey.port, globalGroupJoinKey.username, globalGroupJoinKey.joinKey, globalGroupJoinKey.encryptedMessage, globalGroupJoinKey.signature)){
                                  await Future.delayed(Duration(seconds: 2));  
                                  Navigator.pop(context);   
                                  toastMessageBottomShort("Username Taken For Server", context);
                                  return null;
                                }
                              }
                              currentServer = globalGroupJoinKey.ip;
                              currentPort = globalGroupJoinKey.port;
                              currentPublicKey = await secp256k1EllipticCurve.generatePublicKey(currentPrivateKey.toString());                               
                              newGroupConnection = false;
                              await Future.delayed(Duration(seconds: 2));  
                              Navigator.pop(context);
                              Navigator.pushNamed(context, "/chat");                               
                            }
                            catch(err){
                              print(err);
                              await Future.delayed(Duration(seconds: 2)); 
                              Navigator.pop(context);                                
                              toastMessageBottomShort("Invalid Join Key", context);
                            }
                          }); 
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

