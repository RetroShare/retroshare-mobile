import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:retroshare/common/color_loader_3.dart';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare/provider/friendLocation.dart';
import 'package:retroshare/services/account.dart';
import 'package:share/share.dart';
import 'Update_idenity_screen.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:qrscan/qrscan.dart' as scanner;

enum QRoperation { save, refresh, share }

class QRScanner extends StatefulWidget {
  final String qr_data;
  QRScanner({Key key, this.qr_data = null}) : super(key: key);

  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner>
    with SingleTickerProviderStateMixin {
  bool _requestQR;
  GlobalKey key = new GlobalKey();
  bool check;
  TextEditingController ownCertController = TextEditingController();
  TabController tabController;

  Animation<double> _leftHeaderFadeAnimation;
  Animation<double> _leftHeaderScaleAnimation;
  Animation<double> _rightHeaderFadeAnimation;
  Animation<double> _rightHeaderScaleAnimation;

  @override
  void initState() {
    super.initState();
    check = false;
    _requestQR = false;
    tabController = TabController(vsync: this, length: 2);

    _leftHeaderFadeAnimation = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(tabController.animation);

    _leftHeaderScaleAnimation = Tween(
      begin: 1.0,
      end: 0.5,
    ).animate(tabController.animation);

    _rightHeaderFadeAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(tabController.animation);

    _rightHeaderScaleAnimation = Tween(
      begin: 0.5,
      end: 1.0,
    ).animate(tabController.animation);
  }

  Future<String> _getCert() async {
    String ownCert;
    if (!check)
      ownCert = (await getOwnCert()).replaceAll("\n", "");
    else
      ownCert = (await getShortInvite()).replaceAll("\n", "");
    Future.delayed(Duration(milliseconds: 60));
    return ownCert;
  }

  Widget getHeaderBuilder() {
    return Container(
      child: Stack(
        children: <Widget>[
          ScaleTransition(
            scale: _leftHeaderScaleAnimation,
            child: FadeTransition(
              opacity: _leftHeaderFadeAnimation,
              child: Container(
                child: Text(
                  'Short Invite',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
          ),
          ScaleTransition(
            scale: _rightHeaderScaleAnimation,
            child: FadeTransition(
              opacity: _rightHeaderFadeAnimation,
              child: Container(
                child: Text(
                  'Long Invite',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future _scan() async {
    String barcode = null;
    try {
      barcode = await scanner.scan();
      print(barcode);
      bool success = await Provider.of<FriendLocations>(context, listen: false)
          .addFriendLocation(barcode);
      if (success) {
        showToast('Friend has successfully added');
        Navigator.pop(context);
      } else {
        showToast('An error occurred while adding your friend.');

        setState(() {
          _requestQR = false;
        });
      }
    } catch (e) {
      print(e);
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
      setState(() {
        _requestQR = false;
      });
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
        RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
        var image = await boundary.toImage();
        ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
        Uint8List pngBytes = byteData.buffer.asUint8List();
        final appDir = await getApplicationDocumentsDirectory();
        final result =
            await ImageGallerySaver.saveImage(Uint8List.fromList(pngBytes));
        final file = new File('${appDir.path}/retroshare_qr_code.png').create();
        showToast("Hey there! QR Image has successfully saved.");
      } catch (e) {
        print(e);
        showToast("Oops! something went wrong.");
      }
    } else if (val == QRoperation.share) {
      final appDir = await getApplicationDocumentsDirectory();
      Share.shareFiles(['${appDir.path}/retroshare_qr_code.png'],
          text: "RetroShare invite");
    } else {
      setState(() {});
    }
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
                          child: RepaintBoundary(
                            key: key,
                            child: FutureBuilder(
                                future: _getCert(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.hasData)
                                    return QrImage(
                                      data: snapshot.data,
                                      version: QrVersions.auto,
                                      size: 270,
                                    );
                                  return SizedBox(
                                    width: 270,
                                    height: 270,
                                    child: Center(
                                      child: snapshot.connectionState ==
                                              ConnectionState.waiting
                                          ? Container(
                                              child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                    onPressed: () async {},
                                                    icon: Icon(Icons.refresh)),
                                                Text(
                                                  "Loading",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blueAccent),
                                                ),
                                              ],
                                            ))
                                          : Container(
                                              child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                    onPressed: () async {},
                                                    icon: Icon(
                                                      Icons.error,
                                                      color: Colors.grey,
                                                    )),
                                                Text("something went wrong !",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey)),
                                              ],
                                            )),
                                    ),
                                  );
                                }),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: SwitchListTile(
                          value: check,
                          title: getHeaderBuilder(),
                          onChanged: (newval) {
                            setState(() {
                              check = newval;
                            });
                            if (check)
                              tabController.animateTo(0);
                            else
                              tabController.animateTo(1);
                          },
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
                                _requestQR = true;
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
              visible: _requestQR,
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
