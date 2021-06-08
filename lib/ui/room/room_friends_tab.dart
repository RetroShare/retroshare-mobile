import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:retroshare/redux/actions/app_actions.dart';
import 'package:retroshare/services/init.dart';

import 'package:retroshare/common/person_delegate.dart';
import 'package:retroshare/model/chat.dart';
import 'package:retroshare/model/identity.dart';
import 'package:retroshare/services/chat.dart';
import 'package:retroshare/services/identity.dart';

import 'package:retroshare/redux/model/app_state.dart';

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
  void initState() {
    getParticipants(widget.chat.chatId, context);
    setState(() {});
  }

  void _addToContacts(String gxsId) async {
    await setContact(gxsId, true);

    final store = StoreProvider.of<AppState>(context);
    await updateIdentitiesStore(store);
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  @override
  Widget build(BuildContext context) {
    return
      StoreConnector<AppState, List<Identity>>(
        converter: (store) => (widget.chat.chatId == null ||
          store.state.lobbyParticipants == null ||
          store.state.lobbyParticipants[widget.chat.chatId] == null )
          ? [] : store.state.lobbyParticipants[widget.chat.chatId],
        builder: (context, _lobbyParticipantsList) {
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount:
              _lobbyParticipantsList == null ? 0 : _lobbyParticipantsList.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTapDown: _storePosition,
                // Todo: DRY
                child: PersonDelegate(
                  data: PersonDelegateData.IdentityData(_lobbyParticipantsList[index], context),
                  onLongPress: (Offset tapPosition) {
                    showCustomMenu(
                        "Add to contacts",
                        Icon(
                          Icons.add,
                          color: Colors.black,
                        ),
                            () => _addToContacts(_lobbyParticipantsList[index].mId),
                        tapPosition,
                        context
                    );
                  },
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/room',
                      arguments: {
                        'isRoom': false,
                        'chatData': getChat(
                            context, _lobbyParticipantsList[index]),
                      },
                    );
                  },
                ),
              );
            },
          );
        }
      );
  }
}
