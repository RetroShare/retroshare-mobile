import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/provider/auth.dart';
import 'package:retroshare/services/init.dart';

import 'package:retroshare/common/styles.dart';
import 'package:retroshare/services/auth.dart';
import 'package:retroshare/services/account.dart';
import 'package:retroshare/model/account.dart';

import '../common/color_loader_3.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen(
      {Key key,
      this.isLoading = false,
      this.statusText = "",
      this.spinner = false})
      : super(key: key);
  final isLoading;
  String statusText;
  bool spinner;

  @override
  _SplashState createState() => new _SplashState();
}

class _SplashState extends State<SplashScreen> {
  String _statusText;
  bool _spinner = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isLoading) {
      _statusText = "Loading...";
      checkBackendState(context);
    } else {
      _statusText = widget.statusText;
      _spinner = widget.spinner;
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    statusBarHeight = MediaQuery.of(context).padding.top;

    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
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
                '$_statusText',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              Visibility(
                visible: _spinner,
                child: ColorLoader3(
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

  void _setStatusText(String txt) {
    setState(() {
      _statusText = txt;
    });
  }

  void checkBackendState(BuildContext context) async {
    bool connectedToBackend = true;
    bool isLoggedIn;
    do {
      try {
        isLoggedIn = await checkLoggedIn();
        connectedToBackend = true;
      } catch (e) {
        if (connectedToBackend == true) _setStatusText("Can't connect...");
        connectedToBackend = false;
      }
    } while (!connectedToBackend);
    final provider = Provider.of<AccountCredentials>(context, listen: false);
    bool isTokenValid = await provider.checkisvalidAuthToken();
    if (isLoggedIn && isTokenValid && loggedinAccount != null) {
      _setStatusText("Logging in...");
      initializeStore(
        context,
      );
    } else {
      _setStatusText("Get locations...");
      await provider.fetchAuthAccountList();
      if (provider.accountList.isEmpty)
        // Create or import an account
        Navigator.pushReplacementNamed(context, '/launch_transition');
      else
        Navigator.pushReplacementNamed(context, '/signin');
    }
  }
}
