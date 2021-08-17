import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/HelperFunction/chat.dart';
import 'package:retroshare/provider/friends_identity.dart';
import 'package:retroshare/provider/room.dart';
import 'package:retroshare/common/person_delegate.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';

class RoomFriendsTab extends StatefulWidget {
  final Chat chat;

  RoomFriendsTab({this.chat});

  @override
  _RoomFriendsTabState createState() => _RoomFriendsTabState();
}

class _RoomFriendsTabState extends State<RoomFriendsTab> {
//  List<Identity> _lobbyParticipantsList = List<Identity>();
  var _tapPosition;
  Image myImage;
  @override
  void initState() {
    myImage = Image.asset('assets/icons8/participant_list.jpg');
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(myImage.image, context);
      Provider.of<RoomChatLobby>(context, listen: false)
        .updateParticipants(widget.chat?.chatId);

  }
  

  void _addToContacts(String gxsId) {
    Provider.of<FriendsIdentity>(context, listen: false)
        .toggleContacts(gxsId, true);
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Provider.of<RoomChatLobby>(context, listen: false)
            .updateParticipants(widget.chat?.chatId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done)
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
              return _lobbyParticipantsList.length > 0
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
                                _lobbyParticipantsList[index], context),
                            onLongPress: (Offset tapPosition) {
                              showCustomMenu(
                                  "Add to contacts",
                                  Icon(
                                    Icons.add,
                                    color: Colors.black,
                                  ),
                                  () => _addToContacts(
                                      _lobbyParticipantsList[index].mId),
                                  tapPosition,
                                  context);
                            },
                            onPressed: () {
                       
                                Navigator.pushNamed(
                                  context,
                                  '/room',
                                  arguments: {
                                    'isRoom': false,
                                    'chatData': getChat(
                                        context, _lobbyParticipantsList[index]),
                                
                              });
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
                            SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                'Looks like an empty space',
                                style: Theme.of(context).textTheme.body2,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                'You can invite your friends',
                                style: Theme.of(context).textTheme.body1,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                          ],
                        ),
                      ),
                    );
            });
          return Center(child: CircularProgressIndicator());
        });
  }
}
