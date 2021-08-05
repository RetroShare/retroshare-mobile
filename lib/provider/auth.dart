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
  AuthToken get getAuthToken => _authToken;

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
      for (Account account in _accountsList) {
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
    success = await checkExistingAuthTokens(locationId, password, _authToken);

    if (success) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("username", locationId);
      prefs.setString('password', password);
    }
    return success;
  }

  Future<bool> checkisvalidAuthToken() {
    return isAuthTokenValid(_authToken);
  }

  Future<void> login(Account currentAccount, String password) async {
    try {
      int resp = await requestLogIn(currentAccount, password);
      setLogginAccount(currentAccount);
      // Login success 0, already logged in 1
      if (resp == 0 || resp == 1) {
        bool isAuthTokenValid =
            await getinitializeAuth(currentAccount.locationName, password);
        if (!isAuthTokenValid) {
          throw HttpException("AUTHTOKEN FAILED");
        }
        notifyListeners();
      } else
        throw HttpException("WRONG PASSWORD");
    } catch (e) {
      throw (e);
    }
  }

  Future<void> signup(String username, String password, String nodename) async {
    final map = {"auth": false, "account": false};

    Tuple2<bool, Account> account_create;
    try {
      account_create = await requestAccountCreation(username, password);
      if (account_create != null && account_create.item1) {
        _accountsList.add(account_create.item2);
        setLogginAccount(account_create.item2);
        bool isAuthTokenValid =
            await getinitializeAuth(account_create.item2.locationName, password);
        if (!isAuthTokenValid) throw HttpException("AUTHTOKEN FAILED");
        notifyListeners();
      } else
        throw HttpException("DATA INSUFFICIENT");
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }
}
