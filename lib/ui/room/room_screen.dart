import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/Middleware/register_chat_event.dart';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare/model/cache.dart';
import 'package:retroshare/provider/FriendsIdentity.dart';
import 'package:retroshare/provider/room.dart';
import 'package:retroshare/ui/room/messages_tab.dart';
import 'package:retroshare/ui/room/room_friends_tab.dart';
import 'package:retroshare/model/chat.dart';

class RoomScreen extends StatefulWidget {
  final bool isRoom;
  final Chat chat;
  RoomScreen({Key key, this.isRoom = false, this.chat}) : super(key: key);
  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  final bool isOnline = false;

  Animation<Color> _iconAnimation;

  @override
  void initState() {
    super.initState();
       
    _tabController =
        new TabController(vsync: this, length: widget.isRoom ? 2 : 1);

    _iconAnimation =
        ColorTween(begin: Colors.black, end: Colors.lightBlueAccent)
            .animate(_tabController.animation);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      widget.chat.unreadCount = 0;
       await registerChatEvent(context);
      await Provider.of<FriendsIdentity>(context, listen: false)
          .fetchAndUpdate();
      Provider.of<RoomChatLobby>(context, listen: false)
          .updateCurrentChat(widget.chat);
      if (widget.isRoom) {
        Provider.of<RoomChatLobby>(context, listen: false)
            .updateParticipants(widget.chat.chatId);
        //await getMessagesApi(widget.chat.chatId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: true,
        child: Consumer<FriendsIdentity>(
          builder: (context, friendIdentity, _) {
            return Column(
              children: <Widget>[
                Container(
                  height: appBarHeight,
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 16.0, 0.0),
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
                            Future.delayed(Duration.zero, () async {
                              Provider.of<RoomChatLobby>(context, listen: false)
                                  .updateCurrentChat(null);
                              Navigator.pop(context);
                            });
                          },
                        ),
                      ),
                      Visibility(
                        visible: !widget.isRoom,
                        child: Container(
                          width: appBarHeight,
                          height: appBarHeight,
                          child: Stack(
                            alignment: Alignment(-1.0, 0.0),
                            children: <Widget>[
                              Center(
                                child: Container(
                                  height: appBarHeight * 0.70,
                                  width: appBarHeight * 0.70,
                                  decoration: (widget.chat.interlocutorId ==
                                                  null ||
                                              friendIdentity
                                                      .allIds[widget
                                                          .chat.interlocutorId]
                                                      ?.avatar ==
                                                  null ??
                                          false)
                                      ? null
                                      : BoxDecoration(
                                          border: null,
                                          color: Colors.lightBlueAccent,
                                          borderRadius: BorderRadius.circular(
                                              appBarHeight * 0.70 * 0.33),
                                          image: DecorationImage(
                                              fit: BoxFit.fitWidth,
                                              image: cachedImages[friendIdentity
                                                  .allIds[widget
                                                      .chat.interlocutorId]
                                                  .avatar]),
                                        ),
                                  child: Visibility(
                                    visible: (widget.chat.interlocutorId ==
                                            null ||
                                        friendIdentity
                                                .allIds[
                                                    widget.chat.interlocutorId]
                                                .avatar ==
                                            null),
                                    child: Center(
                                      child: Icon(
                                        (widget.chat.isPublic == null ||
                                                widget.chat.isPublic)
                                            ? Icons.people
                                            : Icons.person,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: isOnline,
                                child: Positioned(
                                  bottom: appBarHeight * 0.63,
                                  left: appBarHeight * 0.63,
                                  child: Container(
                                    height: appBarHeight * 0.25,
                                    width: appBarHeight * 0.25,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white,
                                          width: appBarHeight * 0.03),
                                      color: Colors.lightGreenAccent,
                                      borderRadius: BorderRadius.circular(
                                          appBarHeight * 0.3 * 0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          widget.isRoom
                              ? widget.chat.chatName
                              : friendIdentity
                                  .allIds[widget.chat.interlocutorId].name,
                          style: Theme.of(context).textTheme.body2,
                        ),
                      ),
                      Visibility(
                        visible: widget.isRoom,
                        child: AnimatedBuilder(
                          animation: _tabController.animation,
                          builder: (BuildContext context, Widget widget) {
                            return IconButton(
                              icon: Icon(
                                Icons.people,
                                size: 25,
                              ),
                              color: _iconAnimation.value,
                              onPressed: () {
                                _tabController
                                    .animateTo(1 - _tabController.index);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: List<Widget>.generate(widget.isRoom ? 2 : 1,
                        (int index) {
                      if (index == 0)
                        return MessagesTab(
                          chat: widget.chat,
                          isRoom: widget.isRoom,
                        );
                      else
                        return RoomFriendsTab(chat: widget.chat);
                    }),
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
