import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:retroshare/common/notifications.dart';
import 'package:retroshare/provider/Idenity.dart';
import 'package:retroshare/provider/auth.dart';
import 'package:retroshare/provider/friendLocation.dart';

import 'package:retroshare/routes.dart';
import 'package:retroshare/redux/store.dart';
import 'package:retroshare/redux/model/app_state.dart';

import 'model/app_life_cycle_state.dart';
import 'model/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeNotifications();

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AccountCredentials()),
        ChangeNotifierProvider(create: (ctx) => Identities()),
        ChangeNotifierProvider(create: (ctx) => FriendLocations())
      ],
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
