import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare/provider/Idenity.dart';
import 'package:retroshare/provider/room.dart';
import 'package:retroshare/provider/subscribed.dart';

class DiscoverChatsScreen extends StatefulWidget {
  @override
  _DiscoverChatsScreenState createState() => _DiscoverChatsScreenState();
}

class _DiscoverChatsScreenState extends State<DiscoverChatsScreen> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<ChatLobby>(context, listen: false)
          .fetchAndUpdateUnsubscribed();
    });
  }

  Future<void> _goToChat(lobby) async {
    final curr =
        Provider.of<Identities>(context, listen: false).currentIdentity;
    Navigator.pushNamed(
      context,
      '/room',
      arguments: {
        'isRoom': true,
        'chatData': Provider.of<RoomChatLobby>(context, listen: false)
            .getChat(curr, lobby, from: ''),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: appBarHeight,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: personDelegateHeight,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 25,
                      ),
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Discover public chats',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: Provider.of<ChatLobby>(context, listen: false)
                    .fetchAndUpdateUnsubscribed(),
                builder: (context, snapshot) {
                  return snapshot.connectionState == ConnectionState.done &&
                          !snapshot.hasError
                      ? Consumer<ChatLobby>(
                          builder: (context, chatsList, _) {
                            return chatsList.unSubscribedlist.isNotEmpty
                                ? ListView.builder(
                                    padding: const EdgeInsets.all(8),
                                    itemCount:
                                        chatsList.unSubscribedlist.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () {
                                          _goToChat(chatsList
                                              .unSubscribedlist[index],);
                                        },
                                        key: UniqueKey(),
                                        child: SizedBox(
                                          height: personDelegateHeight,
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        chatsList
                                                            .unSubscribedlist[
                                                                index]
                                                            .lobbyName,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge,
                                                      ),
                                                      Visibility(
                                                        visible: chatsList
                                                            .unSubscribedlist[
                                                                index]
                                                            .lobbyTopic
                                                            .isNotEmpty,
                                                        child: Text(
                                                          'Topic: ${chatsList.unSubscribedlist[index].lobbyTopic}',
                                                          style: Theme.of(
                                                            context,
                                                          ).textTheme.bodyLarge,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Number of participants: ${chatsList.unSubscribedlist[index].totalNumberOfPeers}',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                child: IconButton(
                                                  icon: const Icon(Icons.input),
                                                  onPressed: () {
                                                    _goToChat(
                                                      chatsList
                                                              .unSubscribedlist[
                                                          index],
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Center(
                                    child: SizedBox(
                                      width: 250,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Image.asset(
                                            'assets/icons8/pluto-fatal-error.png',
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 25,
                                            ),
                                            child: Text(
                                              'No public chats are available',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                          },
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
