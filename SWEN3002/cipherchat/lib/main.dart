import 'package:cipherchat/screens/chat.dart';
import 'package:cipherchat/screens/home.dart';
import 'package:cipherchat/secp256k1.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:async';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

void main() => runApp(MyApp());

Dio dio = new Dio(Options(connectTimeout: 5000, receiveTimeout: 5000));
final flutterWebviewPlugin = new FlutterWebviewPlugin();
Secp256k1 secp256k1EllipticCurve = Secp256k1();


Color themeColor = Colors.black38;
Color materialGreen = Colors.teal[400];
Color appBarTextColor = Colors.white;

Future<bool> showCustomProcessDialog(String text, BuildContext context,
    {bool dissmissable, TextAlign alignment}) async {
  if (dissmissable == null) dissmissable = false;
  if (alignment == null) alignment = TextAlign.left;
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
  showDialog(
      context: context, child: customDialog, barrierDismissible: dissmissable);
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
                      borderSide: BorderSide(color: materialGreen, width: 2.0),
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
    ],
  );
  showDialog(context: context, barrierDismissible: true, child: alert);
  Completer<Null> completer = Completer();
  completer.complete();
  return completer.future;
}

Future<void> showAccountSettings(String title, BuildContext context,
    TextEditingController controller, Future<dynamic> callback()) {
  Widget alert = AlertDialog(
    title: Text(
      title,
    ),
    content: SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            width: 70,
            height: 70,
            alignment: Alignment.bottomLeft,
            decoration: BoxDecoration(
              border: Border.all(
                color: themeColor,
              ),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          Container(
            height: 10,
          ),
          Container(
            height: 10,
            alignment: Alignment.bottomLeft,
            child: Text(
              "Username",
              style: TextStyle(
                color: themeColor,
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Container(
                width: 20,
              ),
              Flexible(
                child: Theme(
                  data: ThemeData(cursorColor: materialGreen,),
                  child: TextField(
                    obscureText: false,
                    controller: controller,
                    autofocus: false,
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
                  ),
                ),
              ),
              Container(
                width: 0,
              ),
            ],
          ),
          Container(
            height: 10,
            alignment: Alignment.bottomLeft,
            child: Text(
              "ID",
              style: TextStyle(color: themeColor),
            ),
          ),
          Row(
            children: <Widget>[
              Container(
                width: 20,
              ),
              Flexible(
                child: Theme(
                  data: ThemeData(cursorColor: materialGreen),
                  child: TextField(
                    obscureText: false,
                    controller: controller,
                    autofocus: false,
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
                  ),
                ),
              ),
              Container(
                width: 0,
              ),
              IconButton(
                icon: Icon(
                  Icons.share,
                ),
                color: themeColor,
                onPressed: () {},
              )
            ],
          ),
        ],
      ),
    ),
    actions: <Widget>[
      FlatButton(
        child: Text("GENERATE NEW ID", style: TextStyle(color: materialGreen)),
        onPressed: () {
          Navigator.pop(context);
          //START NEW SEARCH
          callback();
        },
      ),
      FlatButton(
        child: Text("OK", style: TextStyle(color: materialGreen)),
        onPressed: () {
          Navigator.pop(context);
          //START NEW SEARCH
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

Future<bool> isConnected() async {
  try {
    await dio.get("http://example.com/");
    return true;
  } catch (err) {
    return false;
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    /*void listener() async{
      print("STARTING SERVER...");
      var server = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        4040,
      );
      print('Listening on localhost:${server.port}');

      await for (HttpRequest request in server) {
        request.response
          ..write('Hello, world!')
          ..close();
      }      
    }

    listener();*/

    return MaterialApp(
      title: 'CipherChat',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Home(), //MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        "/home": (BuildContext context) => Home(),
        "/chat": (BuildContext context) => Chat(),
      },
    );
  }
}
