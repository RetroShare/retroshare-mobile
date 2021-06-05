import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:retroshare/common/styles.dart';
import 'package:retroshare/redux/model/app_state.dart';
import 'package:retroshare/services/account.dart';
import 'package:retroshare/model/location.dart';
import 'package:retroshare/services/init.dart';
import 'package:retroshare/common/person_delegate.dart';

class FriendsLocationsScreen extends StatefulWidget {
  @override
  _FriendsLocationsScreenState createState() => _FriendsLocationsScreenState();
}

class _FriendsLocationsScreenState extends State<FriendsLocationsScreen> {
  List<Location> _locations = List();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _getFriendsAccounts();
    });
  }

  void _getFriendsAccounts() async {
    final store = StoreProvider.of<AppState>(context);
    await updateLocationsStore(store);
    _locations = store.state.locations;
    setState(() {});
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
                  ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _locations.length,
                    itemBuilder: (BuildContext context, int index) {
                      return PersonDelegate(
                        data: PersonDelegateData(
                          name: _locations[index].accountName +
                              ':' +
                              _locations[index].locationName,
                          message: _locations[index].rsGpgId +
                              ':' +
                              _locations[index].rsPeerId,
                          isOnline: _locations[index].isOnline,
                          isMessage: true,
                        ),
                      );
                    },
                  ),
                  Visibility(
                    visible: _locations.isEmpty,
                    child: Center(
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
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  "You can add friends in the menu",
                                  style: Theme.of(context).textTheme.body1,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
