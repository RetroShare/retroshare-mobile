import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/provider/Idenity.dart';
import 'package:retroshare/provider/room.dart';

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
    this.name = name ?? mId;
    this.avatar = avatar;
  }

  // Get unread count from related distant chat from current id
  int getUnreadCount(context) {
    return Provider.of<RoomChatLobby>(context, listen: false).distanceChat !=
            null
        ? Provider.of<RoomChatLobby>(context, listen: false)
                .distanceChat[Chat.getDistantChatId(
                    this.mId,
                    Provider.of<Identities>(context, listen: false)
                        .currentIdentity
                        .mId)]
                ?.unreadCount ??
            0
        : 0;
  }
}
