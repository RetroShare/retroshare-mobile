import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';

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
      final resp = await RsLoginHelper.getLocations();
      List<Account> accountsList = [];
      resp.forEach((location) {
        if (location != null)
          accountsList.add(Account(location['mLocationId'], location['mPgpId'],
              location['mLocationName'], location['mPgpName']));
      });
      _accountsList = accountsList;
      notifyListeners();

      _lastAccountUsed = await setlastAccountUsed();
    } catch (e) {
      throw HttpException(e.toString());
    }
  }

  get getlastAccountUsed => _lastAccountUsed;

  Future<Account> setlastAccountUsed() async {
    try {
      var currAccount = await RsAccounts.getCurrentAccountId(_authToken);

      for (Account account in _accountsList) {
        if (account.locationId == currAccount) return account;
      }
    } catch (e) {
      throw HttpException(e.toString());
    }
    return null;
  }

  Future<bool> getinitializeAuth(String locationId, String password) async {
    _authToken = AuthToken(locationId, password);
    bool success = false;
    success = await RsJsonApi.checkExistingAuthTokens(locationId, password, _authToken);

    if (success) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("username", locationId);
      prefs.setString('password', password);
    }
    return success;
  }

  Future<bool> checkisvalidAuthToken() {
    return RsJsonApi.isAuthTokenValid(_authToken);
  }

  Future<void> login(Account currentAccount, String password) async {
    try {
      int resp = await RsLoginHelper.requestLogIn(currentAccount, password);
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
      throw (e.toString());
    }
  }

  Future<void> signup(String username, String password, String nodename) async {
    try {
      final resp = await RsLoginHelper.requestAccountCreation(username, password);
      Account account =
          Account(resp['locationId'], resp['pgpId'], username, username);
      Tuple2<bool, Account> account_create = Tuple2<bool, Account>(
          resp["retval"]["errorNumber"] != 0 ? false : true, account);
      if (account_create != null && account_create.item1) {
        _accountsList.add(account_create.item2);
        setLogginAccount(account_create.item2);
        bool isAuthTokenValid = await getinitializeAuth(
            account_create.item2.locationName, password);
        if (!isAuthTokenValid) throw HttpException("AUTHTOKEN FAILED");
        notifyListeners();
      } else
        throw HttpException("DATA INSUFFICIENT");
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
