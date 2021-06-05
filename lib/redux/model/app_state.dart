import 'package:openapi/api.dart';
import 'package:retroshare/model/identity.dart';
import 'package:retroshare/model/chat.dart';
import 'package:retroshare/model/location.dart';

class AppState {
  final Identity currId;
  final Identity selectedId;
  final List<Identity> ownIdsList;
  final List<Identity> friendsIdsList;
  final List<Identity> friendsSignedIdsList;
  final List<Identity> notContactIds;
  // All ids dictionary
  final Map<String, Identity> allIds;
  final List<Chat> subscribedChats;
  final List<VisibleChatLobbyRecord> unSubscribedChats;

  // Where first String is chat id
  final Map<String, Chat> distantChats;
  // Where first String is chat id
  final Map<String, List<ChatMessage>> messagesList;


  // Chat lobby participants list
  final Map<String,List<Identity>> lobbyParticipants;

  // Locations list
  final List<Location> locations;

  // Current opened Chat
  final Chat currentChat;

  AppState ({
    this.currId,
    this.selectedId,
    this.ownIdsList,
    this.friendsIdsList,
    this.friendsSignedIdsList,
    this.notContactIds,
    this.allIds,
    this.subscribedChats,
    this.unSubscribedChats,
    this.distantChats,
    this.messagesList ,
    this.lobbyParticipants ,
    this.locations ,
    this.currentChat ,
  });

  AppState copyWith({
    Identity currId,
    Identity selectedId,
    List<Identity> ownIdsList,
    List<Identity> friendsIdsList,
    List<Identity> friendsSignedIdsList,
    List<Identity> notContactIds,
    Map<String, Identity> allIds,
    List<Chat> subscribedChats,
    List<VisibleChatLobbyRecord> unSubscribedChats,
    Map<String, Chat> distantChats,
    List<Chat> notContactsDistantChat,
    Map<String, List<ChatMessage>> messagesList,
    Map<String, List<Identity>> lobbyParticipants,
    List<Location> locations,
    Chat currentChat,
  }) {
    return AppState(
      currId: currId ?? this.currId,
      selectedId: selectedId ?? this.selectedId,
      ownIdsList: ownIdsList ?? this.ownIdsList,
      friendsIdsList: friendsIdsList ?? this.friendsIdsList,
      friendsSignedIdsList: friendsSignedIdsList ?? this.friendsSignedIdsList,
      notContactIds: notContactIds ?? this.notContactIds,
      allIds: allIds ?? this.allIds,
      subscribedChats: subscribedChats ?? this.subscribedChats,
      unSubscribedChats: unSubscribedChats ?? this.unSubscribedChats,
      distantChats: distantChats ?? this.distantChats,
      messagesList: messagesList ?? this.messagesList,
      lobbyParticipants: lobbyParticipants ?? this.lobbyParticipants,
      locations: locations ?? this.locations,
      currentChat: currentChat ?? this.currentChat,
    );
  }

  /// Search on all identities list and return id object
  Identity searchIdentityById(String mId){
    Identity retId;
    for(List<Identity> list in [this.ownIdsList, this.friendsIdsList, this.friendsSignedIdsList, this.notContactIds]) {
      retId = list.firstWhere((Identity id) => id.mId == mId,
          orElse: () => null);
      if (retId != null) return retId;
    }
    // If the Id is not known, add it to notContactIds and do a rsIdentity/requestIdentity

    return retId = new Identity(mId);
  }
}
