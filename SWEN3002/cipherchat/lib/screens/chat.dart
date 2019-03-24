import 'package:dio/dio.dart';
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
  String privateKey = secp256k1EllipticCurve.generatePrivateKey().toString();
  Map participants = {};
  Map messages = {};

  ///Generates a chat bubble on the left side of the screen to indicate
  ///a message which was sent from the current user
  Widget generateSentMessageWidget(String message, String timestamp) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
      constraints: BoxConstraints(maxWidth: 10),
      alignment: Alignment.topLeft,
      child: Row(
        children: <Widget>[
          Flexible(
            flex: 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  color: Colors.orange,
                  height: 6,
                  width: 6,
                ),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(0),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(0),
                      ),
                      color: Colors.orange,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          message,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
                          padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                          alignment: Alignment.bottomRight,
                          child: Text(
                            timestamp, //DateTime.now().toLocal().toString().split(".")[0],
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(),
          )
        ],
      ),
    );
  }

  ///Generates a chat bubble on the right side of the screen to indicate
  ///a message which was received from another user
  Widget generateReceivedMessageWidget(String message, String timestamp) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
      constraints: BoxConstraints(maxWidth: 10),
      alignment: Alignment.topLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Container(),
          ),
          Flexible(
            flex: 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(0),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(0),
                      ),
                      color: Colors.black12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          message,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
                          padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            timestamp, //DateTime.now().toLocal().toString().split(".")[0],
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.black12,
                  height: 6,
                  width: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ///For improved robustness, Each message has its own set of public keys
  ///The message is then decrypted using the current private key
  Future<String> generateDecryptionSymmetricKeyForMessage(String messageId) async {
    BigInt combinedPublicKey = BigInt.parse("1");
    Map messagePublicKeys = json.decode(messages[messageId]["recipients"]);
    List messagePublicKeysUsernames = messagePublicKeys.keys.toList();
    for (var x = 0; x < messagePublicKeysUsernames.length; x++) {
      try {
        combinedPublicKey *= BigInt.parse(messagePublicKeys[messagePublicKeysUsernames[x]]);
      } catch (err) {
        print(err);
      }
    }
    BigInt symmetricKey = secp256k1EllipticCurve.generateSymmetricKey(BigInt.parse(privateKey), combinedPublicKey);
    return sha256.convert(utf8.encode(symmetricKey.toString())).toString();
  }
  
  ///Generates a symmetric key based on the current participants of the chat.
  ///Before this function is called the participants map should be updated to
  ///get the latest public keys to generate the symmetric key
  Future<String> generateEncryptionSymmetricKeyForMessage() async {
    BigInt combinedPublicKey = BigInt.parse("1");
    List participantUsernames = participants.keys.toList();
    Map userInfo = await databaseManager.getCurrentUserInfo();
    String username = userInfo["username"];    
    for(var x = 0; x < participantUsernames.length; x++){
      try{
        if(participantUsernames[x] != username)
          combinedPublicKey *= BigInt.parse(participants[participantUsernames[x]]["publicKey"]);
      }
      catch(err){
        print(err);
      }
    }
    BigInt symmetricKey = secp256k1EllipticCurve.generateSymmetricKey(BigInt.parse(privateKey), combinedPublicKey);
    return sha256.convert(utf8.encode(symmetricKey.toString())).toString();
  }

  ///Get a map of the current users of the chat from the server.
  ///Also updates the user's public key on the Server
  Future<Map> getChatParticipants() async{
    Response response;
    Map userInfo = await databaseManager.getCurrentUserInfo();
    String username = userInfo["username"];
    try{
      String ip = await server.getCompleteIpAddress();
      response = await dio.get(ip + "getchatparticipants", data: {
        "username": username,
        "publicKey": secp256k1EllipticCurve.generatePublicKey(BigInt.parse(privateKey))
      });      
      return json.decode(response.data);
    }
    catch(err){
      print(err);
    }
    return null;
  }

  ///Messages are encrypted by using the current users private key and
  ///public key from each of the participants. Therefore before a
  ///message is encrypted the participants of the chat should be updated
  ///if possible. Once the message has been sent successfully it should be 
  ///immediately saved to the local database along with all the keys
  Future<String> encryptMessage(String message) async {
    try{
      var currentParticipants = await getChatParticipants();
      if(currentParticipants != null){
        participants.addAll(currentParticipants);
        String key = await generateEncryptionSymmetricKeyForMessage();
        String encryptedMessage = await cryptor.encrypt(message, key);
        return encryptedMessage;      
      }
    }
    catch(err){
      print(err);
    }
    //Connection Error
    return null;
  }


  Future<bool> sendMessage(String message) async {
    Response response;
    Map userInfo = await databaseManager.getCurrentUserInfo();
    String username = userInfo["username"];
    try {
      String encryptedMessage = await encryptMessage(message);
      if(encryptedMessage != null){
        String ip = await server.getCompleteIpAddress();
        Map recipients = {};
        List participantsUsernames = participants.keys.toList();
        for(var x = 0; x < participantsUsernames.length; x++){
          if(participantsUsernames[x] != username)
            recipients[participantsUsernames[x]] = participants[participantsUsernames[x]]["publicKey"];
        }
        response = await dio.post(ip + "message",
            data: {
              "username": username, 
              "message": encryptedMessage,
              "recipients": recipients
            });
        var responseData = json.decode(response.data);
        if (responseData){
          //Message Sent
          return true;
        }
      }
    } catch (err) {
      print(err);
    }
    return false;
  }


  ///Keep-Alive Requests to the server intermittently to indicate
  ///to the server that the user is still active
  Future<bool> connectionRefresher() async{
    while(true){
      try{
        await connectToServer();
      }
      catch(err){
        print(err);
      } 
      await Future.delayed(Duration(seconds: 30));
    }
  }

  ///Called before a message is loaded onto the screen, as all
  ///messages received from the server are encrypted
  Future<String> decryptMessage(String messageId) async {
    String key = await generateDecryptionSymmetricKeyForMessage(messageId);
    String decryptedMessage = await cryptor.decrypt(messages[messageId]["message"], key);
    return decryptedMessage;
  }

  ///Attempts to connect to the server
  Future<bool> connectToServer() async {
    Response response;
    Map userInfo = await databaseManager.getCurrentUserInfo();
    String username = userInfo["username"];
    try {
      String ip = await server.getCompleteIpAddress();
      String profilePic = userInfo["profilePic"];
      response = await dio.post(ip + "connect", data: {
        "username": username,
        "profilePic": profilePic,
        "publicKey": secp256k1EllipticCurve.generatePublicKey(BigInt.parse(privateKey))
      });
      var responseData = json.decode(response.data);
      if (responseData["username"] != null) {
        participants = responseData;
        return true;
      }
      return false;
    } catch (err) {
      return false;
    }
  }

  ///Checks the server intermittently for new messages. if new messages
  ///Are received load them into the message view if the user is scrolled to
  ///the bottom of the screen else show a new messages bubble.
  ///TO BE IMPLEMENTED IN A FUTURE BUILDER
  Future<bool> checkForNewMessages() async {
    Response response;
    bool newMessages = false;
    while (true) {
      try {
        String ip = await server.getCompleteIpAddress();
        response = await dio.get(ip + "anynewmessages",
            data: {"oldMessages": messages.keys.toList()});
        newMessages = json.decode(response.data);
        if (newMessages) 
          break;
      } catch (err) {
        print(err);
      }
      await Future.delayed(Duration(seconds: 10));
    }
    return newMessages;
  }

  Future<Map> getNewMessages() async {
    Response response;
    Map userInfo = await databaseManager.getCurrentUserInfo();
    String username = userInfo["username"];
    try {
      String ip = await server.getCompleteIpAddress();
      response = await dio.get(ip + "getmessages",
          data: {"username": username, "oldMessages": messages.keys.toList()});
      Map newMessages = json.decode(response.data);
      messages.addAll(newMessages);
    } catch (err) {
      print(err);
    }
    return messages;
  }


  ///Disconnects from the current chat. Fired when the user presses
  ///the back button on the Chat Screen
  Future<bool> disconnectFromServer() async {
    Response response;
    Map userInfo = await databaseManager.getCurrentUserInfo();
    String username = userInfo["username"];
    try {
      String ip = await server.getCompleteIpAddress();
      response = await dio.post(ip + "disconnect", data: {"username": username});
      var responseData = json.decode(response.data);
      return responseData;
    } catch (err) {
      return false;
    }
  }

  /* 
   {
        "sender": senderIP,
        "username": username,
        "message": message,
        "ts": timestamp,
        "recipients": {
            username: publicKey,
            username: publicKey,
            username: publicKey,
        }
    }  
  */

  ///Sends a sample request to the peer. returns true if a response is received
  ///and a timeout otherwise
  Future<Map> checkConnection(String ipAddress) async {
    Response response;
    try {
      response = await dio.get(ipAddress + "?check=1");
      return response.data;
    } catch (err) {
      return null;
    }
  }

  ///Repeatedely send TCP packets to the peer until a conneciton is established
  Future<bool> checkUntilConnected() async {
    while (await connectToServer() == false) {
      await Future.delayed(Duration(seconds: 5));
    }
    return true;
  }


  Widget connectingWidget(bool connecting){
    if(connecting){
      return Row(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  server.ip,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                Text(
                  "Connecting..",
                  style: TextStyle(
                    fontSize: 14,
                  ),
                )
              ],
            ),
          ),
        ],
      );
    }
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/profile');
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                server.ip,
                style: TextStyle(
                  fontSize: 18,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }


  bool loadMoreMessages = false;

  var loadProfilePic;
  var loadUsername;
  @override
  Widget build(BuildContext context) {

    /*client.receivedMessages = [
      generateSentMessageWidget(
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
          "d"),
      generateReceivedMessageWidget(
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
          "d")
    ];*/

    connectionRefresher();

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



    loadMessages = FutureBuilder<List>(
      future: databaseManager.getPreviousConversations(server.ip),
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
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () async {
            disconnectFromServer();
            Navigator.pop(context);
          },
        ),
        title: startConnectionChecker,
        backgroundColor: themeColor,
      ),
      body: Stack(
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
                          sendMessage(messageTextController.text);
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
    );
  }
}
