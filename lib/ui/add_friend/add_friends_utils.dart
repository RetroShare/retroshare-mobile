import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/notifications.dart';
import 'package:retroshare/provider/auth.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';
import 'package:share/share.dart';

class GetInvite extends StatefulWidget {
  const GetInvite({required Key key, this.settype}) : super(key: key);

  final settype;

  @override
  _GetInviteState createState() => _GetInviteState();
}

class _GetInviteState extends State<GetInvite> with TickerProviderStateMixin {
  late bool check;
  TextEditingController ownCertController = TextEditingController();
  late TabController tabController;

  late Animation<double> _leftHeaderFadeAnimation;
  late Animation<double> _leftHeaderScaleAnimation;
  late Animation<double> _rightHeaderFadeAnimation;
  late Animation<double> _rightHeaderScaleAnimation;

  @override
  void initState() {
    super.initState();
    check = true;
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
      ownCert = await RsPeers.getShortInvite(authToken);
    }
    Future.delayed(const Duration(milliseconds: 60));
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
              child: const Text(
                'Short Invite',
                style: TextStyle(fontSize: 15, fontFamily: 'Oxygen'),
              ),
            ),
          ),
          ScaleTransition(
            scale: _rightHeaderScaleAnimation,
            child: FadeTransition(
              opacity: _rightHeaderFadeAnimation,
              child: const Text(
                'Long Invite',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getinvitelink() {
    return FutureBuilder(
        future: _getCert(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            final String val = snapshot.data;
            ownCertController.text = val;
            return Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Opacity(
                  opacity: .2,
                  child: TextFormField(
                    key: UniqueKey(),
                    readOnly: true,
                    initialValue: val,
                    maxLines: 10,
                    minLines: 10,
                    style: GoogleFonts.oxygen(
                        textStyle:
                            const TextStyle(fontSize: 12, color: Colors.black),),
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                        prefix: const SizedBox(
                          width: 10,
                        ),
                        filled: true,
                        fillColor: Colors.black.withOpacity(.2),
                        labelStyle: const TextStyle(fontSize: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),),),
                  ),
                ),
                Container(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () async {
                          await Clipboard.setData(
                              ClipboardData(text: ownCertController.text),);
                          await showInviteCopyNotification();
                        },
                        icon: Icon(
                          Icons.copy,
                          color: Colors.blueAccent[200],
                        ),),
                    const Text(
                      'Tap to copy',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Oxygen',
                          color: Colors.blueAccent,),
                    ),
                  ],
                ),),
              ],
            );
          }
          return Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Opacity(
                opacity: .2,
                child: TextFormField(
                  readOnly: true,
                  initialValue: ownCertController.text,
                  maxLines: 10,
                  minLines: 10,
                  style: GoogleFonts.oxygen(
                      textStyle: const TextStyle(
                    fontSize: 12,
                  ),),
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                      prefix: const SizedBox(
                        width: 10,
                      ),
                      labelStyle: const TextStyle(fontSize: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),),),
                ),
              ),
              // ignore: prefer_if_elements_to_conditional_expressions
              snapshot.connectionState == ConnectionState.waiting
                  ? Container(
                      child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () async {},
                            icon: const Icon(Icons.refresh),),
                        const Text(
                          'Loading',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,),
                        ),
                      ],
                    ),)
                  : Container(
                      child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () async {},
                            icon: const Icon(
                              Icons.error,
                              color: Colors.grey,
                            ),),
                        const Text('something went wrong !',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,),),
                      ],
                    ),),
            ],
          );
        },);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        const Text(
          'Retroshare Invite :',
          style: TextStyle(fontSize: 16, fontFamily: 'Oxygen'),
        ),
        const SizedBox(height: 8),
        getinvitelink(),
        const SizedBox(height: 6),
        SwitchListTile(
          value: check,
          title: getHeaderBuilder(),
          onChanged: (newval) {
            setState(() {
              check = newval;
            });
            check ? tabController.animateTo(0) : tabController.animateTo(1);
          },
        ),
        TextButton(
          onPressed: () async {
            Share.share(ownCertController.text);
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white, // Set text color here
          ),
          // padding: EdgeInsets.zero,
          child: Center(
            child: SizedBox(
              width: 120,
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
                padding: const EdgeInsets.all(8.0),
                child: const Row(
                  children: [
                    Icon(Icons.share, size: 17),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      'Tap to Share',
                      style: TextStyle(fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
