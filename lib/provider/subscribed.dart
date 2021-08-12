import 'package:flutter/cupertino.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';

class ChatLobby with ChangeNotifier {
  List<Chat> _listchat = [];
  List<VisibleChatLobbyRecord> _unsubscribedlist = [];
  List<Chat> get subscribedlist => _listchat;
  AuthToken _authToken;

  setAuthToken(AuthToken authToken) async {
    _authToken = authToken;
    notifyListeners();
  }

  List<VisibleChatLobbyRecord> get unSubscribedlist => _unsubscribedlist;

  Future<void> fetchAndUpdate() async {
    var list = await RsMsgs.getSubscribedChatLobbies(_authToken);
    List<Chat> chatsList = [];
    for (int i = 0; i < list.length; i++) {
      final chatItem =
          await RsMsgs.getChatLobbyInfo(list[i]['xstr64'], _authToken);

      chatsList.add(Chat(
          chatId: chatItem['lobby_id']['xstr64'],
          chatName: chatItem['lobby_name'],
          lobbyTopic: chatItem['lobby_topic'],
          ownIdToUse: chatItem['gxs_id'],
          autoSubscribe: await RsMsgs.getLobbyAutoSubscribe(
              chatItem['lobby_id']['xstr64'], _authToken),
          lobbyFlags: chatItem['lobby_flags'],
          isPublic:
              chatItem['lobby_flags'] == 4 || chatItem['lobby_flags'] == 20
                  ? true
                  : false));
    }
    _listchat = chatsList;
    notifyListeners();
  }

  Future<void> fetchAndUpdateUnsubscribed() async {
    _unsubscribedlist = await RsMsgs.getUnsubscribedChatLobbies(_authToken);
    notifyListeners();
  }

  Future<void> unsubscribed(String lobbyId) async {
    await RsMsgs.unsubscribeChatLobby(lobbyId, _authToken);
    var list = await RsMsgs.getSubscribedChatLobbies(_authToken);
    List<Chat> chatsList = [];
    for (int i = 0; i < list.length; i++) {
      final chatItem =
          await RsMsgs.getChatLobbyInfo(list[i]['xstr64'], _authToken);
      chatsList.add(Chat(
          chatId: chatItem['lobby_id']['xstr64'],
          chatName: chatItem['lobby_name'],
          lobbyTopic: chatItem['lobby_topic'],
          ownIdToUse: chatItem['gxs_id'],
          autoSubscribe: await RsMsgs.getLobbyAutoSubscribe(
              chatItem['lobby_id']['xstr64'], _authToken),
          lobbyFlags: chatItem['lobby_flags'],
          isPublic:
              chatItem['lobby_flags'] == 4 || chatItem['lobby_flags'] == 20
                  ? true
                  : false));
    }
    _listchat = chatsList;
    fetchAndUpdateUnsubscribed();
  }

  Future<void> createChatlobby(
      String lobbyName, String idToUse, String lobbyTopic,
      {List<Location> inviteList = const <Location>[],
      bool public = true,
      bool anonymous = true}) async {
    try {
      bool success = await RsMsgs.createChatLobby(
          _authToken, lobbyName, idToUse, lobbyTopic,
          inviteList: inviteList, anonymous: anonymous, public: public);
      if (success) fetchAndUpdate();
    } catch (e) {
      throw e;
    }
  }
}
