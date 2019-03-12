import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:base58check/base58check.dart';
import 'package:cipherchat/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
//import 'package:wifi/wifi.dart';
import 'package:eosdart_ecc/eosdart_ecc.dart';
import '../main.dart';

class Home extends StatefulWidget {
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  int portNumber = 12000;
  String publicIpAddress = "";

  Future<String> getPublicIpAddress() async {
    Response response = await dio.get("http://ipecho.net/plain");
    return response.data;
  }

  void setPortNumber() {
    Random rng = Random();
    int min = 2000;
    int max = 12000;
    portNumber = min + rng.nextInt(max - min);
  }

  Future<String> getCompleteIpAddress() async {
    return "http://" + publicIpAddress + portNumber.toString() + "/";
  }

  Future<bool> startServer() async {
    if (await isConnected() == false) return false;
    publicIpAddress = await getPublicIpAddress();
    setPortNumber();
    var server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      portNumber,
    );
    print('Listening on localhost:${server.port}');

    await for (HttpRequest request in server) {
      //HANDLE INCOMING REQUESTS HERE SUCH AS KEYS, MESSAGES
      request.response
        ..write('Hello, world!')
        ..close();
    }
    return true;
  }

  String generateRandomString(int length) {
    List<String> alpha =
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123456789"
            .split("");
    Random rng = Random();
    int min = 0;
    int max = alpha.length - 1;
    String result = "";
    for (var x = 0; x < length; x++) {
      int r = min + rng.nextInt(max - min);
      result += alpha[r];
    }
    return result;
  }

  @override
  void initState() {
    isConnected().then((connection) {
      if (connection) {
        //START SERVER
      } else {}
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    /*print("Public Ip Address: ");
    getPublicIpAddress().then((ip) {
      print(ip); 
    });*/
    /*
    print(BigInt.parse("02 79BE667E F9DCBBAC 55A06295 CE870B07 029BFCDB 2DCE28D9 59F2815B 16F81798".split(" ").join(""), radix: 16).isValidInt);

    String random =  generateRandomString(51);
    print("RANDOM STIRNg");

    var bytes = utf8.encode(random);
    var digest = sha256.convert(bytes);


    print(digest);   
    print(Base58CheckCodec(bytes.toString()));

    EOSPrivateKey privateKey = EOSPrivateKey.fromRandom();
    EOSPrivateKey privateKey2 = EOSPrivateKey.fromString("5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ");
    EOSPrivateKey privateKey3 = EOSPrivateKey.fromString("");


    print("Private Key");
    print(privateKey);
    print(privateKey.toEOSPublicKey());
    */

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
