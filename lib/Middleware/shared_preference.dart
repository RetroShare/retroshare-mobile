import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eventsource/eventsource.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';

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
      print("hello");
      print(jsonData);
    });

    streamSubscription.onError(onError);
  } on EventSourceSubscriptionException catch (e) {
    print('registerEventsHandler error: ' + e.message);
    throw (statusCodeErrorMessages(e.statusCode, path, reqUrl));
  }
  return streamSubscription;
}
