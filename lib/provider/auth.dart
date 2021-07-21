import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:retroshare/model/account.dart';
import 'package:retroshare/model/auth.dart';
import 'package:retroshare/services/account.dart';
import 'package:retroshare/services/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

class AccountCredentials with ChangeNotifier {
  List<Account> _accountsList = [];
  Account _lastAccountUsed;
  Account _loggedinAccount;
  AuthToken _authToken;
  Account get lastAccountUsed => _lastAccountUsed;
  List<Account> get accountList => _accountsList;
  Account get loggedinAccount => _loggedinAccount;
  AuthToken get getauthToken => _authToken;
  setauthToken(AuthToken authToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("username", authToken.username);
    prefs.setString('password', authToken.password);
    _authToken = authToken;
    notifyListeners();
  }

  setLogginAccount(Account acc) {
    _loggedinAccount = acc;
  }

  get authtoken => _authToken;

  fetchAuthAccountList() async {
    try {
      _accountsList = await getLocations();
    } catch (e) {
      throw HttpException(e);
    }
    _lastAccountUsed = await setlastAccountUsed();
    notifyListeners();
  }

  get getlastAccountUsed => _lastAccountUsed;

  Future<Account> setlastAccountUsed() async {
    try {
      var currAccount = await openapi.rsAccountsGetCurrentAccountId();
      for (Account account in accountsList) {
        if (account.locationId == currAccount.id) return account;
      }
    } catch (e) {
      throw HttpException(e);
    }
    return null;
  }

  Future<bool> getinitializeAuth(String locationId, String password) async {
    _authToken = AuthToken(locationId, password);
    bool success = false;
    try {
      success = await checkExistingAuthTokens(locationId, password);
    } catch (e) {
      print('xx');
      throw HttpException(e);
    }
    if (success) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("username", locationId);
      prefs.setString('password', password);
    }
    return success;
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
    try {
      int resp = await requestloginAccount(currentAccount, password);
      map['res'] = resp;
       setLogginAccount(currentAccount);
      // Login success 0, already logged in 1
      if (resp == 0 || resp == 1) {
        bool isAuthTokenValid =
            await getinitializeAuth(currentAccount.locationId, password);
        if (isAuthTokenValid) {
          map['auth'] = true;
        }
        notifyListeners();
        return map;
      }
    } on HttpException catch (e) {
      print(e);
    } catch (e) {
      throw (e);
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
    }
    notifyListeners();
    return map;
  }
}
