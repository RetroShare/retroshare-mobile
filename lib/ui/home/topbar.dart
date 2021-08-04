import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/provider/Idenity.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:retroshare/common/button.dart';
import 'package:retroshare/common/styles.dart';

import 'dart:convert';

class TopBar extends StatefulWidget {
  final double maxHeight;
  final double minHeight;
  final double panelAnimationValue;
  final TabController tabController;
  final PanelController panelController;

  TopBar(
      {Key key,
      this.maxHeight,
      this.minHeight,
      this.panelAnimationValue,
      this.tabController,
      this.panelController})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> with SingleTickerProviderStateMixin {
  Animation<double> _leftHeaderFadeAnimation;
  Animation<double> _leftHeaderOffsetAnimation;
  Animation<double> _leftHeaderScaleAnimation;
  Animation<double> _rightHeaderFadeAnimation;
  Animation<double> _rightHeaderOffsetAnimation;
  Animation<double> _rightHeaderScaleAnimation;

  Animation<double> _headerFadeAnimation;
  Animation<double> _nameHeaderFadeAnimation;

  AnimationController _animationController;
  CurvedAnimation _curvedAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
    _curvedAnimation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeInCubic);

    _animationController.value = getPanelAnimationValue;

    _leftHeaderFadeAnimation = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(widget.tabController.animation);

    _leftHeaderOffsetAnimation = Tween(
      begin: 0.0,
      end: -60.0,
    ).animate(widget.tabController.animation);

    _leftHeaderScaleAnimation = Tween(
      begin: 1.0,
      end: 0.5,
    ).animate(widget.tabController.animation);

    _rightHeaderFadeAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(widget.tabController.animation);

    _rightHeaderOffsetAnimation = Tween(
      begin: 60.0,
      end: 0.0,
    ).animate(widget.tabController.animation);

    _rightHeaderScaleAnimation = Tween(
      begin: 0.5,
      end: 1.0,
    ).animate(widget.tabController.animation);

    _headerFadeAnimation = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(_curvedAnimation);

    _nameHeaderFadeAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.5,
        1.0,
        curve: Curves.easeInCubic,
      ),
    ));
  }

  double get getPanelAnimationValue {
    return widget.panelAnimationValue;
  }

  Widget getHeaderBuilder(BuildContext context, Widget widget) {
    return Container(
      child: FadeTransition(
        opacity: _headerFadeAnimation,
        child: Stack(
          children: <Widget>[
            Transform(
              transform: Matrix4.translationValues(
                _leftHeaderOffsetAnimation.value,
                0.0,
                0.0,
              ),
              child: ScaleTransition(
                scale: _leftHeaderScaleAnimation,
                child: FadeTransition(
                  opacity: _leftHeaderFadeAnimation,
                  child: Container(
                    child: Text(
                      'Chats',
                      style: Theme.of(context).textTheme.title,
                    ),
                  ),
                ),
              ),
            ),
            Transform(
              transform: Matrix4.translationValues(
                _rightHeaderOffsetAnimation.value,
                0.0,
                0.0,
              ),
              child: ScaleTransition(
                scale: _rightHeaderScaleAnimation,
                child: FadeTransition(
                  opacity: _rightHeaderFadeAnimation,
                  child: Container(
                    child: Text(
                      'Friends',
                      style: Theme.of(context).textTheme.title,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _animationController.value = getPanelAnimationValue;

    double heightOfTopBar = widget.minHeight +
        widget.panelAnimationValue *
            (widget.maxHeight - 5 * buttonHeight - widget.minHeight - 20);

    double heightOfNameHeader = 20 * _curvedAnimation.value;

    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            height: widget.minHeight +
                (widget.maxHeight - widget.minHeight) *
                    widget.panelAnimationValue,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Opacity(
                    opacity: widget.panelAnimationValue,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Visibility(
                              visible: widget.panelAnimationValue == null
                                  ? false
                                  : widget.panelAnimationValue > 0.5,
                              child: Button(
                                  name: 'Add friend',
                                  buttonIcon: Icons.person_add,
                                  onPressed: () {
                                    Future.delayed(Duration.zero, () {
                                      Navigator.pushNamed(
                                          context, '/add_friend');
                                    });
                                  }),
                            ),
                            Visibility(
                              visible: widget.panelAnimationValue == null
                                  ? false
                                  : widget.panelAnimationValue > 0.4,
                              child: Button(
                                name: 'Create new identity',
                                buttonIcon: Icons.add,
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/create_identity');
                                },
                              ),
                            ),
                            Visibility(
                              visible: widget.panelAnimationValue == null
                                  ? false
                                  : widget.panelAnimationValue > 0.3,
                              child: Button(
                                name: 'Change identity',
                                buttonIcon: Icons.visibility,
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/change_identity');
                                },
                              ),
                            ),
                            Visibility(
                              child: Button(
                                name: 'Friends locations',
                                buttonIcon: Icons.devices,
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/friends_locations');
                                },
                              ),
                            ),
                            Visibility(
                              child: Button(
                                name: 'Forum',
                                buttonIcon: Icons.info_rounded,
                                onPressed: () {
                                  Navigator.pushNamed(context, '/forum');
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        blurRadius: 10,
                        color: Color.fromRGBO(255, 255, 255, 1.0),
                        spreadRadius: 15,
                      )
                    ],
                  ),
                  height: heightOfTopBar + heightOfNameHeader,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: AnimatedBuilder(
                                  animation: widget.tabController.animation,
                                  builder: getHeaderBuilder,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Center(
                                child: Consumer<Identities>(
                                  builder: (context, avatar, _) {
                                    return Container(
                                      width: heightOfTopBar * 0.75,
                                      height: heightOfTopBar * 0.75,
                                      decoration:
                                          (avatar.currentIdentity.avatar ==
                                                  null)
                                              ? null
                                              : BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          heightOfTopBar *
                                                              0.75 *
                                                              0.33),
                                                  image: DecorationImage(
                                                    fit: BoxFit.fitWidth,
                                                    image: MemoryImage(
                                                        base64.decode(avatar
                                                            .currentIdentity
                                                            .avatar)),
                                                  ),
                                                ),
                                      child: Visibility(
                                        visible:
                                            (avatar.currentIdentity?.avatar ==
                                                null),
                                        child: Center(
                                          child: Icon(
                                            Icons.person,
                                            size: heightOfTopBar * 0.75,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: widget.panelController.isPanelOpen()
                                        ? widget.panelController.close
                                        : widget.panelController.open,
                                    child: AnimatedIcon(
                                        icon: AnimatedIcons.menu_close,
                                        progress: _curvedAnimation,
                                        size: 30),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        AnimatedBuilder(
                          animation: _curvedAnimation,
                          builder: (BuildContext context, Widget widget) {
                            return Consumer<Identities>(
                              builder: (context, idName, _) {
                                return Center(
                                  child: Container(
                                    height: heightOfNameHeader * 2,
                                    child: Center(
                                      child: ScaleTransition(
                                        scale: _curvedAnimation,
                                        child: FadeTransition(
                                          opacity: _nameHeaderFadeAnimation,
                                          child: Text(
                                            idName.currentIdentity.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .title,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*Future<bool> exportIdentityFunc(BuildContext context) async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  final id = Provider.of<AccountCredentials>(context, listen: false)
      .lastAccountUsed
      .pgpId;
  String appDocPath = appDocDir.path + '/$id.txt';

// for a file
  bool check = File("$appDocPath").existsSync();
  File entry = File("$appDocPath");
  print(appDocPath);
  if (check) {
    await entry.writeAsStringSync('');
  }
  String data = await exportIdentity(id);
  try {
    await entry.writeAsString(data);
  } catch (e) {
    print(e);
    return false;
  }
  return true;
}*/
