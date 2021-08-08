import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:openapi/api.dart';
import 'package:tuple/tuple.dart';
import 'package:retroshare/model/identity.dart';
import 'package:retroshare/model/auth.dart';

Future<List<Identity>> getOwnIdentities(AuthToken authToken) async {
  List<Identity> ownIdsList = [];

  final respSigned = await http
      .get('http://127.0.0.1:9092/rsIdentity/getOwnSignedIds', headers: {
    HttpHeaders.authorizationHeader:
        'Basic ' + base64.encode(utf8.encode('$authToken'))
  });

  if (respSigned.statusCode == 200) {
    json.decode(respSigned.body)['ids']
      ..toSet().forEach((id) {
        if (id != null) ownIdsList.add(Identity(id, true));
      });
  }

  final respPseudonymous = await http
      .get('http://127.0.0.1:9092/rsIdentity/getOwnPseudonimousIds', headers: {
    HttpHeaders.authorizationHeader:
        'Basic ' + base64.encode(utf8.encode('$authToken'))
  });

  if (respPseudonymous.statusCode == 200) {
    json.decode(respPseudonymous.body)['ids']
      ..toSet().forEach((id) {
        if (id != null) ownIdsList.add(Identity(id, false));
      });
  }

  for (int x = 0; x < ownIdsList.length; x++) {
    var resp = await getIdDetails(ownIdsList[x].mId, authToken);
    if (resp.item1) ownIdsList[x] = resp.item2;
  }

  return ownIdsList;
}

Future<Tuple2<bool, Identity>> getIdDetails(
    String id, AuthToken authToken) async {
  final response = await http.post(
      'http://127.0.0.1:9092/rsIdentity/getIdDetails',
      body: json.encode({'id': id}),
      headers: {
        HttpHeaders.authorizationHeader:
            'Basic ' + base64.encode(utf8.encode('$authToken'))
      });

  if (response.statusCode == 200) {
    if (json.decode(response.body)['retval']) {
      Identity identity = Identity(id);
      identity.name = json.decode(response.body)['details']['mNickname'];
      identity.avatar = json.decode(response.body)['mAvatar'] != null &&
              json.decode(response.body)['mAvatar']['mData'] != null
          ? json.decode(response.body)['mAvatar']['mData']['base64']
          : null;

      identity.signed =
          json.decode(response.body)['details']['mPgpId'] != '0000000000000000'
              ? true
              : false;

      return Tuple2<bool, Identity>(true, identity);
    }

    return Tuple2<bool, Identity>(false, Identity(''));
  } else
    throw Exception('Failed to load response');
}

Future<Identity> createIdentity(
    Identity identity, avatar, AuthToken authToken) async {
  var params = {
    'name': identity.name,
    'pseudonimous': !identity.signed,
    'pgpPassword': authToken.password
  };
  if (identity.avatar != null) params['avatar'] = avatar.toJson();
  var b = json.encode(params);
  final response = await http.post(
      'http://127.0.0.1:9092/rsIdentity/createIdentity',
      body: b,
      headers: {
        HttpHeaders.authorizationHeader:
            'Basic ' + base64.encode(utf8.encode('$authToken'))
      });
  if (response.statusCode == 200) {
    if (json.decode(response.body)['retval'])
      return Identity(json.decode(response.body)['id'], identity.signed,
          identity.name, identity.avatar);
    else
      return Identity('');
  } else
    throw Exception('Failed to load response');
}

Future<bool> deleteIdentity(Identity identity, AuthToken authToken) async {
  final response = await http.post(
      'http://127.0.0.1:9092/rsIdentity/deleteIdentity',
      body: json.encode({'id': identity.mId}),
      headers: {
        HttpHeaders.authorizationHeader:
            'Basic ' + base64.encode(utf8.encode('$authToken'))
      });

  if (response.statusCode == 200) {
    if (json.decode(response.body)['retval']) return true;
    return false;
  } 
  
    throw Exception('Failed to load response');
}

Future<bool> updateApiIdentity(
    Identity identity, dynamic avatar, AuthToken authToken) async {
  final params = {
    'name': identity.name,
    'id': identity.mId,
    'pseudonimous': !identity.signed,
    "pgpPassword": authToken.password
  };
  if (identity.avatar != null) params['avatar'] = avatar.toJson();
  var b = json.encode(params);
  final response = await http.post(
      'http://127.0.0.1:9092/rsIdentity/updateIdentity',
      body: b,
      headers: {
        HttpHeaders.authorizationHeader:
            'Basic ' + base64.encode(utf8.encode('$authToken'))
      });
  if (response.statusCode == 200) {
    if (json.decode(response.body)['retval']) return true;
    return false;
  } else
    throw Exception('Failed to load response');
}

// Identities that are not contacts do not have loaded avatars
dynamic getAllIdentities(AuthToken authToken) async {
  final response = await http
      .get('http://127.0.0.1:9092/rsIdentity/getIdentitiesSummaries', headers: {
    HttpHeaders.authorizationHeader:
        'Basic ' + base64.encode(utf8.encode('$authToken'))
  });

  if (response.statusCode == 200) {
    List<String> ids = [];
    print(json.decode(response.body)['ids'].length);
    json.decode(response.body)['ids'].forEach((id) {
      ids.add(id['mGroupId']);
    });

    final response2 = await http.post(
      'http://127.0.0.1:9092/rsIdentity/getIdentitiesInfo',
      headers: {
        HttpHeaders.authorizationHeader:
            'Basic ' + base64.encode(utf8.encode('$authToken'))
      },
      body: json.encode({'ids': ids}),
    );

    List<Identity> notContactIds = [];
    List<Identity> contactIds = [];
    List<Identity> signedContactIds = [];
    List<Identity> ownIds = [];

    if (response2.statusCode == 200) {
      var idsInfo = json.decode(response2.body)['idsInfo'];
      for (var i = 0; i < idsInfo.length; i++) {
        if (idsInfo[i]['mIsAContact'] &&
            idsInfo[i]['mMeta']['mSubscribeFlags'] != 7) {
          bool success = true;
          Identity id;
          do {
            Tuple2<bool, Identity> tuple =
                await getIdDetails(idsInfo[i]['mMeta']['mGroupId'], authToken);
            success = tuple.item1;
            id = tuple.item2;
          } while (!success);
          // This is because sometimes, the returning Id of [getIdDetails], that is a
          // result of call 'torsIdentity/getIdDetails', return identity details, from the cache
          // So sometimes the avatar are not updated, instead of in rsIdentity/getIdentitiesInfo, where they are
          if (id.avatar == "" && idsInfo[i]['mImage']['mData']['base64'] != "")
            id.avatar = idsInfo[i]['mImage']['mData']['base64'];
          id.isContact = true;
          contactIds.add(id);
          if (id.signed) signedContactIds.add(id);
        } else if (idsInfo[i]['mMeta']['mSubscribeFlags'] == 7) {
          ownIds.add(Identity(
              idsInfo[i]['mMeta']['mGroupId'],
              idsInfo[i]['mPgpId'] != '0000000000000000',
              idsInfo[i]['mMeta']['mGroupName'],
              '',
              false));
        } else {
          notContactIds.add(Identity(
              idsInfo[i]['mMeta']['mGroupId'],
              idsInfo[i]['mPgpId'] != '0000000000000000',
              idsInfo[i]['mMeta']['mGroupName'],
              '',
              false));
        }
      }

      notContactIds.sort((id1, id2) {
        return id1.name.compareTo(id2.name);
      });
      print("checks");
      print(signedContactIds.length);
      print(contactIds.length);
      return Tuple3<List<Identity>, List<Identity>, List<Identity>>(
          signedContactIds, contactIds, notContactIds);
    }
  } else
    throw Exception('Failed to load response');
}

Future<bool> setContact(
    String id, bool makeContact, AuthToken authToken) async {
  final response = await http.post(
    'http://127.0.0.1:9092/rsIdentity/setAsRegularContact',
    headers: {
      HttpHeaders.authorizationHeader:
          'Basic ' + base64.encode(utf8.encode('$authToken'))
    },
    body: json.encode({'id': id, 'isContact': makeContact}),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body)['retval'];
  }
  throw Exception('Failed to load response');
}

/// Request unknown identity to near peers
Future<bool> requestIdentity(
  String id,
) async {
  ReqRequestIdentity req = ReqRequestIdentity()..id = id;
  openapi.rsIdentityRequestIdentity(reqRequestIdentity: req);
}

Future<bool> setAutoAddFriendIdsAsContact(
    bool enabled, AuthToken authToken) async {
  final response = await http.post(
      'http://127.0.0.1:9092/rsIdentity/setAutoAddFriendIdsAsContact',
      headers: {
        HttpHeaders.authorizationHeader:
            'Basic ' + base64.encode(utf8.encode('$authToken'))
      },
      body: jsonEncode({"enabled": enabled}));
}
