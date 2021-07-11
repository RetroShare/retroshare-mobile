import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/notifications.dart';
import 'package:retroshare/provider/FriendsIdentity.dart';
import 'package:retroshare/provider/Idenity.dart';
import 'package:retroshare/provider/auth.dart';
import 'package:retroshare/provider/friendLocation.dart';
import 'package:retroshare/provider/room.dart';
import 'package:retroshare/provider/subscribed.dart';
import 'package:retroshare/routes.dart';
import 'model/app_life_cycle_state.dart';
import 'model/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeNotifications();
  /* LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });*/
  openapi = DefaultApi();

  runApp(App());
}

class App extends StatefulWidget {
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
        ChangeNotifierProvider(create: (ctx)=>Identities()),
        ChangeNotifierProvider(create: (ctx)=>FriendLocations()),
        ChangeNotifierProvider(create: (ctx)=>ChatLobby()),
        ChangeNotifierProvider(create: (ctx)=>FriendsIdentity()),
        ChangeNotifierProvider(create: (ctx)=>RoomChatLobby())
      ],
      child: Builder(
        builder: (context) {
          return
        OKToast(
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Retroshare',
          //home: AddFriendScreen()
          initialRoute: '/profile',
          onGenerateRoute: RouteGenerator.generateRoute,
          ),
    );
     },
    ),
    );
  }
}
