import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:retroshare/common/color_loader_3.dart';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare/provider/friendLocation.dart';
import 'package:share/share.dart';
import 'UpdateIdenityScreen.dart';
import 'package:qrscan/qrscan.dart' as scanner;

enum QRoperation { save, refresh, share }

class QRScanner extends StatefulWidget {
  final String qr_data;
  QRScanner({Key key, this.qr_data = null}) : super(key: key);

  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  bool _requestCreateIdentity;
  final key = GlobalKey();
  Future _scan() async {
    String barcode = null;
    try {
      barcode = await scanner.scan();
      print(barcode);
    } catch (e) {
      print(e);
    }
    Future.delayed(new Duration(seconds: 2), () {});
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
      else {
        showToast('An error occurred while adding your friend.');
        setState(() {
          _requestCreateIdentity = true;
        });
      }
    }
  }

  PopupMenuItem popupchildWidget(String text, IconData icon, QRoperation val) {
    return PopupMenuItem(
        child: Row(children: [
          Icon(
            icon,
            size: 20,
          ),
          SizedBox(
            width: 7,
          ),
          Text(
            '$text',
            style: TextStyle(
              fontSize: 12,
            ),
          )
        ]),
        value: val);
  }

  Future<void> onChanged(QRoperation val) async {
    if (val == QRoperation.save) {
      try {
        RenderRepaintBoundary boundary =
            key.currentContext.findRenderObject() as RenderRepaintBoundary;
        var image = await boundary.toImage();
        ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
        Uint8List pngBytes = byteData.buffer.asUint8List();
        final appDir = await getApplicationDocumentsDirectory();
        File file =
            await File('${appDir.path}/retroshare_qr_code.png').create();
        await file?.writeAsBytes(pngBytes);
        showToast("Hey there! QR Image has successfully saved.");
      } catch (e) {
        print(e);
        showToast("Oops! something went wrong.");
      }
    } else if (val == QRoperation.share) {
      final appDir = await getApplicationDocumentsDirectory();
      File file = await File('${appDir.path}/retroshare_qr_code');
      bool check = await file.existsSync();
      if (check) {
        Share.shareFiles(['${appDir.path}/retroshare_qr_code.png'],
            text: "Retroshare Invite");
      } else {
        showToast("Please save your image First");
      }
    } else {
      setState(() {});
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
                    Text(
                      'QR Scanner',
                      style: Theme.of(context).textTheme.body2,
                    ),
                    Spacer(),
                    PopupMenuButton(
                      onSelected: (val) => onChanged(val),
                      icon: Icon(Icons.more_vert),
                      itemBuilder: (BuildContext context) {
                        return [
                          popupchildWidget(
                              "Save", Icons.save, QRoperation.save),
                          popupchildWidget(
                              "Refresh", Icons.refresh, QRoperation.refresh),
                          popupchildWidget(
                              "Share", Icons.share_rounded, QRoperation.share)
                        ];
                      },
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
                      Card(
                        elevation: 20,
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(
                                    20) //         <--- border radius here
                                ),
                          ),
                          child: QrImage(
                            key: key,
                            data: widget.qr_data,
                            version: QrVersions.auto,
                            size: 270,
                            gapless: false,
                          ),
                        ),
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
