import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare/provider/room.dart';
import 'package:retroshare/ui/room/messages_tab.dart';
import 'package:retroshare/ui/room/room_friends_tab.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({Key key, this.isRoom = false, this.chat}) : super(key: key);
  final bool isRoom;
  final Chat chat;

  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  bool _init = true;
  final bool isOnline = false;

  Animation<Color> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _init = true;
    _tabController = TabController(vsync: this, length: widget.isRoom ? 2 : 1);

    _iconAnimation =
        ColorTween(begin: Colors.black, end: Colors.lightBlueAccent)
            .animate(_tabController.animation);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      widget.chat.unreadCount = 0;
      if (widget.isRoom) {
        Provider.of<RoomChatLobby>(context, listen: false)
            .updateParticipants(widget.chat.chatId);
      }
      Provider.of<RoomChatLobby>(context, listen: false)
          .updateCurrentChat(widget.chat);
    });
  }

  @override
  void deactivate() {
    Future.delayed(Duration.zero, () async {
      if (mounted) {
        Provider.of<RoomChatLobby>(context, listen: false)
            .updateCurrentChat(null);
      }
    });
    super.deactivate();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendIdentity = Provider.of<RoomChatLobby>(context, listen: false);
    return Scaffold(
      body: SafeArea(
        child: friendIdentity != null
            ? Column(
                children: <Widget>[
                  Container(
                    height: appBarHeight,
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 16.0, 0.0),
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
                              Future.delayed(Duration.zero, () async {
                                if (widget.isRoom &&
                                    _tabController.index == 1) {
                                  _tabController.animateTo(0);
                                } else {
                                  Navigator.pop(context);
                                }
                              });
                            },
                          ),
                        ),
                        Visibility(
                          visible: !widget.isRoom,
                          child: SizedBox(
                            width: appBarHeight,
                            height: appBarHeight,
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: <Widget>[
                                Center(
                                  child: Container(
                                    height: appBarHeight * 0.70,
                                    width: appBarHeight * 0.70,
                                    decoration: (friendIdentity
                                                    .allIdentity[widget
                                                        .chat.interlocutorId]
                                                    ?.avatar ==
                                                null ||
                                            friendIdentity
                                                .allIdentity[
                                                    widget.chat.interlocutorId]
                                                .avatar
                                                .isEmpty)
                                        ? null
                                        : BoxDecoration(
                                            color: Colors.lightBlueAccent,
                                            borderRadius: BorderRadius.circular(
                                              appBarHeight * 0.70 * 0.33,
                                            ),
                                            image: DecorationImage(
                                              fit: BoxFit.fitWidth,
                                              image: MemoryImage(
                                                base64Decode(
                                                  friendIdentity
                                                      .allIdentity[widget
                                                          .chat.interlocutorId]
                                                      .avatar,
                                                ),
                                              ),
                                            ),
                                          ),
                                    child: Visibility(
                                      visible:
                                          friendIdentity
                                                          .allIdentity[widget
                                                              .chat
                                                              .interlocutorId]
                                                          ?.avatar ==
                                                      null ||
                                                  friendIdentity
                                                      .allIdentity[widget
                                                          .chat.interlocutorId]
                                                      .avatar
                                                      .isEmpty ??
                                              true,
                                      child: Center(
                                        child: Icon(
                                          (widget.chat.isPublic)
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
                                          width: appBarHeight * 0.03,
                                        ),
                                        color: Colors.lightGreenAccent,
                                        borderRadius: BorderRadius.circular(
                                          appBarHeight * 0.3 * 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            widget.isRoom
                                ? widget.chat.chatName
                                : friendIdentity
                                        .allIdentity[
                                            widget.chat.interlocutorId]
                                        ?.name ??
                                    widget.chat.chatName ??
                                    widget.chat.interlocutorId ??
                                    'Name',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Visibility(
                          visible: widget.isRoom,
                          child: AnimatedBuilder(
                            animation: _tabController.animation,
                            builder: (BuildContext context, Widget widget) {
                              return IconButton(
                                icon: const Icon(
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
                        return index == 0
                            ? MessagesTab(
                                chat: widget.chat,
                                isRoom: widget.isRoom,
                              )
                            : RoomFriendsTab(chat: widget.chat);
                      }),
                    ),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
