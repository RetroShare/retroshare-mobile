import 'package:flutter/cupertino.dart';
import 'package:retroshare/model/http_exception.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';
import 'package:tuple/tuple.dart';

class RoomChatLobby with ChangeNotifier {
  late Map<String, List<Identity>> _lobbyParticipants;
  Map<String, Chat> _distanceChat = {};
  late Chat _currentChat;
  Map<String, Chat> get distanceChat => {..._distanceChat};
  Map<String, List<ChatMessage>> _messagesList = {};
  Map<String, List<ChatMessage>> get messagesList => {..._messagesList};
  Map<String, List<Identity>> get lobbyParticipants => {..._lobbyParticipants};
  Map<String, Identity> _allIdentity = {};
  List<Identity> _friendsIdsList = [];
  List<Identity> _notContactIds = [];
  List<Identity> _friendsSignedIdsList = [];
  Map<String, Identity> get allIdentity => {..._allIdentity};
  List<Identity> get friendsIdsList => [..._friendsIdsList];
  List<Identity> get notContactIds => [..._notContactIds];
  List<Identity> get friendsSignedIdsList => [..._friendsSignedIdsList];
  late AuthToken _authToken;

  set authToken(AuthToken authToken) {
    _authToken = authToken;
    notifyListeners();
  }

  AuthToken get authToken => _authToken;

  Future<void> fetchAndUpdate() async {
    final Tuple3<List<Identity>, List<Identity>, List<Identity>> tupleIds =
        await getAllIdentities(_authToken);
    _friendsSignedIdsList = tupleIds.item1;
    _friendsIdsList = tupleIds.item2;
    _notContactIds = tupleIds.item3;

    _allIdentity = {
      for (final id in [tupleIds.item1, tupleIds.item2, tupleIds.item3]
          .expand((x) => x)
          .toList())
        id.mId: id,
    };

    notifyListeners();
  }

  Future<void> setAllIds(Chat chat) async {
    await fetchAndUpdate();
    if (_allIdentity[chat.interlocutorId] == null) {
      _allIdentity = Map.from(_allIdentity)
        ..[chat.interlocutorId] = Identity(chat.interlocutorId);
    }
    notifyListeners();
  }

  Future<void> toggleContacts(String gxsId, bool type) async {
    try {
      final bool success = await RsIdentity.setContact(gxsId, type, _authToken);
      await fetchAndUpdate();
      if (!success) throw HttpException('CHECK CONNECTIVITY');
    } catch (e) {
      rethrow;
    }
  }

  Chat get currentChat => _currentChat;

  Future<void> updateParticipants(String lobbyId) async {
    final List<Identity> participants = [];
    final gxsIds = await RsMsgs.getLobbyParticipants(lobbyId, _authToken);
    for (int i = 0; i < gxsIds.length; i++) {
      bool success = true;
      Identity id;
      do {
        final Tuple2<bool, Identity> tuple =
            await getIdDetails(gxsIds[i]['key'], _authToken);
        success = tuple.item1;
        id = tuple.item2;
      } while (!success);
      participants.add(id);
    }
    _lobbyParticipants =
        Map.from(_lobbyParticipants ?? <String, List<Identity>>{})
          ..putIfAbsent(lobbyId, () => [])
          ..[lobbyId] = participants;
    notifyListeners();
  }

  void updateCurrentChat(Chat chat) {
    _currentChat = chat;
    notifyListeners();
  }

  void addDistanceChat(Chat distantChat) {
    _distanceChat = Map.from(_distanceChat ?? <String, Chat>{})
      ..addAll({distantChat.chatId: distantChat});
    _messagesList = Map.from(_messagesList ?? <String, List<ChatMessage>>{})
      ..addAll({
        distantChat.chatId: [],
      });
  }

// Insert the sent meesage
  void addChatMessage(ChatMessage message, String chatId) {
    _messagesList = Map.from(_messagesList ?? <String, List<ChatMessage>>{})
      ..putIfAbsent(chatId, () => []);
    _messagesList[chatId]?.add(message);
    notifyListeners();
  }

// Get the unreadcount of chatLobbies
  int getUnreadCount(Identity iden, Identity idToUse) {
    return _distanceChat != null
        ? _distanceChat[Chat.getDistantChatId(iden.mId, idToUse.mId)]
                ?.unreadCount ??
            0
        : 0;
  }

// Send the chat messsage to the lobby & Peers
  Future<void> sendMessage(String chatId, String msgTxt,
      [ChatIdType type = ChatIdType.number2_,]) async {
    RsMsgs.sendMessage(chatId, msgTxt, _authToken, type).then((bool res) {
      if (res) {
        //final store = StoreProvider.of<AppState>(context);
        final ChatMessage message = ChatMessage()
          ..chat_id = ChatId()
          ..chat_id.distantChatId = chatId
          ..chat_id.type = type
          ..msg = msgTxt
          ..incoming = false
          ..sendTime = DateTime.now().millisecondsSinceEpoch ~/ 1000
          ..recvTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        // chatMiddleware(message, context);
        addChatMessage(message, chatId);
      } else {
        throw HttpException('You are not the member of the chat Lobby');
      }
    });
  }

  void chatActionMiddleware(Chat distancechat) {
    if (_allIdentity[distancechat.interlocutorId] == null) {
      final identity = Identity(distancechat.interlocutorId);
      identity.name = distancechat.chatName;
      callrequestIdentity(identity);
    }
  }

  String getChatSenderName(ChatMessage message) {
    if (message.isLobbyMessage()) {
      return _lobbyParticipants[message.chat_id.lobbyId.xstr64]
              ?.firstWhere(
                (id) => id.mId == message.lobby_peer_gxs_id,
                orElse: () => null,
              )
              .name ??
          message.lobby_peer_gxs_id;
    }
    final Identity id = _allIdentity[
        _distanceChat[message.chat_id.distantChatId]?.interlocutorId];
    return id.name.isEmpty ? id.mId : id.name;
  }

  // Intitate the distance chat
  Future<void> initiateDistantChat(Chat chat) async {
    final String to = chat.interlocutorId;
    final String from = chat.ownIdToUse;
    final resp = await RsMsgs.c(chat, _authToken);
    if (resp['retval'] == true) {
      chat.chatId = resp['pid'];
      Chat.addDistantChat(to, from, resp['pid']);
      chatActionMiddleware(chat);
      setAllIds(chat);
      addDistanceChat(chat);
    } else {
      throw Exception('Error on initiateDistantChat()');
    }
  }

  // Get the chat lobby
  Chat getChat(
    Identity currentIdentity,
    dynamic to, {
    required String from,
  }) {
    late Chat chat;

    final String currentId = from ?? currentIdentity.mId;
    if (to != null && to is Identity) {
      final String distantChatId = Chat.getDistantChatId(to.mId, currentId);
      if (Chat.distantChatExistsStore(distantChatId, distanceChat)) {
        chat = _distanceChat[distantChatId];
      } else {
        chat = Chat(
          interlocutorId: to.mId,
          isPublic: false,
          chatName: to.name,
          numberOfParticipants: 1,
          ownIdToUse: currentId,
        );
        initiateDistantChat(chat);
      }
    } else if (to != null && (to is VisibleChatLobbyRecord)) {
      chat = Chat.fromVisibleChatLobbyRecord(to);
      joinChatLobby(chat, currentIdentity.mId);
    } else if (to != null && (to is Chat)) {
      chat = to;
      joinChatLobby(to, currentIdentity.mId);
    }
    return chat;
  }

  // Join ChatLobby for the give lobby_id
  Future<void> joinChatLobby(Chat lobby, String idTouse) async {
    await RsMsgs.joinChatLobby(lobby.chatId, idTouse, _authToken);
  }

// call for creation of new Identity
  Future<void> callrequestIdentity(Identity unknownId) async {
    await RsIdentity.requestIdentity(unknownId.mId, _authToken);
  }

  ///  Get distance chat status of connected  Peer

  Future<void> getDistanceChatStatus(ChatMessage msg) async {
    !Chat.distantChatExistsStore(msg.chat_id.distantChatId, _distanceChat)
        ? RsMsgs.getDistantChatStatus(authToken, msg.chat_id.distantChatId, msg)
            .then((DistantChatPeerInfo res) {
            // Create the chat and add it to the store
            final Chat chat = Chat(
              interlocutorId: res.toId,
              isPublic: false,
              numberOfParticipants: 1,
              ownIdToUse: res.ownId,
              chatId: msg.chat_id.distantChatId,
            );
            Chat.addDistantChat(res.toId, res.ownId, res.peerId);
            chatActionMiddleware(chat);
            addDistanceChat(chat);
            setAllIds(chat);
            // Finally send AddChatMessageAction
            addChatMessage(msg, msg.chat_id.distantChatId);
          })
        : addChatMessage(msg, msg.chat_id.distantChatId);
  }

  // Check if the sender exists, if not request the identity
  // Also a dummy identity could be added when distant chat
  // connection is started (id where name and mId are the same)
  // To dispatch the action, check if is dummy identity.
  Future<void> chatIdentityCheck(ChatMessage message) async {
    if (message.msg.isNotEmpty && message.incoming) {
      if (message.isLobbyMessage() &&
          (_allIdentity[message.lobby_peer_gxs_id] == null ||
              _allIdentity[message.lobby_peer_gxs_id]?.mId ==
                  _allIdentity[message.lobby_peer_gxs_id]?.name)) {
        await callrequestIdentity(Identity(message.lobby_peer_gxs_id));
      } else if (!message.isLobbyMessage() &&
          (_allIdentity[_distanceChat[message.chat_id.distantChatId]
                      ?.interlocutorId] ==
                  null ||
              _allIdentity[_distanceChat[message.chat_id.distantChatId]
                          ?.interlocutorId]
                      ?.mId ==
                  _allIdentity[_distanceChat[message.chat_id.distantChatId]
                          ?.interlocutorId]
                      ?.name)) {
        await callrequestIdentity(
          Identity(
            _distanceChat[message.chat_id.distantChatId]?.interlocutorId,
          ),
        );
      }
    }
  }
}
