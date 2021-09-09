import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/drawer.dart';
import 'package:retroshare/common/shimmer.dart';
import 'package:retroshare/provider/friend_location.dart';
import 'package:retroshare/common/person_delegate.dart';

class FriendsLocationsScreen extends StatefulWidget {
  @override
  _FriendsLocationsScreenState createState() => _FriendsLocationsScreenState();
}

class _FriendsLocationsScreenState extends State<FriendsLocationsScreen> {
  @override
  void initState() {
    super.initState();
      if (mounted) _getFriendsAccounts();
    
  }

  Future<void> _getFriendsAccounts() async {
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
      appBar: appBar('Friend Location', context),
      body: SafeArea(
        //top: true,

        child: FutureBuilder(
            future: _getFriendsAccounts(),
            builder: (context, snapshot) {
              return snapshot.connectionState == ConnectionState.done
                  ? Consumer<FriendLocations>(builder: (ctx, idsTuple, _) {
                      return idsTuple.friendlist != null &&
                              idsTuple.friendlist.isNotEmpty
                          ? ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8),
                              itemCount: idsTuple.friendlist.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  child: PersonDelegate(
                                    data: PersonDelegateData(
                                      name:
                                          '${idsTuple.friendlist[index].accountName}:${idsTuple.friendlist[index].locationName}',
                                      message:
                                          '${idsTuple.friendlist[index].rsGpgId}:${idsTuple.friendlist[index].rsPeerId}',
                                      isOnline:
                                          idsTuple.friendlist[index].isOnline,
                                      isMessage: true,
                                    ),
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
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        'woof woof',
                                        style:
                                            Theme.of(context).textTheme.body2,
                                        textAlign: TextAlign.center,
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5),
                                        child: Text(
                                          'You can add friends in the menu',
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
                  : friendLocationShimmer();
            }),
      ),
    );
  }
}
