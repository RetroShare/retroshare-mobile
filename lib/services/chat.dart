import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/Middleware/chat_middleware.dart';
import 'package:retroshare/model/location.dart';
import 'package:retroshare/provider/friends_identity.dart';
import 'package:retroshare/provider/Idenity.dart';
import 'package:retroshare/provider/room.dart';
import 'package:retroshare/provider/subscribed.dart';
import 'package:tuple/tuple.dart';
import 'package:retroshare/model/auth.dart';
import 'package:retroshare/model/chat.dart';
import 'package:retroshare/model/identity.dart';
import 'package:retroshare/services/identity.dart';

Future<List<Chat>> getSubscribedChatLobbies(AuthToken authToken) async {
  final response = await http.get(
    'http://127.0.0.1:9092/rsMsgs/getChatLobbyList',
    headers: {
      HttpHeaders.authorizationHeader:
          'Basic ' + base64.encode(utf8.encode('$authToken'))
    },
  );
  List<Chat> chatsList = [];
  if (response.statusCode == 200) {
    var list = json.decode(response.body)['cl_list'];
    for (int i = 0; i < list.length; i++) {
      Chat chatItem;
      chatItem = await getChatLobbyInfo(list[i]['xstr64'], authToken);
      chatsList.add(chatItem);
    }
    return chatsList;
  } else
    throw Exception('Failed to load response');
}

Future<Chat> getChatLobbyInfo(String lobbyId, AuthToken authToken) async {
  final response =
      await http.post('http://127.0.0.1:9092/rsMsgs/getChatLobbyInfo',
          headers: {
            HttpHeaders.authorizationHeader:
                'Basic ' + base64.encode(utf8.encode('$authToken'))
          },
          body: json.encode({
            'id': {'xstr64': lobbyId}
          }));

  if (response.statusCode == 200) {
    if (json.decode(response.body)['retval']) {
      var chat = json.decode(response.body)['info'];
      return Chat(
          chatId: chat['lobby_id']['xstr64'],
          chatName: chat['lobby_name'],
          lobbyTopic: chat['lobby_topic'],
          ownIdToUse: chat['gxs_id'],
          autoSubscribe:
              await getLobbyAutoSubscribe(chat['lobby_id']['xstr64']),
          lobbyFlags: chat['lobby_flags'],
          isPublic: chat['lobby_flags'] == 4 || chat['lobby_flags'] == 20
              ? true
              : false);
    } else
      return Chat(
          chatId: "0",
          chatName: "Error",
          lobbyTopic: "Couldn't load room details");
  } else
    throw Exception('Failed to load response');
}

Future<bool> joinChatLobby(
    String chatId, String idToUse, AuthToken authToken) async {
  final response = await http.post(
    'http://127.0.0.1:9092/rsMsgs/joinVisibleChatLobby',
    headers: {
      HttpHeaders.authorizationHeader:
          'Basic ' + base64.encode(utf8.encode('$authToken'))
    },
    body: json.encode({
      'lobby_id': {'xstr64': chatId},
      'own_id': idToUse
    }),
  );

  if (response.statusCode == 200) {
    setLobbyAutoSubscribe(chatId);
    return json.decode(response.body)['retval'];
  } else
    throw Exception('Failed to load response');
}

Future<bool> createChatLobby(
    String lobbyName, String idToUse, String lobbyTopic,
    {List<Location> inviteList: const <Location>[],
    bool public: true,
    bool anonymous: true}) async {
  var req = ReqCreateChatLobby()
    ..lobbyName = lobbyName
    ..lobbyTopic = lobbyTopic
    ..lobbyIdentity = idToUse;
  if (inviteList.isNotEmpty)
    req.invitedFriends =
        List.from(inviteList.map((location) => location.rsPeerId));
  // Lobby flags
  // Public = 4
  // Public + signed = 20
  // Private = 0
  // Private + signed = 16
  int privacyType = 0;
  if (public && anonymous)
    privacyType = 4;
  else if (public && !anonymous)
    privacyType = 20;
  else if (!public && !anonymous) privacyType = 16;
  req.lobbyPrivacyType = privacyType;

  var response = await openapi.rsMsgsCreateChatLobby(reqCreateChatLobby: req);

  if (response.retval.xint64 > 0) {
    setLobbyAutoSubscribe(response.retval.xstr64);
    return true;
  }
  throw Exception('Failed to load response');
}

void setLobbyAutoSubscribe(String lobbyId, [bool subs = true]) {
  var req = ReqSetLobbyAutoSubscribe()
    ..lobbyId = new ChatLobbyId()
    ..lobbyId.xstr64 = lobbyId
    ..autoSubscribe = subs;
  openapi.rsMsgsSetLobbyAutoSubscribe(reqSetLobbyAutoSubscribe: req);
}

Future<bool> getLobbyAutoSubscribe(
  String lobbyId,
) async {
  var req = ReqGetLobbyAutoSubscribe()
    ..lobbyId = new ChatLobbyId()
    ..lobbyId.xstr64 = lobbyId;
  var resp =
      await openapi.rsMsgsGetLobbyAutoSubscribe(reqGetLobbyAutoSubscribe: req);
  return resp.retval;
}

Future<void> unsubscribeChatLobby(
  String lobbyId,
) async {
  var req = ReqUnsubscribeChatLobby()
    ..lobbyId = new ChatLobbyId()
    ..lobbyId.xstr64 = lobbyId;
  openapi.rsMsgsUnsubscribeChatLobby(reqUnsubscribeChatLobby: req);
}

/// Send a message of chat [type].
///   0 TYPE_NOT_SET,
///		1 TYPE_PRIVATE,            // private chat with directly connected friend, peer_id is valid
///		2 TYPE_PRIVATE_DISTANT,    // private chat with distant peer, gxs_id is valid
///		3 TYPE_LOBBY,              // chat lobby id, lobby_id is valid
///		4 TYPE_BROADCAST           // message to/from all connected peers
Future<ResSendChat> sendMessage(
    BuildContext context, String chatId, String msgTxt,
    [ChatIdType type = ChatIdType.number2_]) async {
  var reqSendChat = ReqSendChat() // openapi request object
    ..msg = msgTxt
    ..id = new ChatId()
    ..id.type = type;
  if (type == ChatIdType.number2_)
    reqSendChat.id.distantChatId = chatId;
  else if (type == ChatIdType.number3_) {
    reqSendChat.id.lobbyId = ChatLobbyId();
    reqSendChat.id.lobbyId.xstr64 = chatId;
  } else
    throw ("Chat type not supported");

  openapi
      .rsMsgsSendChat(reqSendChat: reqSendChat)
      .then((ResSendChat resSendChat) {
    if (resSendChat.retval) {
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

/// todo: should this be in a redux middleware?
/// Function that update participants of a lobby chat

Future<List<Identity>> getLobbyParticipants(
    String lobbyId, AuthToken authToken) async {
  final response = await http.post(
    'http://127.0.0.1:9092/rsMsgs/getChatLobbyInfo',
    headers: {
      HttpHeaders.authorizationHeader:
          'Basic ' + base64.encode(utf8.encode('$authToken'))
    },
    body: json.encode({
      'id': {'xstr64': lobbyId}
    }),
  );

  List<Identity> ids = [];

  if (response.statusCode == 200) {
    var gxsIds = json.decode(response.body)['info']['gxs_ids'];
    for (int i = 0; i < gxsIds.length; i++) {
      bool success = true;
      Identity id;
      do {
        Tuple2<bool, Identity> tuple =
            await getIdDetails(gxsIds[i]['key'], authToken);
        success = tuple.item1;
        id = tuple.item2;
      } while (!success);

      ids.add(id);
    }
    return ids;
  } else
    throw Exception('Failed to load response');
}

Future<List<VisibleChatLobbyRecord>> getUnsubscribedChatLobbies() async {
  List<VisibleChatLobbyRecord> unsubscribedChatLobby = [];
  var chatLobbies = await openapi.rsMsgsGetListOfNearbyChatLobbies();
  for (VisibleChatLobbyRecord chat in chatLobbies.publicLobbies) {
    bool autosubs = await getLobbyAutoSubscribe(chat.lobbyId.xstr64);
    if (!autosubs) {
      unsubscribedChatLobby.add(chat);
    }
  }
  return unsubscribedChatLobby;
}

/// [TODO] write this as redux Middleware
/// This function initate a distant chat if not exists and store it.
Future<void> _initiateDistantChat(Chat chat, store) async {
  String to = chat.interlocutorId;
  String from = chat.ownIdToUse;
  var req = ReqInitiateDistantChatConnexion();
  req.fromPid = from;
  req.toPid = to;
  req.notify = true;
  var resp = await openapi.rsMsgsInitiateDistantChatConnexion(
      reqInitiateDistantChatConnexion: req);
  if (resp.retval == true) {
    chat.chatId = resp.pid;
    Chat.addDistantChat(to, from, resp.pid);
    await Provider.of<FriendsIdentity>(store, listen: false).fetchAndUpdate();
    Map<String, Identity> allIDs =
        Provider.of<FriendsIdentity>(store, listen: false).allIds;
    chatActionMiddleware(chat, store);
    allIDs = Provider.of<RoomChatLobby>(store, listen: false)
        .addDistanceChat(chat, allIDs);
    Provider.of<FriendsIdentity>(store, listen: false).setAllIds(allIDs);
  } else
    throw ("Error on initiateDistantChat()");
}

/// Get the chat status from [pid]
///  #define RS_DISTANT_CHAT_STATUS_UNKNOWN			0x0000
///  #define RS_DISTANT_CHAT_STATUS_TUNNEL_DN   		0x0001
///  #define RS_DISTANT_CHAT_STATUS_CAN_TALK			0x0002
///  #define RS_DISTANT_CHAT_STATUS_REMOTELY_CLOSED 	0x0003
Future<DistantChatPeerInfo> getDistantChatStatus(
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

/// todo: Write this as redux Middleware
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
    joinChatLobby(to.lobbyId.xstr64, currentIdentity.mId, authToken)
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
    //store.dispatch(UpdateLobbyParticipantsAction(to.chatId, []));
    Provider.of<RoomChatLobby>(context, listen: false)
        .fetchAndUpdateParticipants(to.chatId, []);
    chatMiddleware(null, context);
    Provider.of<RoomChatLobby>(context, listen: false)
        .addChatMessage(null, to.chatId);
  }
  return chat;
}

Future<void> getMessagesApi(String lobbyId, AuthToken authToken) async {
  final response = await http.post(
    'http://127.0.0.1:9092/rsHistory/getMessages',
    headers: {
      HttpHeaders.authorizationHeader:
          'Basic ' + base64.encode(utf8.encode('$authToken'))
    },
    body: json.encode({'chatPeerId': lobbyId, 'loadCount': 100}),
  );
}

Future<void> message_description(String msgId, AuthToken authToken) async {
  int msg_Id = int.parse(msgId);
  final response = await http.post(
    'http://127.0.0.1:9092/rsHistory/getMessage',
    headers: {
      HttpHeaders.authorizationHeader:
          'Basic ' + base64.encode(utf8.encode('$authToken'))
    },
    body: json.encode({'chatPeerId': msg_Id}),
  );
}

Future<void> removeMessageApi(List<String> msgIds, AuthToken authToken) async {
  List<int> msg_ids;
  for (String x in msgIds) {
    msg_ids.add(int.parse(x));
  }
  final response = await http.post(
    'http://127.0.0.1:9092/rsHistory/removeMessages',
    headers: {
      HttpHeaders.authorizationHeader:
          'Basic ' + base64.encode(utf8.encode('$authToken'))
    },
    body: json.encode({'msgIds': msg_ids}),
  );
}

Future<void> clearMessages(String lobbyId, AuthToken authToken) async {
  final response = await http.post(
    'http://127.0.0.1:9092/rsHistory/removeMessages',
    headers: {
      HttpHeaders.authorizationHeader:
          'Basic ' + base64.encode(utf8.encode('$authToken'))
    },
    body: json.encode({'chatPeerId': lobbyId}),
  );
}
