import 'package:flutter/cupertino.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';

class ChatLobby with ChangeNotifier {
  List<Chat> _chatlist = [];
  List<VisibleChatLobbyRecord> _unsubscribedlist = [];
  List<Chat> get subscribedlist => _chatlist;
  late AuthToken _authToken;

  set authToken(AuthToken authToken) {
    _authToken = authToken;
  }

  AuthToken get authToken => _authToken;

  List<VisibleChatLobbyRecord> get unSubscribedlist => _unsubscribedlist;

  Future<void> fetchAndUpdate() async {
    final list = await RsMsgs.getSubscribedChatLobbies(_authToken);
    final List<Chat> chatsList = [];
    for (int i = 0; i < list.length; i++) {
      final chatItem =
          await RsMsgs.getChatLobbyInfo(list[i]['xstr64'], _authToken);

      chatsList.add(Chat(
          chatId: chatItem['lobby_id']['xstr64'],
          chatName: chatItem['lobby_name'],
          lobbyTopic: chatItem['lobby_topic'],
          ownIdToUse: chatItem['gxs_id'],
          autoSubscribe: await RsMsgs.getLobbyAutoSubscribe(
              chatItem['lobby_id']['xstr64'], _authToken,),
          lobbyFlags: chatItem['lobby_flags'],
          isPublic:
              chatItem['lobby_flags'] == 4 || chatItem['lobby_flags'] == 20
                  ? true
                  : false,),);
    }
    _chatlist = chatsList;
    notifyListeners();
  }

  Future<void> fetchAndUpdateUnsubscribed() async {
    _unsubscribedlist = await RsMsgs.getUnsubscribedChatLobbies(_authToken);
    notifyListeners();
  }

  Future<void> unsubscribed(String lobbyId) async {
    await RsMsgs.unsubscribeChatLobby(lobbyId, _authToken);
    final list = await RsMsgs.getSubscribedChatLobbies(_authToken);
    final List<Chat> chatsList = [];
    for (int i = 0; i < list.length; i++) {
      final chatItem =
          await RsMsgs.getChatLobbyInfo(list[i]['xstr64'], _authToken);
      chatsList.add(Chat(
          chatId: chatItem['lobby_id']['xstr64'],
          chatName: chatItem['lobby_name'],
          lobbyTopic: chatItem['lobby_topic'],
          ownIdToUse: chatItem['gxs_id'],
          autoSubscribe: await RsMsgs.getLobbyAutoSubscribe(
              chatItem['lobby_id']['xstr64'], _authToken,),
          lobbyFlags: chatItem['lobby_flags'],
          isPublic:
              chatItem['lobby_flags'] == 4 || chatItem['lobby_flags'] == 20
                  ? true
                  : false,),);
    }
    _chatlist = chatsList;
    await fetchAndUpdateUnsubscribed();
  }

  Future<void> createChatlobby(
    String lobbyName,
    String idToUse,
    String lobbyTopic, {
    List<Location> inviteList = const <Location>[],
    bool public = true,
    bool anonymous = true,
  }) async {
    try {
      final bool success = await RsMsgs.createChatLobby(
        _authToken,
        lobbyName,
        idToUse,
        lobbyTopic,
        inviteList: inviteList,
        anonymous: anonymous,
        public: public,
      );
      if (success) fetchAndUpdate();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
