import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:tuple/tuple.dart';

import 'package:retroshare/model/account.dart';
import 'package:retroshare/model/auth.dart';
import 'package:retroshare/model/location.dart';

dynamic checkLoggedIn() async {
  final response =
      await http.get('http://localhost:9092/rsLoginHelper/isLoggedIn');

  if (response.statusCode == 200)
    return json.decode(response.body)['retval'];
  else
    throw Exception('Failed to load response');
}

Future<List<Account>> getLocations() async {
  final response =
      await http.get('http://localhost:9092/rsLoginHelper/getLocations');
  print(response.body);
  if (response.statusCode == 200) {
    accountsList = [];
    json.decode(response.body)['locations'].forEach((location) {
      if (location != null)
        accountsList.add(Account(location['mLocationId'], location['mPgpId'],
            location['mLocationName'], location['mPgpName']));
    });

    var currAccount = await openapi.rsAccountsGetCurrentAccountId();
    for (Account account in accountsList) {
      if (account.locationId == currAccount.id) lastAccountUsed = account;
    }
    return accountsList;
  }
  return [];
}

Future<String> exportIdentity(String pgpId) async {
  final response =
      await http.post('http://localhost:9092/rsAccounts/exportIdentityToString',
          headers: {
            HttpHeaders.authorizationHeader:
                'Basic ' + base64.encode(utf8.encode('$authToken'))
          },
          body: json.encode({"pgpId": pgpId}));
  if (response.statusCode == 200)
    return json.decode(response.body)['data'];
  else
    throw Exception('Failed to load response');
}

Future<String> importIdentity(String data) async {
  final response = await http.post(
      'http://localhost:9092/rsAccounts/importIdentityFromString',
      body: json.encode({"data": data}));
  if (response.statusCode == 200) {
    final resp =
        await http.post('http://localhost:9092/rsAccounts/getGPGDetails',
            body: json.encode({
              'gpg-id': [json.decode(response.body)['pgpId']]
            }));

    print(json.decode(response.body));
    print(resp.body);

    return json.decode(response.body)['pgpId'];
  } else
    throw Exception('Failed to load response');
}

dynamic requestLogIn(Account selectedAccount, String password) async {
  var accountDetails = {
    'account': selectedAccount.locationId,
    'password': password
  };

  final response = await http.post(
      'http://localhost:9092/rsLoginHelper/attemptLogin',
      body: json.encode(accountDetails));

  if (response.statusCode == 200) {
    return json.decode(response.body)['retval'];
  } else {
    throw Exception('Failed to load response');
  }
}

dynamic requestAccountCreation(String username, String password,
    [String nodeName = 'Mobile']) async {
  /*final accountDetails = {
    "location": {
      "mLocationName": 'Mobile',
      "mPgpName": username,
    },
    "password": password,
    'makeHidden': false,
    'makeAutoTor': false
  };

  final response = await http.post(
      'http://localhost:9092/rsLoginHelper/createLocation',
      body: json.encode(accountDetails));
  print(response.body);
  if (response.statusCode == 200 && json.decode(response.body)['retval']) {
    dynamic resp = json.decode(response.body)['location'];
    Account account = Account(resp['mLocationId'], resp['mPgpId'],
        resp['mLocationName'], resp['mPgpName']);

    return Tuple2<bool, Account>(json.decode(response.body)['retval'], account);
  } else {
    throw Exception('Failed to load response');
  }*/
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
      'http://localhost:9092/rsLoginHelper/createLocationV2',
      body: json.encode(mParams));
  if (response.statusCode == 200) {
    final resp = await json.decode(response.body);
    if (!(resp is Map))
      throw FormatException("response is not a Map");
    else if (resp["retval"]["errorNumber"] != 0)
      throw Exception("Failure creating location: " + jsonEncode(response));
    else if (!(resp["locationId"] is String))
      throw FormatException("location is not a String");

    Account account = Account(resp['locationId'], resp['pgpId'],
        mParams['locationName'], mParams['pgpName']);
    return Tuple2<bool, Account>(
        resp["retval"]["errorNumber"] != 0 ? false : true, account);
  } else {
    throw Exception('Failed to load response');
  }



}

Future<String> getOwnCert() async {
  final response = await http
      .get('http://localhost:9092/rsPeers/GetRetroshareInvite', headers: {
    HttpHeaders.authorizationHeader:
        'Basic ' + base64.encode(utf8.encode('$authToken'))
  });

  if (response.statusCode == 200) {
    return json.decode(response.body)['retval'];
  } else {
    throw Exception('Failed to load response');
  }
}

Future<String> getShortInvite() async {
  final response =
      await http.get('http://localhost:9092/rsPeers/getShortInvite', headers: {
    HttpHeaders.authorizationHeader:
        'Basic ' + base64.encode(utf8.encode('$authToken'))
  });
  print(response.body);
  if (response.statusCode == 200 && json.decode(response.body)['retval']) {
    return json.decode(response.body)['invite'].substring(31);
  } else {
    throw Exception('Failed to load response');
  }
}

Future<bool> addCert(String cert) async {
  final response = await http.post(
    'http://localhost:9092/rsPeers/acceptInvite',
    headers: {
      HttpHeaders.authorizationHeader:
          'Basic ' + base64.encode(utf8.encode('$authToken'))
    },
    body: json.encode({'invite': cert}),
  );
  print(response.body);
  if (response.statusCode == 200) {
    return json.decode(response.body)['retval'];
  } else {
    throw Exception('Failed to load response');
  }
}

Future<bool> parseShortInvite(String cert) async {
  final response = await http.post(
    'http://localhost:9092/rsPeers/parseShortInvite',
    headers: {
      HttpHeaders.authorizationHeader:
          'Basic ' + base64.encode(utf8.encode('$authToken'))
    },
    body: json.encode({'invite': cert}),
  );
  print(response.body);
  if (response.statusCode == 200) {
    return json.decode(response.body)['retval'];
  } else {
    throw Exception('Failed to load response');
  }
}

Future<List<Location>> getFriendsAccounts() async {
  final response = await http.get(
    'http://localhost:9092/rsPeers/getFriendList',
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
    'http://localhost:9092/rsPeers/getPeerDetails',
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
