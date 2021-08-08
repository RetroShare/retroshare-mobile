import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/color_loader_3.dart';
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
              try{
               Provider.of<FriendLocations>(context, listen: false)
                  .addFriendLocation(ownCertController.text);
                   setState(() {
                  _requestAddCert = false;
                  });
                  Fluttertoast.showToast(
                    msg:
                        "Friend has been added",
                        
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }on HttpException catch(err){
                setState(() {
                  _requestAddCert = false;
                });
                Fluttertoast.cancel();
                Fluttertoast.showToast(
                    msg: 'something went Wrong',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }catch(e){
                setState(() {
                  _requestAddCert = false;
                });
                Fluttertoast.cancel();
                Fluttertoast.showToast(
                    msg: 'something went Wrong',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);

              }

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
              Navigator.of(context)
                  .push(new MaterialPageRoute(builder: (_) => QRScanner()));
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
          )
        ],
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
    ]);
  }
}
