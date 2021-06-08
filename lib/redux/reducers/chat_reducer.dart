import 'package:openapi/api.dart';
import 'package:redux/redux.dart';
import 'package:retroshare/model/chat.dart';
import 'package:retroshare/model/identity.dart';
import 'package:retroshare/redux/actions/app_actions.dart';
import 'package:retroshare/redux/model/app_state.dart';

final chatsListReducers = combineReducers<List<Chat>>([
  TypedReducer<List<Chat>, UpdateSubscribedChatsAction>(_updateSubscribedChats),
]);

List<Chat> _updateSubscribedChats(
    List<Chat> subscribedChats, UpdateSubscribedChatsAction action) {
  return List.from(action.subscribedChats);
}

List<VisibleChatLobbyRecord> updateUnSubscribedChats(
    List<VisibleChatLobbyRecord> unSubscribedChats, action) {
  return action is UpdateUnSubscribedChatsAction ? List.from(action.unSubscribedChats)
      : unSubscribedChats;
}

AppState addDistantChat(
    AppState state, AddDistantChatAction action) {
  Map<String, Identity> allIds;
  if(state.allIds[action.distantChat.interlocutorId] == null)
    allIds = Map.from(state.allIds)..[action.distantChat.interlocutorId] = new Identity(action.distantChat.interlocutorId);
  return state.copyWith(
    distantChats: Map.from(state.distantChats ?? Map<String,Chat>())
      ..addAll({action.distantChat.chatId: action.distantChat}),
    messagesList: Map.from(state.messagesList ?? Map<String,List<ChatMessage>>())
      ..addAll({action.distantChat.chatId: [],},),
    allIds: allIds != null ? allIds : state.allIds
  );
}

final messagesListReducers = combineReducers<Map<String, List<ChatMessage>>>([
  TypedReducer<Map<String, List<ChatMessage>>, AddChatMessageAction>(_addChatMessage),
]);

Map<String, List<ChatMessage>> _addChatMessage
  (Map<String, List<ChatMessage>> messageList, AddChatMessageAction action){
  Map<String, List<ChatMessage>> newList = Map.from(messageList ?? Map<String, List<ChatMessage>>())
    ..putIfAbsent(action.chatId, () => new List<ChatMessage>());
   if (action.message != null) newList[action.chatId].add(action.message);
   return newList;
}

Map<String, List<Identity>> updateLobbyParticipants(
    Map<String, List<Identity>> lobbyParticipants, action) {
  if (action is UpdateLobbyParticipantsAction)
    return Map.from(lobbyParticipants ??  Map<String, List<Identity>>())
      ..putIfAbsent(action.lobbyId, () => new List<Identity>())
      ..[action.lobbyId] = action.participants;
  return lobbyParticipants;
}

Chat updateCurrentChat(
    Chat currentChat, action) {
  return action is UpdateCurrentChatAction ? action.currentChat
      : currentChat;
}