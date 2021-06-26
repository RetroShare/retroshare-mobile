import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/src/store.dart';
import 'package:retroshare/model/auth.dart';

import 'package:retroshare/model/identity.dart';
import 'package:retroshare/model/location.dart';
import 'package:retroshare/redux/actions/app_actions.dart';
import 'package:retroshare/redux/model/app_state.dart';
import 'package:tuple/tuple.dart';

import 'account.dart';
import 'auth.dart';
import 'chat.dart';
import 'identity.dart';

// Initialize all the stores

Future<void> initializeStore(BuildContext context,
    {String nextRoute = '/home'}) async {
  final store = StoreProvider.of<AppState>(context);
  bool ownIds = await updateOwnIdentitiesStore(store, context);
  if (ownIds) {
    await updateChatLobbiesStore(store);
    updateUnsubsChatLobbiesStore(store);
    await updateIdentitiesStore(store);
    updateLocationsStore(store);
    Navigator.pushReplacementNamed(context, nextRoute);
  }
  registerChatEvents(store);
  initializeTimers(store);
}

void initializeTimers(Store<AppState> store) {
  Timer.periodic(
      Duration(seconds: 10), (Timer t) => updateLocationsStore(store));
  Timer.periodic(
      Duration(seconds: 5), (Timer t) => updateIdentitiesStore(store));
}

Future<Location> updateLocationsStore(Store<AppState> store) {
  getFriendsAccounts().then((List<Location> locations) {
    store.dispatch(UpdateLocationsAction(locations));
  });
}

// Update own identities
Future<bool> updateOwnIdentitiesStore(store, BuildContext context) async {
  List<Identity> ownIdsList = await getOwnIdentities();
  if (ownIdsList.isEmpty) {
    Navigator.pushReplacementNamed(context, '/create_identity',
        arguments: true);
    return false;
  } else {
    store.dispatch(UpdateOwnIdentitiesAction(ownIdsList));
    return true;
  }
}

// Update subscribed chat lobbies store

Future<void> updateChatLobbiesStore(store) {
  getSubscribedChatLobbies().then((chatsList) {
    store.dispatch(UpdateSubscribedChatsAction(chatsList));
  });
}

// Update unsubscribed chat lobbies store

void updateUnsubsChatLobbiesStore(store) {
  getUnsubscribedChatLobbies().then((unSubsChatsList) {
    store.dispatch(UpdateUnSubscribedChatsAction(unSubsChatsList));
  });
}

// Update not owned Ids
Future<void> updateIdentitiesStore(store) async {
  Tuple3<List<Identity>, List<Identity>, List<Identity>> tupleIds =
      await getAllIdentities();
  store.dispatch(UpdateFriendsSignedIdentitiesAction(tupleIds.item1));
  store.dispatch(UpdateFriendsIdentitiesAction(tupleIds.item2));
  store.dispatch(UpdateNotContactIdsAction(tupleIds.item3));

  Map<String, Identity> allIds = Map.fromIterable(
      [tupleIds.item1, tupleIds.item2, tupleIds.item3]
          .expand((x) => x)
          .toList(),
      key: (id) => id.mId,
      value: (id) => id);

  store.dispatch(UpdateAllIdsAction(allIds));
}

Future<bool> initializeAuth(String locationId, String password) async {
  authToken = AuthToken(locationId, password);
  return await checkExistingAuthTokens(locationId, password);
}
