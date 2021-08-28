import 'package:flutter/material.dart';
import 'package:retroshare/ui/add_friend/add_friend_text.dart';
import 'add_friends_utils.dart';

class AddFriendScreen extends StatefulWidget {
  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar:  AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text(
            "Add Friend",
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                fontFamily: "Oxygen"),
          ),
          automaticallyImplyLeading: true,
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
            top: true,
            bottom: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GetAddfriend(),
                    GetInvite(),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ));
  }
}
