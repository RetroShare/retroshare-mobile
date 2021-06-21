import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:retroshare/model/identity.dart';
import 'package:retroshare/services/identity.dart';

class Identities with ChangeNotifier {
  List<Identity> _ownidentities = [];
  Identity _selected;
  List<Identity> get ownIdentity => _ownidentities;
  Identity _currentIdentity;
  Identity get currentIdentity => _currentIdentity;
  Future<void> fetchOwnidenities() async {
    _ownidentities = await getOwnIdentities();
    if (_currentIdentity == null &&
        _ownidentities != null &&
        _ownidentities.length > 0) {
      _currentIdentity = _ownidentities[0];
      _selected = _ownidentities[0];
    }
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

  Future<void> createnewIdenity(Identity id, int avatarSize) async {
    Identity newId = await createIdentity(id, avatarSize);
    _ownidentities.add(newId);
    _currentIdentity = newId;
    _selected = _currentIdentity;
    notifyListeners();
  }

  Future<bool> providerdeleteIdentity() async {
    bool success = await deleteIdentity(_currentIdentity);
    if (success) {
      // ignore: unrelated_type_equality_checks
      _ownidentities.removeWhere((element) => element.mId == _currentIdentity);
      Random random = new Random();
      int randomNum = random.nextInt(_ownidentities.length);
      _currentIdentity = _ownidentities[randomNum];
      _selected = _currentIdentity;
      return true;
    }
    return false;
  }

  Future<void> callrequestIdentity(Identity unknownId) async {
    await requestIdentity(unknownId.mId);
    notifyListeners();
  }
}
