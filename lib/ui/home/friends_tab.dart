import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/sliver_persistent_header.dart';
import 'package:retroshare/provider/Idenity.dart';
import 'package:retroshare/provider/room.dart';
import 'package:retroshare/common/person_delegate.dart';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';
import 'package:tuple/tuple.dart';

class FriendsTab extends StatefulWidget {
  @override
  _FriendsTabState createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  void _removeFromContacts(String gxsId) {
    Provider.of<RoomChatLobby>(context, listen: false)
        .toggleContacts(gxsId, false);
  }

  void _addToContacts(String gxsId) {
    Provider.of<RoomChatLobby>(context, listen: false)
        .toggleContacts(gxsId, true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Consumer<RoomChatLobby>(
        builder: (context, roomChat, _) {
          final Tuple3<List<Identity>, List<Chat>, Map<String, Identity>>
              friendsDistantAndIdsTuple =
              Tuple3<List<Identity>, List<Chat>, Map<String, Identity>>(
                  roomChat.friendsIdsList,
                  roomChat.distanceChat?.values
                          ?.toList()
                          ?.where((chat) =>
                              roomChat.allIdentity[chat.interlocutorId] ==
                                  null ||
                              roomChat.allIdentity[chat.interlocutorId]
                                      .isContact ==
                                  false)
                          ?.toSet()
                          ?.toList() ??
                      [],
                  roomChat.allIdentity);

          if (friendsDistantAndIdsTuple.item1?.isNotEmpty ?? false) {
            return CustomScrollView(
              slivers: <Widget>[
                sliverPersistentHeader('Contacts', context),
                SliverPadding(
                  padding: EdgeInsets.only(
                      left: 8,
                      top: 8,
                      right: 16,
                      bottom:
                          (friendsDistantAndIdsTuple.item2?.isEmpty != false ??
                                  true)
                              ? homeScreenBottomBarHeight * 2
                              : 8.0),
                  sliver: SliverFixedExtentList(
                    itemExtent: personDelegateHeight,
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return GestureDetector(
                          // Todo: DRY
                          child: PersonDelegate(
                            data: PersonDelegateData.IdentityData(
                                friendsDistantAndIdsTuple.item1[index],
                                context),
                            onLongPress: (Offset tapPosition) {
                              showCustomMenu(
                                  'Remove from contacts',
                                  const Icon(
                                    Icons.delete,
                                    color: Colors.black,
                                  ),
                                  () => _removeFromContacts(
                                      friendsDistantAndIdsTuple
                                          .item1[index].mId),
                                  tapPosition,
                                  context);
                            },
                            onPressed: () {
                              final curr = Provider.of<Identities>(context,
                                      listen: false)
                                  .currentIdentity;

                              Navigator.pushNamed(
                                context,
                                '/room',
                                arguments: {
                                  'isRoom': false,
                                  'chatData': Provider.of<RoomChatLobby>(
                                          context,
                                          listen: false)
                                      .getChat(
                                          curr,
                                          friendsDistantAndIdsTuple
                                              .item1[index]),
                                },
                              );
                            },
                          ),
                        );
                      },
                      childCount: friendsDistantAndIdsTuple.item1?.length,
                    ),
                  ),
                ),
                SliverOpacity(
                  opacity: (friendsDistantAndIdsTuple.item2?.isNotEmpty ??
                              false) &&
                          (friendsDistantAndIdsTuple.item2.isNotEmpty ?? false)
                      ? 1.0
                      : 0.0,
                  sliver: sliverPersistentHeader('People', context),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(
                      left: 8,
                      top: 8,
                      right: 16,
                      bottom: homeScreenBottomBarHeight * 2),
                  sliver: SliverFixedExtentList(
                    itemExtent: personDelegateHeight,
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final Identity actualId =
                            friendsDistantAndIdsTuple.item3[
                                    friendsDistantAndIdsTuple
                                        .item2[index]?.interlocutorId] ??
                                Identity(friendsDistantAndIdsTuple
                                    .item2[index].interlocutorId);
                        return GestureDetector(
                          // Todo: DRY
                          child: PersonDelegate(
                            data: PersonDelegateData.IdentityData(
                                actualId, context),
                            onLongPress: (Offset tapPosition) {
                              showCustomMenu(
                                  'Add to contacts',
                                  const Icon(
                                    Icons.add,
                                    color: Colors.black,
                                  ),
                                  () => _addToContacts(actualId.mId),
                                  tapPosition,
                                  context);
                            },
                            onPressed: () {
                              final curr = Provider.of<Identities>(context,
                                      listen: false)
                                  .currentIdentity;
                              Navigator.pushNamed(
                                context,
                                '/room',
                                arguments: {
                                  'isRoom': false,
                                  'chatData': Provider.of<RoomChatLobby>(
                                          context,
                                          listen: false)
                                      .getChat(curr, actualId),
                                },
                              );
                            },
                          ),
                        );
                      },
                      childCount:
                          friendsDistantAndIdsTuple.item2.toSet().length,
                    ),
                  ),
                ),
              ],
            );
          }

          return Center(
            child: SizedBox(
              width: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/icons8/list-is-empty-3.png'),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      'Looks like an empty space',
                      style: Theme.of(context).textTheme.body2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      'You can add friends in the menu',
                      style: Theme.of(context).textTheme.body1,
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
      ),
    );
  }
}
