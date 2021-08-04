import 'package:flutter/material.dart';
import 'package:retroshare/common/styles.dart';
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
      backgroundColor: Colors.white,
      body: SafeArea(
          top: true,
          bottom: true,
          child: Column(children: <Widget>[
            Container(
              height: appBarHeight,
              child: Row(
                children: <Widget>[
                  Container(
                    width: personDelegateHeight,
                    child: Visibility(
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          size: 25,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Add friend',
                      style: Theme.of(context).textTheme.body2,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: SingleChildScrollView(
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
            ))
          ])),
    );
  }
}
