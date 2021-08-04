import 'dart:collection';
import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:retroshare/model/auth.dart';

Future<bool> isAuthTokenValid(AuthToken authToken) async {
  final response = await http
      .get('http://localhost:9092/RsJsonApi/getAuthorizedTokens', headers: {
    HttpHeaders.authorizationHeader:
        'Basic ' + base64.encode(utf8.encode('$authToken'))
  });

  if (response.statusCode == 200) {
    return true;
  } else
    return false;
}

Future<bool> checkExistingAuthTokens(
    String locationId, String password, AuthToken authToken) async {
  final response = await http
      .get('http://localhost:9092/RsJsonApi/getAuthorizedTokens', headers: {
    HttpHeaders.authorizationHeader:
        'Basic ' + base64.encode(utf8.encode('$locationId:$password'))
  });

  if (response.statusCode == 200) {
    for (LinkedHashMap<String, dynamic> token
        in json.decode(response.body)['retval']) {
      if (token['key'] + ":" + token['value'] == authToken.toString())
        return true;
    }
    authorizeNewToken(locationId, password, authToken);
    return true;
  } else if (response.statusCode == 401) {
    return false;
  } else
    throw Exception('Failed to load response');
}

void authorizeNewToken(
    String locationId, String password, AuthToken authToken) async {
  final response = await http.post(
      'http://localhost:9092/RsJsonApi/authorizeUser',
      body: json.encode({'token': '$authToken'}),
      headers: {
        HttpHeaders.authorizationHeader:
            'Basic ' + base64.encode(utf8.encode('$locationId:$password'))
      });

  if (response.statusCode == 200) {
    return;
  }

  throw Exception('Failed to load response');
}
