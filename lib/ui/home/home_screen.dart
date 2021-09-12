
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/apiUtils/eventsource.dart';
import 'package:retroshare/common/drawer.dart';
import 'package:retroshare/provider/auth.dart';
import 'package:retroshare/provider/room.dart';
import 'package:retroshare/provider/subscribed.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:retroshare/ui/home/chats_tab.dart';
import 'package:retroshare/ui/home/friends_tab.dart';
import 'package:retroshare/common/styles.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TabController _tabController;
  PanelController _panelController;
  Animation<Color> _leftIconAnimation;
  Animation<Color> _rightIconAnimation;
  Animation<Color> shadowColor;
  bool isfetch = true;
  AnimationController _animationController;
  var _isInit = true;
  var _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    _isInit = true;
    _tabController = TabController(vsync: this, length: 2);
    _panelController = PanelController();

    _leftIconAnimation =
        ColorTween(begin: Colors.lightBlueAccent, end: Colors.black12)
            .animate(_tabController.animation);

    _rightIconAnimation =
        ColorTween(begin: Colors.black12, end: Colors.lightBlueAccent)
            .animate(_tabController.animation);

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    isfetch = true;
    shadowColor = ColorTween(
      begin: const Color.fromRGBO(0, 0, 0, 0),
      end: Colors.black12,
    ).animate(_animationController);
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<ChatLobby>(context, listen: false).fetchAndUpdate().then((_) {
        Provider.of<RoomChatLobby>(context, listen: false)
            .fetchAndUpdate()
            .then((_) {
          final authToken =
              Provider.of<AccountCredentials>(context, listen: false).authtoken;
          registerChatEvent(context, authToken).then((_) {
            setState(() {
              _isLoading = false;
            });
          });
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> fetchdata(BuildContext context) async {
    await Provider.of<ChatLobby>(context, listen: false).fetchAndUpdate();
    await Provider.of<RoomChatLobby>(context, listen: false).fetchAndUpdate();
  }

  @override
  void dispose() {
    _tabController.dispose();

    _animationController.dispose();
    super.dispose();
  }

  Widget getLeftIconBuilder(BuildContext context, Widget widget) {
    return Icon(FontAwesomeIcons.facebookMessenger,
        color: _leftIconAnimation.value, size: 30);
  }

  Widget getRightIconBuilder(BuildContext context, Widget widget) {
    return Icon(FontAwesomeIcons.userFriends,
        color: _rightIconAnimation.value, size: 30);
  }

  Widget _appBar(height) => PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, height + 80),
        child: Stack(
          children: <Widget>[
            Container(
              height: height + 75,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[
                    Color(0xFF00FFFF),
                    Color(0xFF29ABE2),
                  ],
                  begin: Alignment(-1.0, -4.0),
                  end: Alignment(1.0, 4.0),
                ),
                color: Theme.of(context).primaryColor,
              ),
              // Background
              child: const Center(
                child: Text(
                  'Retroshare',
                  style: TextStyle(
                      fontSize: 25.0,
                      fontFamily: 'Vollkorn',
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
            Container(), // Required some widget in between to float AppBar
            Positioned(
              // To take AppBar Size only
              top: 100.0,
              left: 20.0,
              right: 20.0,
              child: AppBar(
                backgroundColor: Colors.white,
                leading: InkWell(
                  onTap: () {
                    _scaffoldKey.currentState.openDrawer();
                  },
                  child: Icon(
                    Icons.menu,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                primary: false,
                title: InkWell(
                  onTap: () {
                    Future.delayed(const Duration(milliseconds: 2), () {
                      Navigator.pushNamed(
                        context,
                        '/search',
                        arguments: _tabController.index,
                      ).then((value) async {
                        await fetchdata(context);
                      });
                    });
                  },
                  child: const SizedBox(
                      width: double.maxFinite,
                      child: Text(
                        'Search',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                        textAlign: TextAlign.start,
                      )),
                ),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.search,
                        color: Theme.of(context).primaryColor),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/search',
                        arguments: _tabController.index,
                      );
                    },
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                    child: InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed('/notification')
                              .then((value) {
                            if (value == true) {
                              fetchdata(context);
                            }
                          });
                        },
                        child: NotificationIcon()),
                  )
                ],
              ),
            )
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      onDrawerChanged: (val) async {
        if (!val) {
          await fetchdata(context);
        }
      },
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      drawer: drawerWidget(context),
      appBar: _appBar(AppBar().preferredSize.height),
      body: Stack(children: [
        TabBarView(
          controller: _tabController,
          children: [
            ChatsTab(),
            FriendsTab(),
          ],
        ),
        if (_isLoading)
          Center(
            child: Card(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                width: 200,
                height: 100,
                child: Center(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.purple,
                    ),
                    const Text(
                      'Loading ..',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontFamily: 'Oxygen'),
                    )
                  ],
                )),
              ),
            ),
          )
      ]),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 7,
        child: Stack(
          children: <Widget>[
            SizedBox(
              height: homeScreenBottomBarHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _tabController.animateTo(0);
                      },
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            AnimatedBuilder(
                              animation: _tabController.animation,
                              builder: getLeftIconBuilder,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 74),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _tabController.animateTo(1);
                      },
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            AnimatedBuilder(
                              animation: _tabController.animation,
                              builder: getRightIconBuilder,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _panelController.close,
              child: Opacity(
                opacity: _animationController.value * 0.5,
                child: Container(
                  height: 50,
                  color:
                      _animationController.value == 0.0 ? null : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        height: 60,
        width: 60,
        child: FittedBox(
          child: FloatingActionButton(
            backgroundColor: Colors.lightBlueAccent,
            onPressed: () {
              Navigator.pushNamed(context, '/create_room');
            },
            child: const Icon(
              Icons.add,
              size: 35,
              color: Colors.white,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
