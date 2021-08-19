import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:retroshare/common/color_loader_3.dart';
import 'package:retroshare/common/show_dialog.dart';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare/provider/auth.dart';
import 'package:retroshare/provider/friend_location.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';
import 'package:share/share.dart';
import 'package:qrscan/qrscan.dart' as scanner;

enum QRoperation { save, refresh, share }

class QRScanner extends StatefulWidget {
  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner>
    with SingleTickerProviderStateMixin {
  bool check;
  GlobalKey _globalkey = new GlobalKey();
  TextEditingController ownCertController = TextEditingController();
  TabController tabController;

  Animation<double> _leftHeaderFadeAnimation;
  Animation<double> _leftHeaderScaleAnimation;
  bool _requestQR;
  Animation<double> _rightHeaderFadeAnimation;
  Animation<double> _rightHeaderScaleAnimation;

  @override
  void initState() {
    super.initState();
    check = true;
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
    final authToken =
        Provider.of<AccountCredentials>(context, listen: false).authtoken;
    if (!check)
      ownCert = (await RsPeers.getOwnCert(authToken)).replaceAll("\n", "");
    else {
      
      ownCert = (await RsPeers.getShortInvite(authToken,sslId: Provider.of<AccountCredentials>(context).lastAccountUsed.locationId));
    }
    Future.delayed(Duration(milliseconds: 60));
    return ownCert;
  }

  /*Future<bool> requestCameraPermission() async {
    if (await Permission.camera.isUndetermined) {
      final status = await Permission.camera.request();
      if (status.isDenied) return false;
    }
    return true;
  }

  void checkServiceStatus(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Access Denied!"),
    ));
  }*/

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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
      if (barcode != null) {
        bool success = false;
        await Provider.of<FriendLocations>(context, listen: false)
            .addFriendLocation(barcode)
            .then((value) {
          setState(() {
            _requestQR = false;
          });
          showToast('Friend has successfully added');
        });
      } else {
        showToast('An error occurred while adding your friend.');
      }
    } on HttpException catch (e) {
      setState(() {
        _requestQR = false;
      });
      showToast('An error occurred while adding your friend.');
    } catch (e) {
      setState(() {
        _requestQR = false;
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
            _globalkey.currentContext.findRenderObject();
        var image = await boundary.toImage();
        ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
        Uint8List pngBytes = byteData.buffer.asUint8List();
        final appDir = await getApplicationDocumentsDirectory();
        // final result =
        //await ImageGallerySaver.saveImage(Uint8List.fromList(pngBytes));

        final file = new File('${appDir.path}/retroshare_qr_code.png').create();
        showToast("Hey there! QR Image has successfully saved.");
      } catch (e) {
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
                        popupchildWidget("Save", Icons.save, QRoperation.save),
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
                child: SizedBox(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
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
                      child: FutureBuilder(
                          future: _getCert(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData)
                              return RepaintBoundary(
                                  key: _globalkey,
                                  child: QrImage(
                                    errorStateBuilder: (context, result) {
                                      /*setState(() {
                                          _requestQR = false;
                                        });*/

                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              Constants.padding),
                                        ),
                                        elevation: 0,
                                        backgroundColor: Colors.transparent,
                                        child: contentBox(context),
                                      );
                                    },
                                    data: snapshot.data,
                                    version: QrVersions.auto,
                                    size: 240,
                                  ));
                            return SizedBox(
                              width: 240,
                              height: 240,
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
                                                fontWeight: FontWeight.bold,
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
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey)),
                                        ],
                                      )),
                              ),
                            );
                          }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14.0, vertical: 10),
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
                  Qrinfo()
                ]))),
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            _requestQR = true;
          });
          await _scan();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Icon(Icons.document_scanner),
          ),
        ),
      ),
    );
  }
}

Widget Qrinfo() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 13),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Note :",
          style: GoogleFonts.oxygen(
              textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
        ),
        SizedBox(height: 8),
        Text(
          "Use Long invite when you want to connect with computers running a retroshare version <0.6.6. Otherwise you can use Short invite",
          style: GoogleFonts.oxygen(),
        )
      ],
    ),
  );
}
