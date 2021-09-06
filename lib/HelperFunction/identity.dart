import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:retroshare_api_wrapper/retroshare.dart';
import 'package:tuple/tuple.dart';

Future<List<Identity>> getOwnIdentities(AuthToken authToken) async {
  final List<Identity> ownIdsList = [];

  /// fetch the signed Identity
  final List<dynamic> respSigned =
      await RsIdentity.getOwnSignedIdentity(authToken);

  // ignore: avoid_single_cascade_in_expression_statements
  respSigned
    ..toSet().forEach((id) {
      if (id != null && isNullCheck(id)) {
        ownIdsList.add(Identity(id, true));
      }
    });

  /// fetch the Unsigned Identity
  final List<dynamic> respPseudonymous =
      await RsIdentity.getOwnPseudonimousIds(authToken);
  // ignore: avoid_single_cascade_in_expression_statements
  respPseudonymous
    ..toSet().forEach((id) {
      if (id != null && isNullCheck(id)) {
        ownIdsList.add(Identity(id, false));
      }
    });

  for (int x = 0; x < ownIdsList.length; x++) {
    final resp = await getIdDetails(ownIdsList[x].mId, authToken);
    if (resp.item1) ownIdsList[x] = resp.item2;
  }

  return ownIdsList;
}

Future<Tuple2<bool, Identity>> getIdDetails(
    String id, AuthToken authToken) async {
  final response = await RsIdentity.getIdDetails(id, authToken);

  if (response['retval'] as bool) {
    Identity identity = Identity(id);
    //print(response);
    identity.name = response['details']['mNickname'];
    identity.avatar =
        response['details']['mAvatar']['mData']['base64'] != null &&
                response['details']['mAvatar']['mData']['base64']
                    .toString()
                    .isNotEmpty
            ? response['details']['mAvatar']['mData']['base64'].toString()
            : null;

    if (response['details']['mPgpId'] != '0000000000000000') {
      identity.signed = true;
    } else {
      identity.signed = false;
    }

    return Tuple2<bool, Identity>(true, identity);
  }
  return Tuple2<bool, Identity>(false, Identity(''));
}

// Identities that are not contacts do not have loaded avatars
dynamic getAllIdentities(AuthToken authToken) async {
  final response = await http
      .get('http://127.0.0.1:9092/rsIdentity/getIdentitiesSummaries', headers: {
    HttpHeaders.authorizationHeader:
        'Basic ${base64.encode(utf8.encode('$authToken'))}'
  });

  if (response.statusCode == 200) {
    List<String> ids = [];
    json.decode(response.body)['ids'].forEach((id) {
      ids.add(id['mGroupId']);
    });

    final response2 = await http.post(
      'http://127.0.0.1:9092/rsIdentity/getIdentitiesInfo',
      headers: {
        HttpHeaders.authorizationHeader:
            'Basic ${base64.encode(utf8.encode('$authToken'))}'
      },
      body: json.encode({'ids': ids}),
    );

    final List<Identity> notContactIds = [];
    final List<Identity> contactIds = [];
    final List<Identity> signedContactIds = [];
    final List<Identity> ownIds = [];

    if (response2.statusCode == 200) {
      final idsInfo = json.decode(response2.body)['idsInfo'];
      for (var i = 0; i < idsInfo.length; i++) {
        if (idsInfo[i]['mIsAContact'] == true &&
            idsInfo[i]['mMeta']['mSubscribeFlags'] != 7) {
          bool success = true;
          Identity id;
          do {
            final Tuple2<bool, Identity> tuple =
                await getIdDetails(idsInfo[i]['mMeta']['mGroupId'], authToken);
            success = tuple.item1;
            id = tuple.item2;
          } while (!success);
          // This is because sometimes,
          // the returning Id of [getIdDetails], that is a
          // result of call 'torsIdentity/getIdDetails', return identity details, from the cache
          // So sometimes the avatar are not updated, instead of in rsIdentity/getIdentitiesInfo, where they are
          if (id.avatar == '' &&
              idsInfo[i]['mImage']['mData']['base64'] != '') {
            id.avatar = idsInfo[i]['mImage']['mData']['base64'];
          }
          id.isContact = true;
          contactIds.add(id);
          if (id.signed) signedContactIds.add(id);
        } else if (idsInfo[i]['mMeta']['mSubscribeFlags'] == 7) {
          ownIds.add(Identity(
              idsInfo[i]['mMeta']['mGroupId'],
              idsInfo[i]['mPgpId'] != '0000000000000000',
              idsInfo[i]['mMeta']['mGroupName'],
              ''));
        } else {
          notContactIds.add(Identity(
              idsInfo[i]['mMeta']['mGroupId'],
              idsInfo[i]['mPgpId'] != '0000000000000000',
              idsInfo[i]['mMeta']['mGroupName'],
              ''));
        }
      }

      notContactIds.sort((id1, id2) {
        return id1.name.compareTo(id2.name);
      });
      return Tuple3<List<Identity>, List<Identity>, List<Identity>>(
          signedContactIds, contactIds, notContactIds);
    }
  } else {
    throw Exception('Failed to load response');
  }
}

bool isNullCheck(String s) {
  return s != '00000000000000000000000000000000';
}
