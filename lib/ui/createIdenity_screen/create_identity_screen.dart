import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare/ui/createIdenity_screen/create_signed_identity.dart';
import 'package:retroshare/ui/createIdenity_screen/pseudo_identity.dart';

class CreateIdentityScreen extends StatefulWidget {
  CreateIdentityScreen({Key key, this.isFirstId = false}) : super(key: key);
  final isFirstId;

  @override
  _CreateIdentityScreenState createState() => _CreateIdentityScreenState();
}

class _CreateIdentityScreenState extends State<CreateIdentityScreen>
    with SingleTickerProviderStateMixin {
  Animation<Color> _leftTabIconColor;
  Animation<Color> _rightTabIconColor;
  TabController _tabController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(vsync: this, length: 2, initialIndex: 0);
    _leftTabIconColor = ColorTween(begin: Color(0xFFF5F5F5), end: Colors.white)
        .animate(_tabController.animation);
    _rightTabIconColor = ColorTween(begin: Colors.white, end: Color(0xFFF5F5F5))
        .animate(_tabController.animation);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(!widget.isFirstId);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: SafeArea(
          top: true,
          bottom: true,
          child: Column(
            children: <Widget>[
              Container(
                height: appBarHeight,
                child: Row(
                  children: <Widget>[
                    Visibility(
                      visible: !widget.isFirstId,
                      child: Container(
                        width: personDelegateHeight,
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
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: widget.isFirstId
                                ? 16.0 + personDelegateHeight * 0.04
                                : 0.0),
                        child: Text(
                          'Create identity',
                          style: Theme.of(context).textTheme.body2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Padding(
                  padding: EdgeInsets.only(
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
                                padding: EdgeInsets.all(8),
                                child: Center(
                                  child: Text(
                                    'Pseudo Identity',
                                    style: Theme.of(context).textTheme.body2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(
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
                                padding: EdgeInsets.all(8),
                                child: Center(
                                  child: Text(
                                    'Signed Identity',
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.body2,
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
                  child: TabBarView(controller: _tabController, children: [
                PseudoSignedIdenityTab(widget.isFirstId, UniqueKey()),
                SignedIdenityTab(widget.isFirstId, UniqueKey())
              ])),
            ],
          ),
        ),
      ),
    );
  }
}
