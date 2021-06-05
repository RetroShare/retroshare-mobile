import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:retroshare/common/button.dart';
import 'package:retroshare/common/color_loader_3.dart';
import 'package:retroshare/common/notifications.dart';
import 'package:retroshare/common/person_delegate.dart';

import 'package:retroshare/common/styles.dart';
import 'package:retroshare/common/bottom_bar.dart';
import 'package:retroshare/model/account.dart';
import 'package:retroshare/services/account.dart';
import 'package:share/share.dart';

class AddFriendScreen extends StatefulWidget {
  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  TextEditingController ownCertController = TextEditingController();
  TextEditingController newCertController = TextEditingController();

  String ownCert;
  bool _requestAddCert = false;

  @override
  void initState() {
    super.initState();
    _getCert();
  }

  _getCert() async {
    ownCert = (await getOwnCert()).replaceAll("\n", "");
    ownCertController.text = ownCert;
  }

  _showCertDialog(){
    return 
      showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Your RetroShare invite"),
            content:
              Column(
                children: <Widget>[
                  Button(
                    name: 'Copy to clipboard',
                    buttonIcon: Icons.content_copy,
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: ownCertController.text));
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
                          decoration: InputDecoration(
                              border: InputBorder.none),
                          style: Theme.of(context).textTheme.body2,
                        ),
                    ),
                  ),
                ],
              ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
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
              child: LayoutBuilder(
                builder:
                    (BuildContext context, BoxConstraints viewportConstraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "About me:",
                                    style: TextStyle(
                                      fontSize: 20.0
                                    ),
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
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "1. Share your RetroShare invite",
                                    style: TextStyle(
                                        fontSize: 20.0
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Container(
                                      decoration:  BoxDecoration(
                                        border: Border.all(
                                            width: 2,
                                            color: Colors.black87
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0) //         <--- border radius here
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
                                      decoration:  BoxDecoration(
                                        border: Border.all(
                                            width: 2,
                                            color: Colors.black87
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0) //         <--- border radius here
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
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "2. Paste your friends invite here",
                                  style: TextStyle(
                                      fontSize: 20.0
                                  ),
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
                                        hintText: 'Paste your friend\'s invite here'),
                                    style: Theme.of(context).textTheme.body2,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Visibility(
              visible: !_requestAddCert,
              child: BottomBar(
                child: Center(
                  child: SizedBox(
                    height: 2 * appBarHeight / 3,
                    child: FlatButton(
                      onPressed: () async {
                        setState(() {
                          _requestAddCert = true;
                        });
                        bool success = await addCert(newCertController.text);
                        if(success)
                          Navigator.pop(context);
                        else
                          showToast('An error occurred while adding your friend.');
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
      ),
    );
  }
}