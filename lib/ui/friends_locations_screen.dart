import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:retroshare/common/styles.dart';
import 'package:retroshare/provider/friendLocation.dart';
import 'package:retroshare/common/person_delegate.dart';

class FriendsLocationsScreen extends StatefulWidget {
  @override
  _FriendsLocationsScreenState createState() => _FriendsLocationsScreenState();
}

class _FriendsLocationsScreenState extends State<FriendsLocationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getFriendsAccounts();
    });
  }

  void _getFriendsAccounts() async {
    await Provider.of<FriendLocations>(context, listen: false)
        .fetchfriendLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          children: <Widget>[
            Container(
              height: appBarHeight,
              child: Row(
                children: <Widget>[
                  Container(
                    width: personDelegateHeight,
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
                  Expanded(
                    child: Text(
                      'Friends locations',
                      style: Theme.of(context).textTheme.body2,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: <Widget>[
                  Consumer<FriendLocations>(builder: (ctx, idsTuple, _) {
                    return idsTuple.friendlist != null &&
                            idsTuple.friendlist.length > 0
                        ? ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: idsTuple.friendlist.length,
                            itemBuilder: (BuildContext context, int index) {
                              return PersonDelegate(
                                data: PersonDelegateData(
                                  name: idsTuple.friendlist[index].accountName +
                                      ':' +
                                      idsTuple.friendlist[index].locationName,
                                  message: idsTuple.friendlist[index].rsGpgId +
                                      ':' +
                                      idsTuple.friendlist[index].rsPeerId,
                                  isOnline: idsTuple.friendlist[index].isOnline,
                                  isMessage: true,
                                ),
                              );
                            },
                          )
                        : Center(
                            child: SingleChildScrollView(
                              child: SizedBox(
                                width: 250,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image.asset(
                                        'assets/icons8/pluto-children-parent-relationships-petting-animal.png'),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "woof woof",
                                      style: Theme.of(context).textTheme.body2,
                                      textAlign: TextAlign.center,
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 5),
                                      child: Text(
                                        "You can add friends in the menu",
                                        style:
                                            Theme.of(context).textTheme.body1,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
