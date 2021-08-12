import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/notifications.dart';
import 'package:retroshare/provider/friends_identity.dart';
import 'package:retroshare/provider/Idenity.dart';
import 'package:retroshare/provider/auth.dart';
import 'package:retroshare/provider/friend_location.dart';
import 'package:retroshare/provider/room.dart';
import 'package:retroshare/provider/subscribed.dart';
import 'package:retroshare/routes.dart';
import 'model/app_life_cycle_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeNotifications();
  /* LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });*/

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
        ChangeNotifierProxyProvider<AccountCredentials, Identities>(
          create: (_) => Identities(),
          update: (_, auth, identities) =>
              identities..setAuthToken(auth.authtoken),
        ),
        ChangeNotifierProxyProvider<AccountCredentials, FriendLocations>(
          create: (_) => FriendLocations(),
          update: (_, auth, friendLocations) =>
              friendLocations..setAuthToken(auth.authtoken),
        ),
        ChangeNotifierProxyProvider<AccountCredentials, ChatLobby>(
          create: (_) => ChatLobby(),
          update: (_, auth, chatLobby) =>
              chatLobby..setAuthToken(auth.authtoken),
        ),
        ChangeNotifierProxyProvider<AccountCredentials, FriendsIdentity>(
          create: (_) => FriendsIdentity(),
          update: (_, auth, friendsIdentity) =>
              friendsIdentity..setAuthToken(auth.authtoken),
        ),
        ChangeNotifierProxyProvider<AccountCredentials, RoomChatLobby>(
          create: (_) => RoomChatLobby(),
          update: (_, auth, roomChatLobby) =>
              roomChatLobby..setAuthToken(auth.authtoken),
        ),
      ],
      child: Builder(
        builder: (context) {
          return OKToast(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Retroshare',
              initialRoute: '/profile',
              onGenerateRoute: RouteGenerator.generateRoute,
            ),
          );
        },
      ),
    );
  }
}
