import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/drawer.dart';
import 'package:retroshare/provider/friends_identity.dart';
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
  AnimationController _animationController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
    Provider.of<FriendsIdentity>(context, listen: false).fetchAndUpdate();
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

  _appBar(height) => PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, height + 80),
        child: Stack(
          children: <Widget>[
            Container(
              // Background
              child: Center(
                child: Text(
                  "Retroshare",
                  style: TextStyle(
                      fontSize: 25.0,
                      fontFamily: "Vollkorn",
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                            colors: <Color>[
                              Color(0xFF00FFFF),
                              Color(0xFF29ABE2),
                            ],
                            begin: Alignment(-1.0, -4.0),
                            end: Alignment(1.0, 4.0),
                          ),
                          color: Theme.of(context).primaryColor,
              ),
              
              height: height + 75,
              width: MediaQuery.of(context).size.width,
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
                  child: Icon(
                    Icons.menu,
                    color: Theme.of(context).primaryColor,
                  ),
                  onTap: () {
                    _scaffoldKey.currentState.openDrawer();
                  },
                ),
                
                primary: false,
                title: TextField(
                  onTap: (){
                    Future.delayed(const Duration(milliseconds: 100), () {
                        Navigator.pushNamed(
                          context,
                          '/search',
                          arguments: _tabController.index,
                        );
                      });
                  },
                    decoration: InputDecoration(
                        hintText: "Search",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey))),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.search,
                        color: Theme.of(context).primaryColor),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.notifications,
                        color: Theme.of(context).primaryColor),
                    onPressed: () {},
                  )
                ],
              ),
            )
          ],
        ),
      );

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
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      drawer: drawerWidget(context),
      appBar: _appBar(AppBar().preferredSize.height),
      body: TabBarView(
        controller: _tabController,
        children: [
          ChatsTab(),
          FriendsTab(),
        ],
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
