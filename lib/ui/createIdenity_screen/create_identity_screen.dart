import 'package:flutter/material.dart';
import 'package:retroshare/common/drawer.dart';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare/ui/createIdenity_screen/create_signed_identity.dart';
import 'package:retroshare/ui/createIdenity_screen/pseudo_identity.dart';

class CreateIdentityScreen extends StatefulWidget {
  const CreateIdentityScreen({Key key, this.isFirstId = false})
      : super(key: key);
  final bool isFirstId;

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
    _tabController =
        TabController(vsync: this, length: widget.isFirstId ? 1 : 2);
    _leftTabIconColor =
        ColorTween(begin: const Color(0xFFF5F5F5), end: Colors.white)
            .animate(_tabController.animation);
    _rightTabIconColor =
        ColorTween(begin: Colors.white, end: const Color(0xFFF5F5F5))
            .animate(_tabController.animation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: appBar('Create Identity', context),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: (appBarHeight - 40) / 2,
                  top: 20,
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
                                  'Signed Identity',
                                  overflow: TextOverflow.ellipsis,
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
                                  ' Pseudo Identity',
                                  overflow: TextOverflow.ellipsis,
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
                  SignedIdenityTab(widget.isFirstId, UniqueKey()),
                  if (!widget.isFirstId)
                    PseudoSignedIdenityTab(widget.isFirstId, UniqueKey()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
