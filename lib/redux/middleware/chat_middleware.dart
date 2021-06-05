import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:redux/redux.dart';
import 'package:retroshare/common/notifications.dart';
import 'package:retroshare/model/app_life_cycle_state.dart';
import 'package:retroshare/model/chat.dart';
import 'package:retroshare/model/identity.dart';
import 'package:retroshare/redux/actions/app_actions.dart';
import 'package:retroshare/redux/model/app_state.dart';

class ChatMiddleware implements MiddlewareClass<AppState> {

  @override
  void call(Store<AppState> store, action, next) {
    if(action is AddChatMessageAction
        && action.message != null
        && action.message.msg.isNotEmpty
        && action.message.incoming
    ) {

      // Check if the sender exists, if not request the identity
      // Also a dummy identity could be added when distant chat connection is started (id where name and mId are the same)
      // To dispatch the action, check if is dummy identity.
      if(action.message.isLobbyMessage()
          && (store.state.allIds[action.message.lobby_peer_gxs_id] == null
              || store.state.allIds[action.message.lobby_peer_gxs_id].mId ==
                  store.state.allIds[action.message.lobby_peer_gxs_id].name)){
        store.dispatch(RequestUnknownIdAction(new Identity(action.message.lobby_peer_gxs_id)));
      } else if (!action.message.isLobbyMessage()
          && (store.state.allIds[store.state.distantChats[action.message.chat_id.distantChatId].interlocutorId] == null
              || store.state.allIds[store.state.distantChats[action.message.chat_id.distantChatId].interlocutorId].mId ==
                  store.state.allIds[store.state.distantChats[action.message.chat_id.distantChatId].interlocutorId].name)){
        store.dispatch(RequestUnknownIdAction(
            new Identity(store.state.distantChats[action.message.chat_id.distantChatId].interlocutorId)));
      }

      String parsedMsg;
      var parsed =
          parse(action.message.msg).getElementsByTagName("span");
      parsed.length > 0 ? parsedMsg = parsed[0].text : parsedMsg = action.message.msg;

      // Check if current chat is focused, to notify unread count
      if(
      store.state.currentChat == null ||
      (store.state.currentChat != null
          && ((action.message.isLobbyMessage() && store.state.currentChat.chatId != action.message.chat_id.lobbyId.xstr64)
              || (!action.message.isLobbyMessage() && store.state.currentChat.chatId != action.message.chat_id.distantChatId) ))
      ){
        Chat chat = action.message.isLobbyMessage()
            ? store.state.subscribedChats
            .firstWhere(
              (chat) =>
          chat.chatId == action.message.chat_id.lobbyId.xstr64,)
            : store.state.distantChats[action.message.chat_id.distantChatId];
        chat.unreadCount++;
      }

      // Show notification
      if (actuaApplState != AppLifecycleState.resumed)
        showChatNotification(
          // Id of notification
          action.message.chat_id.peerId,
          // Title of notification
          action.message.isLobbyMessage()
              ? store.state.subscribedChats
                  .firstWhere(
                    (chat) =>
                        chat.chatId == action.message.chat_id.lobbyId.xstr64,
                  )
                  .chatName
              : action.message.getChatSenderName(
                  store,
                ),
          // Message notification
          action.message.isLobbyMessage()
              ? action.message.getChatSenderName(
                    store,
                  ) +
                  ": " +
                  parsedMsg
              : parsedMsg);
    }
    else if(action is AddDistantChatAction && store.state.allIds[action.distantChat.interlocutorId] == null){
      store.dispatch(RequestUnknownIdAction(new Identity(action.distantChat.interlocutorId)));
    }
    next(action);
  }
}