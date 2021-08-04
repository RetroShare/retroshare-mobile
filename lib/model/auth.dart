//AuthToken authToken = '0000';
import 'package:openapi/api.dart';

//AuthToken authToken;
DefaultApi openapi;

class AuthToken {
  final String _username;
  final String _password;

  get authToken => this._username + ":" + this._password;

  get username => _username;
  get password => _password;

  AuthToken(this._username, this._password) {
    defaultApiClient.getAuthentication<HttpBasicAuth>('BasicAuth').username =
        this._username;
    defaultApiClient.getAuthentication<HttpBasicAuth>('BasicAuth').password =
        this._password;
  }

  @override
  String toString() => this.authToken;
}
