import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/button.dart';
import 'package:retroshare/common/color_loader_3.dart';
import 'package:retroshare/common/notifications.dart';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare/common/bottom_bar.dart';
import 'package:retroshare/provider/auth.dart';
import 'package:retroshare/provider/friendLocation.dart';
import 'package:retroshare/services/account.dart';
import 'package:retroshare/ui/Qr_scanner_screen.dart';
import 'package:share/share.dart';
import 'Update_idenity_screen.dart';

class AddFriendScreen extends StatefulWidget {
  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  TextEditingController newCertController = TextEditingController();
  String ownCert;
  TextEditingController ownCertController = TextEditingController();
  bool type = false;

  bool _requestAddCert = false;

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
              left: Constants.padding,
              top: Constants.avatarRadius,
              right: Constants.padding,
              bottom: Constants.padding),
          margin: EdgeInsets.only(top: Constants.avatarRadius),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.padding),
              boxShadow: [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'something went Wrong!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 15,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "OK",
                      style: TextStyle(fontSize: 14),
                    )),
              ),
            ],
          ),
        ),
        Positioned(
          left: Constants.padding,
          right: Constants.padding,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: Constants.avatarRadius,
            child: ClipRRect(
              borderRadius:
                  BorderRadius.all(Radius.circular(Constants.avatarRadius)),
              child: Image(
                image: AssetImage('assets/rs-logo.png'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    child: Text(
                      'Add friend',
                      style: Theme.of(context).textTheme.body2,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Stack(children: [
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        maxLines: 10,
                        minLines: 6,
                        controller: newCertController,
                        style: TextStyle(
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                            prefix: SizedBox(
                              width: 10,
                            ),
                            labelStyle: TextStyle(fontSize: 12),
                            hintText: 'Paste your friend\'s invite here',
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(6))),
                      ),
                      SizedBox(height: 10),
                      FlatButton(
                        onPressed: () async {
                          setState(() {
                            _requestAddCert = true;
                          });
                          Provider.of<FriendLocations>(context, listen: false)
                              .addFriendLocation(newCertController.text)
                              .then((value) {
                            setState(() {
                              _requestAddCert = false;
                            });
                            Fluttertoast.cancel();
                            value
                                ? Fluttertoast.showToast(
                                    msg: "Friend has been added",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0)
                                : Fluttertoast.showToast(
                                    msg: "Something went wrong",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                          });
                        },
                        textColor: Colors.white,
                        padding: const EdgeInsets.all(0.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: LinearGradient(
                                colors: <Color>[
                                  Color(0xFF00FFFF),
                                  Color(0xFF29ABE2),
                                ],
                                begin: Alignment(-1.0, -4.0),
                                end: Alignment(1.0, 4.0),
                              ),
                            ),
                            padding: const EdgeInsets.all(10.0),
                            child: const Text(
                              'Add Friend',
                              style: TextStyle(fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: Text(
                            "OR",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).push(new MaterialPageRoute(
                              builder: (_) => QRScanner()));
                        },
                        textColor: Colors.white,
                        padding: const EdgeInsets.all(0.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: LinearGradient(
                                colors: <Color>[
                                  Color(0xFF00FFFF),
                                  Color(0xFF29ABE2),
                                ],
                                begin: Alignment(-1.0, -4.0),
                                end: Alignment(1.0, 4.0),
                              ),
                            ),
                            padding: const EdgeInsets.all(10.0),
                            child: const Text(
                              'Add Friend via QR',
                              style: TextStyle(fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      GetInvite(),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Visibility(
                    visible: _requestAddCert,
                    child: ColorLoader3(
                      radius: 15.0,
                      dotRadius: 6.0,
                    ),
                  ),
                )
              ]),
            ))
          ])),
    );
  }
}

class GetInvite extends StatefulWidget {
  GetInvite({Key key, this.settype}) : super(key: key);

  final settype;

  @override
  _GetInviteState createState() => _GetInviteState();
}

class _GetInviteState extends State<GetInvite> with TickerProviderStateMixin {
  bool check;
  TextEditingController ownCertController = TextEditingController();
  TabController tabController;

  Animation<double> _leftHeaderFadeAnimation;
  Animation<double> _leftHeaderScaleAnimation;
  Animation<double> _rightHeaderFadeAnimation;
  Animation<double> _rightHeaderScaleAnimation;

  @override
  void initState() {
    super.initState();
    check = false;
    tabController = TabController(vsync: this, length: 2);

    _leftHeaderFadeAnimation = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(tabController.animation);

    _leftHeaderScaleAnimation = Tween(
      begin: 1.0,
      end: 0.5,
    ).animate(tabController.animation);

    _rightHeaderFadeAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(tabController.animation);

    _rightHeaderScaleAnimation = Tween(
      begin: 0.5,
      end: 1.0,
    ).animate(tabController.animation);
  }

  Future<String> _getCert() async {
    String ownCert;
    if (!check)
      ownCert = (await getOwnCert()).replaceAll("\n", "");
    else
      ownCert = (await getShortInvite()).replaceAll("\n", "");
    Future.delayed(Duration(milliseconds: 60));
    return ownCert;
  }

  Widget getHeaderBuilder() {
    return Container(
      child: Stack(
        children: <Widget>[
          ScaleTransition(
            scale: _leftHeaderScaleAnimation,
            child: FadeTransition(
              opacity: _leftHeaderFadeAnimation,
              child: Container(
                child: Text(
                  'Short Invite',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
          ),
          ScaleTransition(
            scale: _rightHeaderScaleAnimation,
            child: FadeTransition(
              opacity: _rightHeaderFadeAnimation,
              child: Container(
                child: Text(
                  'Long Invite',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getinvitelink() {
    return FutureBuilder(
        future: _getCert(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            String val = snapshot.data;
            ownCertController.text = val;
            return Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Opacity(
                  opacity: .2,
                  child: TextFormField(
                    key: UniqueKey(),
                    readOnly: true,
                    initialValue: val,
                    maxLines: 10,
                    minLines: 10,
                    style: TextStyle(
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                        prefix: SizedBox(
                          width: 10,
                        ),
                        filled: true,
                        fillColor: Colors.black.withOpacity(.2),
                        labelStyle: TextStyle(fontSize: 12),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(6))),
                  ),
                ),
                Container(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () async {
                          await Clipboard.setData(
                              ClipboardData(text: ownCertController.text));
                          await showInviteCopyNotification();
                        },
                        icon: Icon(
                          Icons.copy,
                          color: Colors.blueAccent[200],
                        )),
                    Text(
                      "Tap to copy",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent),
                    ),
                  ],
                ))
              ],
            );
          }
          return Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Opacity(
                opacity: .2,
                child: TextFormField(
                  readOnly: true,
                  initialValue: ownCertController.text,
                  maxLines: 10,
                  minLines: 10,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                      prefix: SizedBox(
                        width: 10,
                      ),
                      labelStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(6))),
                ),
              ),
              snapshot.connectionState == ConnectionState.waiting
                  ? Container(
                      child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () async {}, icon: Icon(Icons.refresh)),
                        Text(
                          "Loading",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent),
                        ),
                      ],
                    ))
                  : Container(
                      child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () async {},
                            icon: Icon(
                              Icons.error,
                              color: Colors.grey,
                            )),
                        Text("something went wrong !",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                      ],
                    ))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          value: check,
          title: getHeaderBuilder(),
          onChanged: (newval) {
            setState(() {
              check = newval;
            });
            if (check)
              tabController.animateTo(0);
            else
              tabController.animateTo(1);
          },
        ),
        SizedBox(height: 10),
        getinvitelink(),
        SizedBox(height: 20),
        FlatButton(
          onPressed: () async {
            Share.share(ownCertController.text);
          },
          textColor: Colors.white,
          padding: const EdgeInsets.all(0.0),
          child: SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: <Color>[
                    Color(0xFF00FFFF),
                    Color(0xFF29ABE2),
                  ],
                  begin: Alignment(-1.0, -4.0),
                  end: Alignment(1.0, 4.0),
                ),
              ),
              padding: const EdgeInsets.all(10.0),
              child: const Text(
                'Tap to Share',
                style: TextStyle(fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        )
      ],
    );
  }
}
