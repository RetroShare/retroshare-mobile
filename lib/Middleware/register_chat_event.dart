

import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/Middleware/chat_middleware.dart';
import 'package:retroshare/model/auth.dart';
import 'package:retroshare/model/chat.dart';
import 'package:retroshare/provider/FriendsIdentity.dart';
import 'package:retroshare/provider/room.dart';
import 'package:retroshare/services/events.dart';

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

