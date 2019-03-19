
import 'package:Grease_Monkey/screen/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      seconds: 4,
      navigateAfterSeconds: new LoginScreen(),
      title: new Text('Grease Monkey',
      style: new TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20.0,
        color: Colors.greenAccent,
      ),),
      image: Image.asset('image/icon.png'),
      backgroundColor: Colors.green,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 50.0,
      onClick: ()=>print("Flutter Egypt"),
      loaderColor: Colors.black
    );
  }
}

// class AfterSplash extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         fit: StackFit.expand,
//         children: <Widget>[
//           Container(
//             decoration: BoxDecoration(color: Colors.greenAccent),
//           )
//         ],

//       ),

//     );
//   }
// }

