import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/HelperFunction/chat.dart';
import 'package:retroshare/provider/subscribed.dart';
import 'package:retroshare/common/person_delegate.dart';
import 'package:retroshare/common/styles.dart';
import 'package:shimmer/shimmer.dart';

class ChatsTab extends StatelessWidget {
  void _unsubscribeChatLobby(lobbyId, context) async {
    Provider.of<ChatLobby>(context, listen: false).unsubscribed(lobbyId); 
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        bottom: false,
        child: FutureBuilder(
            future:
                Provider.of<ChatLobby>(context, listen: false).fetchAndUpdate(),
            builder: (context, snapshot) {
              return snapshot.connectionState == ConnectionState.done
                  ? Consumer<ChatLobby>(
                      builder: (context, chatsList, _) {
                        if (chatsList.subscribedlist != null &&
                            chatsList.subscribedlist?.isNotEmpty)
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
                                        data: PersonDelegateData.ChatData(
                                            chatsList.subscribedlist[index]),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, '/room', arguments: {
                                            'isRoom': true,
                                            'chatData': getChat(context,
                                                chatsList.subscribedlist[index])
                                          });
                                        },
                                        onLongPress: (Offset tapPosition) {
                                          showCustomMenu(
                                              "Unsubscribe chat lobby",
                                              Icon(
                                                Icons.delete,
                                                color: Colors.black,
                                              ),
                                              () => _unsubscribeChatLobby(
                                                  chatsList
                                                      .subscribedlist[index]
                                                      .chatId,
                                                  context),
                                              tapPosition,
                                              context);
                                        },
                                      );
                                    },
                                    childCount:
                                        chatsList.subscribedlist?.length ?? 0,
                                  ),
                                ),
                              )
                            ],
                          );

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
                      },
                    )
                  : Shimmer(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFEBEBF4),
                          Color(0xFFF4F4F4),
                          Color(0xFFEBEBF4),
                        ],
                        stops: [
                          0.1,
                          0.3,
                          0.4,
                        ],
                        begin: Alignment(-1.0, -0.3),
                        end: Alignment(1.0, 0.3),
                        tileMode: TileMode.clamp,
                      ),
                      enabled: true,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        itemBuilder: (_, __) => Container(
                            padding: const EdgeInsets.only(
                                bottom: 8.0, left: 8, right: 8, top: 8),
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 14),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(14)),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 20,
                                  ),
                                  Padding(padding: const EdgeInsets.all(8)),
                                  Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 8,
                                          color: Colors.white,
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          width: 210,
                                          height: 18,
                                          color: Colors.white,
                                        ),
                                      ])
                                ])),
                        itemCount: 5,
                      ),
                    );
            }));
  }
}
