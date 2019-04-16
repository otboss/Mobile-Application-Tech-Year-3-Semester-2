import 'dart:io';
import 'package:cipherchat/screens/chat.dart';
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
                        newGroupConnection = true;
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
                              await dio.get("https://"+ipFieldController.text+":"+portFieldController.text+"/");
                              await dio.get("https://"+ipFieldController.text+":"+portFieldController.text+"/ads");
                              await dio.post("https://"+ipFieldController.text+":"+portFieldController.text+"/newgroup");
                              await dio.post("https://"+ipFieldController.text+":"+portFieldController.text+"/joingroup");
                              await dio.put("https://"+ipFieldController.text+":"+portFieldController.text+"/setgroupname");
                              await dio.post("https://"+ipFieldController.text+":"+portFieldController.text+"/message");
                              await dio.get("https://"+ipFieldController.text+":"+portFieldController.text+"/messages");
                              await dio.get("https://"+ipFieldController.text+":"+portFieldController.text+"/anynewmessages");
                              await dio.get("https://"+ipFieldController.text+":"+portFieldController.text+"/participants"); 
                              currentServer = ipFieldController.text;
                              currentPort = port;
                              currentPrivateKey = await secp256k1EllipticCurve.generatePrivateKey();
                              currentPublicKey = await secp256k1EllipticCurve.generatePublicKey(currentPrivateKey.toString());
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
                          newGroupConnection = true;
                          showCustomProcessDialog("Finding Server", context);
                          Map server = await selectRandomServerFromGithub();
                          if(server == null){
                            Navigator.pop(context);
                            toastMessageBottomShort("Try again later", context);
                          }
                          else{
                            currentServer = server["ip"];
                            currentPort = server["port"];
                            Navigator.pop(context);
                            await Future.delayed(Duration(seconds: 1));
                            Navigator.pushNamed(context, '/chat');
                          }
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
                            newGroupConnection = true;
                            try{
                              String ipAddress = joinKeyFieldController.text.substring(64);
                              String port = ipAddress.split(":")[1];
                              if(ipAddress.length > 6){
                                await showCustomProcessDialog("Please Wait", context);
                                await Future.delayed(Duration(seconds: 2)); 
                                Navigator.pop(context);
                                Navigator.pushNamed(context, "/chat"); 
                              }
                              else{
                                toastMessageBottomShort("Invalid Join Key", context);
                              }
                            }
                            catch(err){
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