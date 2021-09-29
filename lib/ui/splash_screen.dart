import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/apiUtils/retroshareService.dart';
import 'package:retroshare/common/show_dialog.dart';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare/provider/Idenity.dart';
import 'package:retroshare/provider/auth.dart';
import 'package:retroshare_api_wrapper/retroshare.dart' as rs;

import '../common/color_loader_3.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({
    Key key,
    this.isLoading = false,
    this.statusText = '',
    this.spinner = false,
  }) : super(key: key);

  final bool isLoading;
  bool spinner;
  String statusText;

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<SplashScreen> {
  bool _spinner = false;
  String _statusText;
  bool _init = true;

  @override
  void didChangeDependencies() {
    if (_init) {
      if (widget.isLoading == false) {
        _statusText = 'Loading...';
        checkBackendState(context);
      } else {
        _statusText = widget.statusText;
        _spinner = widget.spinner;
      }
    }
    _init = false;
    super.didChangeDependencies();
  }

  void _setStatusText(String txt) {
    setState(() {
      _statusText = txt;
    });
  }

  Future<void> checkBackendState(BuildContext context) async {
    bool run = true;

    // run until retroshare service will start
    while (run) {
      try {
        await Future.delayed(const Duration(seconds: 2));
        RsServiceControl.startRetroshare().then((value) async {
          rs.isRetroshareRunning().then((isstart) {
            if (isstart) {
              //break the loop
              run = false;
              setControlCallbacks();
              final auth =
                  Provider.of<AccountCredentials>(context, listen: false);
              auth.checkisvalidAuthToken().then((isTokenValid) async {
                // Already authenticated
                if (isTokenValid && auth.loggedinAccount != null) {
                  _setStatusText('Logging in...');
                  final ids = Provider.of<Identities>(context, listen: false);
                  ids.fetchOwnidenities().then((value) {
                    if (ids.ownIdentity != null && ids.ownIdentity.isEmpty) {
                      Navigator.pushReplacementNamed(
                        context,
                        '/create_identity',
                        arguments: true,
                      );
                    } else {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  });
                } else {
                  // Fetching the existing node location
                  _setStatusText('Get locations...');
                  await auth.fetchAuthAccountList().then((value) {
                    if (auth.accountList.isEmpty) {
                      Navigator.pushReplacementNamed(
                          context, '/launch_transition');
                    } else {
                      Navigator.pushReplacementNamed(context, '/signin');
                    }
                  });
                }
              });
            }
          });
        });
      } catch (err) {
        errorShowDialog(
            'Something went wrong', 'Try to start  the app again', context);
      }
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    statusBarHeight = MediaQuery.of(context).padding.top;

    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        key: _scaffoldKey,
        body: Center(
            child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Hero(
                tag: 'logo',
                child: Image.asset(
                  'assets/rs-logo.png',
                ),
              ),
              Text(
                _statusText,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              Visibility(
                visible: _spinner,
                child: const ColorLoader3(
                  radius: 15.0,
                  dotRadius: 6.0,
                ),
              )
            ],
          ),
        )),
      ),
    );
  }
}
