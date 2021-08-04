import 'dart:convert';
import 'dart:typed_data';

class Identity {
  String mId;
  String name;
  String _avatar;
  bool signed;
  bool isContact;

  void set avatar(String avatar) {
    this._avatar = avatar;
  }

  String get avatar => this._avatar;

  Identity(String this.mId,
      [this.signed, name, this._avatar, this.isContact = false]) {
    this.name = name ?? mId;
  }
}

class RsGxsImage {
  int mSize;
  Uint8List mData;
  String base64String;

  RsGxsImage(this.mData) {
    this.mSize = mData?.length;
    this.base64String = base64.encode(mData);
  }

  Map<String, dynamic> toJson() => {
        'mSize': mSize,
        'mData': {'base64': base64String},
      };
}
