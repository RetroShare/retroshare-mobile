import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:retroshare/HelperFunction/identity.dart';

import 'package:retroshare/model/http_exception.dart';


import 'package:retroshare_api_wrapper/retroshare.dart';

class Identities with ChangeNotifier {
  List<Identity> _ownidentities = [];
  Identity _selected;
  AuthToken _authToken;
  setAuthToken(AuthToken authToken) async {
    _authToken = authToken;
  }

  List<Identity> get ownIdentity => _ownidentities;
  Identity _currentIdentity;
  Identity get currentIdentity => _currentIdentity;

  Future<void> fetchOwnidenities() async {
    _ownidentities = await getOwnIdentities(_authToken);
    if (_currentIdentity == null &&
        _ownidentities != null &&
        _ownidentities.length > 0) {
      _currentIdentity = _ownidentities[0];
      _selected = _ownidentities[0];
    }
    notifyListeners();
  }

  Identity get selectedIdentity => _selected;

  void updatecurrentIdentity() {
    if (_selected != null) _currentIdentity = _selected;
    notifyListeners();
  }

  void updateSelectedIdentity(Identity id) {
    if (_selected.mId != id.mId) {
      _selected = id;
      notifyListeners();
    }
  }

  Future<void> createnewIdenity(Identity id, RsGxsImage image) async {
    Identity newIdentity =
        await RsIdentity.createIdentity(id, image, _authToken);
    _ownidentities.add(newIdentity);
    _currentIdentity = newIdentity;
    _selected = _currentIdentity;
    notifyListeners();
  }

  Future<void> deleteIdentityfunc() async {
    try {
      bool success =
          await RsIdentity.deleteIdentity(_currentIdentity, _authToken);
      // ignore: unrelated_type_equality_checks
      _ownidentities.removeWhere((element) => element.mId == _currentIdentity);
      Random random = new Random();
      int randomNum = random.nextInt(_ownidentities.length);
      _currentIdentity = _ownidentities[randomNum];
      _selected = _currentIdentity;
      notifyListeners();
      if (!success) throw HttpException("BAD REQUEST");
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateIdentity(Identity id, RsGxsImage avatar) async {
    bool success = await RsIdentity.updateIdentity(id, avatar, _authToken);
    if (!success) throw "Try Again";
    for (var i in _ownidentities) {
      if (i.mId == id.mId) {
        i = id;
        break;
      }
    }
    _currentIdentity = id;
    _selected = _currentIdentity;
    notifyListeners();
  }

  Future<void> callrequestIdentity(Identity unknownId) async {
    await RsIdentity.requestIdentity(unknownId.mId, _authToken);
    notifyListeners();
  }
}
