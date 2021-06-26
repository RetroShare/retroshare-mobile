import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/provider/FriendsIdentity.dart';
import 'package:retroshare/provider/room.dart';
import 'package:retroshare/provider/subscribed.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:retroshare/ui/home/topbar.dart';
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
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _panelController = PanelController();
    _leftIconAnimation =
        ColorTween(begin: Colors.lightBlueAccent, end: Colors.black12)
            .animate(_tabController.animation);

    _rightIconAnimation =
        ColorTween(begin: Colors.black12, end: Colors.lightBlueAccent)
            .animate(_tabController.animation);

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    shadowColor = ColorTween(
      begin: Color.fromRGBO(0, 0, 0, 0),
      end: Colors.black12,
    ).animate(_animationController);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<ChatLobby>(context, listen: false).fetchAndUpdate();
      Provider.of<FriendsIdentity>(context, listen: false).fetchAndUpdate();
      registerChatEvent(context);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget getLeftIconBuilder(BuildContext context, Widget widget) {
    return Icon(Icons.chat_bubble_outline,
        color: _leftIconAnimation.value, size: 30);
  }

  Widget getRightIconBuilder(BuildContext context, Widget widget) {
    return Icon(Icons.people_outline,
        color: _rightIconAnimation.value, size: 30);
  }

  Widget _body(double topBarMinHeight) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: topBarMinHeight,
        ),
        /*Hero(
          tag: 'search_box',
          child:*/
        Material(
          color: Colors.white,
          child: GestureDetector(
            onTap: () {
              Future.delayed(const Duration(milliseconds: 100), () {
                Navigator.pushNamed(
                  context,
                  '/search',
                  arguments: _tabController.index,
                );
              });
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Color(0xFFF5F5F5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              margin: EdgeInsets.symmetric(horizontal: 8),
              height: 40,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.search,
                        color: Theme.of(context).textTheme.body1.color),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        'Type text...',
                        style: Theme.of(context)
                            .textTheme
                            .body2
                            .copyWith(color: Theme.of(context).hintColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        //),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              ChatsTab(),
              FriendsTab(),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final double statusBarHeight = mediaQueryData.padding.top;
    final double screenHeight = mediaQueryData.size.height;
    final double appBarMinHeight = kAppBarMinHeight - statusBarHeight;
    final double appBarMaxHeight = appBarMinHeight +
        (screenHeight - statusBarHeight) * 0.15 +
        5 * buttonHeight +
        20;

    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: true,
        child: SlidingUpPanel(
          controller: _panelController,
          maxHeight: appBarMaxHeight,
          minHeight: kAppBarMinHeight,
          parallaxEnabled: true,
          parallaxOffset: .5,
          body: _body(kAppBarMinHeight),
          panel: TopBar(
            maxHeight: appBarMaxHeight,
            minHeight: kAppBarMinHeight,
            tabController: _tabController,
            panelAnimationValue: _animationController.value,
            panelController: _panelController,
          ),
          slideDirection: SlideDirection.DOWN,
          backdropEnabled: true,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: shadowColor.value,
              blurRadius: 20.0,
              spreadRadius: 5.0,
              offset: Offset(
                0.0,
                15.0,
              ),
            ),
          ],
          padding: EdgeInsets.only(
              bottom: _animationController.value * appBarHeight / 3),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(
                  _animationController.value * appBarHeight / 3),
              bottomRight: Radius.circular(
                  _animationController.value * appBarHeight / 3)),
          onPanelSlide: (double pos) => setState(
            () {
              _animationController.value = pos;
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Stack(
          children: <Widget>[
            Container(
              height: homeScreenBottomBarHeight,
              child: Row(
                mainAxisSize: MainAxisSize.max,
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
                  SizedBox(width: 74),
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
        shape: CircularNotchedRectangle(),
        notchMargin: 7,
      ),
      floatingActionButton: Container(
        height: 60,
        width: 60,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/create_room');
            },
            child: Icon(
              Icons.add,
              size: 35,
              color: Colors.white,
            ),
            backgroundColor: Colors.lightBlueAccent,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
