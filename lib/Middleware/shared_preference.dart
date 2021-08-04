import 'package:retroshare/model/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AuthToken> authcheck() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return AuthToken(
      prefs.containsKey('username') ? prefs.getString('username') : '',
      prefs.containsKey('password') ? prefs.getString('password') : '');
}
