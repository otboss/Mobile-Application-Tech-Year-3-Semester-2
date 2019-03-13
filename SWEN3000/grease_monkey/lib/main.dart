import 'package:flutter/material.dart';

void main() => runApp( MaterialApp(
    theme:
        ThemeData(primaryColor: Colors.blue, accentColor: Colors.lightBlueAccent),
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
    ));

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() =>  _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build (BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.blue),
          )
        ],

      ),

    );
  }
}