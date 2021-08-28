import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/provider/Idenity.dart';
import 'package:retroshare/provider/auth.dart';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';

import '../common/color_loader_3.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen(
      {Key key,
      this.isLoading = false,
      this.statusText = "",
      this.spinner = false})
      : super(key: key);

  final isLoading;
  bool spinner;
  String statusText;

  @override
  _SplashState createState() => new _SplashState();
}

class _SplashState extends State<SplashScreen> {
  bool _spinner = false;
  String _statusText;

  @override
  void initState() {

    super.initState();
    if (!widget.isLoading) {
      _statusText = "Loading...";
      SchedulerBinding.instance.addPostFrameCallback((_) {
        checkBackendState(context);
      });
    } else {
      _statusText = widget.statusText;
      _spinner = widget.spinner;
    }
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
        isLoggedIn = await RsLoginHelper.checkLoggedIn();
        connectedToBackend = true;
      } catch (e) {
        if (connectedToBackend == true) _setStatusText("Can't connect...");
        connectedToBackend = false;
      }
    } while (!connectedToBackend);
    final auth = Provider.of<AccountCredentials>(context, listen: false);
    bool isTokenValid = await auth.checkisvalidAuthToken();
    if (isLoggedIn && isTokenValid && auth.loggedinAccount != null) {
      _setStatusText("Logging in...");
      final ids = Provider.of<Identities>(context, listen: false);
      ids.fetchOwnidenities().then((value) {
        if (ids.ownIdentity != null && ids.ownIdentity.length == 0)
          Navigator.pushReplacementNamed(context, '/create_identity',
              arguments: true);
        else
          Navigator.pushReplacementNamed(context, '/home');
      });
    } else {
      _setStatusText("Get locations...");
      await auth.fetchAuthAccountList();
      if (auth.accountList.isEmpty)
        // Create or import an account
        Navigator.pushReplacementNamed(context, '/launch_transition');
      else
        Navigator.pushReplacementNamed(context, '/signin');
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
}
