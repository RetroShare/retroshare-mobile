import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eventsource/eventsource.dart';
import 'package:flutter/cupertino.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';

Future<StreamSubscription<Event>> registerEventsHandlers(
    RsEventType eventType, Function callback, AuthToken authToken,
    {Function onError, String basicAuth}) async {
  final body = {'eventType': eventType.index};
  const path = '/rsEvents/registerEventsHandler';
  final reqUrl = getRetroshareServicePrefix() + path;
  StreamSubscription<Event> streamSubscription;
  try {
    final eventSource = await EventSource.connect(
      reqUrl,
      method: 'GET',
      body: jsonEncode(body),
      headers: {
        HttpHeaders.authorizationHeader:
            'Basic ${base64.encode(utf8.encode('$authToken'))}'
      },
    );

    streamSubscription = eventSource.listen((Event event) {
      // Deserialize the message
      final jsonData = event.data != null ? jsonDecode(event.data) : null;
      debugPrint(jsonData);
    });

    streamSubscription.onError(onError);
  } on EventSourceSubscriptionException catch (e) {
    print('registerEventsHandler error: ${e.message}');
    throw statusCodeErrorMessages(e.statusCode, path, reqUrl);
  }
  return streamSubscription;
}
