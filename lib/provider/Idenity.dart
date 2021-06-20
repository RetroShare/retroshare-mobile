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

  Future<void> createnewIdenity(Identity id, int avatarSize) async {
    Identity newId = await createIdentity(id, avatarSize);
    _ownidentities.add(newId);
    _currentIdentity = newId;
    notifyListeners();
  }
}
