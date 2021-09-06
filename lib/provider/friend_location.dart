import 'package:flutter/cupertino.dart';
import 'package:retroshare/model/http_exception.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';

class FriendLocations with ChangeNotifier {
  List<Location> _friendlist = [];
  List<Location> get friendlist => _friendlist;
  AuthToken _authToken;
  void setAuthToken(AuthToken authToken) {
    _authToken = authToken;
    notifyListeners();
  }

  AuthToken get getAuthToken => _authToken;

  Future<void> fetchfriendLocation() async {
    final sslIds = await RsPeers.getFriendList(_authToken);
    final List<Location> locations = [];
    for (int i = 0; i < sslIds.length; i++) {
      locations.add(await RsPeers.getPeerFriendDetails(sslIds[i], _authToken));
    }
    _friendlist = locations;
    notifyListeners();
  }

  Future<void> addFriendLocation(String base64Payload) async {
    bool isAdded = false;
    if (base64Payload != null && base64Payload.length < 100) {
      isAdded = await RsPeers.acceptShortInvite(_authToken, base64Payload);
    } else {
      isAdded = await RsPeers.acceptInvite(
        _authToken,
        base64Payload,
      );
    }

    if (!isAdded) throw HttpException('WRONG Certi');
    RsIdentity.setAutoAddFriendIdsAsContact(true, _authToken);
    fetchfriendLocation();
  }
}
