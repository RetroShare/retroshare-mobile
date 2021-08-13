import 'package:provider/provider.dart';

import 'package:retroshare/provider/friends_identity.dart';
import 'package:retroshare/provider/Idenity.dart';
import 'package:retroshare/provider/room.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';

int getUnreadCount(context, Identity identity) {
  return Provider.of<RoomChatLobby>(context, listen: false).distanceChat != null
      ? Provider.of<RoomChatLobby>(context, listen: false)
              .distanceChat[Chat.getDistantChatId(
                  identity.mId,
                  Provider.of<Identities>(context, listen: false)
                      .currentIdentity
                      .mId)]
              ?.unreadCount ??
          0
      : 0;
}

String getChatSenderName(dynamic context, ChatMessage message) {
  final distantChats =
      Provider.of<RoomChatLobby>(context, listen: false).distanceChat;
  final allIds = Provider.of<FriendsIdentity>(context, listen: false).allIds;
  final lobbyParticipants =
      Provider.of<RoomChatLobby>(context, listen: false).lobbyParticipants;
  if (message.isLobbyMessage()) {
    return lobbyParticipants[message.chat_id.lobbyId.xstr64]
            .firstWhere((id) => id.mId == message.lobby_peer_gxs_id,
                orElse: () => null)
            ?.name ??
        message.lobby_peer_gxs_id;
  }
  Identity id =
      allIds[distantChats[message.chat_id.distantChatId].interlocutorId];
  if (id == null) {
    Provider.of<Identities>(context, listen: false).callrequestIdentity(
        new Identity(
            distantChats[message.chat_id.distantChatId].interlocutorId));
    return distantChats[message.chat_id.distantChatId].interlocutorId;
  }
  return id.name.isEmpty ? id.mId : id.name;
}
