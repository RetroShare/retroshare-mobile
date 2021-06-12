import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:oktoast/oktoast.dart';
import 'package:openapi/api.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:retroshare/common/notifications.dart';

import 'package:retroshare/routes.dart';
import 'package:retroshare/redux/store.dart';
import 'package:retroshare/redux/model/app_state.dart';

import 'package:retroshare/services/account.dart';

import 'model/app_life_cycle_state.dart';
import 'model/auth.dart';
import 'package:http/http.dart' as http;

const rsPlatform = const MethodChannel("cc.retroshare.retroshare/retroshare");

Future<bool> startRetroshare() async {
  int attempts = 20;
  for (; attempts >= 0; attempts--) {
    print("Starting Retroshare Service. Attempts countdown $attempts");
    try {
      bool isUp = await isRetroshareRunning();
      print(isUp);
      if (isUp) return true;

      await rsPlatform.invokeMethod('start');

      if (attempts == 0) {
        return false;
      }
      await Future.delayed(Duration(seconds: 2));
    } catch (err) {
      print(err);
      await Future.delayed(Duration(seconds: 2));
    }
  }
}

Future<void> stopRetroshare() async {
  try {
    await rsPlatform.invokeMethod('stop');

    await Future.delayed(Duration(milliseconds: 3000));
    bool isUp = await isRetroshareRunning();
    if (isUp) throw Exception("The service did not stop after a while");
  } catch (err) {
    throw Exception("The service could not be stopped");
  }
}

Future<void> restartRetroshare() async {
  try {
    await rsPlatform.invokeMethod('restart');

    await Future.delayed(Duration(milliseconds: 300));
    bool isUp = await isRetroshareRunning();
    if (!isUp) throw Exception("The service did not restart after a while");
  } catch (err) {
    throw Exception("The service could not be restarted");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeNotifications();
  startRetroshare();

  final rsStore = await retroshareStore();
  openapi = DefaultApi();

  runApp(App(rsStore));
}

class App extends StatefulWidget {
  final Store<AppState> store;

  App(this.store);

  @override
  _AppState createState() => new _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    // Used for notifications to open specific Navigator path
    configureSelectNotificationSubject(context);
    // Used to check when the app is on background
    WidgetsBinding.instance.addObserver(new LifecycleEventHandler());
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: widget.store,
      child: OKToast(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Retroshare',
          initialRoute: '/',
          onGenerateRoute: RouteGenerator.generateRoute,
        ),
      ),
    );
  }
}
