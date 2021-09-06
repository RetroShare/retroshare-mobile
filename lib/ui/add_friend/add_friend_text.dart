import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/color_loader_3.dart';
import 'package:retroshare/common/show_dialog.dart';
import 'package:retroshare/model/http_exception.dart';
import 'package:retroshare/provider/friend_location.dart';

import '../Qr_scanner_screen.dart';

class GetAddfriend extends StatefulWidget {
  @override
  _GetAddfriendState createState() => _GetAddfriendState();
}

class _GetAddfriendState extends State<GetAddfriend> {
  TextEditingController ownCertController = TextEditingController();

  bool _requestAddCert = false;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Column(
        children: [
          TextFormField(
            maxLines: 10,
            minLines: 6,
            controller: ownCertController,
            style: const TextStyle(
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
                prefix: const SizedBox(
                  width: 10,
                ),
                hintStyle: const TextStyle(fontSize: 16, fontFamily: 'Oxygen'),
                labelStyle: const TextStyle(fontSize: 12),
                hintText: 'Paste your friend\'s invite here',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(6))),
          ),
          const SizedBox(height: 10),
          FlatButton(
            onPressed: () async {
              setState(() {
                _requestAddCert = true;
              });
              try {
                await Provider.of<FriendLocations>(context, listen: false)
                    .addFriendLocation(ownCertController.text)
                    .then((value) {
                  setState(() {
                    _requestAddCert = false;
                  });
                  Fluttertoast.cancel();
                  showFlutterToast('Friend has been added', Colors.red);
                });
                Navigator.of(context)
                    .pushReplacementNamed('/friends_locations');
              } on HttpException catch (e) {
                setState(() {
                  _requestAddCert = false;
                });
                Fluttertoast.cancel();
                showFlutterToast('Invalid certi', Colors.red);
              } catch (e) {
                setState(() {
                  _requestAddCert = false;
                });
                Fluttertoast.cancel();
                showFlutterToast('something went wrong', Colors.red);
              }
            },
            textColor: Colors.white,
            padding: const EdgeInsets.all(0.0),
            child: SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
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
          const Align(
              child: Text(
            'OR',
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
          FlatButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => QRScanner()));
            },
            textColor: Colors.white,
            padding: EdgeInsets.zero,
            child: SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    colors: <Color>[Colors.purple, Colors.purpleAccent],
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
          )
        ],
      ),
      Center(
        child: Visibility(
          visible: _requestAddCert,
          child: const ColorLoader3(
            radius: 15.0,
            dotRadius: 6.0,
          ),
        ),
      )
    ]);
  }
}
