import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cipherchat/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import '../main.dart';

class Home extends StatefulWidget {
  HomeState createState() => HomeState();
}

class Conversation {
  int timestamp;
}

class HomeState extends State<Home> {
  TextEditingController accountIpInputController = TextEditingController();
  TextEditingController accountPortInputController = TextEditingController();
  TextEditingController accountUsernameInputController =
      TextEditingController();
  TextEditingController peerIpInputController = TextEditingController();

  bool loadMoreChats = false;

  Widget generateRecentConvoCard(String username, String profilePic,
      int timestamp, String lastMessage, String lastSender) {
    try {
      base64ToImageConverter(profilePic);
    } catch (err) {
      profilePic = databaseManager.defaultProfilePicBase64;
    }
    String date = "";
    int timeDiff = DateTime.now().millisecondsSinceEpoch - timestamp;
    if(timeDiff < 8640000){
      String hour = DateTime.fromMillisecondsSinceEpoch(timestamp).hour.toString();
      if(int.parse(hour) < 10)
        hour = "0"+hour;
      date = hour+":"+DateTime.fromMillisecondsSinceEpoch(timestamp).minute.toString();
    }
    else{
      date = DateTime.fromMillisecondsSinceEpoch(timestamp).day.toString()+"/"+DateTime.fromMillisecondsSinceEpoch(timestamp).month.toString()+"/"+DateTime.fromMillisecondsSinceEpoch(timestamp).year.toString();
    }
    return Card(
      color: cardColor,
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              //Navigate to chat screen and show previous messages
              newGroupConnection = false;
              Navigator.pushNamed(context, "/chat");
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 7, 0),
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: base64ToImageConverter(profilePic),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            username,
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Row(
                            children: <Widget>[
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: 80
                                ), 
                                child: Text("author lex", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600],),),
                              ),
                              Text(": ", maxLines: 1),
                              Text("Message", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600],),),                              
                            ],
                          ),
                          Container(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              date,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  /*
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: this.statusIndicator,
                  ),*/
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showAccountSettings(
      String title,
      BuildContext context,
      TextEditingController usernameController,
      TextEditingController ipController,
      TextEditingController portController,
      Future<dynamic> callback()) {
    databaseManager.getUsername().then((username) {
      accountUsernameInputController.text = username;
    });
    Widget alert = AlertDialog(
      title: Text(
        title,
      ),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Theme(
              data: ThemeData(cursorColor: materialGreen),
              child: TextField(
                obscureText: false,
                controller: accountUsernameInputController,
                autofocus: true,
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: materialGreen),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: materialGreen, width: 2.0),
                  ),
                  labelText: "Username",
                  border: new UnderlineInputBorder(
                      borderSide: new BorderSide(color: Colors.red)),
                  labelStyle: Theme.of(context).textTheme.caption.copyWith(
                        color: materialGreen,
                        fontSize: 16,
                      ),
                  errorText: null,
                ),
                style: TextStyle(
                  color: materialGreen,
                  fontSize: 16,
                ),
                onEditingComplete: () async {
                  //UPDATE USERNAME
                },
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        /*FlatButton(
        child: Text("SUPPORT", style: TextStyle(color: materialGreen)),
        onPressed: () async {
          Navigator.pop(context);
          await Future.delayed(Duration(seconds: 2));
          //showDonationAlert(context);
        },
      ),*/
        FlatButton(
          child: Text("SAVE", style: TextStyle(color: materialGreen)),
          onPressed: () {
            callback();
          },
        )
      ],
    );
    showDialog(context: context, barrierDismissible: true, child: alert);
    Completer<Null> completer = Completer();
    completer.complete();
    return completer.future;
  }

  var loadProfilePicForSettingsMenu;

  TextEditingController usernameFieldController = TextEditingController();
  TextEditingController ipFieldController = TextEditingController();
  TextEditingController portFieldController = TextEditingController();

  int groupsOffset = -1;
  List<Widget> loadedConversations = [];

  @override
  void initState() {
    databaseManager.getUsername().then((username) {
      accountUsernameInputController.text = username;
    });
    databaseManager.getLastPageChecked().then((int lastPage) async {
      while (true) {
        int offset = await databaseManager.getServerPageOffset(lastPage);
        Map servers = await getPublicServers(offset, lastPage);
        List serverDomains = servers.keys.toList();
        if (serverDomains.length == 0) break;
        for (var x = 0; x < serverDomains.length; x++) {
          await databaseManager.saveServer(servers[serverDomains[x]]["ip"],
              servers[serverDomains[x]]["port"], lastPage);
        }
        lastPage++;
        await Future.delayed(Duration(seconds: 3));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FutureBuilder loadRecentConversations = FutureBuilder<List>(
      future: databaseManager.getAllGroups(
          groupsOffset), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('Press button to start.');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Text('Awaiting result...');
          case ConnectionState.done:
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            //return Text('Result: ${snapshot.data}');
            List pastConvos = snapshot.data;
            groupsOffset = pastConvos[pastConvos.length - 1]["gid"];
            if (pastConvos.length == 0) {
              return Center(
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.fromLTRB(20, 15, 20, 40),
                  children: [
                    Center(
                      child: Text(
                        'Your past conversations will show here',
                        style: TextStyle(
                          color: themeColor,
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
            for (var x = 0; x < pastConvos.length; x++) {
              //loadedConversations.add();
            }
          //loadedConversations.addAll(pastConvos);
        }
        return null; // unreachable
      },
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: Text("CipherChat"),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.settings,
            ),
            color: Colors.white,
            onPressed: () {
              showAccountSettings("Settings", context, usernameFieldController,
                  ipFieldController, portFieldController, () async {
                if (accountUsernameInputController.text.length > 0) if (await databaseManager
                    .updateUsername(accountUsernameInputController.text))
                  toastMessageBottomShort("Updated Successfully", context);
              });
            },
          )
        ],
      ),
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
        children: [
          generateRecentConvoCard("username", "", 1554644990130, "hello", "me")
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeColor,
        onPressed: () {
          Navigator.pushNamed(context, '/start');
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
