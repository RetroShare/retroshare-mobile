import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/drawer.dart';
import 'package:retroshare/provider/auth.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({required Key key,required this.curr}) : super(key: key);

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
      appBar: appBar('Identity Info', context),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 100,
              width: 100,
              margin: const EdgeInsets.only(top: 10),
              decoration: (widget.curr.avatar == null)
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(),
                    )
                  : BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(),
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: MemoryImage(base64.decode(widget.curr.avatar)),
                      ),
                    ),
              child: Visibility(
                visible: widget.curr.avatar == null,
                child: const Center(
                  child: Icon(
                    Icons.person,
                    size: 80,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Form(
                child: Column(
                  children: [
                    textField(widget.curr.name, 'Identity Name'),
                    const SizedBox(height: 20),
                    textField(widget.curr.mId, 'Identity ID'),
                    const SizedBox(height: 20),
                    textField(
                        widget.curr.signed ? 'signed' : 'unsigned', 'Type',),
                    const SizedBox(height: 20),
                    textField(lastAccount.pgpName, 'Node Name'),
                    const SizedBox(height: 20),
                    textField(lastAccount.locationId, 'Node ID'),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () async {
                        Navigator.of(context).pushReplacementNamed(
                          '/updateIdentity',
                          arguments: {'id': widget.curr},
                        );
                      },
                      child: Container(
                        height: 40,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(
                            colors: <Color>[
                              Color(0xFF00FFFF),
                              Color(0xFF29ABE2),
                            ],
                            begin: Alignment(-1.0, -4.0),
                            end: Alignment(1.0, 4.0),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 6,),
                        child: const Text(
                          'Edit Identity',
                          style:
                              TextStyle(fontSize: 15, fontFamily: 'Vollkorn'),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget textField(String text, String label) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontFamily: 'Vollkorn',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      TextFormField(
        readOnly: true,
        initialValue: text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          fontFamily: 'Oxygen',
        ),
        decoration: InputDecoration(
          prefix: const SizedBox(
            width: 10,
          ),
          labelStyle: const TextStyle(fontSize: 12),
          border: OutlineInputBorder(
            borderSide: const BorderSide(width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ],
  );
}
