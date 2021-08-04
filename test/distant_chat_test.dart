import 'package:flutter_test/flutter_test.dart';
import 'package:openapi/api.dart';
import 'package:retroshare/model/auth.dart';
import 'package:retroshare/services/chat.dart';

//// tests for ChatId
void main() {
  group('test distant Chat', () {
    String locationId = "814228577bc0c5da968c79272adcbfce";
    String password = "prueba";
    openapi = DefaultApi();
    //initializeAuth(locationId, password);
//
//    test('to test instant chat initiation', () async {
//      String from = '';
//      String to = '';
//      var res = await initiateDistantChat(to, from);
//      prints(res.peerId);
//      expect(res.status, anyOf(1, 2));
//    });
//
//    test('to test instant chat status', () async {
//      String from = 'b218b295b0af1f79d05ed36a0c54fcda';
//      String to = '4eb85b340bad7d54958e71634c8dfb9e';
//      await initiateDistantChat(to, from);
//      var res = await initiateDistantChat(to, from);
//      print(res);
//      expect(res.status, anyOf(1, 2));
//    });
//
//    test('to test send message', () async {
//      String from = 'b218b295b0af1f79d05ed36a0c54fcda';
//      String to = '4eb85b340bad7d54958e71634c8dfb9e';
//      var res = await initiateDistantChat(to, from);
//      expect(res.status, anyOf(1, 2));
//      var chatId = res.peerId;
//      String msg = "This is a test message2";
//      var msgResp = await sendMessage(chatId, msg, ChatIdType.number2_);
//      expect(msgResp.retval, true);
//    });
//
//    test('to test register event handler', () async {
//      var chatId = "2f9f47c4a2d4bbddb25a9f6d14de0eab";
//      await eventsRegisterChatMessage((var json, ChatMessage chatMessage) {
//        if (json['retval'] != null) {
//          print("Handler started");
//          print(json['retval']);
//          expect(json['retval']['errorNumber'], 0);
//        } else if (chatMessage != null) {
//          print("Message received");
//          print(json['event']);
//          expect(json["event"]["mType"], RsEventType.CHAT_MESSAGE.index);
//        }
//      });
//      // Time to send a message
//      await Future.delayed(const Duration(seconds: 15));
//    });
//
//    test('to test avatar', () async {
////      Tuple2<bool, Identity> tuple = await getIdDetails("4eb85b340bad7d54958e71634c8dfb9e");
//
//    var id = '4eb85b340bad7d54958e71634c8dfb9e';
//      final response = await http.post(
//          'http://127.0.0.1:9092/rsIdentity/getIdDetails',
//          body: json.encode({'id': id}),
//          headers: {
//            HttpHeaders.authorizationHeader:
//            'Basic ' + base64.encode(utf8.encode('$authToken'))
//          });
//
//      if (response.statusCode == 200) {
//        if (json.decode(response.body)['retval']) {
//
////          Identity identity = Identity(id);
////          identity.name = json.decode(response.body)['details']['mNickname'];
////        response.body
//          String avatar = json.decode((response.body))['details']['mAvatar']['mData'];
//
//          print(avatar);
//
//
////          String avatar =
////            json.decode((response.body))['details']['mAvatar']['mData'];
////          print(avatar);
////          identity.signed =
////              json.decode(response.body)['details']['mPgpId'] != '0000000000000000';
////          return Tuple2<bool, Identity>(true, identity);
//        } else
//          return;
////          return Tuple2<bool, Identity>(false, Identity(''));
//      } else
//        throw Exception('Failed to load response');
//
//
//
//    });

    test('to test set autosubscribe', () async {
      var resp = await getSubscribedChatLobbies();
      print(resp);

      setLobbyAutoSubscribe(resp[3].chatId);
      resp = await getSubscribedChatLobbies();
    });
  });
}
