import 'package:flutter/material.dart';
import 'dart:async';

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
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5),()=> print("Done"));
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.green),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 50.0,
                        child : Icon(
                          Icons.build,            
                          color: Colors.greenAccent,
                          size: 50.0,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 18.0),
                      ),
                      Text(
                        "Grease Monkey", 
                        style: TextStyle(
                        color: Colors.white, 
                        fontSize: 24.0, 
                        fontWeight: FontWeight.bold),
                      )

                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  Padding(
                    padding: EdgeInsets.only(top: 20.0),                  
                  ),
                  Text("Mechanics at your \n Fingertips", style: TextStyle(
                    color: Colors.white, 
                    fontSize: 18.0, 
                    fontWeight: FontWeight.bold)),
                ],

              ))
            ]
          )
        ],

      ),

    );
  }
}