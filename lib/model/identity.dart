import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:retroshare/redux/model/app_state.dart';

import 'cache.dart';
import 'chat.dart';

class Identity {
  String mId;
  String name;
  String _avatar;
  bool signed;
  bool isContact;

  void set avatar(String avatar) {
    this._avatar = avatar;
    if (avatar?.isNotEmpty ?? false) {
      if (cachedImages[avatar] == null)
        cachedImages[avatar] = MemoryImage(base64.decode(avatar));
    }
  }

  String get avatar => this._avatar;

  Identity(String this.mId,
      [this.signed, name, avatar, this.isContact = false]) {
    this.name = name ??= this.mId;
    this.avatar = avatar;
  }

  // Get unread count from related distant chat from current id
  int getUnreadCount(context) {
    return StoreProvider.of<AppState>(context).state.distantChats != null
        ? StoreProvider.of<AppState>(context)
                .state
                .distantChats[Chat.getDistantChatId(this.mId,
                    StoreProvider.of<AppState>(context).state.currId.mId)]
                ?.unreadCount ??
            0
        : 0;
  }
}
