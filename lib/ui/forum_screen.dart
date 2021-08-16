import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:retroshare/common/styles.dart';

class ForumScreen extends StatefulWidget {
  @override
  _ForumScreenState createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  @override
  void initState() {
    // TODO: implement initState

    _tabController = TabController(vsync: this, length: 4, initialIndex: 0);
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: Scaffold(
          endDrawerEnableOpenDragGesture: false,
          backgroundColor: Colors.white,
          body: SafeArea(
              top: true,
              bottom: true,
              child: Column(children: <Widget>[
                Container(
                  height: appBarHeight,
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: personDelegateHeight,
                        child: Visibility(
                          child: Center(
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
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Forum',
                          style: Theme.of(context).textTheme.body2,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                          onPressed: () {
                            scaffoldKey.currentState.openDrawer();
                          },
                          icon: Icon(Icons.add))
                    ],
                  ),
                ),
                Material(
                  color: Colors.white,
                  child: GestureDetector(
                    onTap: () {
                      Future.delayed(const Duration(milliseconds: 100), () {
                        Navigator.pushNamed(
                          context,
                          '/search',
                        );
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
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
                                    .copyWith(
                                        color: Theme.of(context).hintColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                    child: TabBarView(controller: _tabController, children: [
                  AllForums(),
                  AllForums(),
                  AllForums(),
                  AllForums()
                ]))
              ]))),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 15,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        currentIndex: _tabController.index,
        backgroundColor: Colors.white,
        selectedLabelStyle: GoogleFonts.oxygen(
            textStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        )),
        onTap: (int curr) {
          _tabController.animateTo(curr);
          setState(() {});
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.all_inbox, color: Colors.black12),
              label: "My Forum",
              activeIcon: Icon(
                Icons.all_inbox_rounded,
                size: 28,
                color: Colors.blueAccent,
              )),
          BottomNavigationBarItem(
              icon: Icon(Icons.emoji_symbols_rounded, color: Colors.black12),
              label: "Subscribed",
              activeIcon: Icon(Icons.emoji_symbols_rounded,
                  size: 28, color: Colors.blueAccent)),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.public,
                color: Colors.black12,
              ),
              label: "Popular",
              activeIcon:
                  Icon(Icons.public, size: 28, color: Colors.blueAccent)),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.podcasts,
                color: Colors.black12,
              ),
              label: "Discovery",
              activeIcon:
                  Icon(Icons.podcasts, size: 28, color: Colors.blueAccent)),
        ],
      ),
    );
  }
}

class AllForums extends StatefulWidget {
  @override
  _AllForumsState createState() => _AllForumsState();
}

class _AllForumsState extends State<AllForums> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                elevation: 12,
                shadowColor: Colors.black26,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 130,
                    constraints: BoxConstraints(maxHeight: 200),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Container(
                              alignment: Alignment.center,
                              width: 90,
                              height: 110,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 2,
                                      color: Colors.black,
                                      style: BorderStyle.solid),
                                  borderRadius: BorderRadius.circular(13)),
                              child: Center(
                                  child: FaIcon(
                                FontAwesomeIcons.megaport,
                                color: Colors.blue,
                              )),
                            ),
                            title: Text("Test1",
                                style: TextStyle(fontFamily: "Oxygen")),
                            subtitle: Text(
                                "Lorem Ipsum is simply dummy text of the printing and typesetting industry."),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              FlatButton(
                                  onPressed: () {},
                                  child: Text(
                                    "Unsubscribed",
                                    style: TextStyle(
                                        fontFamily: "Abel",
                                        fontWeight: FontWeight.w600),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
