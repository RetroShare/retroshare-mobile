import 'package:flutter/cupertino.dart';
import 'package:retroshare/model/account.dart';
import 'package:retroshare/model/auth.dart';
import 'package:retroshare/services/account.dart';
import 'package:retroshare/services/auth.dart';
import 'package:tuple/tuple.dart';

class AccountCredentials with ChangeNotifier {
  List<Account> _accountsList;
  Account _lastAccountUsed;
  Account _loggedinAccount;
  AuthToken _authToken;

  get accountList => _accountsList;
  get loggedinAccount => _loggedinAccount;
  get authToken => _authToken;
  setauthToken(AuthToken authToken) {
    _authToken = authToken;
  }

  setLogginAccount(Account acc) {
    _loggedinAccount = acc;
  }

  fetchAuthAccountList() async {
    _accountsList = await getLocations();
    _lastAccountUsed = await setlastAccountUsed();
    notifyListeners();
  }

  get getlastAccountUsed => _lastAccountUsed;

  Future<Account> setlastAccountUsed() async {
    var currAccount = await openapi.rsAccountsGetCurrentAccountId();
    for (Account account in accountsList) {
      if (account.locationId == currAccount.id) return account;
    }
    return null;
  }

  getinitializeAuth(String locationId, String password) async {
    _authToken = AuthToken(locationId, password);

    return await checkExistingAuthTokens(locationId, password);
  }

  Future<int> requestloginAccount(
      Account currentaccount, String password) async {
    return await requestLogIn(currentaccount, password);
  }

  Future<bool> checkisvalidAuthToken() {
    return isAuthTokenValid();
  }

  Future<Tuple2<bool, Account>> requestsignup(
      String username, String password, String nodeName) {
    requestAccountCreation(username, password);
  }

  Future<Map<String, dynamic>> login(
      Account currentAccount, String password) async {
    final map = {'res': -1, 'auth': false};
    int resp = await requestloginAccount(currentAccount, password);
    map['res'] = resp;
    // Login success 0, already logged in 1
    if (resp == 0 || resp == 1) {
      bool isAuthTokenValid =
          await getinitializeAuth(currentAccount.locationId, password);
      if (isAuthTokenValid) {
        setLogginAccount(currentAccount);
        map['auth'] = true;
      }
      return map;
    }
  }

  Future<Map<String, bool>> signup(
      String username, String password, String nodename) async {
    final map = {"auth": false, "account": false};

    Tuple2<bool, Account> accountCreate;
    accountCreate = await requestAccountCreation(username, password, nodename);
    if (accountCreate != null && accountCreate.item1) {
      map['account'] = true;
      _accountsList.add(accountCreate.item2);
      setLogginAccount(accountCreate.item2);

      bool isAuthTokenValid =
          await getinitializeAuth(accountCreate.item2.locationId, password);
      if (isAuthTokenValid) map['auth'] = true;
      notifyListeners();
    }
    return map;
  }
}
