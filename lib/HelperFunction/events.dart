import 'dart:async';
import 'dart:convert';
import 'dart:io';
import "package:eventsource/eventsource.dart";
import 'package:retroshare_api_wrapper/retroshare.dart';

Map<RsEventType, StreamSubscription<Event>> rsEventsSubscriptions;

/// Register event specifically for chat messages
/// This function add code to deserialization of the message, automatizing the process.
Future<StreamSubscription<Event>> eventsRegisterChatMessage(
    {Function listenCb, Function onError, AuthToken authToken}) async {
  return await registerEvent(RsEventType.CHAT_MESSAGE, (Event event) {
    // Deserialize the message
    var jsonData = event.data != null ? jsonDecode(event.data) : null;
    ChatMessage chatMessage;
    print(jsonData['event']);
    if (jsonData['event'] != null) {
      chatMessage = ChatMessage.fromJson(jsonData['event']['mChatMessage']);
    }
    if (listenCb != null) listenCb(json, chatMessage);
  }, authToken, onError: onError);
}

/// Register generic Event
///
/// Where [eventType] is the enum that specifies the code.
Future<StreamSubscription<Event>> registerEvent(
    RsEventType eventType, Function listenCb, AuthToken authToken,
    {Function onError}) async {
  var body = {'eventType': eventType.index};
  String url = "http://127.0.0.1:9092/rsEvents/registerEventsHandler";
  EventSource eventSource = await EventSource.connect(
    url,
    method: "POST",
    body: body,
    headers: {
      HttpHeaders.authorizationHeader:
          'Basic ' + base64.encode(utf8.encode('$authToken'))
    },
  );

  StreamSubscription<Event> streamSubscription = eventSource.listen(listenCb);
  streamSubscription.onError(onError);

  // Store the subscription on a dictionary
  rsEventsSubscriptions ??= Map();
  rsEventsSubscriptions[eventType] = streamSubscription;
  return streamSubscription;
}
