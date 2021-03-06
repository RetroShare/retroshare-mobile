import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:retroshare/Middleware/shared_preference.dart';
import 'package:retroshare/model/auth.dart';
import "package:eventsource/eventsource.dart";
import 'package:retroshare/model/chat.dart';
import 'package:retroshare/model/events.dart';

/// Register event specifically for chat messages
///
/// This function add code to deserialization of the message, automatizing the process.
Future<StreamSubscription<Event>> eventsRegisterChatMessage(
    {Function listenCb, Function onError}) async {
  return await registerEvent(RsEventType.CHAT_MESSAGE, (Event event) {
    // Deserialize the message
    var json = event.data != null ? jsonDecode(event.data) : null;
    ChatMessage chatMessage;
    if (json['event'] != null) {
      chatMessage = ChatMessage.fromJson(json['event']['mChatMessage']);
    }
    if (listenCb != null) listenCb(json, chatMessage);
  }, onError: onError);
}

/// Register generic Event
///
/// Where [eventType] is the enum that specifies the code.
Future<StreamSubscription<Event>> registerEvent(
    RsEventType eventType, Function listenCb,
    {Function onError}) async {
  if (rsEventsSubscriptions != null && rsEventsSubscriptions[eventType] != null)
    return null;

  var body = {'eventType': eventType.index};
  String url = "http://127.0.0.1:9092/rsEvents/registerEventsHandler";
  final authToken = await authcheck();
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
