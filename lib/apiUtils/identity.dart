import 'package:retroshare_api_wrapper/retroshare.dart';
import 'package:tuple/tuple.dart';

Future<List<Identity>> getOwnIdentities(AuthToken authToken) async {
  final List<Identity> ownIdsList = [];

  /// fetch the signed Identity
  final List<dynamic> respSigned =
      await RsIdentity.getOwnSignedIdentity(authToken);

  respSigned
    ..toSet().forEach((id) {
      if (id != null && isNullCheck(id)) {
        ownIdsList.add(Identity(id, true));
      }
    });

  /// fetch the Unsigned Identity
  final List<dynamic> respPseudonymous =
      await RsIdentity.getOwnPseudonimousIds(authToken);

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
Future<Tuple3<List<Identity>, List<Identity>, List<Identity>>> getAllIdentities(
    AuthToken authToken) async {
  final response = await RsIdentity.getIdentitiesSummaries(authToken);
  List<String> ids = [];
  response.forEach((id) {
    ids.add(id['mGroupId']);
  });
  final response2 = await RsIdentity.getIdentitiesInfo(ids, authToken);

  List<Identity> notContactIds = [];
  List<Identity> contactIds = [];
  List<Identity> signedContactIds = [];
  List<Identity> ownIds = [];
  final idsInfo = response2;
  for (var i = 0; i < idsInfo.length; i++) {
    if (idsInfo[i]['mIsAContact'] == true &&
        idsInfo[i]['mMeta']['mSubscribeFlags'] != 7) {
      // get the  contact IDs and Unknown Ids
      final Tuple2<Identity, bool> knownIden =
          await getKnownIdentity(idsInfo[i], authToken);
      if (knownIden.item2) {
        signedContactIds.add(knownIden.item1);
      }
      contactIds.add(knownIden.item1);
    } else if (idsInfo[i]['mMeta']['mSubscribeFlags'] == 7) {
      // ownIdentity
      ownIds.add(Identity(
          idsInfo[i]['mMeta']['mGroupId'],
          idsInfo[i]['mPgpId'] != '0000000000000000',
          idsInfo[i]['mMeta']['mGroupName'],
          ''));
    } else {
      // unknown Identity
      notContactIds.add(Identity(
          idsInfo[i]['mMeta']['mGroupId'],
          idsInfo[i]['mPgpId'] != '0000000000000000',
          idsInfo[i]['mMeta']['mGroupName'],
          ''));
    }
  }
  // sort the unknown Identity by name
  notContactIds.sort((id1, id2) {
    return id1.name.compareTo(id2.name);
  });
  return Tuple3<List<Identity>, List<Identity>, List<Identity>>(
      signedContactIds, contactIds, notContactIds);
}

Future<Tuple2<Identity, bool>> getKnownIdentity(
    dynamic idsInfo, AuthToken authToken) async {
  Identity identity;
  bool success = true;
  do {
    final Tuple2<bool, Identity> tuple =
        await getIdDetails(idsInfo['mMeta']['mGroupId'], authToken);
    success = tuple.item1;
    identity = tuple.item2;
  } while (!success);

  // This is because sometimes,
  // the returning Id of [getIdDetails], that is a
  // result of call 'torsIdentity/getIdDetails', return identity details, from the cache
  // So sometimes the avatar are not updated, instead of in rsIdentity/getIdentitiesInfo, where they are
  if (identity.avatar == '' && idsInfo['mImage']['mData']['base64'] != '') {
    identity.avatar = idsInfo['mImage']['mData']['base64'];
  }
  identity.isContact = true;

  //return the tuple
  return Tuple2<Identity, bool>(identity, identity.signed);
}

bool isNullCheck(String s) {
  return s != '00000000000000000000000000000000';
}
