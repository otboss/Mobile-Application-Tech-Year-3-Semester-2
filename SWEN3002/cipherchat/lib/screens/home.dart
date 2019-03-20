import 'package:cipherchat/main.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class Home extends StatefulWidget {
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  TextEditingController accountIpInputController = TextEditingController();
  TextEditingController accountPortInputController = TextEditingController();
  TextEditingController accountUsernameInputController =
      TextEditingController();
  TextEditingController peerIpInputController = TextEditingController();

  bool loadMoreChats = false;

  Widget generateRecentConvoCard(
      String username, String profilePic, String timestamp) {
    return Card(
      color: cardColor,
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              //Navigate to chat screen and show previous messages
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
                                fontSize: 18, color: Colors.grey[500]),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            timestamp,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[500]),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
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



  var loadProfilePicForSettingsMenu;

  @override
  void initState() {
    isConnected().then((connection) async {
      if (connection) {
        server.getPublicIpAddress().then((ip) {
          accountIpInputController.text = ip;
        });
        accountPortInputController.text = server.port.toString();
      } else {
        toastMessageBottomShort("Connection Unavailable", context);
      }
      var currentUserInfo = await databaseManager.getCurrentUserInfo();
      accountUsernameInputController.text = await currentUserInfo["username"];
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    accountIpInputController.text = server.ip;
    accountPortInputController.text = server.port.toString();

    secp256k1EllipticCurve.generatePrivateKey().then((prkey1) {
      secp256k1EllipticCurve.generatePrivateKey().then((prkey2) {
        print("THE Private KEY 1 IS :");
        print(prkey1);
        print("THE Private KEY 2 IS :");
        print(prkey2);
        BigInt pubKey1 = secp256k1EllipticCurve.generatePublicKey(prkey1);
        BigInt pubKey2 = secp256k1EllipticCurve.generatePublicKey(prkey2);
        print("THE SYMMETRIC KEY A IS :");
        print(secp256k1EllipticCurve.generateSymmetricKey(prkey2, pubKey1));
        print("THE SYMMETRIC KEY B IS :");
        print(secp256k1EllipticCurve.generateSymmetricKey(prkey1, pubKey2));
      });
    });

    FutureBuilder loadPastConversations = FutureBuilder<List>(
      future: databaseManager.getPastConversations(
          loadedChatIds.keys.toList(), loadMoreChats),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            break;
          case ConnectionState.active:
            return Container();
          case ConnectionState.waiting:
            return Container();
          case ConnectionState.done:
            if (loadMoreChats) loadMoreChats = false;
            if (snapshot.hasError) {
              print(snapshot.error);
              return Text('Error: ${snapshot.error}');
            }
            List convos = snapshot.data;
            List results = [];
            bool allChatsLoaded = true;
            if (loadedChatIds.keys.length < convos.length)
              allChatsLoaded = false;
            for (var x = 0; x < convos.length; x++) {
              results.add(generateRecentConvoCard(convos[x]["username"],
                  convos[x]["profilePic"], convos[x]["ts"]));
              loadedChatIds[convos[x]["cid"].toString()] = true;
            }
            if (results.length == 0) {
              return Center(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    Center(
                      child: Text(
                        'Your Chats will Appear Here',
                        style: TextStyle(
                          color: themeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            if (allChatsLoaded == false) {
              results.insert(
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
                      loadMoreChats = true;
                    });
                  },
                ),
              );
            }
            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(20.0),
              children: results,
            );
        }
      },
    );

    FutureBuilder loadProfilePicFromDatabase = FutureBuilder<Map>(
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
            if (loadMoreChats) loadMoreChats = false;
            if (snapshot.hasError) {
              print(snapshot.error);
              return Text('Error: ${snapshot.error}');
            }
            accountUsernameInputController.text = snapshot.data["username"];
            return base64ToImageConverter(snapshot.data["profilePic"]);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: Text(
          "CipherChat",
          style: TextStyle(
            color: appBarTextColor,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.vpn_key,
            ),
            onPressed: () {
              showAccountSettings(
                "Account",
                context,
                accountUsernameInputController,
                accountIpInputController,
                accountPortInputController,
                loadProfilePicFromDatabase,
                null,
              );
            },
          )
        ],
      ),
      body: loadPastConversations,
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeColor,
        child: Icon(
          Icons.add,
        ),
        onPressed: () {
          showPrompt("Enter Peer IP", context, peerIpInputController, () async {
            String ip = peerIpInputController.text;
            if (ip.split(".").length == 4 &&
                ip != await server.getCompleteIpAddress()) {
              await Future.delayed(Duration(seconds: 1));
              Navigator.pop(context);
              peerIpAddress = ip;
              peerIpInputController.text = "";
              Navigator.pushNamed(context, "/chat");
            } else {
              await Future.delayed(Duration(seconds: 1));
              Navigator.pop(context);
              peerIpInputController.text = "";
              await toastMessageBottomShort("Invalid IP", context);
            }
          });
        },
      ),
    );
  }
}
