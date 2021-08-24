import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';

class MessageDelegate extends StatelessWidget {
  const MessageDelegate({this.data, this.bubbleTitle, this.key});
  final key;
  final String bubbleTitle;
  final ChatMessage data;

  bool isMessageType(String msg) {
    final regexp =
        RegExp(r'^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)?$');

// find the first match though you could also do `allMatches`
    final match = regexp.hasMatch(msg);
    return match;
  }

  

  @override
  Widget build(BuildContext context) {
    return Visibility(
      key: key,
      visible: data != null,
      child: GestureDetector(
        child: FractionallySizedBox(
          alignment:
              !data.incoming ? Alignment.centerRight : Alignment.centerLeft,
          widthFactor: 0.7,
          child: Card(
            color: !data.incoming ? Colors.white : Colors.white70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Visibility(
                  visible: bubbleTitle?.isNotEmpty ?? false,
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 6.0),
                          child: Text(
                            bubbleTitle == null ? "" : bubbleTitle,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ))),
                ),
                Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, bottom: 8.0, top: 4.0),
                      child:!(isMessageType(data.msg))? Html(
          
          data: 
                  (data.msg) +
              "<span> &nbsp;&nbsp;&nbsp;</span>" // Todo: add some white space to don't overlap the time
          ):FadeInImage(
                       alignment: Alignment.centerLeft,
                        imageErrorBuilder: (BuildContext context,
                            Object exception, StackTrace stackTrace) {
                          print('Error Handler');
                          return Align( alignment: Alignment.centerLeft ,child: Text(data.msg,textAlign: TextAlign.left,));
                        },
                        placeholder: NetworkImage('http://via.placeholder.com/10x10'),
                        image: MemoryImage(base64.decode(data.msg)),
                        fit: BoxFit.fill,
                      ),
                    ),
                    //real additionalInfo
                    Positioned(
                      child: Text(
                        DateTime.fromMillisecondsSinceEpoch(
                                    (data.recvTime ?? data.recvTime) * 1000)
                                .hour
                                .toStringAsFixed(0) +
                            ":" +
                            DateTime.fromMillisecondsSinceEpoch(
                                    (data.sendTime ?? data.recvTime) * 1000)
                                .minute
                                .toString()
                                .padLeft(2, '0'),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11.0,
                        ),
                      ),
                      right: 8.0,
                      bottom: 4.0,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
