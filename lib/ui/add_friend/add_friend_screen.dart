import 'package:flutter/material.dart';
import 'package:retroshare/common/drawer.dart';
import 'package:retroshare/ui/add_friend/add_friend_text.dart';
import 'package:retroshare/ui/add_friend/add_friends_utils.dart';

class AddFriendScreen extends StatefulWidget {
  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: appBar('Add Friend', context),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GetAddfriend(),
                const GetInvite(),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),);
  }
}
