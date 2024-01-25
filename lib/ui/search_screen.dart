import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/person_delegate.dart';
import 'package:retroshare/common/sliver_persistent_header.dart';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare/provider/Idenity.dart';
import 'package:retroshare/provider/room.dart';
import 'package:retroshare/provider/subscribed.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key key, this.initialTab}) : super(key: key);
  final int initialTab;

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  final TextEditingController _searchBoxFilter = TextEditingController();
  Animation<Color> _leftTabIconColor;
  Animation<Color> _rightTabIconColor;
  bool _init = true;
  String _searchContent = '';
  List<Identity> allIds = [];
  List<Identity> filteredAllIds = [];
  List<Identity> contactsIds = [];
  List<Identity> filteredContactsIds = [];
  List<Chat> subscribedChats = [];
  List<Chat> filteredSubscribedChats = [];
  List<VisibleChatLobbyRecord> publicChats = [];
  List<VisibleChatLobbyRecord> filteredPublicChats = [];

  var _tapPosition;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(vsync: this, length: 2, initialIndex: widget.initialTab);
    _init = true;
    _searchBoxFilter.addListener(() {
      if (_searchBoxFilter.text.isEmpty) {
        if (mounted) {
          setState(() {
            _searchContent = '';
            filteredAllIds = allIds;
            filteredContactsIds = contactsIds;
            filteredSubscribedChats = subscribedChats;
            filteredPublicChats = publicChats;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _searchContent = _searchBoxFilter.text;
          });
        }
      }
    });

    _leftTabIconColor = ColorTween(begin: const Color(0xFFF5F5F5), end: Colors.white)
        .animate(_tabController.animation);
    _rightTabIconColor = ColorTween(begin: Colors.white, end: const Color(0xFFF5F5F5))
        .animate(_tabController.animation);
  }

  @override
  void didChangeDependencies() {
    if (_init) {
      final friendIdentity = Provider.of<RoomChatLobby>(context, listen: false);
      final chatLobby = Provider.of<ChatLobby>(context, listen: false);
      friendIdentity.fetchAndUpdate();
      chatLobby.fetchAndUpdate();
      chatLobby.fetchAndUpdateUnsubscribed();
      allIds = friendIdentity.notContactIds;
      contactsIds = friendIdentity.friendsIdsList;
      subscribedChats = chatLobby.subscribedlist;
      publicChats = chatLobby.unSubscribedlist;
    }
    _init = false;
    super.didChangeDependencies();
  }

  Future<void> _goToChat(lobby) async {
    final curr =
        Provider.of<Identities>(context, listen: false).currentIdentity;
    Navigator.pushNamed(context, '/room', arguments: {
      'isRoom': true,
      'chatData': Provider.of<RoomChatLobby>(context, listen: false)
          .getChat(curr, lobby),
    },);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                        Future.delayed(const Duration(milliseconds: 100), () {
                          Navigator.pop(context);
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: Material(
                      color: Colors.white,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color(0xFFF5F5F5),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        height: 40,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.search,
                                color:
                                    Theme.of(context).textTheme.bodyLarge.color,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _searchBoxFilter,
                                  autofocus: true,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Type text...',
                                  ),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // ),
                ],
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: (appBarHeight - 40) / 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AnimatedBuilder(
                      animation: _tabController.animation,
                      builder: (BuildContext context, Widget widget) {
                        return GestureDetector(
                          onTap: () {
                            _tabController.animateTo(0);
                          },
                          child: Container(
                            width: 2 * appBarHeight,
                            decoration: BoxDecoration(
                              color: _leftTabIconColor.value,
                              borderRadius:
                                  BorderRadius.circular(appBarHeight / 2),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Center(
                                child: Text(
                                  'Chats',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    AnimatedBuilder(
                      animation: _tabController.animation,
                      builder: (BuildContext context, Widget widget) {
                        return GestureDetector(
                          onTap: () {
                            _tabController.animateTo(1);
                          },
                          child: Container(
                            width: 2 * appBarHeight,
                            decoration: BoxDecoration(
                              color: _rightTabIconColor.value,
                              borderRadius:
                                  BorderRadius.circular(appBarHeight / 2),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Center(
                                child: Text(
                                  'People',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Stack(
                    key: UniqueKey(),
                    children: <Widget>[
                      _buildChatsList(),
                      Visibility(
                        visible: filteredSubscribedChats.isEmpty ??
                            // ignore: null_aware_in_logical_operator
                            true && filteredPublicChats.isEmpty ??
                            true,
                        child: Center(
                          child: SingleChildScrollView(
                            child: SizedBox(
                              width: 200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                      'assets/icons8/sport-yoga-reading-1.png',),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 25,),
                                    child: Text(
                                      'Nothing was found',
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    key: UniqueKey(),
                    children: <Widget>[
                      _buildPeopleList(),
                      Visibility(
                        visible: (filteredAllIds.isEmpty) &&
                            (filteredContactsIds.isEmpty),
                        child: Center(
                          child: SingleChildScrollView(
                            child: SizedBox(
                              width: 200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                      'assets/icons8/virtual-reality.png',),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 25,),
                                    child: Text(
                                      'Nothing was found',
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatsList() {
    if (_searchContent.isNotEmpty ?? false) {
      final List<Chat> tempChatsList = [];
      for (int i = 0; i < subscribedChats.length; i++) {
        if (subscribedChats[i]
            .chatName
            .toLowerCase()
            .contains(_searchContent.toLowerCase())) {
          tempChatsList.add(subscribedChats[i]);
        }
      }
      filteredSubscribedChats = tempChatsList;

      final List<VisibleChatLobbyRecord> tempList = [];
      for (int i = 0; i < publicChats.length; i++) {
        if (publicChats[i]
            .lobbyName
            .toLowerCase()
            .contains(_searchContent.toLowerCase())) {
          tempList.add(publicChats[i]);
        }
      }
      filteredPublicChats = tempList;
    } else {
      filteredSubscribedChats = subscribedChats;
      filteredPublicChats = publicChats;
    }

    return Visibility(
      visible: filteredSubscribedChats.isNotEmpty ??
          false || filteredPublicChats.isNotEmpty ??
          false,
      child: CustomScrollView(
        slivers: <Widget>[
          sliverPersistentHeader('Subscribed chats', context),
          SliverFixedExtentList(
            itemExtent: personDelegateHeight,
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                // Todo: DRY
                return PersonDelegate(
                  data: PersonDelegateData.ChatData(
                      filteredSubscribedChats[index],),
                  onPressed: () {
                    Navigator.pushNamed(context, '/room', arguments: {
                      'isRoom': true,
                      'chatData': filteredSubscribedChats[index],
                    },);
                  },
                );
              },
              childCount: filteredSubscribedChats.length ?? 0,
            ),
          ),
          sliverPersistentHeader('Public chats', context),
          SliverFixedExtentList(
            itemExtent: personDelegateHeight,
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    _goToChat(filteredPublicChats[index]);
                  },
                  child: PersonDelegate(
                    data: PersonDelegateData.PublicChatData(
                        filteredPublicChats[index],),
                    onPressed: () {
                      _goToChat(filteredPublicChats[index]);
                    },
                  ),
                );
              },
              childCount: filteredPublicChats.length ?? 0,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleContacts(String gxsId, bool type) {
    Provider.of<RoomChatLobby>(context, listen: false)
        .toggleContacts(gxsId, type);
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  Widget _buildPeopleList() {
    if (_searchContent.isNotEmpty) {
      final List<Identity> tempContactsList = [];
      for (int i = 0; i < contactsIds.length; i++) {
        if (contactsIds[i]
            .name
            .toLowerCase()
            .contains(_searchContent.toLowerCase())) {
          tempContactsList.add(contactsIds[i]);
        }
      }
      filteredContactsIds = tempContactsList;

      final List<Identity> tempList = [];
      for (int i = 0; i < allIds.length; i++) {
        if (allIds[i]
            .name
            .toLowerCase()
            .contains(_searchContent.toLowerCase())) {
          tempList.add(allIds[i]);
        }
      }
      filteredAllIds = tempList;
    } else {
      filteredContactsIds = contactsIds;
      filteredAllIds = allIds;
    }

    return Visibility(
//      visible: (filteredAllIds?.isNotEmpty
//?? false || filteredContactsIds.isNotEmpty ),
      visible: (filteredAllIds.isNotEmpty) ||
          (filteredContactsIds.isNotEmpty),
      child: CustomScrollView(
        slivers: <Widget>[
          sliverPersistentHeader('Contacts', context),
          SliverFixedExtentList(
            itemExtent: personDelegateHeight,
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return GestureDetector(
                  onTapDown: _storePosition,
                  // Todo: DRY
                  child: PersonDelegate(
                    data: PersonDelegateData.IdentityData(
                        filteredContactsIds[index], context,),
                    onLongPress: (Offset tapPosition) {
                      showCustomMenu(
                          'Remove from contacts',
                          const Icon(
                            Icons.delete,
                            color: Colors.black,
                          ),
                          () =>
                              _toggleContacts(filteredAllIds[index].mId, false),
                          tapPosition,
                          context,);
                    },
                    onPressed: () {
                      final curr =
                          Provider.of<Identities>(context, listen: false)
                              .currentIdentity;
                      Navigator.pushNamed(
                        context,
                        '/room',
                        arguments: {
                          'isRoom': false,
                          'chatData':
                              Provider.of<RoomChatLobby>(context, listen: false)
                                  .getChat(curr, filteredContactsIds[index]),
                        },
                      );
                    },
                  ),
                );
              },
              childCount: filteredContactsIds.length ?? 0,
            ),
          ),
          sliverPersistentHeader('People', context),
          SliverFixedExtentList(
            itemExtent: personDelegateHeight,
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return GestureDetector(
                  onTapDown: _storePosition,
                  // Todo: DRY
                  child: PersonDelegate(
                    data: PersonDelegateData.IdentityData(
                        filteredAllIds[index], context,),
                    onLongPress: (Offset tapPosition) {
                      showCustomMenu(
                          'Add to contacts',
                          const Icon(
                            Icons.person_add,
                            color: Colors.black,
                          ),
                          () =>
                              _toggleContacts(filteredAllIds[index].mId, true),
                          tapPosition,
                          context,);
                    },
                    onPressed: () {
                      final curr =
                          Provider.of<Identities>(context, listen: false)
                              .currentIdentity;
                      Navigator.pushNamed(
                        context,
                        '/room',
                        arguments: {
                          'isRoom': false,
                          'chatData':
                              Provider.of<RoomChatLobby>(context, listen: false)
                                  .getChat(curr, filteredAllIds[index]),
                        },
                      );
                    },
                  ),
                );
              },
              childCount: filteredAllIds.length ?? 0,
            ),
          ),
        ],
      ),
    );
  }
}
