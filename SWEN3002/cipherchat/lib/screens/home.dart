import 'dart:convert';
import 'package:cipherchat/main.dart';
import 'package:cipherchat/server.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class Home extends StatefulWidget {
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
 

  @override
  void initState() {
    isConnected().then((connection) {
      if (connection) {
        //START SERVER
        server.startServer();
      } else {}
    });
    super.initState();
  }


  @override 
  Widget build(BuildContext context) {
    secp256k1EllipticCurve.generatePrivateKey().then((prkey1){
      secp256k1EllipticCurve.generatePrivateKey().then((prkey2){
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
              showAccountSettings("Account", context, null, null);
            },
          )
        ],
      ),
      body: Center(
        child: new ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20.0),
          children: [
            Center(
              child: new Text(
                'Your Chats will Appear Here',
                style: TextStyle(color: themeColor),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeColor,
        child: Icon(Icons.add),
        onPressed: () async {},
      ),
    );
  }
}
