import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eventsource/eventsource.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AuthToken> authcheck() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return AuthToken(
      prefs.containsKey('username') ? prefs.getString('username') : '',
      prefs.containsKey('password') ? prefs.getString('password') : '');
}

Future<StreamSubscription<Event>> registerEventsHandlers(
    RsEventType eventType, Function callback, AuthToken authToken,
    {Function onError, String basicAuth}) async {
  var body = {'eventType': eventType.index};
  var path = '/rsEvents/registerEventsHandler';
  var reqUrl = getRetroshareServicePrefix() + path;
  StreamSubscription<Event> streamSubscription;
  try {
    var eventSource = await EventSource.connect(
      reqUrl,
      method: 'GET',
      body: jsonEncode(body),
      headers: {
        HttpHeaders.authorizationHeader:
            'Basic ' + base64.encode(utf8.encode('$authToken'))
      },
    );

    streamSubscription = eventSource.listen((Event event) {
      // Deserialize the message
      var jsonData = event.data != null ? jsonDecode(event.data) : null;
    });
    streamSubscription.onError(onError);
  } on EventSourceSubscriptionException catch (e) {
    print('registerEventsHandler error: ' + e.message);
    throw (statusCodeErrorMessages(e.statusCode, path, reqUrl));
  }
  return streamSubscription;
}
