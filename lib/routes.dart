import 'package:flutter/material.dart';
import 'package:retroshare/ui/Update_idenity_screen.dart';
import 'package:retroshare/ui/about_screen.dart';
import 'package:retroshare/ui/forum_screen.dart';
import 'package:retroshare/ui/profile_screen.dart';
import 'package:retroshare/ui/splash_screen.dart';
import 'package:retroshare/ui/home/home_screen.dart';
import 'package:retroshare/ui/signin_screen.dart';
import 'package:retroshare/ui/signup_screen.dart';
import 'package:retroshare/ui/room/room_screen.dart';
import 'package:retroshare/ui/create_room_screen.dart';
import 'package:retroshare/ui/createIdenity_screen/create_identity_screen.dart';
import 'package:retroshare/ui/launch_transition_screen.dart';
import 'package:retroshare/ui/change_identity_screen.dart';
import 'package:retroshare/ui/add_friend/add_friend_screen.dart';
import 'package:retroshare/ui/discover_chats_screen.dart';
import 'package:retroshare/ui/search_screen.dart';
import 'package:retroshare/ui/friends_locations_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        if (args is Map)
//        if (args is bool || args is String || args is SplashScreenArguments)
          return MaterialPageRoute(
              builder: (_) => SplashScreen(
                    isLoading: args['isLoading'],
                    spinner: args['spinner'],
                    statusText: args['statusText'],
                  ));

        return MaterialPageRoute(builder: (_) => SplashScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case '/signin':
        return MaterialPageRoute(builder: (_) => SignInScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => SignUpScreen());
      case '/launch_transition':
        return MaterialPageRoute(builder: (_) => LaunchTransitionScreen());
      case '/updateIdentity':
        if (args is Map)
          return MaterialPageRoute(
              builder: (_) => UpdateIdentityScreen(
                    curr: args['id'],
                  ));
        return MaterialPageRoute(builder: (_) => UpdateIdentityScreen());
      case '/room':
        if (args is Map) {
          return MaterialPageRoute(
            builder: (_) => RoomScreen(
              isRoom: args['isRoom'],
              chat: args['chatData'],
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => RoomScreen());
      case '/create_room':
        return MaterialPageRoute(builder: (_) => CreateRoomScreen());
      case '/create_identity':
        if (args is bool)
          return MaterialPageRoute(
              builder: (_) => CreateIdentityScreen(isFirstId: args));

        return MaterialPageRoute(builder: (_) => CreateIdentityScreen());
      case '/profile':
        if (args is Map)
          return MaterialPageRoute(
              builder: (_) => ProfileScreen(
                    curr: args['id'],
                  ));
        return MaterialPageRoute(builder: (_) => SplashScreen());

      case '/change_identity':
        return MaterialPageRoute(builder: (_) => ChangeIdentityScreen());
      case '/add_friend':
        return MaterialPageRoute(builder: (_) => AddFriendScreen());
      case '/discover_chats':
        return MaterialPageRoute(builder: (_) => DiscoverChatsScreen());
      case '/search':
        if (args is int)
          return MaterialPageRoute(
              builder: (_) => SearchScreen(initialTab: args));
        return MaterialPageRoute(builder: (_) => SearchScreen());
      case '/friends_locations':
        return MaterialPageRoute(builder: (_) => FriendsLocationsScreen());
      case '/about':
        return MaterialPageRoute(builder: (_) => MyWebView());

      case '/forum':
        return MaterialPageRoute(builder: (_) => ForumScreen());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Error'),
          ),
          body: Center(
            child: Text('Error'),
          ),
        );
      },
    );
  }
}
