import 'dart:async';

import "package:eventsource/eventsource.dart";
import 'package:openapi/api.dart';

Map<RsEventType, StreamSubscription<Event>> rsEventsSubscriptions;

enum RsEventType {
  NONE,

  /// Used internally to detect invalid event type passed
  /// @see RsBroadcastDiscovery
  BROADCAST_DISCOVERY,

  /// @see RsDiscPendingPgpReceivedEvent
  GOSSIP_DISCOVERY,

  /// @see AuthSSL
  AUTHSSL_CONNECTION_AUTENTICATION,

  /// @see pqissl
  PEER_CONNECTION,

  /// @see RsGxsChanges, used also in @see RsGxsBroadcast
  GXS_CHANGES,

  /// Emitted when a peer state changes, @see RsPeers
  PEER_STATE_CHANGED,

  /// @see RsMailStatusEvent
  MAIL_STATUS,

  /// @see RsGxsCircleEvent
  GXS_CIRCLES,

  /// @see RsGxsChannelEvent
  GXS_CHANNELS,

  /// @see RsGxsForumEvent
  GXS_FORUMS,

  /// @see RsGxsPostedEvent
  GXS_POSTED,

  /// @see RsGxsPostedEvent
  GXS_IDENTITY,

  /// @see RsFiles
  SHARED_DIRECTORIES,

  /// @see RsFiles
  FILE_TRANSFER,

  /// @see RsMsgs
  CHAT_MESSAGE,
  MAX

  /// Used internally, keep last
}
enum RsForumEventCode {
  UNKNOWN, //= 0x00,
  NEW_FORUM, //= 0x01, /// emitted when new forum is received
  UPDATED_FORUM, //= 0x02, /// emitted when existing forum is updated
  NEW_MESSAGE, //= 0x03, /// new message reeived in a particular forum
  UPDATED_MESSAGE, //= 0x04, /// existing message has been updated in a particular forum
  SUBSCRIBE_STATUS_CHANGED, //= 0x05, /// forum was subscribed or unsubscribed
  READ_STATUS_CHANGED, //= 0x06, /// msg was read or marked unread
  STATISTICS_CHANGED, //= 0x07, /// suppliers and how many messages they have changed
  MODERATOR_LIST_CHANGED, //= 0x08, /// forum moderation list has changed.
  VOID, //= 0x09 this is deleted from RS code but is needed here to correct following values
  SYNC_PARAMETERS_UPDATED, //= 0x0a, /// sync and storage times have changed
  PINNED_POSTS_CHANGED, //= 0x0b, /// some posts where pinned or un-pinned
  DELETED_FORUM, //= 0x0c, /// forum was deleted by cleaning
  DELETED_POST, //= 0x0d,  /// Post deleted (usually by cleaning)

  /// Distant search result received
  DISTANT_SEARCH_RESULT, //= 0x0e
}

enum RsGxsCircleType {
  /// Used to detect uninizialized values.
  UNKNOWN,

  /// Public distribution, based on GxsIds
  PUBLIC,

  /// Restricted to an external circle, based on GxsIds
  EXTERNAL,

  /// Restricted to a group of friend nodes, the administrator of the circle
  /// behave as a hub for them Based on PGP nodes ids.
  NODES_GROUP,

  /// not distributed at all
  LOCAL,

  /// Self-restricted. Used only at creation time of self-restricted circles
  ///  when the circle id isn't known yet. Once the circle id is known the type
  ///  is set to EXTERNAL, and the external circle id is set to the id of the
  ///  circle itself. Based on GxsIds.
  EXT_SELF,

  /// distributed to nodes signed by your own PGP key only.
  YOUR_EYES_ONLY
}

/// Subscription flags for circle details
///
/// When you receive a circle detail, one of the attributes is called
/// `mSubscriptionFlags`. To know if one of the flags below is contained by the
/// circle `mSubscriptionFlags` you have to do a BitWise AND operator. Example:
///
/// ```
/// mSubscriptionFlags = 5;
/// mSubscriptionFlags & RsGxsCircleSubscriptionFlags.GXS_EXTERNAL_CIRCLE_FLAGS_IN_ADMIN_LIST
///   == RsGxsCircleSubscriptionFlags.GXS_EXTERNAL_CIRCLE_FLAGS_IN_ADMIN_LIST // true
/// mSubscriptionFlags & RsGxsCircleSubscriptionFlags.GXS_EXTERNAL_CIRCLE_FLAGS_SUBSCRIBED
///   == RsGxsCircleSubscriptionFlags.GXS_EXTERNAL_CIRCLE_FLAGS_SUBSCRIBED // false
/// mSubscriptionFlags & RsGxsCircleSubscriptionFlags.GXS_EXTERNAL_CIRCLE_FLAGS_KEY_AVAILABLE
///   == RsGxsCircleSubscriptionFlags.GXS_EXTERNAL_CIRCLE_FLAGS_KEY_AVAILABLE // true
/// mSubscriptionFlags & RsGxsCircleSubscriptionFlags.GXS_EXTERNAL_CIRCLE_FLAGS_ALLOWED
///   == RsGxsCircleSubscriptionFlags.GXS_EXTERNAL_CIRCLE_FLAGS_ALLOWED // false
/// ```
class RsGxsCircleSubscriptionFlags {
  /// User is validated by circle admin. (Admin invited to the circle)
  static const int IN_ADMIN_LIST = 0x0001;

  /// User has subscribed the group. (Has requested circle membership)
  static const int FLAGS_SUBSCRIBED = 0x0002;

  /// key is available, so we can encrypt for this circle
  static const int KEY_AVAILABLE = 0x0004;

  /// user is allowed. Combines all flags above. (Belongs the circle)
  static const int FLAGS_ALLOWED = 0x0007;
}

class RsMsgMetaData {
  String mGroupId;
  String mMsgId;
  String mThreadId;
  String mParentId;
  String mOrigMsgId;
  String mAuthorId;
  // This in elrepo.io is a JSON object
  String mMsgName;
  RstimeT mPublishTs;

  /// the lower 16 bits for service, upper 16 bits for GXS
  /// @todo mixing service level flags and GXS level flag into the same member
  /// is prone to confusion, use separated members for those things, this could
  /// be done without breaking network retro-compatibility */
  int mMsgFlags;

  /// the first 16 bits for service, last 16 for GXS
  /// @todo mixing service level flags and GXS level flag into the same member
  /// is prone to confusion, use separated members for those things, this could
  /// be done without breaking network retro-compatibility */
  int mMsgStatus;
  RstimeT mChildTs; // Timestamp
  String mServiceString; // Service Specific Free-Form extra storage.

  /// Used to store the raw json if created fromJson constructor
  ///
  /// Usefull when the object returned is not a pure RsMsgMetaData, for example,
  /// for local search, that return a very similar object called RsGxsSearchResult
  /// but containing usefull attributes like "distance", used for perceptual search
  Map<String, dynamic> rawJson;

  RsMsgMetaData(
      {this.mGroupId,
      this.mMsgId,
      this.mThreadId,
      this.mParentId,
      this.mOrigMsgId,
      this.mAuthorId,
      this.mMsgName,
      this.mPublishTs,
      this.mMsgFlags,
      this.mMsgStatus,
      this.mChildTs,
      this.mServiceString,
      this.rawJson});

  RsMsgMetaData.fromJson(Map<String, dynamic> jsonString)
      : this(
          mGroupId: jsonString['mGroupId'],
          mMsgId: jsonString['mMsgId'],
          mThreadId: jsonString['mThreadId'],
          mParentId: jsonString['mParentId'],
          mOrigMsgId: jsonString['mOrigMsgId'],
          mAuthorId: jsonString['mAuthorId'],
          mMsgName: jsonString['mMsgName'],
          mPublishTs: RstimeT.fromJson(jsonString['mPublishTs']),
          mMsgFlags: jsonString['mMsgFlags'],
          mMsgStatus: jsonString['mMsgStatus'],
          // For search results this doesn't exist check RsGxsSearchResult
          mChildTs: jsonString['mChildTs'] != null
              ? RstimeT.fromJson(jsonString['mChildTs'])
              : RstimeT(),
          mServiceString: jsonString['mServiceString'],
          rawJson: jsonString,
        );
}
