import 'package:flutter/cupertino.dart';
import 'package:retroshare/model/location.dart';
import 'package:retroshare/services/account.dart';

class FriendLocations with ChangeNotifier {
  List<Location> _friendlist = [];
  List<Location> get friendlist => _friendlist;

  Future<void> fetchfriendLocation() async {
    _friendlist = await getFriendsAccounts();
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
