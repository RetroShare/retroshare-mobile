import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare/provider/Idenity.dart';
import 'package:retroshare/provider/room.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';

class PersonDelegateData {
  const PersonDelegateData({
    required this.name,
    required this.mId,
    this.message = '',
    this.time = '',
    this.profileImage = '',
    this.isOnline = false,
    this.isMessage = false,
    this.isUnread = false,
    this.isTime = false,
    this.isRoom = false,
    this.icon = Icons.person,
    required this.image,
  });

  final String name;
  final String mId;
  final String message;
  final String time;
  final String profileImage;
  final bool isOnline;
  final bool isMessage;
  final bool isUnread;
  final bool isTime;
  final bool isRoom;
  final IconData icon;
  final MemoryImage image;

  /// Generate generic chat person delegate data for DRY
  static PersonDelegateData ChatData(Chat chatData) {
    return PersonDelegateData(
      name: chatData.chatName,
      message: chatData.lobbyTopic,
      mId: chatData.chatId,
      isRoom: true,
      isMessage: true,
      icon: chatData.isPublic ?? true ? Icons.public : Icons.lock,
      isUnread: chatData.unreadCount > 0, image: null,
    );
  }

  static PersonDelegateData PublicChatData(VisibleChatLobbyRecord chatData) {
    // ignore: prefer_interpolation_to_compose_strings
    final String message = chatData.lobbyTopic +
        (chatData.totalNumberOfPeers != null || chatData.totalNumberOfPeers != 0
            ? 'Total: ${chatData.totalNumberOfPeers}'
            : ' ') +
        (chatData.participatingFriends.isNotEmpty
            ? 'Friends: ${chatData.participatingFriends.length}'
            : '');

    return PersonDelegateData(
      name: chatData.lobbyName,
      message: message,
      mId: chatData.lobbyId.xstr64,
      isRoom: true,
      isMessage: true,
      icon: Chat.isPublicChat(chatData.lobbyFlags) ?? true
          ? Icons.public
          : Icons.lock, image: null,
    );
  }

  static PersonDelegateData IdentityData(
    Identity identity,
    BuildContext context,
  ) {
    final Identity currentIdenInfo =
        Provider.of<Identities>(context, listen: false).currentIdentity;
    return PersonDelegateData(
      name: identity.name,
      mId: identity.mId,
      image: identity.avatar.isNotEmpty
          ? MemoryImage(base64Decode(identity.avatar))
          : null,
      isMessage: true,
      // ignore: avoid_bool_literals_in_conditional_expressions
      isUnread: Provider.of<RoomChatLobby>(context, listen: false)
                  .getUnreadCount(identity, currentIdenInfo) >
              0
          ? true
          : false,
    );
  }

  // ignore: non_constant_identifier_names
  // ignore: prefer_constructors_over_static_methods
  static PersonDelegateData LocationData(Location location) {
    return PersonDelegateData(
      name: location.accountName,
      message: location.locationName,
      isOnline: location.isOnline,
      isMessage: true, mId: '', image: null,
    );
  }
}

class PersonDelegate extends StatefulWidget {
  const PersonDelegate(
      {required this.data, required this.onPressed, required this.onLongPress, this.isSelectable = false,});
  final PersonDelegateData data;
  final Function onPressed;
  final Function onLongPress;
  final bool isSelectable;

  @override
  _PersonDelegateState createState() => _PersonDelegateState();
}

// Todo: implement ListTile or ExpansionPanel or similar class here
class _PersonDelegateState extends State<PersonDelegate>
    with SingleTickerProviderStateMixin {
  final double delegateHeight = personDelegateHeight;

  late Animation<Decoration> boxShadow;
  late AnimationController _animationController;
  late CurvedAnimation _curvedAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200),);
    _curvedAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut);

    boxShadow = DecorationTween(
      begin: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0),
            spreadRadius: appBarHeight / 3,
          ),
        ],
        borderRadius: const BorderRadius.all(Radius.circular(appBarHeight / 3)),
        color: Colors.white.withOpacity(0),
      ),
      end: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            spreadRadius: 2.0,
          ),
        ],
        borderRadius: BorderRadius.all(Radius.circular(appBarHeight / 3)),
        color: Colors.white,
      ),
    ).animate(_curvedAnimation);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  late Offset _tapPosition;
  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  Widget _build(BuildContext context, [Identity id = null]) {
    return GestureDetector(
      onTap: () {
        widget.onPressed();
      },
      onLongPress: () {
        widget.onLongPress(_tapPosition);
      },
      onTapDown: _storePosition,
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
        height: delegateHeight,
        decoration: boxShadow.value,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: delegateHeight,
              height: delegateHeight,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: <Widget>[
                  Center(
                    child: Visibility(
                      visible: widget.data.isUnread,
                      child: Container(
                        height: delegateHeight * 0.92,
                        width: delegateHeight * 0.92,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF00FFFF),
                              Color(0xFF29ABE2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(
                              delegateHeight * 0.92 * 0.33,),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      height: widget.data.isUnread
                          ? delegateHeight * 0.88
                          : delegateHeight * 0.8,
                      width: widget.data.isUnread
                          ? delegateHeight * 0.88
                          : delegateHeight * 0.8,
                      decoration:
                          (widget.data.isRoom)
                              ? null
                              : BoxDecoration(
                                  border: widget.data.isUnread
                                      ? Border.all(
                                          color: Colors.white,
                                          width: delegateHeight * 0.03,)
                                      : null,
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      delegateHeight * 0.92 * 0.33,),
                                  image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: widget.data.image,
                                      onError: (context, stackTrace) => Center(
                                              child: Icon(
                                            widget.data.icon,
                                            size: personDelegateIconHeight,
                                          ),),),
                                ),
                      child: Visibility(
                        visible:
                            widget.data.isRoom,
                        child: Center(
                          child: Icon(
                            widget.data.icon,
                            size: personDelegateIconHeight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: widget.data.isOnline,
                    child: Positioned(
                      bottom: delegateHeight * 0.73,
                      left: delegateHeight * 0.73,
                      child: Container(
                        height: delegateHeight * 0.25,
                        width: delegateHeight * 0.25,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.white,
                              width: delegateHeight * 0.03,),
                          color: Colors.lightGreenAccent,
                          borderRadius:
                              BorderRadius.circular(delegateHeight * 0.3 * 0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(children: [
                      SizedBox(
                        width: 200,
                        child: Text(
                          widget.data.name,
                          style: widget.data.isMessage
                              ? Theme.of(context).textTheme.bodyLarge
                              : Theme.of(context).textTheme.bodyLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      Visibility(
                        visible:
                            widget.isSelectable && _curvedAnimation.value == 1,
                        child: IconButton(
                          icon: const Icon(Icons.navigate_next),
                          onPressed: () =>
                              Navigator.of(context).pushReplacementNamed(
                            '/profile',
                            arguments: {'id': id},
                          ),
                        ),
                      ),
                    ],),
                    Visibility(
                      visible: widget.data.isMessage &&
                          widget.data.message.isNotEmpty,
                      child: Text(
                        widget.data.message,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: widget.data.isTime,
              child: Text(
                widget.data.time,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSelectable) {
      return Consumer<Identities>(
        key: UniqueKey(),
        builder: (context, id, _) {
          if (id.selectedIdentity.mId == widget.data.mId) {
            _animationController.value = 1;
          } else {
            _animationController.value = 0;
          }

          return _build(context, id.selectedIdentity);
        },
      );
    }

    return _build(context);
  }
}

/// Todo: do this better when new PersonDelegate
/// class will be implemented. For ListTile, integrate new popup menu.
Future<void> showCustomMenu(String title, Icon icon, Function action,
    Offset tapPosition, BuildContext context,) async {
  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject()! as RenderBox;

  final delta = await showMenu(
    context: context,
    items: <PopupMenuEntry>[
      PopupMenuItem(
        value: 0,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          leading: icon,
          title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    ],
    position: RelativeRect.fromRect(
      tapPosition & const Size(40, 40),
      Offset.zero & overlay.semanticBounds.size,
    ),
  );

  if (delta != null) {
    if (delta == 0) action();
  }
}
