import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:retroshare/Middleware/shared_preference.dart';

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

  if (response.statusCode == 200) {
    accountsList = [];
    json.decode(response.body)['locations'].forEach((location) {
      if (location != null)
        accountsList.add(Account(location['mLocationId'], location['mPgpId'],
            location['mLocationName'], location['mPgpName']));
    });
    return accountsList;
  }
  return [];
}

Future<String> exportIdentity(String pgpId, AuthToken authToken) async {
  final authToken = await authcheck();
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

Future<String> importIdentity(String data, AuthToken authToken) async {
  final authToken = await authcheck();
  final response = await http.post(
      'http://localhost:9092/rsAccounts/importIdentityFromString',
      body: json.encode({"data": data}));
  if (response.statusCode == 200) {
    final resp =
        await http.post('http://localhost:9092/rsAccounts/getGPGDetails',
            body: json.encode({
              'gpg-id': [json.decode(response.body)['pgpId']]
            }));

    

    return json.decode(response.body)['pgpId'];
  } else
    throw Exception('Failed to load response');
}

dynamic requestLogIn(Account selectedAccount, String password) async {
  final authToken = await authcheck();
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
  final accountDetails = {
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

  if (response.statusCode == 200 && json.decode(response.body)['retval']) {
    dynamic resp = json.decode(response.body)['location'];
    Account account = Account(resp['mLocationId'], resp['mPgpId'],
        resp['mLocationName'], resp['mPgpName']);

    return Tuple2<bool, Account>(json.decode(response.body)['retval'], account);
  } else {
    throw Exception('Failed to load response');
  }
}

Future<String> getOwnCert(AuthToken authToken) async {
  final authToken = await authcheck();
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

Future<String> getShortInvite(AuthToken authToken) async {
  final authToken = await authcheck();
  final response =
      await http.get('http://localhost:9092/rsPeers/getShortInvite', headers: {
    HttpHeaders.authorizationHeader:
        'Basic ' + base64.encode(utf8.encode('$authToken'))
  });

  if (response.statusCode == 200 && json.decode(response.body)['retval']) {
    return json.decode(response.body)['invite'].substring(31);
  } else {
    throw Exception('Failed to load response');
  }
}

Future<bool> addCert(String cert,AuthToken authToken) async {
  final response = await http.post(
    'http://localhost:9092/rsPeers/acceptInvite',
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

Future<bool> parseShortInvite(String cert, AuthToken authToken) async {

  final response = await http.post(
    'http://localhost:9092/rsPeers/parseShortInvite',
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

Future<List<Location>> getFriendsAccounts(AuthToken authToken) async {

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
      locations.add(await getLocationsDetails(sslIds[i],authToken));
    }
    return locations;
  } else {
    throw Exception('Failed to load response');
  }
}

Future<Location> getLocationsDetails(String peerId, AuthToken authToken) async {
  final authToken = await authcheck();
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
