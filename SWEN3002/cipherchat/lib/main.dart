import 'dart:convert';
import 'dart:typed_data';
import './client.dart';
import './database.dart';
import './screens/chat.dart';
import './screens/home.dart';
import './screens/profile.dart';
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

Color themeColor = Color.fromRGBO(162, 162, 162, 1); //Colors.black38;
Color materialGreen = Colors.teal[400];
Color appBarTextColor = Colors.white;
Color cardColor = Colors.white;
String defaultProfilePicFile = "assets/default_profile_pic_base64.txt";
String peerUsername = "";
String peerIpAddress = "";
String peerProfilePic = "";
int limitPerChatsFetchFromDatabase = 20;
int limitPerMessagesFetchFromDatabase = 20;
Map loadedMessagesIds = {};
Map loadedChatIds = {};

_launchURL(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Locale getLocality(BuildContext context) {
  return Localizations.localeOf(context);
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
            Text(
                "CipherChat allows users to send messages securely using multiple cryptographical techniques. It is also completely free and open source. If you would like to support the CipherChat project tap Donate below"),
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
          _launchURL(
              "https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=otsurfer6@gmail.com&lc=US&item_name=Open Source Support&no_note=0&cn=&curency_code=USD&bn=PP-DonationsBF:btn_donateCC_LG.gif:NonHosted");
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

Image base64ToImageConverter(String base64String) {
  Uint8List bytes = base64.decode(base64String);
  return Image.memory(Uint8List.fromList(bytes));
}

Future<bool> toastMessageBottomShort(
    String message, BuildContext context) async {
  Toast.show(message, context, duration: 4, gravity: Toast.BOTTOM);
  return true;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CipherChat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
      routes: {
        "/home": (BuildContext context) => Home(),
        "/chat": (BuildContext context) => Chat(),
        "/profile": (BuildContext context) => Profile(),
      },
    );
  }
}
