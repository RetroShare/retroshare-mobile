import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/color_loader_3.dart';
import 'package:retroshare/common/styles.dart';

import 'package:retroshare/provider/friendLocation.dart';

import 'package:retroshare/ui/Qr_scanner_screen.dart';
import 'add_friends_utils.dart';

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
                            Fluttertoast.showToast(
                                msg: value
                                    ? "Friend has been added"
                                    : 'something went Wrong',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
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
