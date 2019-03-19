import 'package:flutter/material.dart';
import '../main.dart';

class Chat extends StatefulWidget {
  ChatState createState() => ChatState();
}

class ChatState extends State<Chat> {
  TextEditingController messageTextController = TextEditingController();

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

  bool loadMoreMessages = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    client.receivedMessages = [
      generateSentMessageWidget(
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
          "d"),
      generateReceivedMessageWidget(
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
          "d")
    ];

    databaseManager.getCurrentUserInfo().then((info) {
      print(info);
      print(info);
    });

    FutureBuilder profilePic = FutureBuilder<Map>(
      future: databaseManager.getCurrentUserInfo(),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            break;
          case ConnectionState.active:
            return Container();
          case ConnectionState.waiting:
            return Container();
          case ConnectionState.done:
            if (snapshot.hasError) {
              print(snapshot.error);
              return Text('Error: ${snapshot.error}');
            }
            Image profilePicture = snapshot.data["profilePic"];
            return profilePicture;
        }
      },
    );

    FutureBuilder loadMessages = FutureBuilder<List>(
      future: databaseManager.getMessages(peerIpAddress, peerUsername, false, loadedMessagesIds.keys.toList(), loadMoreMessages),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            break;
          case ConnectionState.active:
            return Container();
          case ConnectionState.waiting:
            return Container();
          case ConnectionState.done:
            if (snapshot.hasError) {
              print(snapshot.error);
              return Text('Error: ${snapshot.error}');
            }

            List messages = snapshot.data;
            List<Widget> messagesContainer = [];
            Widget messagesList = ListView(
              shrinkWrap: true,
              reverse: true,
              padding: EdgeInsets.fromLTRB(2, 10, 2, 75),
              children: messagesContainer,
            );
            if(loadMoreMessages){
              loadMoreMessages = false;
            }

            for (var x = 0; x < messages.length; x++) {
              if (messages[x]["inbound"] < 0) {
                //SENT MESSAGE
                messagesContainer.add(generateSentMessageWidget(messages[x]["inbound"], messages[x]["ts"]));
              } else {
                //RECEIVED MESSAGE
                messagesContainer.add(generateReceivedMessageWidget(messages[x]["inbound"], messages[x]["ts"]));
              }
              loadedMessagesIds[messages[x]["mid"]] = true;
            }
            
            if (messagesContainer.length == 0) {
              return ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(20.0),
                children: [
                  Center(
                    child: new Text(
                        'No messages to here. Remember to ask Security Questions.'),
                  ),
                  Center(
                    child: new Text('Happy Chatting!'),
                  )
                ],
              );
            }
            if(messagesContainer.length < loadedMessagesIds.length){
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () async {},
        ),
        title: Row(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 0, 7, 0),
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  /*
                image: DecorationImage(
                  image: AssetImage('assets/default_profile_pic.png'),
                ), */
                ),
                child: ClipRRect(
                  borderRadius: new BorderRadius.circular(30),
                  child: Hero(
                    tag: 'peerProfilePicture',
                    child: profilePic,
                  ),
                ),
              ),
            ),
            Text(peerUsername)
          ],
        ),
        backgroundColor: themeColor,
      ),
      body: Stack(
        children: <Widget>[
          Container(
            child: ListView(
              shrinkWrap: true,
              reverse: true,
              padding: EdgeInsets.fromLTRB(2, 10, 2, 75),
              children: client.receivedMessages,
            ),
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
                          client.sendMessage(
                              peerIpAddress, messageTextController.text);
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
