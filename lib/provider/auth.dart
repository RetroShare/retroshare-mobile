import 'dart:io';
import 'package:flutter/cupertino.dart';
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

  set logginAccount(Account acc) {
    _loggedinAccount = acc;
  }

  AuthToken get authtoken => _authToken;

  Future<void> fetchAuthAccountList() async {
    try {
      final resp = await RsLoginHelper.getLocations();
      List<Account> accountsList = [];
      resp.forEach((location) {
        if (location != null) {
          accountsList.add(Account(location['mLocationId'], location['mPgpId'],
              location['mLocationName'], location['mPgpName']));
        }
      });
      _accountsList = accountsList;
      notifyListeners();

      _lastAccountUsed = await setlastAccountUsed();
    } catch (e) {
      throw HttpException(e.toString());
    }
  }

  Account get getlastAccountUsed => _lastAccountUsed;

  Future<Account> setlastAccountUsed() async {
    try {
      final currAccount = await RsAccounts.getCurrentAccountId(_authToken);
      for (final Account account in _accountsList) {
        if (account.locationId == currAccount) return account;
      }
    } catch (e) {
      throw HttpException(e.toString());
    }
    return null;
  }

  Future<bool> getinitializeAuth(String locationId, String password) async {
    _authToken = AuthToken(locationId, password);
    final bool success = await RsJsonApi.checkExistingAuthTokens(
            locationId, password, _authToken) ??
        false;
    return success;
  }

  Future<bool> checkisvalidAuthToken() {
    return RsJsonApi.isAuthTokenValid(_authToken);
  }

  Future<void> login(Account currentAccount, String password) async {
    final int resp = await RsLoginHelper.requestLogIn(currentAccount, password);
    logginAccount = currentAccount;
    // Login success 0, already logged in 1
    if (resp == 0 || resp == 1) {
      final bool isAuthTokenValid =
          await getinitializeAuth(currentAccount.locationName, password);
      if (!isAuthTokenValid) {
        throw const HttpException('AUTHTOKEN FAILED');
      }
      notifyListeners();
    } else {
      throw const HttpException('WRONG PASSWORD');
    }
  }

  Future<void> signup(String username, String password, String nodename) async {
    final resp = await RsLoginHelper.requestAccountCreation(username, password);
    final Account account =
        Account(resp['locationId'], resp['pgpId'], username, username);
    final Tuple2<bool, Account> accountCreate = Tuple2<bool, Account>(
        resp['retval']['errorNumber'] != 0 ? false : true, account);
    if (accountCreate != null && accountCreate.item1) {
      _accountsList.add(accountCreate.item2);
      logginAccount = accountCreate.item2;
      final bool isAuthTokenValid =
          await getinitializeAuth(accountCreate.item2.locationName, password);
      if (!isAuthTokenValid) throw const HttpException('AUTHTOKEN FAILED');
      notifyListeners();
    } else {
      throw const HttpException('DATA INSUFFICIENT');
    }
  }
}
