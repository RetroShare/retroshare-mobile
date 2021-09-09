import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/HelperFunction/events.dart';
import 'package:retroshare/HelperFunction/identity.dart';
import 'package:retroshare/Middleware/chat_middleware.dart';
import 'package:retroshare/provider/room.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';

Future<void> registerChatEvent(
    BuildContext context, AuthToken authToken) async {
  await eventsRegisterChatMessage(
      listenCb: (var json, ChatMessage msg) {
        if (msg != null) {
          // Check if is a lobby chat
          if (msg.isLobbyMessage()) {
            Provider.of<RoomChatLobby>(context, listen: false)
                .chatIdentityCheck(msg);
            showChatNotify(msg, context);
            Provider.of<RoomChatLobby>(context, listen: false)
                .addChatMessage(msg, msg.chat_id.lobbyId.xstr64);
          }
          // Check if is distant chat message
          else if (isNullCheck(msg.chat_id.distantChatId)) {
            // First check if the recieved message
            //is from an already registered chat
            Provider.of<RoomChatLobby>(context, listen: false)
                .chatIdentityCheck(msg);
            Provider.of<RoomChatLobby>(context, listen: false)
                .getDistanceChatStatus(msg);
          }
        }
      },
      authToken: authToken);
}
