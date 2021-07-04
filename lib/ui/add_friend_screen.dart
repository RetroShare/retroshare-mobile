import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

import 'UpdateIdenityScreen.dart';

class AddFriendScreen extends StatefulWidget {
  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  TextEditingController ownCertController = TextEditingController();
  TextEditingController newCertController = TextEditingController();

  String ownCert;
  bool _requestAddCert = false;

  Future<String> _getCert() async {
    ownCert = (await getShortInvite());
    return ownCert;
  }

  _showCertDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Your RetroShare invite"),
            content: Container(
              height: 300,
              child: Column(
                children: <Widget>[
                  Button(
                    name: 'Copy to clipboard',
                    buttonIcon: Icons.content_copy,
                    onPressed: () async {
                      await Clipboard.setData(
                          ClipboardData(text: ownCertController.text));
                      await showInviteCopyNotification();
                    },
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: TextField(
                        readOnly: true,
                        controller: ownCertController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(border: InputBorder.none),
                        style: Theme.of(context).textTheme.body2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final loggedinAccount =
        Provider.of<AccountCredentials>(context, listen: false).loggedinAccount;
    return Scaffold(
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
                  child: FutureBuilder(
                      future: _getCert(),
                      builder: (context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          ownCertController.text = ownCert;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  /*Padding(
                                    padding: const EdgeInsets.only(bottom: 15.0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "About me:",
                                        style: TextStyle(fontSize: 20.0),
                                      ),
                                    ),
                                  ),
                                   PersonDelegate(
                                    data: PersonDelegateData(
                                      name: loggedinAccount.pgpName +
                                          ':' +
                                          loggedinAccount.locationName,
                                      message: loggedinAccount.pgpId +
                                          ':' +
                                          loggedinAccount.locationId,
                                      isOnline: true,
                                      isMessage: true,
                                    ),
                                  ),*/
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 15.0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "1. Share your RetroShare invite",
                                        style: TextStyle(fontSize: 20.0),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 15.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 2,
                                                color: Colors.black87),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    5.0) //         <--- border radius here
                                                ),
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.share,
                                            ),
                                            iconSize: 45.0,
                                            color: Colors.black87,
                                            onPressed: () {
                                              Share.share(ownCert);
                                            },
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 2,
                                                color: Colors.black87),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    5.0) //         <--- border radius here
                                                ),
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.remove_red_eye,
                                            ),
                                            iconSize: 45.0,
                                            color: Colors.black87,
                                            onPressed: () {
                                              _showCertDialog();
                                            },
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 2,
                                                color: Colors.black87),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    5.0) //         <--- border radius here
                                                ),
                                          ),
                                          child: IconButton(
                                            icon: Icon(Icons.document_scanner),
                                            iconSize: 45.0,
                                            color: Colors.black87,
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                  new MaterialPageRoute(
                                                      builder: (_) => QRScanner(
                                                          qr_data:
                                                              ownCertController
                                                                  .text)));
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "2. Paste your friends invite here",
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Color(0xFFF5F5F5),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Color(0xFFF5F5F5),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: TextField(
                                        controller: newCertController,
                                        keyboardType: TextInputType.multiline,
                                        maxLines: null,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText:
                                                'Paste your friend\'s invite here'),
                                        style:
                                            Theme.of(context).textTheme.body2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          /*showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(Constants.padding),
                                ),
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                child: contentBox(context),
                              );
                            },
                          );*/
                        }

                        return Center(
                          child: ColorLoader3(
                            radius: 15.0,
                            dotRadius: 6.0,
                          ),
                        );
                      })),
              Visibility(
                visible: !_requestAddCert,
                child: BottomBar(
                  child: Center(
                    child: SizedBox(
                      height: 2 * appBarHeight / 3,
                      child: FlatButton(
                        onPressed: () async {
                          if (newCertController != null &&
                              newCertController.text.length > 0) {
                            setState(() {
                              _requestAddCert = true;
                            });
                            bool success = await Provider.of<FriendLocations>(
                                    context,
                                    listen: false)
                                .addFriendLocation(newCertController.text);
                            if (success) Navigator.pop(context);
                          } else
                            showToast(
                                'An error occurred while adding your friend.');
                        },
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0 + personDelegateHeight * 0.04),
                        child: SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
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
                            child: Text(
                              'Add friend',
                              style: Theme.of(context).textTheme.button,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: _requestAddCert,
                child: ColorLoader3(
                  radius: 15.0,
                  dotRadius: 6.0,
                ),
              )
            ],
          ),
        ));
  }

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
}
