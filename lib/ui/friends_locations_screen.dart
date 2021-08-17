import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/provider/friend_location.dart';
import 'package:retroshare/common/person_delegate.dart';
import 'package:shimmer/shimmer.dart';

class FriendsLocationsScreen extends StatefulWidget {
  @override
  _FriendsLocationsScreenState createState() => _FriendsLocationsScreenState();
}

class _FriendsLocationsScreenState extends State<FriendsLocationsScreen> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getFriendsAccounts();
    });
  }

  Future<void> _getFriendsAccounts() async {
    await Future.delayed(Duration(seconds: 3));
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          "Friend Location",
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 16, fontFamily: "Oxygen"),
        ),
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        child: FutureBuilder(
            future: _getFriendsAccounts(),
            builder: (context, snapshot) {
              return snapshot.connectionState == ConnectionState.done
                  ? Consumer<FriendLocations>(builder: (ctx, idsTuple, _) {
                      return idsTuple.friendlist != null &&
                              idsTuple.friendlist.length > 0
                          ? ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: idsTuple.friendlist.length,
                              itemBuilder: (BuildContext context, int index) {
                                return PersonDelegate(
                                  data: PersonDelegateData(
                                    name: idsTuple
                                            .friendlist[index].accountName +
                                        ':' +
                                        idsTuple.friendlist[index].locationName,
                                    message:
                                        idsTuple.friendlist[index].rsGpgId +
                                            ':' +
                                            idsTuple.friendlist[index].rsPeerId,
                                    isOnline:
                                        idsTuple.friendlist[index].isOnline,
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
                                        style:
                                            Theme.of(context).textTheme.body2,
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
                    })
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 0),
                      child: Shimmer(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFEBEBF4),
                            Color(0xFFF4F4F4),
                            Color(0xFFEBEBF4),
                          ],
                          stops: [
                            0.1,
                            0.3,
                            0.4,
                          ],
                          begin: Alignment(-1.0, -0.3),
                          end: Alignment(1.0, 0.3),
                          tileMode: TileMode.clamp,
                        ),
                        enabled: true,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          itemBuilder: (_, __) => Container(
                              padding: const EdgeInsets.only(
                                  bottom: 8.0, left: 8, right: 8, top: 8),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 8),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(14)),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      width: 60,
                                      height: 60,
                                      alignment: Alignment.topCenter,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15))),
                                    ),
                                    Padding(padding: const EdgeInsets.all(8)),
                                    Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 8,
                                            color: Colors.white,
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 4),
                                            width: 210,
                                            height: 18,
                                            color: Colors.white,
                                          ),
                                        ])
                                  ])),
                          itemCount: 6,
                        ),
                      ),
                    );
            }),
      ),
    );
  }
}
