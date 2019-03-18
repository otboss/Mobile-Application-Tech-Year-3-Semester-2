import 'package:flutter/material.dart';
import '../main.dart';

class Chat extends StatefulWidget {
  ChatState createState() => ChatState();
}

class ChatState extends State<Chat> {
  TextEditingController messageTextController = TextEditingController();
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
              padding: EdgeInsets.fromLTRB(2, 5, 2, 55),
              children: <Widget>[],
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
