import 'package:openapi/api.dart';
import 'package:retroshare/model/identity.dart';
import 'package:retroshare/redux/actions/app_actions.dart';
import 'package:retroshare/redux/model/app_state.dart';
import 'package:redux/redux.dart';

class Chat {
  String chatId;
  String chatName;
  String ownIdToUse;
  String interlocutorId;
  String lobbyTopic;
  bool isPublic;
  int numberOfParticipants;
  int lobbyFlags;
  bool autoSubscribe;
  int unreadCount;

  Chat(
      {this.chatId,
      this.chatName,
      this.lobbyTopic,
      this.ownIdToUse,
      this.interlocutorId,
      this.isPublic,
      this.numberOfParticipants,
      this.lobbyFlags,
      this.autoSubscribe,
      this.unreadCount = 0});

  /// Distant Chat list
  /// Where:
  /// Map<To, Map<from, distantChatId>>
  static Map<String, Map<String, String>> _chatToFromMap;

  static String getDistantChatId(String to, String from){
    if (distantChatExists(to, from))
      return _chatToFromMap[to][from];
    return "";
  }

  // This is: if we don't have a distant chat with this to and from
  // Should be a better way to write this... :
  static bool distantChatExists(String to, String from){
    if ((_chatToFromMap?.isEmpty ?? true) ||
          (_chatToFromMap[to]?.isEmpty ?? true) ||
            (_chatToFromMap[to][from]?.isEmpty ?? true))
      return false;
    return true;
  }

  static void addDistantChat(String to, String from, String distantId){
    if (!distantChatExists(to, from)){
      // If distant chat doesn't exist
      // Should be a better way to do that
      _chatToFromMap ??= Map();
      _chatToFromMap[to] ??= Map();
      _chatToFromMap[to][from] = distantId;
    }
  }

  /// Function used to known if a distant chat exists (is already stored) by it
  /// [distantChatId].
  static bool distantChatExistsStore(String distantChatId, store) {
    if ((distantChatId?.isNotEmpty ?? false) &&
        ((store.state.distantChats?.isNotEmpty ?? false) &&
            (store.state.distantChats[distantChatId] != null)))
      return true;
    return false;
  }

  static Chat fromVisibleChatLobbyRecord(VisibleChatLobbyRecord chatLobbyRecord){
    return Chat(
      chatId: chatLobbyRecord.lobbyId.xstr64,
      isPublic: chatLobbyRecord.lobbyFlags == 1 ? true: false,
      lobbyTopic: chatLobbyRecord.lobbyTopic,
      chatName: chatLobbyRecord.lobbyName,
      numberOfParticipants: chatLobbyRecord.totalNumberOfPeers,
    );
  }

  /// [Lobby flags]
  /// Public = 4
  /// Public + signed = 20
  /// Private = 0
  /// Private + signed = 16
  static bool isPublicChat(int lobbyFlags) => lobbyFlags == 4 || lobbyFlags == 20
      ? true : false;
  bool imPublicChat () => Chat.isPublicChat(this.lobbyFlags);

}

class ChatMessage {
  ChatId chat_id;
  String broadcast_peer_id;
  String lobby_peer_gxs_id;
  String peer_alternate_nickname;
  int chatflags;
  int sendTime;
  int recvTime;
  String msg;
  bool incoming;
  bool online;

  ChatMessage();

  ChatMessage.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    chat_id = (json['chat_id'] == null) ?
    null :
    ChatId.fromJson(json['chat_id']);
    broadcast_peer_id = json['broadcast_peer_id'];
    lobby_peer_gxs_id = json['lobby_peer_gxs_id'];
    peer_alternate_nickname = json['peer_alternate_nickname'];
    chatflags = json['chatflags'];
    sendTime = json['sendTime'];
    recvTime = json['recvTime'];
    msg = json['msg'];
    incoming = json['incoming'];
    online = json['online'];
  }

  bool isLobbyMessage() => this.chat_id.lobbyId.xstr64 != "0";

  String getChatSenderName(Store<AppState> store, ){
    if(isLobbyMessage()){
      return store.state.lobbyParticipants[this.chat_id.lobbyId.xstr64]
          .firstWhere((id) => id.mId == this.lobby_peer_gxs_id, orElse: () => null)
          ?.name ?? this.lobby_peer_gxs_id;
    }
    Identity id =  store.state.allIds[store.state.distantChats[this.chat_id.distantChatId].interlocutorId];
    if (id == null) {
      store.dispatch(RequestUnknownIdAction(new Identity(store
          .state.distantChats[this.chat_id.distantChatId].interlocutorId)));
      return store.state.distantChats[this.chat_id.distantChatId].interlocutorId;
    }
    return id.name.isEmpty ? id.mId : id.name;
  }
}
