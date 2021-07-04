import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:retroshare/common/color_loader_3.dart';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare/provider/friendLocation.dart';
import 'UpdateIdenityScreen.dart';
import 'package:qrscan/qrscan.dart' as scanner;

enum QRoperation { save, refresh }

class QRScanner extends StatefulWidget {
  final String qr_data;
  QRScanner({Key key, this.qr_data = null}) : super(key: key);

  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  bool _requestCreateIdentity;

  Future _scan() async {
    String barcode = null;
    try {
      barcode = await scanner.scan();
      print("hello");
      print(barcode);
    } catch (e) {
      print(e);
    }
    if (barcode == null) {
      setState(() {
        _requestCreateIdentity = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.padding),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: contentBox(context),
          );
        },
      );
    } else {
      print(barcode);
      bool success = await Provider.of<FriendLocations>(context, listen: false)
          .addFriendLocation(barcode);
      if (success)
        Navigator.pop(context);
      else
        showToast('An error occurred while adding your friend.');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _requestCreateIdentity = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.only(top: 40, left: 8, right: 8),
          child: Stack(children: [
            Column(children: <Widget>[
              Container(
                height: appBarHeight,
                child: Row(
                  children: <Widget>[
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
                    Expanded(
                      child: Text(
                        'QR Scanner',
                        style: Theme.of(context).textTheme.body2,
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton(
                        icon: Icon(Icons.more_vert),
                        items: [
                          DropdownMenuItem(
                              value: QRoperation.save, child: Text("Save")),
                          DropdownMenuItem(
                              child: Text("Refresh"),
                              value: QRoperation.refresh)
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                    child: SizedBox(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      QrImage(
                        data: widget.qr_data,
                        version: QrVersions.auto,
                        size: 250,
                        gapless: false,
                      ),
                      Card(
                        borderOnForeground: false,
                        margin: const EdgeInsets.all(0),
                        color: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.black87),
                            borderRadius: BorderRadius.all(Radius.circular(
                                    50) //         <--- border radius here
                                ),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.document_scanner),
                            iconSize: 45.0,
                            color: Colors.black87,
                            onPressed: () async {
                              setState(() {
                                _requestCreateIdentity = true;
                              });
                              await _scan();
                            },
                          ),
                        ),
                      ),
                    ]))),
              )
            ]),
            Visibility(
              visible: _requestCreateIdentity,
              child: Center(
                child: ColorLoader3(
                  radius: 15.0,
                  dotRadius: 6.0,
                ),
              ),
            )
          ]),
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
