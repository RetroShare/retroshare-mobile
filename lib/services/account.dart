import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:retroshare/redux/actions/app_actions.dart';
import 'package:retroshare/redux/model/app_state.dart';
import 'package:tuple/tuple.dart';

import 'package:retroshare/model/account.dart';
import 'package:retroshare/model/auth.dart';
import 'package:retroshare/model/location.dart';

const RETROSHARE_HOST = "127.0.0.1";
const RETROSHARE_PORT = 9092;
const RETROSHARE_SERVICE_PREFIX = "http://$RETROSHARE_HOST:$RETROSHARE_PORT";

String getRetroshareServicePrefix() => RETROSHARE_SERVICE_PREFIX;

dynamic checkLoggedIn() async {
  final response =
      await http.get('http://localhost:9092/rsLoginHelper/isLoggedIn');
  print(response.body);

  if (response.statusCode == 200)
    return json.decode(response.body)['retval'];
  else
    throw Exception('Failed to load response');
}

Future<bool> isRetroshareRunning() async {
  final String reqUrl = "http://localhost:9092";
  try {
    final response = await http.get(reqUrl);
    print(response.body);
    return response != null && response.statusCode is int;
  } catch (err) {
    print(err);
    return false;
  }
}

Future<bool> getLocations() async {
  final response =
      await http.get('$RETROSHARE_SERVICE_PREFIX/rsLoginHelper/getLocations');

  if (response.statusCode == 200) {
    accountsList = new List();
    json.decode(response.body)['locations'].forEach((location) {
      if (location != null)
        accountsList.add(Account(location['mLocationId'], location['mPgpId'],
            location['mLocationName'], location['mPgpName']));
    });

    var currAccount = await openapi.rsAccountsGetCurrentAccountId();
    for (Account account in accountsList) {
      if (account.locationId == currAccount.id) lastAccountUsed = account;
    }

    return true;
  } else
    return false;
}

dynamic requestLogIn(Account selectedAccount, String password) async {
  var accountDetails = {
    'account': selectedAccount.locationId,
    'password': password
  };

  final response = await http.post(
      '$RETROSHARE_SERVICE_PREFIX/rsLoginHelper/attemptLogin',
      body: json.encode(accountDetails));

  if (response.statusCode == 200) {
    return json.decode(response.body)['retval'];
  } else {
    throw Exception('Failed to load response');
  }
}

String makeAuthHeader(String username, String password) =>
    'Basic ' + base64Encode(utf8.encode('$username:$password'));

Future<Map<String, dynamic>> rsApiCall(
  String path, {
  Map<String, dynamic> params,
  String basicAuth,
}) async {
  final String reqUrl = getRetroshareServicePrefix() + path;
  await isRetroshareRunning();
  try {
    final response = await http.post(
      reqUrl,
      body: jsonEncode(params ?? {}),
      // headers: <String, String>{'Authorization': basicAuth}
    );
    print(response.body);
    if (response == null) throw Exception("Request failed: " + reqUrl);

    return response.statusCode == 200
        ? jsonDecode(utf8.decode(response.bodyBytes))
        : throw Exception("error");
  } catch (err) {
    throw err;
  }
}

Future<Map> createLocation(String locationName, String password,
    {String api_user}) async {
  final mPath = "/rsLoginHelper/createLocationV2";
  final mParams = {
    "locationName": locationName,
    "pgpName": locationName,
    "password": password,
    "apiUser": "retroshare",
    /* TODO(G10h4ck): The new token scheme permit arbitrarly more secure
       * options to avoid sending PGP password at each request. */
    "apiPass": password
  };
  final response = await rsApiCall(mPath, params: mParams);

  if (!(response is Map))
    throw FormatException("response is not a Map");
  else if (response["retval"]["errorNumber"] != 0)
    throw Exception("Failure creating location: " + jsonEncode(response));
  else if (!(response["locationId"] is String))
    throw FormatException("location is not a String");

  Map<String, String> location = {
    "mLocationName": locationName,
    "mLocationId": response["locationId"]
  };
  return location;
}

dynamic requestAccountCreation(
    BuildContext context, String username, String password,
    [String nodeName = 'Mobile']) async {
  final mParams = {
    "locationName": username,
    "pgpName": username,
    "password": password,
    "apiUser": username,
    /* TODO(G10h4ck): The new token scheme permit arbitrarly more secure
       * options to avoid sending PGP password at each request. */
    "apiPass": password
  };
  final response = await http.post(
      '$RETROSHARE_SERVICE_PREFIX/rsLoginHelper/createLocationV2',
      body: json.encode(mParams));

  if (response.statusCode == 200) {
    final resp = jsonDecode(utf8.decode(response.bodyBytes));
    print(resp);
    if (!(resp is Map))
      throw FormatException("response is not a Map");
    else if (resp["retval"]["errorNumber"] != 0)
      throw Exception("Failure creating location: " + jsonEncode(response));
    else if (!(resp["locationId"] is String))
      throw FormatException("location is not a String");

    Account account = Account(resp['mLocationId'], resp['mPgpId'],
        mParams['LocationName'], mParams['PgpName']);

    return Tuple2<bool, Account>(
        resp["retval"]["errorNumber"] != 0 ? false : true, account);
  } else {
    throw Exception('Failed to load response');
  }
}

Future<String> getOwnCert() async {
  final response = await http
      .get('$RETROSHARE_SERVICE_PREFIX/rsPeers/GetRetroshareInvite', headers: {
    HttpHeaders.authorizationHeader:
        'Basic ' + base64.encode(utf8.encode('$authToken'))
  });

  if (response.statusCode == 200) {
    return json.decode(response.body)['retval'];
  } else {
    throw Exception('Failed to load response');
  }
}

Future<bool> addCert(String cert) async {
  final response = await http.post(
    '$RETROSHARE_SERVICE_PREFIX/rsPeers/acceptInvite',
    headers: {
      HttpHeaders.authorizationHeader:
          'Basic ' + base64.encode(utf8.encode('$authToken'))
    },
    body: json.encode({'invite': cert}),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body)['retval'];
  } else {
    throw Exception('Failed to load response');
  }
}

Future<List<Location>> getFriendsAccounts() async {
  await isRetroshareRunning();
  final response = await http.get(
    '$RETROSHARE_SERVICE_PREFIX/rsPeers/getFriendList',
    headers: {
      HttpHeaders.authorizationHeader:
          'Basic ' + base64.encode(utf8.encode('$authToken'))
    },
  );

  if (response.statusCode == 200) {
    var sslIds = json.decode(response.body)['sslIds'];
    List<Location> locations = List();
    for (int i = 0; i < sslIds.length; i++) {
      locations.add(await getLocationsDetails(sslIds[i]));
    }
    return locations;
  } else {
    throw Exception('Failed to load response');
  }
}

Future<Location> getLocationsDetails(String peerId) async {
  final response = await http.post(
    '$RETROSHARE_SERVICE_PREFIX/rsPeers/getPeerDetails',
    headers: {
      HttpHeaders.authorizationHeader:
          'Basic ' + base64.encode(utf8.encode('$authToken'))
    },
    body: json.encode({'sslId': peerId}),
  );

  if (response.statusCode == 200) {
    var det = json.decode(response.body)['det'];
    return Location(
      det['id'],
      det['gpg_id'],
      det['name'],
      det['location'],
      det['connectState'] != 0 &&
          det['connectState'] != 2 &&
          det['connectState'] != 3,
    );
  } else {
    throw Exception('Failed to load response');
  }
}
