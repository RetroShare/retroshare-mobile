import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:openapi/api.dart';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare/redux/model/app_state.dart';

import 'package:retroshare/ui/room/message_delegate.dart';
import 'package:retroshare/common/bottom_bar.dart';
import 'package:retroshare/model/chat.dart';
import 'package:retroshare/services/chat.dart';

class MessagesTab extends StatefulWidget {
  final Chat chat;
  final bool isRoom;

  MessagesTab({this.chat, this.isRoom});

  @override
  _MessagesTabState createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  TextEditingController msgController = TextEditingController();
  double _bottomBarHeight = appBarHeight;

  @override
  void dispose() {
    msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child:
          StoreConnector<AppState, List<ChatMessage>>(
            converter: (store) => (widget.chat.chatId == null ||
                                  store.state.messagesList == null ||
                                  store.state.messagesList[widget.chat.chatId] == null )
                ? [] : store.state.messagesList[widget.chat.chatId].reversed.toList(),
            builder: (context, msgList){
              return Stack(
                children: <Widget>[
                  ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: msgList == null ? 0 : msgList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return MessageDelegate(
                        data: msgList[index],
                        bubbleTitle: widget.isRoom
                            && (msgList[index] != null)
                            && (msgList[index].incoming)  // Why msgList[index]?.incoming ?? false is not working??
                            ? msgList[index].getChatSenderName(StoreProvider.of<AppState>(context))
                            : null,
                      );
                    },
                  ),
                  Visibility(
                    visible: msgList?.isEmpty ?? true,
                    child: Center(
                      child: SingleChildScrollView(
                        child: SizedBox(
                          width: 250,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                  'assets/icons8/pluto-no-messages-1.png'),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 25),
                                child: Text('It seems like there is no messages',
                                    style: Theme.of(context).textTheme.body2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        BottomBar(
          minHeight: _bottomBarHeight,
          maxHeight: _bottomBarHeight * 2.5,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.insert_emoticon,
                  ),
                  onPressed: () {},
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Color(0xFFF5F5F5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextField(
                      controller: msgController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: 'Type text...'),
                      style: Theme.of(context).textTheme.body2,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.image,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                  ),
                  onPressed: () {
                    sendMessage(context, widget.chat.chatId, msgController.text,
                        (widget.isRoom ? ChatIdType.number3_: ChatIdType.number2_));
                    msgController.clear();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
