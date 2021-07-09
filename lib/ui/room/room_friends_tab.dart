import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/model/identity.dart';
import 'package:retroshare/provider/FriendsIdentity.dart';
import 'package:retroshare/provider/room.dart';

import 'package:retroshare/common/person_delegate.dart';
import 'package:retroshare/model/chat.dart';
import 'package:retroshare/services/chat.dart';

class RoomFriendsTab extends StatefulWidget {
  final Chat chat;

  RoomFriendsTab({this.chat});

  @override
  _RoomFriendsTabState createState() => _RoomFriendsTabState();
}

class _RoomFriendsTabState extends State<RoomFriendsTab> {
//  List<Identity> _lobbyParticipantsList = List<Identity>();
  var _tapPosition;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Provider.of<RoomChatLobby>(context, listen: false)
        .updateParticipants(widget.chat.chatId);
  }

  void _addToContacts(String gxsId) async {
    await Provider.of<FriendsIdentity>(context, listen: false)
        .toggleContacts(gxsId, true);
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomChatLobby>(
        builder: (context, lobbyParticipantsList, _) {
      List<Identity> _lobbyParticipantsList = widget.chat.chatId != null ||
              lobbyParticipantsList.lobbyParticipants == null ||
              lobbyParticipantsList.lobbyParticipants[widget.chat.chatId] ==
                  null
          ? []
          : lobbyParticipantsList.lobbyParticipants[widget.chat.chatId];
      print(_lobbyParticipantsList);
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount:
            _lobbyParticipantsList == null ? 0 : _lobbyParticipantsList.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTapDown: _storePosition,
            // Todo: DRY
            child: PersonDelegate(
              data: PersonDelegateData.IdentityData(
                  _lobbyParticipantsList[index], context),
              onLongPress: (Offset tapPosition) {
                showCustomMenu(
                    "Add to contacts",
                    Icon(
                      Icons.add,
                      color: Colors.black,
                    ),
                    () => _addToContacts(_lobbyParticipantsList[index].mId),
                    tapPosition,
                    context);
              },
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/room',
                  arguments: {
                    'isRoom': false,
                    'chatData': getChat(context, _lobbyParticipantsList[index]),
                  },
                );
              },
            ),
          );
        },
      );
    });
  }
}
