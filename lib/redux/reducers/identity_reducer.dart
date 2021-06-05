import 'package:retroshare/model/identity.dart';
import 'package:retroshare/redux/actions/app_actions.dart';
import 'package:retroshare/redux/model/app_state.dart';
import 'package:redux/redux.dart';

// Reducers for single identities
Identity changeCurrentIdentity(
    Identity id, action) {
  return action is ChangeCurrentIdentityAction ? action.identity
      : id;
}

Identity changeSelectedIdentity(
    Identity id, action) {
  return action is ChangeSelectedIdentityAction ? action.identity
      :id;
}

// Reducers for lists of identities
// Update current id if is null
AppState updateOwnIdentities(AppState state, UpdateOwnIdentitiesAction action) {
  Identity currId = state.currId == null
      ? (action.ownIdsList == null ? null : action.ownIdsList.first)
      : state.currId;
  return state.copyWith(
      currId: currId,
      selectedId: currId,
      ownIdsList: action.ownIdsList,
  );
}

List<Identity> updateFriendsIdentities(
    List<Identity> friendsIdsList, action) {
  return action is UpdateFriendsIdentitiesAction? List.from(action.friendsIdsList)
    : friendsIdsList;
}

List<Identity> updateFriendsSignedIdentities(
    List<Identity> friendsSignedIdsList, action) {
  return action is UpdateFriendsSignedIdentitiesAction ? List.from(action.friendsSignedIdsList)
    : friendsSignedIdsList;
}

List<Identity> updateNotContactIds(
    List<Identity> allIdsList, action) {
  return action is UpdateNotContactIdsAction ? List.from(action.notContactIds)
      : allIdsList;
}

final allIdentitiesListReducers = combineReducers<Map<String, Identity>>([
  TypedReducer<Map<String, Identity>, UpdateAllIdsAction>(_updateAllIds),
  TypedReducer<Map<String, Identity>, RequestUnknownIdAction>(_addUnknownId),
]);

Map<String, Identity> _updateAllIds(
    Map<String, Identity> allIdsList, UpdateAllIdsAction action) {
  // Use this to prevent delete identities that are not already requested and must to be in the allIds map to open the chat
  return {}..addAll(allIdsList ?? Map<String, Identity>())..addAll(action.allIds);
}

Map<String, Identity> _addUnknownId(
    Map<String, Identity> allIdsList, RequestUnknownIdAction action) {
  return Map.from(allIdsList)..[action.unknownId.mId] = action.unknownId;
}