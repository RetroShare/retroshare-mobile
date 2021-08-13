import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/notifications.dart';
import 'package:retroshare/provider/auth.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';
import 'package:share/share.dart';

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
    check = true;
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
    final authToken =
        Provider.of<AccountCredentials>(context, listen: false).authtoken;
    if (!check)
      ownCert = (await RsPeers. getOwnCert(authToken)).replaceAll("\n", "");
    else
      ownCert = (await RsPeers. getShortInvite(authToken));
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
                    style: GoogleFonts.oxygen(
                        textStyle:
                            TextStyle(fontSize: 12, color: Colors.black)),
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
                  style: GoogleFonts.oxygen(
                      textStyle: TextStyle(
                    fontSize: 12,
                  )),
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
            check ? tabController.animateTo(0) : tabController.animateTo(1);
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
