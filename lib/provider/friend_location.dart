import 'package:flutter/cupertino.dart';
import 'package:retroshare/model/auth.dart';
import 'package:retroshare/model/location.dart';
import 'package:retroshare/services/account.dart';
import 'package:retroshare/services/identity.dart';

class FriendLocations with ChangeNotifier {
  List<Location> _friendlist = [];
  List<Location> get friendlist => _friendlist;
  AuthToken _authToken;
  setAuthToken(AuthToken authToken) async {
    _authToken = authToken;
  }

  Future<void> fetchfriendLocation() async {
    _friendlist = await getFriendsAccounts(_authToken);
    notifyListeners();
  }

  Future<bool> addFriendLocation(String name) async {
    bool isAdded = false;
    if (name != null && name.length < 100)
      isAdded = await parseShortInvite(name, _authToken);
    else
      isAdded = await addCert(name, _authToken);
    if (isAdded) {
      setAutoAddFriendIdsAsContact(true, _authToken);
      fetchfriendLocation();
      return true;
    }
    return false;
  }
}
