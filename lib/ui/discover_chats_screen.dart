import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:openapi/api.dart';

import 'package:retroshare/common/styles.dart';

import 'package:retroshare/services/chat.dart';
import 'package:retroshare/model/chat.dart';

import 'package:retroshare/redux/model/app_state.dart';
import 'package:retroshare/services/init.dart';

class DiscoverChatsScreen extends StatefulWidget {
  @override
  _DiscoverChatsScreenState createState() => _DiscoverChatsScreenState();
}

class _DiscoverChatsScreenState extends State<DiscoverChatsScreen> {

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      final store = StoreProvider.of<AppState>(context);
      updateUnsubsChatLobbiesStore(store);
    });
  }

  void _goToChat(lobby) async {
    Navigator.pushNamed(context, '/room',
        arguments: {
          'isRoom': true,
          'chatData': getChat(context, lobby)
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: true,
        bottom: true,
        child:
        StoreConnector<AppState, List<VisibleChatLobbyRecord>>(
          converter: (store) => store.state.unSubscribedChats,
          builder: (context, _chatsList) {
            return Column(
              children: <Widget>[
                Container(
                  height: appBarHeight,
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: personDelegateHeight,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            size: 25,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Discover public chats',
                          style: Theme.of(context).textTheme.body2,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      ListView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: _chatsList?.length ?? 0,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              _goToChat(_chatsList[index]);
                            },
                            child: Container(
                              height: personDelegateHeight,
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            _chatsList[index].lobbyName,
                                            style:
                                            Theme.of(context).textTheme.body2,
                                          ),
                                          Visibility(
                                            visible: _chatsList[index]
                                                .lobbyTopic
                                                .isNotEmpty,
                                            child: Text(
                                              'Topic: ' +
                                                  _chatsList[index].lobbyTopic,
                                              style:
                                              Theme.of(context).textTheme.body1,
                                            ),
                                          ),
                                          Text(
                                            'Number of participants: ' +
                                                _chatsList[index]
                                                    .totalNumberOfPeers
                                                    .toString(),
                                            style:
                                            Theme.of(context).textTheme.body1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: IconButton(
                                      icon: Icon(Icons.input),
                                      onPressed: () {
                                        _goToChat(_chatsList[index]);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      Visibility(
                        visible: _chatsList?.isEmpty ?? true,
                        child: Center(
                          child: SizedBox(
                            width: 250,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset('assets/icons8/pluto-fatal-error.png'),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 25),
                                  child: Text('No public chats are available',
                                      style: Theme.of(context).textTheme.body2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
