import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/person_delegate.dart';
import 'package:retroshare/provider/Idenity.dart';
import 'package:retroshare/provider/room.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';

class RoomFriendsTab extends StatefulWidget {
  const RoomFriendsTab({this.chat});
  final Chat chat;
  @override
  _RoomFriendsTabState createState() => _RoomFriendsTabState();
}

class _RoomFriendsTabState extends State<RoomFriendsTab> {
//  List<Identity> _lobbyParticipantsList = List<Identity>();
  Image myImage;
  @override
  void initState() {
    myImage = Image.asset('assets/icons8/friends_together.png');
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      precacheImage(myImage.image, context);
      Provider.of<RoomChatLobby>(context, listen: false)
          .updateParticipants(widget.chat?.chatId);
    });
  }

  void _addToContacts(String gxsId) {
    Provider.of<RoomChatLobby>(context, listen: false)
        .toggleContacts(gxsId, true);
  }

  void _storePosition(TapDownDetails details) {}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<RoomChatLobby>(context, listen: false)
          .updateParticipants(widget.chat?.chatId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Consumer<RoomChatLobby>(
            builder: (context, lobbyParticipantsList, _) {
              List<Identity> _lobbyParticipantsList = widget.chat?.chatId !=
                          null ||
                      lobbyParticipantsList.lobbyParticipants != null ||
                      lobbyParticipantsList
                              .lobbyParticipants[widget.chat?.chatId] !=
                          null
                  ? lobbyParticipantsList.lobbyParticipants[widget.chat?.chatId]
                  : null;
              return _lobbyParticipantsList.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _lobbyParticipantsList == null
                          ? 0
                          : _lobbyParticipantsList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTapDown: _storePosition,
                          // Todo: DRY
                          child: PersonDelegate(
                            data: PersonDelegateData.IdentityData(
                              _lobbyParticipantsList[index],
                              context,
                            ),
                            onLongPress: (Offset tapPosition) {
                              showCustomMenu(
                                'Add to contacts',
                                const Icon(
                                  Icons.add,
                                  color: Colors.black,
                                ),
                                () => _addToContacts(
                                  _lobbyParticipantsList[index].mId,
                                ),
                                tapPosition,
                                context,
                              );
                            },
                            onPressed: () {
                              final curr = Provider.of<Identities>(
                                context,
                                listen: false,
                              ).currentIdentity;
                              Navigator.pushNamed(
                                context,
                                '/room',
                                arguments: {
                                  'isRoom': false,
                                  'chatData': Provider.of<RoomChatLobby>(
                                    context,
                                    listen: false,
                                  ).getChat(
                                    curr,
                                    _lobbyParticipantsList[index],
                                  ),
                                },
                              );
                            },
                          ),
                        );
                      },
                    )
                  : Center(
                      child: SizedBox(
                        width: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            myImage,
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                'Looks like an empty space',
                                style: Theme.of(context).textTheme.bodyText1,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                'You can invite your friends',
                                style: Theme.of(context).textTheme.bodyText1,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                          ],
                        ),
                      ),
                    );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
