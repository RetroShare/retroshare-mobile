import 'package:flutter/cupertino.dart';
import 'package:retroshare/model/auth.dart';
import 'package:retroshare/model/location.dart';
import 'package:retroshare/services/account.dart';

class FriendLocations with ChangeNotifier {
  List<Location> _friendlist = [];
  List<Location> get friendlist => _friendlist;
  AuthToken _authToken;

  Future<void> fetchfriendLocation() async {
    _friendlist = await getFriendsAccounts();
    notifyListeners();
  }
    void setAuthToken(AuthToken authToken) {
    _authToken = authToken;
    notifyListeners();
  }
  Future<bool> addFriendLocation(String name) async {
    bool isAdded = await addCert(name);
    if (isAdded) {
      fetchfriendLocation();
      return true;
    }
    return false;
  }
}
