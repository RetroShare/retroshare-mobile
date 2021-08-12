
import 'package:retroshare_api_wrapper/retroshare.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AuthToken> authcheck() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return AuthToken(
      prefs.containsKey('username') ? prefs.getString('username') : '',
      prefs.containsKey('password') ? prefs.getString('password') : '');
}
