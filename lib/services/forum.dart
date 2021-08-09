import 'dart:convert';
import 'dart:io';
import 'package:retroshare/model/auth.dart';
import 'package:http/http.dart' as http;
import '../model/events.dart';

String errToStr(Map<String, dynamic> cxx_std_error_condition) {
  var err = cxx_std_error_condition;
  return "${err["errorCategory"]} ${err["errorNumber"]} ${err["errorMessage"]}";
}

Future<Map<String, dynamic>> rsApiCall(
  String path,
  AuthToken authToken, {
  Map<String, dynamic> params,
}) async {
  final reqUrl = 'http://localhost:9092${path}';
  final response = await http
      .post(Uri.parse(reqUrl), body: jsonEncode(params ?? {}), headers: {
    HttpHeaders.authorizationHeader:
        'Basic ' + base64.encode(utf8.encode('$authToken'))
  });
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else
    throw Exception('Failed to load response');
}

Future<String> createForumV2(String name, AuthToken authToken,
    {String circleId = '', String description = ''}) async {
  var circleType =
      circleId.isEmpty ? RsGxsCircleType.PUBLIC : RsGxsCircleType.EXTERNAL;

  final response =
      await rsApiCall('/rsGxsForums/createForumV2', authToken, params: {
    'name': name,
    'description': description,
    'circleType': circleType.index,
    'circleId': circleId
  });
  if (response['retval'] != true) {
    throw Exception('Forum could not be created.');
  }
  return response['forumId'];
}

Future<String> createPost(String forumId, String title, String mBody,
    String authorId, AuthToken authToken,
    [String parentId = '', String origPostId = '']) async {
  final response =
      await rsApiCall('/rsGxsForums/createPost', authToken, params: {
    'forumId': forumId,
    'title': title,
    'mBody': mBody,
    'authorId': authorId,
    'parentId': parentId,
    'origPostId': origPostId
  });
  if (response['retval'] != true) {
    throw Exception('${response["errorMessage"]}');
  }
  return response['postMsgId'];
}

Future<List<dynamic>> getForumsInfo(
    List<String> forumIds, AuthToken authToken) async {
  final response = await rsApiCall('/rsGxsForums/getForumsInfo', authToken,
      params: {'forumIds': forumIds});
  if (response['retval'] != true) {
    throw Exception('Could not retrieve forums info');
  }
  return response['forumsInfo'];
}

Future<List<dynamic>> getForumsSummaries(AuthToken authToken) async {
  final response =
      await rsApiCall('/rsGxsForums/getForumsSummaries', authToken);
  if (response['retval'] != true) {
    throw Exception('Could not retrieve forum summaries');
  }
  getForumMsgMetaData(response['forums'][0]['mGroupId'], authToken);
  return response['forums'];
}

Future<List<RsMsgMetaData>> getForumMsgMetaData(
    String forumId, AuthToken authToken) async {
  final response = await rsApiCall(
      '/rsGxsForums/getForumMsgMetaData', authToken,
      params: {'forumId': forumId});
  if (response['retval'] != true) {
    throw Exception('Could not retrieve messages metadata');
  }
  return [
    for (Map<String, dynamic> meta in response['msgMetas'])
      RsMsgMetaData.fromJson(meta)
  ];
}

Future<List<dynamic>> getForumContent(
    String forumId, AuthToken authToken, List<String> msgIds) async {
  final response = await rsApiCall('/rsGxsForums/getForumContent', authToken,
      params: {'forumId': forumId, 'msgsIds': msgIds});
  if (response['retval'] != true) {
    throw Exception('Could not retrieve messages content');
  }
  return response['msgs'];
}

Future<bool> subscribeToForum(
    String forumId, bool subscribe, AuthToken authToken) async {
  final response = await rsApiCall('/rsGxsForums/subscribeToForum', authToken,
      params: {'forumId': forumId, 'subscribe': true});
  if (response['retval'] != true) {
    throw Exception('Could not subscribe to forum');
  }
  return response['retval'] == true;
}

void requestSynchronization(AuthToken authToken) async {
  try {
    rsApiCall('/rsGxsForums/requestSynchronization', authToken);
  } catch (err) {
    print('/rsGxsForums/requestSynchronization not available $err');
  }
}

Future<List<dynamic>> getChildPosts(
    String forumId, String parentId, AuthToken authToken) async {
  final response = await rsApiCall('/rsGxsForums/getChildPosts', authToken,
      params: {'forumId': forumId, 'parentId': parentId});
  if (response['retval']['errorNumber'] != 0) {
    throw Exception(
        'Could not retrieve child posts for $forumId/$parentId. Response: $response');
  }
  List childPosts = response['childPosts'];
  // sort last comment on top
  childPosts.sort((a, b) => publishTs(b).compareTo(publishTs(a)));

//    final postsMeta =
//        childPosts.map((item) => item["mMeta"]).toList();
  return childPosts;
}

Future<int> distantSearchRequest(
    String matchString, AuthToken authToken) async {
  final response = await rsApiCall(
      '/rsGxsForums/distantSearchRequest', authToken,
      params: {'matchString': matchString});
  if (response['retval']['errorNumber'] != 0) {
    throw Exception("Error: ${(response["retval"])}");
  }
  return response['searchId'];
}

Future<List<dynamic>> localSearch(
    String matchString, AuthToken authToken) async {
  final response = await rsApiCall('/rsGxsForums/localSearch', authToken,
      params: {'matchString': matchString});
  if (response['retval']['errorNumber'] != 0) {
    throw Exception("Error: ${errToStr(response["retval"])}");
  }
  return response['searchResults'];
}

Future<bool> toggleSubscribeToForum(
    String forumId, bool subscribe, AuthToken authToken) async {
  final response = await rsApiCall('/rsGxsForums/subscribeToForum', authToken,
      params: {'forumId': forumId});
  return response['retval'];
}

String publishTs(Map post) {
  String pts = post['mMeta']['mPublishTs']['xstr64'];
  return pts;
}

