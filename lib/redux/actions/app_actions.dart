import 'package:openapi/api.dart';
import 'package:retroshare/model/identity.dart';
import 'package:retroshare/model/chat.dart';
import 'package:retroshare/model/location.dart';

class ChangeCurrentIdentityAction {
  final Identity identity;

  ChangeCurrentIdentityAction(this.identity);
}

class ChangeSelectedIdentityAction {
  final Identity identity;

  ChangeSelectedIdentityAction(this.identity);
}

class UpdateOwnIdentitiesAction {
  final List<Identity> ownIdsList;

  UpdateOwnIdentitiesAction(this.ownIdsList);
}

class UpdateFriendsIdentitiesAction {
  final List<Identity> friendsIdsList;

  UpdateFriendsIdentitiesAction(this.friendsIdsList);
}

class UpdateFriendsSignedIdentitiesAction {
  final List<Identity> friendsSignedIdsList;

  UpdateFriendsSignedIdentitiesAction(this.friendsSignedIdsList);
}

class UpdateNotContactIdsAction {
  final List<Identity> notContactIds;

  UpdateNotContactIdsAction(this.notContactIds);
}

class UpdateAllIdsAction {
  final Map<String, Identity> allIds;

  UpdateAllIdsAction(this.allIds);
}

class RequestUnknownIdAction {
  final Identity unknownId;
  RequestUnknownIdAction(this.unknownId);
}

class UpdateSubscribedChatsAction {
  final List<Chat> subscribedChats;

  UpdateSubscribedChatsAction(this.subscribedChats);
}

class UpdateUnSubscribedChatsAction {
  final List<VisibleChatLobbyRecord> unSubscribedChats;

  UpdateUnSubscribedChatsAction(this.unSubscribedChats);
}

class AddDistantChatAction {
  final Chat distantChat;
  AddDistantChatAction(this.distantChat);
}

class AddChatMessageAction {
  final ChatMessage message;
  final String chatId;
  AddChatMessageAction(this.message, this.chatId);
}

class UpdateLobbyParticipantsAction {
  final String lobbyId;
  final List<Identity> participants;
  UpdateLobbyParticipantsAction(this.lobbyId, this.participants);
}

class UpdateLocationsAction {
  final List<Location> locations;
  UpdateLocationsAction(this.locations,);
}

class UpdateCurrentChatAction {
  final Chat currentChat;
  UpdateCurrentChatAction(this.currentChat,);
}