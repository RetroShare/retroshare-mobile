import 'package:flutter/material.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/person_delegate.dart';
import 'package:retroshare/common/show_dialog.dart';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare/provider/Idenity.dart';
import 'package:retroshare/provider/friend_location.dart';
import 'package:retroshare/provider/room.dart';
import 'package:retroshare/provider/subscribed.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';

class CreateRoomScreen extends StatefulWidget {
  @override
  _CreateRoomScreenState createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen>
    with TickerProviderStateMixin {
  final TextEditingController _inviteFriendsController =
      TextEditingController();
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _roomTopicController = TextEditingController();
  bool isPublic;
  bool isAnonymous;

  bool _isRoomCreation;
  bool _blockCreation; //Used to prevent double click on room creation
  Animation<double> _fadeAnimation;
  Animation<double> _heightAnimation;
  Animation<double> _buttonHeightAnimation;
  Animation<double> _buttonFadeAnimation;
  AnimationController _animationController;

  Animation<Color> _doneButtonColor;
  AnimationController _doneButtonController;

  List<Identity> _friendsList;
  List<Identity> _suggestionsList;
  List<Location> _locationsList;
  List<Location> _selectedLocations;
  bool _init = true;
  @override
  void initState() {
    super.initState();
    _init = true;
    _isRoomCreation = false;
    isPublic = true;
    isAnonymous = true;
    _blockCreation = false;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _doneButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _roomNameController.addListener(() {
      if (_isRoomCreation && _roomNameController.text.length > 2) {
        _doneButtonController.forward();
      } else {
        _doneButtonController.reverse();
      }
    });

    _fadeAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.5,
          1.0,
          curve: Curves.easeInOut,
        ),
      ),
    );

    _heightAnimation = Tween(
      begin: 40.0,
      end: 5 * 40.0 + 3 * 8.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _buttonHeightAnimation = Tween(
      begin: personDelegateHeight - 15,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _buttonFadeAnimation = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.0,
          0.75,
          curve: Curves.easeInOut,
        ),
      ),
    );

    _doneButtonColor =
        ColorTween(begin: const Color(0xFF9E9E9E), end: Colors.black).animate(
      CurvedAnimation(
        parent: _doneButtonController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) {
      Provider.of<FriendLocations>(context, listen: false)
          .fetchfriendLocation();
      final identities = Provider.of<RoomChatLobby>(context, listen: false);
      final locations = Provider.of<FriendLocations>(context, listen: false);
      _friendsList = identities.friendsSignedIdsList;
      _suggestionsList = identities.friendsSignedIdsList;
      _locationsList = locations.friendlist;
      _selectedLocations = <Location>[];
    }
    _init = false;
  }

  @override
  void dispose() {
    _inviteFriendsController.dispose();
    _roomNameController.dispose();
    _roomTopicController.dispose();
    _animationController.dispose();
    _doneButtonController.dispose();

    super.dispose();
  }

  void _onGoBack() {
    if (_isRoomCreation) {
      _animationController.reverse();
      setState(() {
        _isRoomCreation = false;
      });
    } else {
      Navigator.pop(context, true);
    }
  }

  Future<void> _createChat() async {
    if (_isRoomCreation && !_blockCreation) {
      _blockCreation = true;
      _doneButtonController.reverse();
      final id =
          Provider.of<Identities>(context, listen: false).currentIdentity.mId;
      try {
        Provider.of<ChatLobby>(context, listen: false)
            .createChatlobby(
          _roomNameController.text,
          id,
          _roomTopicController.text,
          inviteList: _selectedLocations,
          anonymous: isAnonymous,
          public: isPublic,
        )
            .then((value) {
          Navigator.of(context).pop();
        });
      } catch (e) {
        errorShowDialog('Error', 'Try to retart the app!', context);
      }

      _doneButtonController.forward();
      _blockCreation = false;
    }
  }

  void _updateSuggestions(filteredList) {
    setState(() {
      _suggestionsList = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _onGoBack();
        return Future.value(false);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: appBarHeight,
                      width: personDelegateHeight,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 25,
                        ),
                        onPressed: () {
                          _onGoBack();
                        },
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (BuildContext context, Widget widget) {
                            return SizedBox(
                              height: _heightAnimation.value + 10,
                              child: Stack(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: SizedBox(
                                      height: 4 * 40.0 + 3 * 8,
                                      width: double.infinity,
                                      child: FadeTransition(
                                        opacity: _fadeAnimation,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            const SizedBox(
                                              height: 8.0,
                                            ),
                                            Visibility(
                                              visible: _heightAnimation.value >=
                                                  4 * 40.0 + 3 * 8,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  color:
                                                      const Color(0xFFF5F5F5),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 15,
                                                ),
                                                height: 40,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: TextField(
                                                          controller:
                                                              _roomNameController,
                                                          decoration:
                                                              const InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            hintText:
                                                                'Room name',
                                                          ),
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 8.0,
                                            ),
                                            Visibility(
                                              visible: _heightAnimation.value >=
                                                  3 * 40.0 + 3 * 8,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  color:
                                                      const Color(0xFFF5F5F5),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 15,
                                                ),
                                                height: 40,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: TextField(
                                                          controller:
                                                              _roomTopicController,
                                                          decoration:
                                                              const InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            hintText:
                                                                'Room topic',
                                                          ),
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 8.0,
                                            ),
                                            SizedBox(
                                              width: double.infinity,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    isPublic = !isPublic;
                                                  });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      15,
                                                    ),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 2),
                                                  height: 40,
                                                  child: Row(
                                                    children: <Widget>[
                                                      Checkbox(
                                                        value: isPublic,
                                                        onChanged:
                                                            (bool value) {
                                                          setState(() {
                                                            isPublic = value;
                                                          });
                                                        },
                                                      ),
                                                      const SizedBox(width: 3),
                                                      Text(
                                                        'Public',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: double.infinity,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    isAnonymous = !isAnonymous;
                                                  });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      15,
                                                    ),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 2),
                                                  height: 40,
                                                  child: Row(
                                                    children: <Widget>[
                                                      Checkbox(
                                                        value: isAnonymous,
                                                        onChanged:
                                                            (bool value) {
                                                          setState(() {
                                                            isAnonymous = value;
                                                          });
                                                        },
                                                      ),
                                                      const SizedBox(width: 3),
                                                      Text(
                                                        'Accessible to anonymous',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // *********** Start of
                                  // chips input ***********
                                  ChipsInput(
                                    decoration: InputDecoration(
                                      hintText: _isRoomCreation
                                          ? 'Invite friends'
                                          : 'Search',
                                      isDense: true,
                                    ),
                                    findSuggestions: (String query) {
                                      if (query.isNotEmpty) {
                                        final lowercaseQuery =
                                            query.toLowerCase();
                                        // If is room creation,
                                        // open suggestion box and
                                        //find it on locations list
                                        if (_isRoomCreation) {
                                          final results =
                                              _locationsList.where((profile) {
                                            return profile.locationName
                                                    .toLowerCase()
                                                    .contains(
                                                        query.toLowerCase(),) ||
                                                profile.accountName
                                                    .toLowerCase()
                                                    .contains(
                                                      query.toLowerCase(),
                                                    );
                                          }).toList(growable: false)
                                                ..sort(
                                                  (a, b) => a.locationName
                                                      .toLowerCase()
                                                      .indexOf(lowercaseQuery)
                                                      .compareTo(
                                                        b.locationName
                                                            .toLowerCase()
                                                            .indexOf(
                                                              lowercaseQuery,
                                                            ),
                                                      ),
                                                );

                                          return results;
                                        }
                                        // Otherwise the suggestions will
                                        // be on friends list and showed on a
                                        // widget using the
                                        //_updateSuggestions function.
                                        // The suggestion box is not
                                        //open because it
                                        //return always an empty list
                                        final results = _friendsList.where(
                                            (profile) {
                                          return profile.name
                                              .toLowerCase()
                                              .contains(query.toLowerCase());
                                        }).toList(growable: false)
                                          ..sort((a, b) => a.name
                                              .toLowerCase()
                                              .indexOf(lowercaseQuery)
                                              .compareTo(b.name
                                                  .toLowerCase()
                                                  .indexOf(lowercaseQuery),),);
                                        _updateSuggestions(results);
                                        return _isRoomCreation
                                            ? results
                                            : const <Location>[];
                                      } else {
                                        _updateSuggestions(_friendsList);
                                        return const <Location>[];
                                      }
                                    },
                                    onChanged: (data) {},
                                    chipBuilder: (context, state, profile) {
                                      if (!_selectedLocations
                                          .contains(profile)) {
                                        _selectedLocations.add(profile);
                                      }
                                      return InputChip(
                                        key: ObjectKey(profile),
                                        label: Text(profile.accountName),
                                        // avatar: CircleAvatar(
                                        // backgroundImage:
                                        // NetworkImage(profile.imageUrl),
                                        //),
                                        onDeleted: () {
                                          _selectedLocations.removeWhere(
                                            (location) =>
                                                location.rsPeerId ==
                                                profile.rsPeerId,
                                          );
                                          state.deleteChip(profile);
                                        },
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      );
                                    },
                                    suggestionBuilder:
                                        (context, state, profile) {
                                      return Expanded(
                                        child: PersonDelegate(
                                          data: PersonDelegateData.LocationData(
                                            profile,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: appBarHeight,
                      child: AnimatedBuilder(
                        animation: _doneButtonController,
                        builder: (BuildContext context, Widget widget) {
                          return IconButton(
                            icon: const Icon(
                              Icons.done,
                              size: 25,
                            ),
                            color: _doneButtonColor.value,
                            onPressed: () {
                              _createChat();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // ***********  Start of Discover public chats button ***********
              AnimatedBuilder(
                animation: _animationController,
                builder: (BuildContext context, Widget widget) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/discover_chats');
                    },
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 16,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
//                      height: _buttonHeightAnimation.value,
                      child: FadeTransition(
                        opacity: _buttonFadeAnimation,
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              height: _buttonHeightAnimation.value,
                              width: personDelegateHeight,
                              child: Center(
                                child: Icon(
                                  Icons.language,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      .color,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  'Discover public chats',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              // *********** Start of Create new room +
              //friends signed list button ***********
              Expanded(
                child: Stack(
                  children: <Widget>[
                    ListView.builder(
                      padding:
                          const EdgeInsets.only(left: 8, right: 16, bottom: 8),
//                            itemCount: friendsSignedIdsList.length + 1,
                      itemCount: (_suggestionsList == null)
                          ? 1
                          : _suggestionsList.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return AnimatedBuilder(
                            animation: _animationController,
                            builder: (BuildContext context, Widget widget) {
                              return GestureDetector(
                                onTap: () {
                                  _animationController.forward();
                                  setState(() {
                                    _isRoomCreation = true;
                                  });
                                },
                                child: Container(
                                  color: Colors.white,
                                  height: _buttonHeightAnimation.value,
                                  child: FadeTransition(
                                    opacity: _buttonFadeAnimation,
                                    child: Row(
                                      children: <Widget>[
                                        SizedBox(
                                          height: _buttonHeightAnimation.value,
                                          width: personDelegateHeight,
                                          child: Center(
                                            child: Icon(
                                              Icons.add,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  .color,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            child: Text(
                                              'Create new room',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                        index -= 1;
                        // Todo: DRY
                        return PersonDelegate(
                          data: PersonDelegateData.IdentityData(
                            _suggestionsList[index],
                            context,
                          ),
                          onPressed: () {
                            final curr =
                                Provider.of<Identities>(context, listen: false)
                                    .currentIdentity;
                            Navigator.pushNamed(
                              context,
                              '/room',
                              arguments: {
                                'isRoom': false,
                                'chatData': Provider.of<RoomChatLobby>(
                                  context,
                                  listen: false,
                                ).getChat(curr, _suggestionsList[index]),
                              },
                            );
                          },
                        );
                      },
                    ),
                    Visibility(
                      visible: _friendsList.isEmpty ?? false,
                      child: Center(
                        child: SingleChildScrollView(
                          child: SizedBox(
                            width: 200,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  'assets/icons8/list-is-empty-3.png',
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    'Looks like an empty space',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    'You can add friends in the menu',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                    textAlign: TextAlign.center,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
