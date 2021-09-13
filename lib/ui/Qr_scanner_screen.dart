import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
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
  final GlobalKey _globalkey = GlobalKey();
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
    if (!check) {
      ownCert = (await RsPeers.getOwnCert(authToken)).replaceAll('\n', '');
    } else {
      ownCert = await RsPeers.getShortInvite(authToken,
          sslId: Provider.of<AccountCredentials>(context)
              .lastAccountUsed
              .locationId);
    }
    Future.delayed(const Duration(milliseconds: 60));
    return ownCert;
  }

/// WIP : Permisssion for Camera 
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
    return SizedBox(
      child: Stack(
        children: <Widget>[
          ScaleTransition(
            scale: _leftHeaderScaleAnimation,
            child: FadeTransition(
              opacity: _leftHeaderFadeAnimation,
              child: Container(
                child: const Text(
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
              child: const SizedBox(
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
    try {
      await scanner.scan().then((barcode) {
        if (barcode != null) {
          Provider.of<FriendLocations>(context, listen: false)
              .addFriendLocation(barcode)
              .then((value) {
            showToast('Friend has successfully added',
                position: ToastPosition.bottom);
          });
        } else {
          showToast('An error occurred while adding your friend.',
              position: ToastPosition.bottom);
        }
      });
    } on HttpException catch (e) {
      showToast('An error occurred while adding your friend.',
          position: ToastPosition.bottom);
    } catch (e) {
      showToast('An error occurred while adding your friend.',
          position: ToastPosition.bottom);
    }
  }

  PopupMenuItem popupchildWidget(String text, IconData icon, QRoperation val) {
    return PopupMenuItem(
      value: val,
      child: Row(children: [
        Icon(
          icon,
          size: 20,
        ),
        const SizedBox(
          width: 7,
        ),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
          ),
        )
      ]),
    );
  }

  Future<void> onChanged(QRoperation val) async {
    if (val == QRoperation.save) {
      try {
        final RenderRepaintBoundary boundary =
            _globalkey.currentContext.findRenderObject();
        final image = await boundary.toImage();
        ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        final appDir = await getApplicationDocumentsDirectory();
        await ImageGallerySaver.saveImage(Uint8List.fromList(pngBytes));
        File('${appDir.path}/retroshare_qr_code.png').create();
        showToast('Hey there! QR Image has successfully saved.',
            position: ToastPosition.bottom);
      } catch (e) {
        showToast('Oops! something went wrong.',
            position: ToastPosition.bottom);
      }
    } else if (val == QRoperation.share) {
      final appDir = await getApplicationDocumentsDirectory();
      Share.shareFiles(['${appDir.path}/retroshare_qr_code.png'],
          text: 'RetroShare invite');
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
            SizedBox(
              height: appBarHeight,
              child: Row(
                children: <Widget>[
                  Visibility(
                    child: SizedBox(
                      width: personDelegateHeight,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 25,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'QR Scanner',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  const Spacer(),
                  PopupMenuButton(
                    onSelected: (val) => onChanged(val),
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (BuildContext context) {
                      return [
                        popupchildWidget('Save', Icons.save, QRoperation.save),
                        popupchildWidget(
                            'Refresh', Icons.refresh, QRoperation.refresh),
                        popupchildWidget(
                            'Share', Icons.share_rounded, QRoperation.share)
                      ];
                    },
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
            Expanded(
                child: SizedBox(
                    child: Column(children: <Widget>[
              const SizedBox(
                height: 20,
              ),
              Card(
                elevation: 20,
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                        Radius.circular(20) //         <--- border radius here
                        ),
                  ),
                  child: FutureBuilder(
                      future: _getCert(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return RepaintBoundary(
                              key: _globalkey,
                              child: QrImage(
                                errorStateBuilder: (context, result) {
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
                                size: 240,
                              ));
                        }
                        return SizedBox(
                          width: 240,
                          height: 240,
                          child: Center(
                            child: snapshot.connectionState ==
                                    ConnectionState.waiting
                                ? SizedBox(
                                    child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                          onPressed: () async {},
                                          icon: const Icon(Icons.refresh)),
                                      const Text(
                                        'Loading',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueAccent),
                                      ),
                                    ],
                                  ))
                                : SizedBox(
                                    child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                          onPressed: () async {},
                                          icon: const Icon(
                                            Icons.error,
                                            color: Colors.grey,
                                          )),
                                      const Text('something went wrong !',
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10),
                child: SwitchListTile(
                  value: check,
                  title: getHeaderBuilder(),
                  onChanged: (newval) {
                    setState(() {
                      check = newval;
                    });
                    if (check) {
                      tabController.animateTo(0);
                    } else {
                      tabController.animateTo(1);
                    }
                  },
                ),
              ),
              Qrinfo()
            ]))),
          ]),
          Visibility(
            visible: _requestQR,
            child: const Center(
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
          await _scan();
        },
        child: const Padding(
          padding: EdgeInsets.all(8.0),
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
          'Note :',
          style: GoogleFonts.oxygen(
              textStyle:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
        ),
        const SizedBox(height: 8),
        Text(
          '''
Use Long invite when you want to connect with computers running a retroshare version <0.6.6. Otherwise you can use Short invite''',
          style: GoogleFonts.oxygen(),
        )
      ],
    ),
  );
}
