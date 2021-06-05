import 'package:retroshare/redux/model/app_state.dart';
import 'package:retroshare/redux/actions/app_actions.dart';
import 'package:retroshare/redux/reducers/identity_reducer.dart';
import 'package:retroshare/redux/reducers/location_reducer.dart';

import 'chat_reducer.dart';

AppState retroshareStateReducers(AppState state, dynamic action) {
  // This action can modify various states
  if (action is UpdateOwnIdentitiesAction)
    return updateOwnIdentities(state, action);
  else if (action is AddDistantChatAction)
    return addDistantChat(state, action);
  else
    return AppState(
      currId: changeCurrentIdentity(state.currId, action),
      selectedId: changeSelectedIdentity(state.selectedId, action),
      ownIdsList: state.ownIdsList,
      friendsIdsList: updateFriendsIdentities(state.friendsIdsList, action),
      friendsSignedIdsList: updateFriendsSignedIdentities(state.friendsSignedIdsList, action),
      notContactIds: updateNotContactIds(state.notContactIds, action),
      allIds: allIdentitiesListReducers(state.allIds, action),
      subscribedChats: chatsListReducers(state.subscribedChats, action),
      unSubscribedChats: updateUnSubscribedChats(state.unSubscribedChats, action),
      distantChats: state.distantChats,
      messagesList: messagesListReducers(state.messagesList, action),
      lobbyParticipants: updateLobbyParticipants(state.lobbyParticipants, action),
      locations: UpdateLocations(state.locations, action),
      currentChat: updateCurrentChat(state.currentChat, action),
  );
}