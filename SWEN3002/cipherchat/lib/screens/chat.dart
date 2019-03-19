import 'package:flutter/material.dart';
import '../main.dart';

class Chat extends StatefulWidget {
  ChatState createState() => ChatState();
}

class ChatState extends State<Chat> {
  TextEditingController messageTextController = TextEditingController();
  TriangleClipper chatTriangle = TriangleClipper();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () async {},
        ),
        title: Text("Username"),
        backgroundColor: themeColor,
      ),
      body: Stack(
        children: <Widget>[
          Container(
            child: ListView(
              padding: EdgeInsets.fromLTRB(2, 10, 2, 55),
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  constraints: BoxConstraints(maxWidth: 10),
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        flex: 2,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              color: themeColor,
                              height: 6,
                              width: 6,
                            ),
                            Flexible(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(0),
                                    bottomLeft: Radius.circular(0),
                                    bottomRight: Radius.circular(0),
                                  ),
                                  color: themeColor,
                                ),
                                child: Text(
                                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                                  style: TextStyle(
                                    color: appBarTextColor,
                                    fontSize: 18
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(),
                      )
                    ],
                  ),
                ),

                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  constraints: BoxConstraints(maxWidth: 10),
                  alignment: Alignment.topLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Flexible(
                        flex: 1,
                        child: Container(),
                      ),                      
                      Flexible(
                        flex: 2,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Flexible(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(0),
                                    bottomLeft: Radius.circular(0),
                                    bottomRight: Radius.circular(0),
                                  ),
                                  color: Colors.black12,
                                ),
                                child: Text(
                                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              color: Colors.black12,
                              height: 6,
                              width: 6,
                            ),                            
                          ],
                        ),
                      ),
                    ],
                  ),
                ),                
                Container(
                  constraints: BoxConstraints(maxWidth: 10),
                  alignment: Alignment.topLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                        color: Colors.black12,
                        child: Text(
                          "Lorem Ipsum",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.black12,
                        height: 5,
                        width: 5,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
                alignment: Alignment.bottomCenter,
                constraints: BoxConstraints(
                  maxHeight: 180,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                        decoration: BoxDecoration(
                          color: appBarTextColor,
                          border: Border.all(
                            color: themeColor,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: SingleChildScrollView(
                          child: Theme(
                            data: ThemeData(cursorColor: materialGreen),
                            child: TextField(
                              maxLines: null,
                              obscureText: false,
                              controller: messageTextController,
                              autofocus: false,
                              decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                hintText: "type your message here..",
                                border: new UnderlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.red)),
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .caption
                                    .copyWith(
                                        color: materialGreen, fontSize: 16),
                                errorText: null,
                              ),
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      padding: EdgeInsets.fromLTRB(3, 0, 0, 0),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                          color: themeColor,
                          borderRadius: BorderRadius.circular(30)),
                      child: IconButton(
                        icon: Icon(
                          Icons.send,
                        ),
                        color: appBarTextColor,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0.0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TriangleClipper oldClipper) => false;
}
