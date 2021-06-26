import 'package:flutter/cupertino.dart';
import 'package:retroshare/model/identity.dart';
import 'package:retroshare/services/identity.dart';
import 'package:tuple/tuple.dart';

class FriendsIdentity with ChangeNotifier {
  Map<String, Identity> _allIds = {};
  List<Identity> _friendsIdsList = [];
  List<Identity> _notContactIds = [];
  List<Identity> _friendsSignedIdsList = [];
  Map<String, Identity> get allIds => {..._allIds};
  List<Identity> get friendsIdsList => [..._friendsIdsList];
  List<Identity> get notContactIds => [..._notContactIds];
  List<Identity> get friendsSignedIdsList => [..._friendsSignedIdsList];

  Future<void> fetchAndUpdate() async {
    Tuple3<List<Identity>, List<Identity>, List<Identity>> tupleIds =
        await getAllIdentities();
    _friendsSignedIdsList = tupleIds.item1;
    _friendsIdsList = tupleIds.item2;
    _notContactIds = tupleIds.item3;
    _allIds = Map.fromIterable(
        [tupleIds.item1, tupleIds.item2, tupleIds.item3]
            .expand((x) => x)
            .toList(),
        key: (id) => id.mId,
        value: (id) => id);

    notifyListeners();
  }

  Future<void> setAllIds(Map<String, Identity> allIDS) {
    _allIds = Map.from(allIDS);
    notifyListeners();
  }

  Future<bool> toggleContacts(String gxsId, bool type) async {
    bool success = await setContact(gxsId, false);
    if (success) await fetchAndUpdate();
    return success;
  }
}
