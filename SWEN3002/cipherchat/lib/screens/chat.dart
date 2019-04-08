
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import '../main.dart';
import 'dart:convert';

class Chat extends StatefulWidget {
  ChatState createState() => ChatState();
}

class ChatState extends State<Chat> {
  TextEditingController messageTextController = TextEditingController();

  //bool publicKeySent = false;
  //bool publicKeyReceived = false;
  
  Map participants = {};
  Map messages = {};
  String passphrase = "";
  TextEditingController passphraseFieldController = TextEditingController();
  int offsetForMessages;
  String currentServerUrl = "https://"+currentServer+":"+currentPort.toString()+"/";


  Future<bool> updateProfilePic(int participantId) async{
    try{
      File image = await FilePicker.getFile(type: FileType.IMAGE);
      String base64ProfilePic = base64.encode(await image.readAsBytes());
      await databaseManager.updateProfilePicture(base64ProfilePic, false, gid: currentGroupId, pid: participantId);
      Navigator.pop(context);
      setState(() {});
      toastMessageBottomShort("Profile Updated", context); 
    }
    catch(err){

    }
  }

  Future<bool> createNewGroup(String username, String publicKey) async{
    try{
      Response response = await dio.post(currentServerUrl+"newgroup", data: {
        "username": username,
        "publicKey": publicKey,
        "passphrase": passphrase
      });
      if(response.data == "-1"){
        return false;
      }
      else{
        String joinKey = response.data;
        String privateKey = secp256k1EllipticCurve.generatePrivateKey().toString();
        await databaseManager.saveGroup(currentServer, currentPort, currentServer, privateKey, joinKey);
        //int insertId = await databaseManager.getLatestGroup();
        //await databaseManager.saveParticipant(insertId, username, databaseManager.defaultProfilePicBase64);
        await updateParticipants();
        return true;
      }
    }
    catch(err){
      
    }
    return null;
  }

  Future<Map> joinGroup(String joinKey, String username, String publicKey, String publicKey2, String encryptedMessage, String signature) async{
      try{
        Response response = await dio.post(currentServerUrl+"/newgroup", data: {
          "username": username,
          "publicKey": publicKey,
          "publicKey2": publicKey2,
          "encryptedMessage": encryptedMessage,
          "signature": signature
        });
        return json.decode(response.data);
      }
      catch(err){
        print(err);
      }  
      return null;
  }

  ///Creates a base64 encoded Map of the required credentials to join a server
  Future<String> generateJoinKey() async{
    Map groupInfo = await databaseManager.getGroupInfo(currentGroupId);
    Map completeJoinKey = {};
    completeJoinKey["ip"] = groupInfo["serverIp"];
    completeJoinKey["port"] = groupInfo["serverPort"];    
    completeJoinKey["joinKey"] = groupInfo["joinKey"];    
    completeJoinKey["encryptedMessage"] = cryptor.encrypt(secp256k1EllipticCurve.generateRandomString(100), groupInfo["privateKey"]);
    return base64.encode(utf8.encode(json.encode(completeJoinKey)));
  }
  
  ///Parses a join key received from another peer (join keys are base64 encoded)
  Map parseJoinKey(String joinKey) {
    return json.decode(utf8.decode(base64.decode(joinKey)));
  }

  Future<Map> getPrivateKey() async{
    Map groupInfo = await databaseManager.getGroupInfo(currentGroupId);
    return groupInfo["privateKey"];
  }


  ///Retrieves the Admob ID from the server. Also tests for connection to the server
  Future<String> getAdmodId() async{
    while(true){
      try{
        Response response = await dio.get(currentServerUrl+"/ads");
        return response.data;
      }
      catch(err){

      }
      await Future.delayed(Duration(seconds: 4));
    }  
  }

  Future<String> getGroupName() async{
      try{
        String randomMessage = secp256k1EllipticCurve.generateRandomString(100);
        String username = await databaseManager.getUsername();
        String messageHash = sha256.convert(utf8.encode(randomMessage)).toString();
        BigInt privateKey = await databaseManager.getPrivateKey(currentGroupId);
        Map signature = await secp256k1EllipticCurve.signMessage(messageHash, privateKey);
        String joinKey = await databaseManager.getGroupJoinKey(currentGroupId);
        Response response = await dio.get(currentServerUrl+"/getgroupname", data: {
          "encryptedMessage": randomMessage,
          "signature": signature,
          "username": username,
          "joinKey": joinKey
        });
        return response.data;
      }
      catch(err){

      }
      await Future.delayed(Duration(seconds: 4));    
  }

  Future<bool> setGroupName(String groupName) async{
      try{
        String randomMessage = secp256k1EllipticCurve.generateRandomString(100);
        String messageHash = sha256.convert(utf8.encode(randomMessage)).toString();
        BigInt privateKey = await databaseManager.getPrivateKey(currentGroupId);
        Map signature = await secp256k1EllipticCurve.signMessage(messageHash, privateKey);
        String joinKey = await databaseManager.getGroupJoinKey(currentGroupId);
        Response response = await dio.put(currentServerUrl+"/setgroupname", data: {
          "encryptedMessage": randomMessage,
          "signature": signature,
          "joinKey": joinKey
        });
        if(response.data != "1")
          return false;
      }
      catch(err){
        return false;
      }
      return true;   
  }
  
  Future<Map> getParticipants() async{
    try{
      String message = secp256k1EllipticCurve.generateRandomString(100);
      String messageHash = sha256.convert(utf8.encode(message)).toString();
      BigInt privateKey = await databaseManager.getPrivateKey(currentGroupId);
      BigInt symmetricKey = await databaseManager.getSymmetricKey(currentGroupId);
      Map signature = await secp256k1EllipticCurve.signMessage(messageHash, privateKey);
      String encryptedMessage = await cryptor.encrypt(message, symmetricKey.toString());
      String joinKey = await databaseManager.getGroupJoinKey(currentGroupId);
      String username = await databaseManager.getUsername();
      Response response = await dio.get(currentServerUrl+"/participants", data: {
        "encryptedMessage":encryptedMessage,
        "signature": json.encode(signature),
        "joinKey": joinKey,
        "username": username
      });    
      return json.decode(response.data);
    }
    catch(err){
      print(err);
    }
    return null;
  }

  Future<bool> muteChat() async {
    
  }  

  Future<bool> updateParticipants() async{
      Map participants = await getParticipants();
      List usernames = participants.keys.toList();    
      for(var x = 0; x < usernames.length; x++){
        try{
          await databaseManager.saveParticipant(currentGroupId, usernames[x], databaseManager.defaultProfilePicBase64, BigInt.parse(participants[usernames[x]]["publicKey"]), participants[usernames[x]]["publicKey2"], participants[usernames[x]]["joined"]);
          if(usernames.length == 2){
            String joinKey = await databaseManager.getGroupJoinKey(currentGroupId);
            String username = await databaseManager.getUsername();
            if(usernames[x] != username)
            await databaseManager.updateServerLabel(usernames[x], joinKey);
          }
          if(usernames.length > 2){
            String message = secp256k1EllipticCurve.generateRandomString(100);
            String messageHash = sha256.convert(utf8.encode(message)).toString();
            BigInt privateKey = await databaseManager.getPrivateKey(currentGroupId);
            BigInt symmetricKey = await databaseManager.getSymmetricKey(currentGroupId);
            Map signature = await secp256k1EllipticCurve.signMessage(messageHash, privateKey);
            String encryptedMessage = await cryptor.encrypt(message, symmetricKey.toString());
            String joinKey = await databaseManager.getGroupJoinKey(currentGroupId);
            String username = await databaseManager.getUsername();            
            Response response = await dio.get(currentServerUrl+"getgroupname", data: {
              "encryptedMessage":encryptedMessage,
              "signature": json.encode(signature),
              "joinKey": joinKey,
              "username": username
            });
            await databaseManager.updateServerLabel(json.encode(response.data), joinKey);            
          }
        }
        catch(err){
          print(err);
        }
      }
    return true;
  }


  Future<bool> sendMessage(String message) async {
    try{
      BigInt privateKey = await databaseManager.getPrivateKey(currentGroupId);
      BigInt compositeKey = await databaseManager.getCompositeKey(currentGroupId);
      BigInt symmetricKey = await databaseManager.getSymmetricKey(currentGroupId);
      String hashedSymmetricKey = sha256.convert(utf8.encode(symmetricKey.toString())).toString();
      String username = await databaseManager.getUsername();
      String encryptedMessage = await cryptor.encrypt(message, hashedSymmetricKey);
      String encryptedMessageHash = sha256.convert(utf8.encode(encryptedMessage)).toString();
      Map signature = await secp256k1EllipticCurve.signMessage(encryptedMessageHash, privateKey);  
      String joinKey = await databaseManager.getGroupJoinKey(currentGroupId);
      await updateParticipants();
      Response response = await dio.post(currentServerUrl+"/message", data: {
        "encryptedMessage": encryptedMessage,
        "signature": json.encode(signature),
        "joinKey": joinKey,
        "username": username,
        "compositeKey": compositeKey
      });
      if(response.data == "false")
        return false;
    }
    catch(err){
      print(err);
      return false;
    }
    return true;
  }  

  Future<Map> getNewMessages() async{
      String message = secp256k1EllipticCurve.generateRandomString(100);
      String messageHash = sha256.convert(utf8.encode(message)).toString();
      BigInt privateKey = await databaseManager.getPrivateKey(currentGroupId);
      BigInt symmetricKey = await databaseManager.getSymmetricKey(currentGroupId);
      Map signature = await secp256k1EllipticCurve.signMessage(messageHash, privateKey);
      String encryptedMessage = await cryptor.encrypt(message, symmetricKey.toString());
      String joinKey = await databaseManager.getGroupJoinKey(currentGroupId);
      String username = await databaseManager.getUsername();
      int offset = await databaseManager.getLastMessageId(currentGroupId);
      Response response;
      try{
        response = await dio.get(currentServerUrl+"/messages", data: {
          "encryptedMessage":encryptedMessage,
          "signature": json.encode(signature),
          "joinKey": joinKey,
          "username": username,
          "offset": offset
        });            
      }
      catch(err){
        return {};
      }
      return json.decode(response.data);      
  }

  Future<Map> getOlderMessages() async{
    Map oldMessages = await databaseManager.getMessages(currentGroupId, offset: offsetForMessages);
    List messageIds = oldMessages.keys.toList();
    messageIds.sort();
    offsetForMessages = int.parse(messageIds[messageIds.length - 1]);
    return oldMessages;    
  }

  Future<bool> newMessagesCheck() async{
      try{
        String randomMessage = secp256k1EllipticCurve.generateRandomString(100);
        String messageHash = sha256.convert(utf8.encode(randomMessage)).toString();
        BigInt privateKey = await databaseManager.getPrivateKey(currentGroupId);
        Map signature = await secp256k1EllipticCurve.signMessage(messageHash, privateKey);
        String username = await databaseManager.getUsername();
        String joinKey = await databaseManager.getGroupJoinKey(currentGroupId);
        int offset = await databaseManager.getLastMessageId(currentGroupId);
        Response response = await dio.put(currentServerUrl+"/setgroupname", data: {
          "encryptedMessage": randomMessage,
          "signature": signature,
          "joinKey": joinKey,
          "username": username,
          "offset": offset
        });
        if(response.data != "true")
          return false;
      }
      catch(err){
        return false;
      }
      return true;   
  }  

  Future<Map> getMessagesForInitialDisplaying() async{
    int lastMessageId = await databaseManager.getLastMessageId(currentGroupId);
    Map oldMessages = await databaseManager.getMessages(currentGroupId, offset: lastMessageId);
    return oldMessages;
  }

  Map<String, bool> participantCheckboxIndicators = {};

  bool passphrasePromptOpen = false;

  Future<bool> newGroupConnector() async{
    String username = await databaseManager.getUsername();
    while(true){
      try{
        BigInt privateKey = await secp256k1EllipticCurve.generatePrivateKey();
        Map publicKey = await secp256k1EllipticCurve.generatePublicKey(privateKey.toString());
        Response response = await dio.post(currentServerUrl+"newgroup", data:{
          "username": username,
          "publicKey": publicKey["x2"],
          "publicKey2": publicKey["x"],
          "passphrase": passphrase
        });
        if(response.data == "0"){
          if(passphrasePromptOpen == false)
            showPrompt("Passphrase Required", context, passphraseFieldController, (){
              passphrasePromptOpen = false;
              setState(() {
                passphrase = passphraseFieldController.text;                  
              });
            });
          passphrasePromptOpen = true;
        }
        else{
          if(response.data != "-1"){
            //Connection Successful, New group created
            String joinKey = json.encode(response.data);
            await databaseManager.saveGroup(currentServer, currentPort, currentServer, privateKey.toString(), joinKey);
            return true;
          }
        }
      }
      catch(err){
        //Connection Timeout
      }
      await Future.delayed(Duration(seconds: 4));
    }
  }


  Future<bool> oldGroupConnector() async{
    while(true){
      try{
        String message = secp256k1EllipticCurve.generateRandomString(100);
        String messageHash = sha256.convert(utf8.encode(message)).toString();              
        BigInt privateKey = await databaseManager.getPrivateKey(currentGroupId);
        Map publicKey = await secp256k1EllipticCurve.generatePublicKey(privateKey.toString());
        BigInt symmetricKey = await databaseManager.getSymmetricKey(currentGroupId);
        Map signature = await secp256k1EllipticCurve.signMessage(messageHash, privateKey);
        String encryptedMessage = await cryptor.encrypt(message, symmetricKey.toString());
        String username = await databaseManager.getUsername();        
        Response response = await dio.get(currentServerUrl+"joingroup", data:{
          "username": username,
          "publicKey": publicKey["x2"],
          "publicKey2": publicKey["x"],
          "encryptedMessage": encryptedMessage,
          "signature": signature
        });
        if(response.data == "-3"){
          return true;
        }
      } 
      catch(err){

      }
      await Future.delayed(Duration(seconds: 4));
    }
  }

  @override 
  void initState() {
    databaseManager.getLastMessageId(currentGroupId).then((offsetVal){
      offsetForMessages = offsetVal;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dio.onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
    };  
    /*dio.get("https://wrong.host.badssl.com/").then((response){
      print("THE RESPONSE IS: ");
      print(response);
    });  
    HttpClient client = new HttpClient();
    client.badCertificateCallback =((X509Certificate cert, String host, int port) => true);
    client.postUrl(Uri.parse("https://wrong.host.badssl.com/")).then((response) async{
      print(response);
    });*/
    var startConnection;
    if(newGroupConnection){
      startConnection = FutureBuilder<bool>(
        future: newGroupConnector(), // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          Widget connectingIndicator = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(currentServer),
              Text(
                "Connecting..",
                style: TextStyle(
                  fontSize: 12,
                ),
              )
            ],
          );
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return connectingIndicator;
            case ConnectionState.active:
              return connectingIndicator;
            case ConnectionState.waiting:
              return connectingIndicator;
            case ConnectionState.done:
              if (snapshot.hasError)
                return Text('Error: ${snapshot.error}');
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(currentServer),
                  Text(
                    "Connected",
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  )
                ],
              );              
          }
        },
      );
    }
    else{
      startConnection = FutureBuilder<bool>(
        future: oldGroupConnector(), // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          Widget connectingIndicator = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(pastGroupName),
              Text(
                "Connecting..",
                style: TextStyle(
                  fontSize: 12,
                ),
              )
            ],
          );
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return connectingIndicator;
            case ConnectionState.active:
              return connectingIndicator;
            case ConnectionState.waiting:
              return connectingIndicator;
            case ConnectionState.done:
              if (snapshot.hasError)
                return Text('Error: ${snapshot.error}');
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(pastGroupName),
                    Text(
                      "Connected",
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    )
                  ],
              );   
          }
          return null; // unreachable
        },
      );
    }


    FutureBuilder loadParticipants= FutureBuilder<Map>(
      future: databaseManager.getParticipants(currentGroupId), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        Widget loadingIndicator = Center(
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
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ],
                    ),
                  ),
                )                    
              ]
          ),
        );
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return loadingIndicator;
          case ConnectionState.active:
            return loadingIndicator;      
          case ConnectionState.waiting:
            return loadingIndicator;
          case ConnectionState.done:
            if (snapshot.hasError)
              return Text('Error: ${snapshot.error}');
            Map result = snapshot.data;
            List usernames = result.keys.toList();
            List<Widget> users = [];
            for(var x = 0; x < usernames.length; x++){
              users.add(
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(usernames[x]),
                    Checkbox(
                      value: participantCheckboxIndicators[usernames[x]],
                      activeColor: materialGreen,
                      onChanged: (val) async{
                        await databaseManager.updateChatRecipient(currentGroupId, usernames[x], val);
                        setState(() {
                          participantCheckboxIndicators[usernames[x]] = val;                   
                        });
                      },
                    )
                  ],
                )
              );
            }
            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(30, 20, 23, 40),
              children: [
                Column(
                  children: users,
                ),
              ],
            );    
        }
      },
    );
    
    /*client.receivedMessages = [
      generateSentMessageWidget(
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
          "d"),
      generateReceivedMessageWidget(
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
          "d")
    ];*/

    /*
    secp256k1EllipticCurve.generatePrivateKey().then((prkey1) {
      secp256k1EllipticCurve.generatePrivateKey().then((prkey2) {
        secp256k1EllipticCurve.generatePrivateKey().then((prkey3) async{
          print("THE Private KEY 1 IS :");
          print(prkey1);
          print("THE Private KEY 2 IS :");
          print(prkey2);
          print("THE Private KEY 3 IS :");
          print(prkey3);
          var pubKey1 = await secp256k1EllipticCurve.generatePublicKey(prkey1.toString());
          var pubKey2 = await secp256k1EllipticCurve.generatePublicKey(prkey2.toString());
          var pubKey3 = await secp256k1EllipticCurve.generatePublicKey(prkey3.toString());
          String pubk1 = pubKey1["x2"];
          String pubk2 = pubKey2["x2"];
          String pubk3 = pubKey3["x2"];
          print("THE SYMMETRIC KEY A IS :");
          print(await secp256k1EllipticCurve.generateSymmetricKey(prkey1, [BigInt.parse(pubk2), BigInt.parse(pubk3)]));
          print("THE SYMMETRIC KEY B IS :");
          print(await secp256k1EllipticCurve.generateSymmetricKey(prkey2, [BigInt.parse(pubk1), BigInt.parse(pubk3)]));
          print("THE SYMMETRIC KEY C IS :");
          print(await secp256k1EllipticCurve.generateSymmetricKey(prkey3, [BigInt.parse(pubk1), BigInt.parse(pubk2)]));
        });
      });
    });    */    

    var loadMessages;
    /*
    if (peerUsername != "Anonymous") {
      loadMessages = FutureBuilder<List>(
        future: databaseManager.getMessages(peerIpAddress, peerUsername, false,
            loadedMessagesIds.keys.toList(), loadMoreMessages),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              break;
            case ConnectionState.active:
              return Container();
            case ConnectionState.waiting:
              return Container();
            case ConnectionState.done:
              if (loadMoreMessages) loadMoreMessages = false;
              if (snapshot.hasError) {
                print(snapshot.error);
                return Text('Error: ${snapshot.error}');
              }
              bool allMessagesLoaded = true;
              if (loadedMessagesIds.keys.length < snapshot.data.length)
                allMessagesLoaded = false;
              List messages = snapshot.data;
              List<Widget> messagesContainer = [];
              Widget messagesList = ListView(
                shrinkWrap: true,
                reverse: true,
                padding: EdgeInsets.fromLTRB(2, 10, 2, 75),
                children: messagesContainer,
              );
              for (var x = 0; x < messages.length; x++) {
                if (messages[x]["inbound"] < 0) {
                  //SENT MESSAGE
                  messagesContainer.add(generateSentMessageWidget(
                      messages[x]["inbound"], messages[x]["ts"]));
                } else {
                  //RECEIVED MESSAGE
                  messagesContainer.add(generateReceivedMessageWidget(
                      messages[x]["inbound"], messages[x]["ts"]));
                }
                loadedMessagesIds[messages[x]["mid"].toString()] = true;
              }
              if (messagesContainer.length == 0) {
                return ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    Center(
                      child: new Text(
                        'No messages to here. Remember to ask Security Questions.',
                      ),
                    ),
                    Center(
                      child: new Text(
                        'Happy Chatting!',
                      ),
                    ),
                  ],
                );
              }
              if (allMessagesLoaded == false) {
                messagesContainer.insert(
                  0,
                  RaisedButton(
                    color: themeColor,
                    child: Text(
                      "Load More",
                      style: TextStyle(
                        color: appBarTextColor,
                      ),
                    ),
                    onPressed: () async {
                      setState(() {
                        loadMoreMessages = true;
                      });
                    },
                  ),
                );
              }
              return messagesList;
          }
        },
      );
    } else {
      loadMessages = ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(20.0),
        children: [
          Center(
            child: new Text(
              'No messages to here. Remember to ask Security Questions.',
            ),
          ),
          Center(
            child: new Text(
              'Happy Chatting!',
            ),
          ),
        ],
      );
    }*/

    /*
    loadMessages = FutureBuilder<List>(
      future: databaseManager.getMessages(server.ip, messages.keys.toList(), loadMoreMessages),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return connectingWidget(true);
          case ConnectionState.active:
            return connectingWidget(true);
          case ConnectionState.waiting:
            return connectingWidget(true);
          case ConnectionState.done:
            if (snapshot.hasError) {
              toastMessageBottomShort("Error While Connecting", context);
              print(snapshot.error);
              return Text('Error: ${snapshot.error}');
            }
            if(loadMoreMessages)
              loadMoreMessages = false;
            return connectingWidget(false);
        }
      },
    );

    FutureBuilder startConnectionChecker = FutureBuilder<bool>(
      future: checkUntilConnected(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return connectingWidget(true);
          case ConnectionState.active:
            return connectingWidget(true);
          case ConnectionState.waiting:
            return connectingWidget(true);
          case ConnectionState.done:
            if (snapshot.hasError) {
              toastMessageBottomShort("Error While Connecting", context);
              print(snapshot.error);
              return Text('Error: ${snapshot.error}');
            }
            return connectingWidget(false);
        }
      },
    );*/


    return DefaultTabController(
      length: 2,
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () async {
            //muteChat();
            //Navigator.pushReplacementNamed(context, "/honme")
          },
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("192.168.0.1"),
            Text(
              "Connecting..",
              style: TextStyle(
                fontSize: 12,
              ),
            )
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share, color: appBarTextColor,),
            onPressed: (){

            },
          )
        ],
      ),
      body: TabBarView(
            children: [
              Stack(
                children: <Widget>[
                  Container(
                    child: loadMessages,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
                        alignment: Alignment.bottomCenter,
                        constraints: BoxConstraints(
                          maxHeight: 180,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Flexible(
                              flex: 1,
                              child: Container(
                                padding: EdgeInsets.fromLTRB(13, 3, 13, 3),
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                decoration: BoxDecoration(
                                  color: appBarTextColor,
                                  border: Border.all(
                                    color: themeColor,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: SingleChildScrollView(
                                  child: Theme(
                                    data: ThemeData(cursorColor: materialGreen),
                                    child: TextField(
                                      maxLines: null,
                                      obscureText: false,
                                      controller: messageTextController,
                                      autofocus: false,
                                      decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                            width: 2.0,
                                          ),
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                        hintText: "type your message here..",
                                        border: new UnderlineInputBorder(
                                            borderSide:
                                                new BorderSide(color: Colors.red)),
                                        labelStyle: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .copyWith(
                                                color: materialGreen, fontSize: 16),
                                        errorText: null,
                                      ),
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              padding: EdgeInsets.fromLTRB(3, 0, 0, 0),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: themeColor,
                                  borderRadius: BorderRadius.circular(30)),
                              child: IconButton(
                                icon: Icon(
                                  Icons.send,
                                ),
                                color: appBarTextColor,
                                onPressed: () {
                                  //sendMessage(messageTextController.text);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.topLeft,
                    height: 60,
                    padding: EdgeInsets.fromLTRB(10, 20, 0, 0),
                    child: SizedBox.expand(
                      child: Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Participants",
                              style: TextStyle(
                                color: themeColor,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topRight,
                            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Text(
                              "Recipients",
                              style: TextStyle(
                                color: themeColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 10,
                    fit: FlexFit.tight,
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(30, 20, 23, 40),
                      children: [
                        Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("Username"),
                                Checkbox(
                                  value: true,
                                  activeColor: materialGreen,
                                  onChanged: (val){

                                  },
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                    /*Center(
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
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      )                    
                    ]
                ),
              );*/
                  ),
          
                ],
              )
            ],
          ),
    ),
  
    );
  }
}
