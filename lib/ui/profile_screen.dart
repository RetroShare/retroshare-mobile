import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          "Identity Info",
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 16, fontFamily: "Oxygen"),
        ),
        automaticallyImplyLeading: true,
      ),
      body: 
          SingleChildScrollView(
            child: Column(children: <Widget>[
              Container(
                height: 100,
                width: 100,
                margin: const EdgeInsets.only(top: 10),
                decoration: (widget.curr.avatar == null)
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black))
                    : BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black),
                        image: DecorationImage(
                          fit: BoxFit.fitWidth,
                          image: MemoryImage(
                              base64.decode(widget.curr.avatar)),
                        ),
                      ),
                child: Visibility(
                  visible: (widget.curr?.avatar == null),
                  child: Center(
                    child: Icon(
                      Icons.person,
                      size: 80,
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
                  InkWell(
                    
                    onTap: () async {
                      Navigator.of(context).pushReplacementNamed(
                          '/updateIdentity',
                          arguments: {'id': widget.curr});
                    },
            
                    child:
                      Container(
                         height: 40,
                         width: double.infinity,
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
                          padding: const EdgeInsets.symmetric(vertical:10.0,horizontal: 6),
                          child: const Text(
                            'Edit Identity',
                            style: TextStyle(fontSize: 15,fontFamily: "Vollkorn"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                     ),
                ])),
              )
            ]),
          ),
    );
  }
}

Widget textField(String text, String label) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    
    children: [
      Text(label,style: TextStyle(fontFamily: "Vollkorn",fontSize: 16,fontWeight: FontWeight.w600),),
      TextFormField(
        readOnly: true,
        initialValue: text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,fontFamily: 'Oxygen'),
        decoration: InputDecoration(
            prefix: SizedBox(
              width: 10,
            ),
            labelStyle: TextStyle(fontSize: 12),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black,width: 2),
                borderRadius: BorderRadius.circular(12))),
      ),
    ],
  );
}
