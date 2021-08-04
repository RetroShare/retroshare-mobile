import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/show_dialog.dart';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare/model/account.dart';
import 'package:retroshare/model/identity.dart';
import 'package:retroshare/provider/auth.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key key, this.curr}) : super(key: key);

  final Identity curr;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final Account lastAccount =
        Provider.of<AccountCredentials>(context, listen: false).loggedinAccount;
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.only(top: 40, left: 8, right: 8),
          child: SingleChildScrollView(
            child: Column(children: <Widget>[
              Container(
                  height: appBarHeight,
                  child: Row(children: <Widget>[
                    Visibility(
                      visible: true,
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
                    SizedBox(height: 20),
                    Text(
                      'Identity Info',
                      style: Theme.of(context).textTheme.body2,
                    ),
                    Spacer(),
                    PopupMenuButton(
                      onSelected: (val) {
                        val == "edit"
                            ? Navigator.of(context).pushReplacementNamed(
                                '/updateIdentity',
                                arguments: {'id': widget.curr})
                            : showdeleteDialog(context);
                      },
                      icon: Icon(Icons.more_vert),
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem(
                              child: Row(children: [
                                Icon(
                                  Icons.edit,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 7,
                                ),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                )
                              ]),
                              value: 'edit'),
                          PopupMenuItem(
                              child: Row(children: [
                                Icon(
                                  Icons.delete,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 7,
                                ),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                )
                              ]),
                              value: 'trash'),
                        ];
                      },
                    ),
                    SizedBox(width: 10),
                  ])),
              Container(
                height: 300 * 0.7,
                width: 300 * 0.7,
                decoration: widget.curr.avatar == null
                    ? null
                    : BoxDecoration(
                        borderRadius: BorderRadius.circular(300 * 0.7 * 0.33),
                        image: DecorationImage(
                          fit: BoxFit.fitWidth,
                          image: MemoryImage(base64.decode(widget.curr.avatar)),
                        ),
                      ),
                child: Visibility(
                  visible: widget.curr.avatar != null ? false : true,
                  child: Center(
                    child: Icon(
                      Icons.person,
                      size: 300 * 0.7,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Form(
                    child: Column(children: [
                  textField(widget.curr.name, "Identity Name"),
                  SizedBox(height: 20),
                  textField(widget.curr.mId, 'Identity ID'),
                  SizedBox(height: 20),
                  textField(widget.curr.signed ? "signed" : "unsigned", "Type"),
                  SizedBox(height: 20),
                  textField(lastAccount.pgpName, "Node Name"),
                  SizedBox(height: 20),
                  textField(lastAccount.locationId, "Node ID"),
                  SizedBox(height: 20),
                  FlatButton(
                    onPressed: () async {
                      Navigator.of(context).pushReplacementNamed(
                          '/updateIdentity',
                          arguments: {'id': widget.curr});
                    },
                    textColor: Colors.white,
                    padding: const EdgeInsets.all(0.0),
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
                        child: const Text(
                          'Edit Identity',
                          style: TextStyle(fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ])),
              )
            ]),
          )),
    );
  }
}

Widget textField(String text, String label) {
  return TextFormField(
    readOnly: true,
    initialValue: text,
    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    decoration: InputDecoration(
        labelText: label,
        prefix: SizedBox(
          width: 10,
        ),
        labelStyle: TextStyle(fontSize: 12),
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(6))),
  );
}
