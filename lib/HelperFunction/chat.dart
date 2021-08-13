import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/Middleware/chat_middleware.dart';

import 'package:retroshare/provider/friends_identity.dart';
import 'package:retroshare/provider/Idenity.dart';
import 'package:retroshare/provider/room.dart';
import 'package:retroshare/provider/subscribed.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';

/// Send a message of chat [type].
///   0 TYPE_NOT_SET,
///		1 TYPE_PRIVATE,            // private chat with directly connected friend, peer_id is valid
///		2 TYPE_PRIVATE_DISTANT,    // private chat with distant peer, gxs_id is valid
///		3 TYPE_LOBBY,              // chat lobby id, lobby_id is valid
///		4 TYPE_BROADCAST           // message to/from all connected peers
Future<void> sendMessage(BuildContext context, String chatId, String msgTxt,
    [ChatIdType type = ChatIdType.number2_]) async {
  final authToken= Provider.of<RoomChatLobby>(context, listen: false).authToken;
  RsMsgs.sendMessage(chatId, msgTxt, authToken).then((bool res) {
    if (res) {
      //final store = StoreProvider.of<AppState>(context);
      ChatMessage message = new ChatMessage()
        ..chat_id = new ChatId()
        ..chat_id.distantChatId = chatId
        ..chat_id.type = type
        ..msg = msgTxt
        ..incoming = false
        ..sendTime = DateTime.now().millisecondsSinceEpoch ~/ 1000
        ..recvTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      chatMiddleware(message, context);
      Provider.of<RoomChatLobby>(context, listen: false)
          .addChatMessage(message, chatId);
    }
  });
}

/// Function that update participants of a lobby chat

/// This function initate a distant chat if not exists and store it.
Future<void> _initiateDistantChat(Chat chat, BuildContext context) async {
  String to = chat.interlocutorId;
  String from = chat.ownIdToUse;
  AuthToken authToken = Provider.of<RoomChatLobby>(context).authToken;
  final resp = await RsMsgs.c(chat, authToken);
  if (resp['retval'] == true) {
    chat.chatId = resp['pid'];
    Chat.addDistantChat(to, from, resp['pid']);
    await Provider.of<FriendsIdentity>(context, listen: false).fetchAndUpdate();
    Map<String, Identity> allIDs =
        Provider.of<FriendsIdentity>(context, listen: false).allIdentity;
    chatActionMiddleware(chat, context);
    allIDs = Provider.of<RoomChatLobby>(context, listen: false)
        .addDistanceChat(chat, allIDs);
    Provider.of<FriendsIdentity>(context, listen: false).setAllIds(allIDs);
  } else
    throw ("Error on initiateDistantChat()");
}

/// Get the chat status from [pid]
///  #define RS_DISTANT_CHAT_STATUS_UNKNOWN			0x0000
///  #define RS_DISTANT_CHAT_STATUS_TUNNEL_DN   		0x0001
///  #define RS_DISTANT_CHAT_STATUS_CAN_TALK			0x0002
///  #define RS_DISTANT_CHAT_STATUS_REMOTELY_CLOSED 	0x0003

/// Middleware to manage access to chat lobby via [lobbyId] or distant chat via
/// [toId] of the destination Identity. Initiate the distant chat if is not
/// already initiated.
///
/// return: [Chat] object
Chat getChat(
  BuildContext context,
  to, {
  String from,
}) {
  Chat chat;
  final currentIdentity =
      Provider.of<Identities>(context, listen: false).currentIdentity;
  String currentId = from ?? currentIdentity.mId;
  if (to != null && to is Identity) {
    final distanceChat =
        Provider.of<RoomChatLobby>(context, listen: false).distanceChat;
    String distantChatId = Chat.getDistantChatId(to.mId, currentId);
    if (Chat.distantChatExistsStore(distantChatId, distanceChat)) {
      chat = Provider.of<RoomChatLobby>(context, listen: false)
          .distanceChat[distantChatId];
    } else {
      chat = Chat(
          interlocutorId: to.mId,
          isPublic: false,
          chatName: to.name,
          numberOfParticipants: 1,
          ownIdToUse: currentId);
      _initiateDistantChat(chat, context);
    }
  } else if (to != null && (to is VisibleChatLobbyRecord)) {
    chat = Chat.fromVisibleChatLobbyRecord(to);
    Provider.of<RoomChatLobby>(context, listen: false)
        .addChatMessage(null, to.lobbyId.xstr64);
    final authToken =
        Provider.of<RoomChatLobby>(context, listen: false).authToken;
    RsMsgs.joinChatLobby(to.lobbyId.xstr64, currentIdentity.mId, authToken)
        .then((success) {
      if (success) {
        Provider.of<ChatLobby>(context, listen: false)
            .fetchAndUpdateUnsubscribed();
        Provider.of<ChatLobby>(context, listen: false).fetchAndUpdate();
      }
    });
  } else if (to != null && (to is Chat)) {
    chat = to;
    // Ugly way to initialize lobby participants
    Provider.of<RoomChatLobby>(context, listen: false)
        .fetchAndUpdateParticipants(to.chatId, []);
    chatMiddleware(null, context);
    Provider.of<RoomChatLobby>(context, listen: false)
        .addChatMessage(null, to.chatId);
  }
  return chat;
}
