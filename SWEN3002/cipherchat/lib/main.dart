import 'package:cipherchat/client.dart';
import 'package:cipherchat/database.dart';
import 'package:cipherchat/screens/chat.dart';
import 'package:cipherchat/screens/home.dart';
import 'package:cipherchat/secp256k1.dart';
import 'package:cipherchat/server.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'dart:async';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

Dio dio = Dio(Options(connectTimeout: 5000, receiveTimeout: 5000));
final flutterWebviewPlugin = FlutterWebviewPlugin();
final Secp256k1 secp256k1EllipticCurve = Secp256k1();
final Server server = Server();
final Client client = Client();
final DatabaseManager databaseManager = DatabaseManager();
final cryptor = new PlatformStringCryptor();


Color themeColor = Colors.black38;
Color materialGreen = Colors.teal[400];
Color appBarTextColor = Colors.white;

_launchURL(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

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
    TextEditingController usernameController, TextEditingController ipController, TextEditingController portController, Future<dynamic> callback()) {
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
                color: Colors.black12,
              ),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          Container(
            height: 10,
          ),
          Container(
            height: 0,
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
                    controller: usernameController,
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
                    onEditingComplete: (){
                      //UPDATE USERNAME
                    },
                  ),
                ),
              ),
              Container(
                height: 80,
                width: 0,
              ),
            ],
          ),
          Container(
            height: 10,
            padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
            alignment: Alignment.bottomLeft,
            child: Text(
              "IP",
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
                    enabled: true,
                    obscureText: false,
                    controller: ipController,
                    autofocus: false,
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: materialGreen),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: materialGreen, width: 2.0),
                      ),
                      disabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 2.0),
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
          Container(
            height: 20,
            padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
            alignment: Alignment.bottomLeft,
            child: Text(
              "Port",
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
                    enabled: false,
                    obscureText: false,
                    controller: portController,
                    autofocus: false,
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: materialGreen),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: materialGreen, width: 2.0),
                      ),
                      disabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 2.0),
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
              Flexible(
                flex: 1,
                child: Container(),
              ),
              Container(
                width: 0,
              ),
            ],
          ),
          Container(
            height: 5,
          )
        ],
      ),
    ),
    actions: <Widget>[
     FlatButton(
        child: Text("SUPPORT", style: TextStyle(color: materialGreen)),
        onPressed: () async{
          Navigator.pop(context);
          //START NEW SEARCH
          await Future.delayed(Duration(seconds: 2));
          showDonationAlert(context);
          //callback();
        },
      ),
      FlatButton(
        child: Text("SAVE", style: TextStyle(color: materialGreen)),
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

Future<void> showAlert(String title, String body, BuildContext context) {
  Widget alert = AlertDialog(
    title: Text(title),
    content: SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: ListBody(
          children: <Widget>[
            Text(body),
          ],
        ),
      ),
    ),
    actions: <Widget>[
      FlatButton(
        child: Text("OK", style: TextStyle(color: materialGreen)),
        onPressed: () {
          Navigator.pop(context);
        },
      )
    ],
  );
  showDialog(context: context, child: alert);
}

Future<void> showDonationAlert(BuildContext context) {
  Widget alert = AlertDialog(
    title: Text("Support CipherChat"),
    content: SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: ListBody(
          children: <Widget>[
            Text("CipherChat allows users to send messages securely using multiple cryptographical techniques. It is also completely free and open source. If you would like to support the CipherChat project tap Donate below"),
          ],
        ),
      ),
    ),
    actions: <Widget>[
      FlatButton(
        child: Text("CANCEL", style: TextStyle(color: materialGreen)),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      FlatButton(
        child: Text("DONATE", style: TextStyle(color: materialGreen)),
        onPressed: () {
          Navigator.pop(context);
          _launchURL("https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=otsurfer6@gmail.com&lc=US&item_name=Open Source Support&no_note=0&cn=&curency_code=USD&bn=PP-DonationsBF:btn_donateCC_LG.gif:NonHosted");
        },
      )
    ],
  );
  showDialog(context: context, child: alert);
}

Future<bool> isConnected() async {
  try {
    await dio.get("http://example.com/");
    return true;
  } catch (err) {
    return false;
  }
}

Future<bool> toastMessageBottomShort(String message, BuildContext context) async {
  Toast.show(message, context, duration: 4, gravity: Toast.BOTTOM);
  return true;
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
      home: Chat(), //MyHomePage(title: 'Flutter Demo Home Page'),
      routes: { 
        "/home": (BuildContext context) => Home(),
        "/chat": (BuildContext context) => Chat(),
      },
    );
  }
}
