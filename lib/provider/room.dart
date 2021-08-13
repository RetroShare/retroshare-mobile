import 'package:flutter/cupertino.dart';
import 'package:retroshare/HelperFunction/identity.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';
import 'package:tuple/tuple.dart';

class RoomChatLobby with ChangeNotifier {
  Map<String, List<Identity>> _lobbyParticipants;
  Map<String, Chat> _distanceChat = {};
  Chat _currentChat;
  Map<String, Chat> get distanceChat => {..._distanceChat};
  Map<String, List<ChatMessage>> _messagesList;
  Map<String, List<ChatMessage>> get messagesList => {..._messagesList};
  Map<String, List<Identity>> get lobbyParticipants => {..._lobbyParticipants};

  Chat get currentChat => _currentChat;

  AuthToken _authToken;
  setAuthToken(AuthToken authToken) async {
    _authToken = authToken;
    notifyListeners();
  }

  get authToken => _authToken;

  Future<void> fetchAndUpdateParticipants(
      String lobbyId, List<Identity> participants) async {
    _lobbyParticipants =
        Map.from(_lobbyParticipants ?? Map<String, List<Identity>>())
          ..putIfAbsent(lobbyId, () => [])
          ..[lobbyId] = participants;
    notifyListeners();
  }

  Future<void> updateParticipants(String lobbyId) async {
    List<Identity> participants = [];
    var gxsIds = await RsMsgs.getLobbyParticipants(lobbyId, _authToken);
    for (int i = 0; i < gxsIds.length; i++) {
      bool success = true;
      Identity id;
      do {
        Tuple2<bool, Identity> tuple =
            await getIdDetails(gxsIds[i]['key'], authToken);
        success = tuple.item1;
        id = tuple.item2;
      } while (!success);

      participants.add(id);
    }
    await fetchAndUpdateParticipants(lobbyId, participants);
  }

  Future<void> updateCurrentChat(Chat chat) {
    _currentChat = chat;
    notifyListeners();
  }

  Map<String, Identity> addDistanceChat(
      Chat distantChat, Map<String, Identity> allIDs) {
    Map<String, Identity> allIds;
    if (allIDs[distantChat.interlocutorId] == null) {
      allIds = Map.from(allIDs)
        ..[distantChat.interlocutorId] =
            new Identity(distantChat.interlocutorId);
    }

    _distanceChat = Map.from(_distanceChat ?? Map<String, Chat>())
      ..addAll({distantChat.chatId: distantChat});
    _messagesList = Map.from(_messagesList ?? Map<String, List<ChatMessage>>())
      ..addAll({
        distantChat.chatId: [],
      });
    return allIds != null ? allIds : allIDs;
  }

  void addChatMessage(ChatMessage message, String chatId) {
    _messagesList = Map.from(_messagesList ?? Map<String, List<ChatMessage>>())
      ..putIfAbsent(chatId, () => []);
    if (message != null) _messagesList[chatId].add(message);
    notifyListeners();
  }
}
