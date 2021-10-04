import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/person_delegate.dart';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare/provider/Idenity.dart';
import 'package:retroshare/provider/room.dart';
import 'package:retroshare/provider/subscribed.dart';

class ChatsTab extends StatelessWidget {
  Future<void> _unsubscribeChatLobby(lobbyId, context) async {
    Provider.of<ChatLobby>(context, listen: false).unsubscribed(lobbyId);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Consumer<ChatLobby>(
        builder: (context, chatsList, _) {
          if (chatsList.subscribedlist != null &&
              chatsList.subscribedlist.isNotEmpty) {
            return CustomScrollView(
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    top: 8,
                    right: 16,
                    bottom: 8,
                  ),
                  sliver: SliverFixedExtentList(
                    itemExtent: personDelegateHeight,
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        // Todo: DRY
                        return PersonDelegate(
                          data: PersonDelegateData.ChatData(
                              chatsList.subscribedlist[index]),
                          onPressed: () {
                            final curr =
                                Provider.of<Identities>(context, listen: false)
                                    .currentIdentity;
                            Navigator.pushNamed(
                              context,
                              '/room',
                              arguments: {
                                'isRoom': true,
                                'chatData': Provider.of<RoomChatLobby>(
                                  context,
                                  listen: false,
                                ).getChat(
                                  curr,
                                  chatsList.subscribedlist[index],
                                )
                              },
                            );
                          },
                          onLongPress: (Offset tapPosition) {
                            showCustomMenu(
                              'Unsubscribe chat lobby',
                              const Icon(
                                Icons.delete,
                                color: Colors.black,
                              ),
                              () => _unsubscribeChatLobby(
                                chatsList.subscribedlist[index].chatId,
                                context,
                              ),
                              tapPosition,
                              context,
                            );
                          },
                        );
                      },
                      childCount: chatsList.subscribedlist?.length ?? 0,
                    ),
                  ),
                )
              ],
            );
          }

          return Center(
            child: SizedBox(
              width: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/icons8/pluto-sign-in.png'),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    child: Text(
                      "Looks like there aren't any subscribed chats",
                      style: Theme.of(context).textTheme.bodyText1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
