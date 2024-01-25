import 'package:flutter/cupertino.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/notifications.dart';
import 'package:retroshare/model/app_life_cycle_state.dart';
import 'package:retroshare/provider/room.dart';
import 'package:retroshare/provider/subscribed.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';

// register chat event
Future<void> registerChatEvent(
  BuildContext context,
  AuthToken authToken,
) async {
  await eventsRegisterChatMessage(
    listenCb: (var json, ChatMessage msg) {
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
        },
    authToken: authToken,
  );
}

// Show the incoming chat  message  notification when app is in background/ resume state
Future<void> showChatNotify(ChatMessage message, BuildContext context) async {
  if (message.msg.isNotEmpty && message.incoming) {
    final roomChatLobby = Provider.of<RoomChatLobby>(context, listen: false);
    final subscribedChats =
        Provider.of<ChatLobby>(context, listen: false).subscribedlist;

    // Parse the notification message from the HTML tag.
    String parsedMsg;
    final parsed = parse(message.msg).getElementsByTagName('span');
    parsed != null ? parsedMsg = parsed[0].text : parsedMsg = message.msg;

    // Check if current chat is focused, to notify unread count
    if ((message.isLobbyMessage() &&
                    roomChatLobby.currentChat.chatId !=
                        message.chat_id.lobbyId.xstr64) ||
                (message.isLobbyMessage() &&
                    roomChatLobby.currentChat.chatId !=
                        message.chat_id.distantChatId)) {
      final Chat chat = message.isLobbyMessage()
          ? subscribedChats.firstWhere(
              (chat) => chat.chatId == message.chat_id.lobbyId.xstr64,
            )
          : roomChatLobby.distanceChat[message.chat_id.distantChatId];
      chat.unreadCount++;
    }

    // Show notification
    if (actuaApplState != AppLifecycleState.resumed) {
      showChatNotification(
        // Id of notification
        message.chat_id.peerId,

        // Title of notification
        message.isLobbyMessage()
            ? subscribedChats
                .firstWhere(
                  (chat) => chat.chatId == message.chat_id.lobbyId.xstr64,
                )
                .chatName
            : roomChatLobby.getChatSenderName(message),
        // Message notification
        message.isLobbyMessage()
            ? '${roomChatLobby.getChatSenderName(message)}: $parsedMsg'
            : parsedMsg,
      );
    }
  }
}
