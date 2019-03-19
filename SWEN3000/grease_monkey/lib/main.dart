import 'package:Grease_Monkey/screen/splashScreen.dart';
import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp( MaterialApp(
    theme:
        ThemeData(primaryColor: Colors.blue, accentColor: Colors.lightBlueAccent),
    debugShowCheckedModeBanner: false,
    home: MyApp(),
    ));

