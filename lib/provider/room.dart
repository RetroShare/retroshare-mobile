import 'package:flutter/cupertino.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/Middleware/chat_middleware.dart';
import 'package:retroshare/model/auth.dart';
import 'package:retroshare/model/chat.dart';
import 'package:retroshare/model/identity.dart';
import 'package:retroshare/provider/FriendsIdentity.dart';
import 'package:retroshare/services/chat.dart';
import 'package:retroshare/services/events.dart';
import 'dart:collection';

Future<DistantChatPeerInfo> _getDistantChatStatus(
    String pid, ChatMessage aaa) async {
  var req = ReqGetDistantChatStatus();
  req.pid = pid;
  var resp =
      await openapi.rsMsgsGetDistantChatStatus(reqGetDistantChatStatus: req);
  if (resp.retval != true) {
    throw ("Error on getDistantChatStatus()");
  }
  return resp.info;
}

class RoomChatLobby with ChangeNotifier {
  Map<String, List<Identity>> _lobbyParticipants;
  Map<String, Chat> _distanceChat = {};
  Chat _currentChat;
  AuthToken _authToken;
  Map<String, Chat> get distanceChat => {..._distanceChat};
  Map<String, List<ChatMessage>> _messagesList;
  Map<String, List<ChatMessage>> get messagesList => {..._messagesList};
  Map<String, List<Identity>> get lobbyParticipants => {..._lobbyParticipants};
  Chat get currentChat => _currentChat;

  void setAuthToken(AuthToken authToken) {
    _authToken = authToken;
    notifyListeners();
  }

  Future<void> fetchAndUpdateParticipants(
      String lobbyId, List<Identity> participants) async {
    _lobbyParticipants =
        Map.from(_lobbyParticipants ?? Map<String, List<Identity>>())
          ..putIfAbsent(lobbyId, () => [])
          ..[lobbyId] = participants;
    notifyListeners();
  }

  Future<void> updateParticipants(String lobbyId) async {
    List<Identity> participants = await getLobbyParticipants(lobbyId);
    await fetchAndUpdateParticipants(lobbyId, participants);
  }

  Future<void> updateCurrentChat(Chat chat) {
    _currentChat = chat;
    notifyListeners();
  }

  Map<String, Identity> addDistanceChat(
      Chat distantChat, Map<String, Identity> allIDs) {
    Map<String, Identity> allIds;
    if (allIds[distantChat.interlocutorId] == null)
      allIds = Map.from(allIDs)
        ..[distantChat.interlocutorId] =
            new Identity(distantChat.interlocutorId);

    _distanceChat = Map.from(_distanceChat ?? Map<String, Chat>())
      ..addAll({distantChat.chatId: distantChat});
    _messagesList = Map.from(_messagesList ?? Map<String, List<ChatMessage>>())
      ..addAll({
        distantChat.chatId: [],
      });
    notifyListeners();
    return allIds != null ? allIds : allIDs;
  }

  void addChatMessage(ChatMessage message, String chatId) {
    _messagesList = Map.from(_messagesList ?? Map<String, List<ChatMessage>>())
      ..putIfAbsent(chatId, () => []);
    if (message != null) _messagesList[chatId].add(message);
    notifyListeners();
  }
}

Future<void> registerChatEvent(BuildContext context) async {
  await eventsRegisterChatMessage(
      listenCb: (LinkedHashMap<String, dynamic> json, ChatMessage msg) {
    if (msg != null) {
      // Check if is a lobby chat
      if (msg.chat_id.lobbyId.xstr64 != "0") {
        chatMiddleware(msg, context);
        Provider.of<RoomChatLobby>(context, listen: false)
            .addChatMessage(msg, msg.chat_id.lobbyId.xstr64);
      }
      // Check if is distant chat message
      else if (msg.chat_id.distantChatId !=
          "00000000000000000000000000000000") {
        // First check if the recieved message is from an already registered chat
        chatMiddleware(msg, context);
        !Chat.distantChatExistsStore(msg.chat_id.distantChatId,
                Provider.of<RoomChatLobby>(context, listen: false).distanceChat)
            ? _getDistantChatStatus(msg.chat_id.distantChatId, msg)
                .then((DistantChatPeerInfo res) {
                // Create the chat and add it to the store
                Chat chat = Chat(
                    interlocutorId: res.toId,
                    isPublic: false,
                    numberOfParticipants: 1,
                    ownIdToUse: res.ownId,
                    chatId: msg.chat_id.distantChatId);
                Chat.addDistantChat(res.toId, res.ownId, res.peerId);
                chatActionMiddleware(chat, context);
                dynamic allIDs =
                    Provider.of<FriendsIdentity>(context, listen: false).allIds;
                allIDs = Provider.of<RoomChatLobby>(context, listen: false)
                    .addDistanceChat(chat, allIDs);
                Provider.of<FriendsIdentity>(context, listen: false)
                    .setAllIds(allIDs);

                // Finally send AddChatMessageAction

                Provider.of<RoomChatLobby>(context, listen: false)
                    .addChatMessage(msg, msg.chat_id.distantChatId);
              })
            : Provider.of<RoomChatLobby>(context, listen: false)
                .addChatMessage(msg, msg.chat_id.distantChatId);
      }
    }
  });
}
