import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:retroshare/services/chat.dart';

import 'package:retroshare/common/person_delegate.dart';
import 'package:retroshare/common/styles.dart';

import 'package:retroshare/model/chat.dart';
import 'package:retroshare/redux/model/app_state.dart';
import 'package:retroshare/services/init.dart';

class ChatsTab extends StatelessWidget {

  void _unsubscribeChatLobby(String lobbyId, context) async {
    await unsubscribeChatLobby(lobbyId);
    final store = StoreProvider.of<AppState>(context);
    updateChatLobbiesStore(store);
    updateUnsubsChatLobbiesStore(store);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Stack(
        children: <Widget>[
          StoreConnector<AppState, List<Chat>>(
            converter: (store) => store.state.subscribedChats,
            builder: (context, chatsList) {
              if (chatsList != null && chatsList?.isNotEmpty)
                return CustomScrollView(
                slivers: <Widget>[
                  SliverPadding(
                    padding: const EdgeInsets.only(
                        left: 8, top: 8, right: 16, bottom: 8),
                    sliver: SliverFixedExtentList(
                      itemExtent: personDelegateHeight,
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          // Todo: DRY
                          return PersonDelegate(
                            data: PersonDelegateData.ChatData(chatsList[index]),
                            onPressed: () {
                              Navigator.pushNamed(context, '/room',
                                  arguments: {
                                    'isRoom': true,
                                    'chatData': getChat(context, chatsList[index])
                                  });
                            },
                            onLongPress: (Offset tapPosition) {
                              showCustomMenu(
                                  "Unsubscribe chat lobby",
                                  Icon(
                                    Icons.delete,
                                    color: Colors.black,
                                  ),
                                      () => _unsubscribeChatLobby(chatsList[index].chatId, context),
                                  tapPosition,
                                  context
                              );
                            },
                          );
                        },

                        childCount: chatsList?.length ?? 0,
                      ),
                    ),
                  )
                ],
              );
              else
                return Container();
            },
          ),
          StoreConnector<AppState, List<Chat>>(
            converter: (store) => store.state.subscribedChats,
            builder: (context, chatsList) {
              if (chatsList == null || chatsList?.isEmpty)
                return Center(
                  child: SizedBox(
                    width: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset('assets/icons8/pluto-sign-in.png'),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 25),
                          child: Text(
                            "Looks like there aren't any subscribed chats",
                            style: Theme.of(context).textTheme.body2,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              else
                return Container();
            },
          ),
        ],
      ),
    );
  }
}
